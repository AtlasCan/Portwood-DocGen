public without sharing class DocGenSignatureController {

    // Helper wrapper class for LWC response
    public class SignatureInitResponse {
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String signerName;
        @AuraEnabled public String documentTitle;
        @AuraEnabled public String documentUrl;
        @AuraEnabled public String templateBase64;
        @AuraEnabled public String recordId;
        @AuraEnabled public String mergeDataJson;
    }

    /**
     * Fetches the actual document content for client-side rendering.
     */
    @AuraEnabled
    public static SignatureInitResponse fetchDocumentData(String token) {
        SignatureInitResponse res = validateToken(token);
        if (!res.isValid) return res;

        List<DocGen_Signature_Request__c> requests = [
            SELECT Source_Document_Id__c, Related_Record_Id__c
            FROM DocGen_Signature_Request__c
            WHERE Secure_Token__c = :token
            WITH SYSTEM_MODE
            LIMIT 1
        ];

        if (!requests.isEmpty()) {
            DocGen_Signature_Request__c req = requests[0];
            res.recordId = req.Related_Record_Id__c;
            
            List<ContentVersion> cvs = [SELECT VersionData FROM ContentVersion WHERE Id = :req.Source_Document_Id__c WITH SYSTEM_MODE LIMIT 1];
            if (!cvs.isEmpty()) {
                res.templateBase64 = EncodingUtil.base64Encode(cvs[0].VersionData);
            }
        }
        return res;
    }

    /**
     * @description Called by the LWC upon load to verify the token is valid and hasn't been signed.
     */
    @AuraEnabled
    @RemoteAction
    public static SignatureInitResponse validateToken(String token) {
        SignatureInitResponse res = new SignatureInitResponse();
        res.isValid = false;

        if (String.isBlank(token)) {
            res.errorMessage = 'Invalid or missing security token.';
            return res;
        }

        List<DocGen_Signature_Request__c> requests = [
            SELECT Id, Status__c, Signer_Name__c, Source_Document_Id__c, Related_Record_Id__c
            FROM DocGen_Signature_Request__c
            WHERE Secure_Token__c = :token
            WITH SYSTEM_MODE
            LIMIT 1
        ];

        if (requests.isEmpty()) {
            res.errorMessage = 'Signature request not found. The link may be invalid.';
            return res;
        }

        DocGen_Signature_Request__c req = requests[0];
        
        if (req.Status__c == 'Signed') {
            res.errorMessage = 'This document has already been signed.';
            return res;
        }
        
        if (req.Status__c == 'Cancelled') {
            res.errorMessage = 'This signature request has been cancelled.';
            return res;
        }

        // Update status to Viewed if it was merely Sent
        if (req.Status__c == 'Sent') {
            req.Status__c = 'Viewed';
            update req;
        }

        res.isValid = true;
        res.signerName = req.Signer_Name__c;
        
        // Lookup the ContentVersion to get the true title
        List<ContentVersion> cvs = [SELECT Id, Title FROM ContentVersion WHERE Id = :req.Source_Document_Id__c WITH SYSTEM_MODE LIMIT 1];
        if (!cvs.isEmpty()) {
            res.documentTitle = cvs[0].Title;
            
            // Try to find an existing ContentDistribution (Public Link)
            List<ContentDistribution> dists = [
                SELECT DistributionPublicUrl 
                FROM ContentDistribution 
                WHERE ContentVersionId = :cvs[0].Id
                WITH SYSTEM_MODE LIMIT 1
            ];
            
            if (!dists.isEmpty()) {
                res.documentUrl = dists[0].DistributionPublicUrl;
            } else {
                // Generate a temporary one if it doesn't exist
                ContentDistribution cd = new ContentDistribution();
                cd.Name = 'Signature Preview - ' + cvs[0].Title;
                cd.ContentVersionId = cvs[0].Id;
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesLinkLatestVersion = true;
                cd.PreferencesExpires = false;
                insert cd; // System Mode
                
                cd = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.Id WITH SYSTEM_MODE LIMIT 1];
                res.documentUrl = cd.DistributionPublicUrl;
            }
        } else {
            res.documentTitle = 'Confidential Document';
        }
        
        return res;
    }

    /**
     * Stamps the signature and returns the NEW docx base64.
     * This allows the browser to perform the final PDF rendering.
     */
    @AuraEnabled
    public static Map<String, String> stampAndReturnSource(String token, String base64Image) {
        List<DocGen_Signature_Request__c> requests = [
            SELECT Id, Status__c, Signer_Name__c, Source_Document_Id__c, Related_Record_Id__c
            FROM DocGen_Signature_Request__c
            WHERE Secure_Token__c = :token
            WITH SYSTEM_MODE
            LIMIT 1
        ];

        if (requests.isEmpty() || requests[0].Status__c == 'Signed' || requests[0].Status__c == 'Cancelled') {
            throw new AuraHandledException('Invalid request or document already signed.');
        }

        DocGen_Signature_Request__c req = requests[0];
        
        try {
            // 1. Stamp on server (returns Blob, NO record insert)
            Blob stampedBlob = DocGenSignatureService.stampSignatureToBlob(req.Source_Document_Id__c, base64Image, req.Id);
            
            // 2. Fetch Original Metadata for filename
            ContentVersion sourceDoc = [SELECT Title FROM ContentVersion WHERE Id = :req.Source_Document_Id__c WITH SYSTEM_MODE LIMIT 1];
            
            // 3. Mark as signed (Update Request Status)
            req.Status__c = 'Signed';
            update req;

            // 4. Create Audit Trail (Initial State)
            DocGen_Signature_Audit__c audit = new DocGen_Signature_Audit__c();
            audit.Signature_Request__c = req.Id;
            audit.Signed_Date__c = System.now();
            audit.Document_Hash_SHA256__c = 'PENDING_CLIENT_PDF'; // Will be updated by finishSignatureUpload
            audit.IP_Address__c = 'Captured via Client-Side Hybrid Flow';
            audit.User_Agent__c = 'Browser-Based Renderer';
            insert audit;

            return new Map<String, String>{
                'base64' => EncodingUtil.base64Encode(stampedBlob),
                'title' => sourceDoc.Title + ' - Signed'
            };
        } catch (Exception e) {
            throw new AuraHandledException('Stamping failed: ' + e.getMessage());
        }
    }

    /**
     * Finalizes the signature by uploading the browser-generated PDF and updating the audit trail.
     */
    @AuraEnabled
    public static void finishSignatureUpload(String token, String base64Pdf, String fileName) {
        List<DocGen_Signature_Request__c> requests = [
            SELECT Id, Related_Record_Id__c
            FROM DocGen_Signature_Request__c
            WHERE Secure_Token__c = :token
            WITH SYSTEM_MODE
            LIMIT 1
        ];

        if (requests.isEmpty()) throw new AuraHandledException('Request not found.');
        DocGen_Signature_Request__c req = requests[0];

        try {
            // 1. Save PDF
            Id contentDocId = DocGenController.saveGeneratedDocument(
                req.Related_Record_Id__c, 
                fileName, 
                base64Pdf, 
                'pdf'
            );

            // 2. Update Audit Trail with PDF Hash
            List<DocGen_Signature_Audit__c> audits = [
                SELECT Id FROM DocGen_Signature_Audit__c 
                WHERE Signature_Request__c = :req.Id
                WITH SYSTEM_MODE
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (!audits.isEmpty()) {
                String pdfHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', EncodingUtil.base64Decode(base64Pdf)));
                audits[0].Document_Hash_SHA256__c = pdfHash;
                update audits;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Finalization failed: ' + e.getMessage());
        }
    }
}