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
        upsert settings;
    }

    @AuraEnabled
    public static String buildProvisionPackage(String consumerKey, String consumerSecret) {
        if (String.isBlank(consumerKey) || String.isBlank(consumerSecret)) {
            throw new AuraHandledException('Consumer Key and Consumer Secret are required.');
        }
        if (!FeatureManagement.checkPermission('DocGen_Admin_Access') &&
            !Schema.sObjectType.DocGen_Settings__c.isUpdateable()) {
            throw new AuraHandledException('Insufficient privileges to provision credentials.');
        }

        String orgUrl = Url.getOrgDomainUrl().toExternalForm();

        Compression.ZipWriter zw = new Compression.ZipWriter();
        zw.addEntry('package.xml', Blob.valueOf(buildPackageXml()));
        zw.addEntry(
            'authproviders/DocGen_Auth_Provider.authprovider-meta.xml',
            Blob.valueOf(buildAuthProviderXml(consumerKey, consumerSecret))
        );
        zw.addEntry(
            'externalCredentials/DocGen_Loopback_Auth.externalCredential-meta.xml',
            Blob.valueOf(buildExternalCredentialXml())
        );
        zw.addEntry(
            'namedCredentials/DocGen_Loopback.namedCredential-meta.xml',
            Blob.valueOf(buildNamedCredentialXml(orgUrl))
        );

        return EncodingUtil.base64Encode(zw.getArchive());
    }

    private static String buildPackageXml() {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n' +
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n' +
            '    <types>\n' +
            '        <members>DocGen_Auth_Provider</members>\n' +
            '        <name>AuthProvider</name>\n' +
            '    </types>\n' +
            '    <types>\n' +
            '        <members>DocGen_Loopback_Auth</members>\n' +
            '        <name>ExternalCredential</name>\n' +
            '    </types>\n' +
            '    <types>\n' +
            '        <members>DocGen_Loopback</members>\n' +
            '        <name>NamedCredential</name>\n' +
            '    </types>\n' +
            '    <version>65.0</version>\n' +
            '</Package>';
    }

    private static String buildAuthProviderXml(String consumerKey, String consumerSecret) {
        return '<?xml version="1.0" encoding="UTF-8"?>\n' +
            '<AuthProvider xmlns="http://soap.sforce.com/2006/04/metadata">\n' +
            '    <consumerKey>' + escapeXml(consumerKey) + '</consumerKey>\n' +
            '    <consumerSecret>' + escapeXml(consumerSecret) + '</consumerSecret>\n' +
            '    <defaultScopes>api refresh_token</defaultScopes>\n' +
            '    <friendlyName>DocGen Auth Provider</friendlyName>\n' +
            '    <includeOrgIdInIdentifier>true</includeOrgIdInIdentifier>\n' +
            '    <isPkceEnabled>false</isPkceEnabled>\n' +
            '    <providerType>Salesforce</providerType>\n' +
            '    <requireMfa>false</requireMfa>\n' +
            '    <sendAccessTokenInHeader>false</sendAccessTokenInHeader>\n' +
            '    <sendClientCredentialsInHeader>false</sendClientCredentialsInHeader>\n' +
            '    <sendSecretInApis>true</sendSecretInApis>\n' +
            '</AuthProvider>';
    }

    private static String buildExternalCredentialXml() {
        return '<?xml version="1.0" encoding="UTF-8"?>\n' +
            '<ExternalCredential xmlns="http://soap.sforce.com/2006/04/metadata">\n' +
            '    <authenticationProtocol>Oauth</authenticationProtocol>\n' +
            '    <externalCredentialParameters>\n' +
            '        <authProvider>DocGen_Auth_Provider</authProvider>\n' +
            '        <parameterGroup>DefaultGroup</parameterGroup>\n' +
            '        <parameterName>AuthProvider</parameterName>\n' +
            '        <parameterType>AuthProvider</parameterType>\n' +
            '    </externalCredentialParameters>\n' +
            '    <externalCredentialParameters>\n' +
            '        <parameterGroup>Admin</parameterGroup>\n' +
            '        <parameterName>Admin</parameterName>\n' +
            '        <parameterType>NamedPrincipal</parameterType>\n' +
            '        <sequenceNumber>1</sequenceNumber>\n' +
            '    </externalCredentialParameters>\n' +
            '    <label>DocGen Loopback Auth.</label>\n' +
            '</ExternalCredential>';
    }

    private static String buildNamedCredentialXml(String orgUrl) {
        return '<?xml version="1.0" encoding="UTF-8"?>\n' +
            '<NamedCredential xmlns="http://soap.sforce.com/2006/04/metadata">\n' +
            '    <allowMergeFieldsInBody>false</allowMergeFieldsInBody>\n' +
            '    <allowMergeFieldsInHeader>false</allowMergeFieldsInHeader>\n' +
            '    <calloutStatus>Enabled</calloutStatus>\n' +
            '    <generateAuthorizationHeader>true</generateAuthorizationHeader>\n' +
            '    <label>DocGen Loopback</label>\n' +
            '    <namedCredentialParameters>\n' +
            '        <parameterName>Url</parameterName>\n' +
            '        <parameterType>Url</parameterType>\n' +
            '        <parameterValue>' + escapeXml(orgUrl) + '</parameterValue>\n' +
            '    </namedCredentialParameters>\n' +
            '    <namedCredentialParameters>\n' +
            '        <externalCredential>DocGen_Loopback_Auth</externalCredential>\n' +
            '        <parameterName>ExternalCredential</parameterName>\n' +
            '        <parameterType>Authentication</parameterType>\n' +
            '    </namedCredentialParameters>\n' +
            '    <namedCredentialType>SecuredEndpoint</namedCredentialType>\n' +
            '</NamedCredential>';
    }

    private static String escapeXml(String input) {
        if (input == null) return '';
        return input.replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace('\'', '&apos;');
    }
}