public without sharing class DocGenSignatureController {

    // Helper wrapper class for LWC response
    public class SignatureInitResponse {
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String signerName;
        @AuraEnabled public String documentTitle;
        @AuraEnabled public String documentUrl;
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

}
