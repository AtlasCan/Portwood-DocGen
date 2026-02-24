public with sharing class DocGenSignatureSenderController {
    
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getRelatedDocuments(Id recordId) {
        List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH USER_MODE];
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) docIds.add(link.ContentDocumentId);
        
        return [
            SELECT Id, Title, FileExtension, ContentDocumentId
            FROM ContentVersion 
            WHERE ContentDocumentId IN :docIds AND IsLatest = true 
            AND FileExtension IN ('docx', 'pdf')
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];
    }
    
    @AuraEnabled
    public static String createSignatureRequest(Id contentDocumentId, String relatedRecordId, String signerName, String signerEmail) {
        // Resolve Latest ContentVersionId from ContentDocumentId defensively
        List<ContentDocument> docs = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentDocumentId WITH SYSTEM_MODE LIMIT 1];
        if (docs.isEmpty()) {
            throw new AuraHandledException('Error: You do not have permission to access this document, or it has been deleted.');
        }
        Id contentVersionId = docs[0].LatestPublishedVersionId;
        // Generate cryptographic secure token
        Blob hash = Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(System.now().getTime()) + Math.random() + signerEmail));
        String token = EncodingUtil.convertToHex(hash);
        
        DocGen_Signature_Request__c req = new DocGen_Signature_Request__c();
        req.Signer_Name__c = signerName;
        req.Signer_Email__c = signerEmail;
        req.Source_Document_Id__c = contentVersionId;
        req.Related_Record_Id__c = relatedRecordId;
        req.Secure_Token__c = token;
        req.Status__c = 'Sent';
        
        insert req; // REMOVED "as user" so System Mode can insert as Guest User
        
        // Return the public URL
        DocGen_Settings__c settings = DocGen_Settings__c.getOrgDefaults();
        String siteUrl = settings.Experience_Site_Url__c;

        if (String.isBlank(siteUrl)) {
            // Fallback to legacy Site guessing if setting is missing
            List<Site> sites = [SELECT Id FROM Site WHERE Status = 'Active' WITH SYSTEM_MODE LIMIT 1];
            if (!sites.isEmpty()) {
                SiteDetail sd = [SELECT SecureUrl FROM SiteDetail WHERE DurableId = :sites[0].Id WITH SYSTEM_MODE LIMIT 1];
                siteUrl = sd.SecureUrl + '/DocGenSign';
            }
        }
        
        if (String.isBlank(siteUrl)) {
            siteUrl = 'https://<CONFIGURE_SITE_URL_IN_SETUP>';
        }

        // Ensure we handle parameters correctly
        String separator = siteUrl.contains('?') ? '&' : '?';
        return siteUrl + separator + 'token=' + token;
    }
}