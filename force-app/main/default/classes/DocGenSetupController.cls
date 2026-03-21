public with sharing class DocGenSetupController {
    @AuraEnabled(cacheable=true)
    public static String getOrgUrl() {
        // Return the core my.salesforce.com URL, not the Lightning domain
        return Url.getOrgDomainUrl().toExternalForm();
    }

    @AuraEnabled(cacheable=true)
    public static DocGen_Settings__c getSettings() {
        return DocGen_Settings__c.getOrgDefaults();
    }

    @AuraEnabled
    public static void saveSettings(String experienceSiteUrl) {
        // Only allow users with Customize Application or DocGen_Admin permission set
        if (!FeatureManagement.checkPermission('DocGen_Admin_Access') &&
            !Schema.sObjectType.DocGen_Settings__c.isUpdateable()) {
            throw new AuraHandledException('Insufficient privileges to modify DocGen settings.');
        }
        DocGen_Settings__c settings = DocGen_Settings__c.getOrgDefaults();
        settings.Experience_Site_Url__c = experienceSiteUrl;
        // Package-internal object — CRUD controlled by DocGen permission sets
        upsert settings;
    }

    // =========================================================================
    // Custom Font Management
    // =========================================================================

    @AuraEnabled(cacheable=true)
    public static List<DocGen_Font__c> getFonts() {
        return [
            SELECT Id, Font_Family__c, Font_Weight__c, Font_Style__c, Font_Format__c, Content_Version_Id__c
            FROM DocGen_Font__c
            WITH SECURITY_ENFORCED
            ORDER BY Font_Family__c, Font_Weight__c, Font_Style__c
        ];
    }

    /**
     * Uploads a font file and creates a DocGen_Font__c record.
     * The font binary is stored as a ContentVersion; the record tracks the mapping.
     */
    @AuraEnabled
    public static DocGen_Font__c uploadFont(String fontFamily, String fontWeight, String fontStyle,
                                             String fontFormat, String fileName, String base64Data) {
        if (String.isBlank(fontFamily) || String.isBlank(base64Data)) {
            throw new AuraHandledException('Font family and file data are required.');
        }

        // Validate file extension
        String ext = '';
        if (String.isNotBlank(fileName) && fileName.contains('.')) {
            ext = fileName.substringAfterLast('.').toLowerCase();
        }
        Set<String> allowedExtensions = new Set<String>{ 'ttf', 'woff', 'woff2' };
        if (String.isNotBlank(ext) && !allowedExtensions.contains(ext)) {
            throw new AuraHandledException('Only TTF, WOFF, and WOFF2 font files are supported.');
        }

        // Save font file as ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'docgen_font_' + fontFamily.replaceAll('[^a-zA-Z0-9]', '_');
        cv.PathOnClient = fileName;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        SObjectAccessDecision cvDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<ContentVersion>{ cv });
        insert cvDecision.getRecords();
        Id savedCvId = cvDecision.getRecords()[0].Id;

        // Create font record
        DocGen_Font__c font = new DocGen_Font__c();
        font.Font_Family__c = fontFamily.trim();
        font.Font_Weight__c = String.isNotBlank(fontWeight) ? fontWeight : 'normal';
        font.Font_Style__c = String.isNotBlank(fontStyle) ? fontStyle : 'normal';
        font.Font_Format__c = String.isNotBlank(fontFormat) ? fontFormat : 'truetype';
        font.Content_Version_Id__c = savedCvId;
        SObjectAccessDecision fontDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<DocGen_Font__c>{ font });
        insert fontDecision.getRecords();

        return [SELECT Id, Font_Family__c, Font_Weight__c, Font_Style__c, Font_Format__c, Content_Version_Id__c
                FROM DocGen_Font__c WHERE Id = :fontDecision.getRecords()[0].Id WITH SECURITY_ENFORCED LIMIT 1];
    }

    /**
     * Deletes a font record and its associated ContentVersion.
     */
    @AuraEnabled
    public static void deleteFont(Id fontId) {
        List<DocGen_Font__c> fonts = [
            SELECT Content_Version_Id__c FROM DocGen_Font__c
            WHERE Id = :fontId WITH SECURITY_ENFORCED LIMIT 1
        ];
        if (fonts.isEmpty()) {
            throw new AuraHandledException('Font not found.');
        }

        // Delete the ContentVersion's parent ContentDocument
        String cvId = fonts[0].Content_Version_Id__c;
        if (String.isNotBlank(cvId)) {
            try {
                ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvId LIMIT 1];
                delete [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, 'DocGen: Could not delete font file: ' + e.getMessage());
            }
        }

        delete fonts;
    }
}