/**
 * Controller for the DocGen landing page and community signup.
 * Handles install links, help request form submissions, and
 * automated Chatter Free user creation for community signups.
 * Welcome emails sent via Resend API (not Salesforce email sends).
 * Deploy to partner org only — runs on VF Site with guest user profile.
 */
public without sharing class DocGenLandingController {

    private static final String DEMO_USER_ID = '005di00000GkOuFAAV';
    private static final String DEMO_RET_URL = '/lightning/app/portwoodglobal__DocGen/page/portwoodglobal__DocGen_Command_Hub';
    private static final String CHATTER_PROFILE_NAME = 'Chatter Free User';
    private static final String LOGIN_URL = 'https://portwoodglobalsolutions.my.salesforce.com';
    private static final String RESET_URL = LOGIN_URL + '/secur/forgotpassword.jsp';

    private DocGen_Landing_Config__mdt configRecord;

    private DocGen_Landing_Config__mdt getConfig() {
        if (configRecord == null) {
            List<DocGen_Landing_Config__mdt> configs = [
                SELECT Package_Version_Id__c, Slack_Invite_Url__c FROM DocGen_Landing_Config__mdt
                WHERE DeveloperName = 'Current' LIMIT 1
            ];
            configRecord = configs.isEmpty() ? new DocGen_Landing_Config__mdt() : configs[0];
        }
        return configRecord;
    }

    public String installLinkProd {
        get { return 'https://login.salesforce.com/packaging/installPackage.apexp?p0=' + getConfig().Package_Version_Id__c; }
    }
    public String installLinkSandbox {
        get { return 'https://test.salesforce.com/packaging/installPackage.apexp?p0=' + getConfig().Package_Version_Id__c; }
    }
    public String slackInviteUrl {
        get { return getConfig().Slack_Invite_Url__c; }
    }

    public String demoUrl {
        get {
            try {
                List<DocGen_Demo_Config__c> configs = [
                    SELECT Access_Token__c, Instance_Url__c
                    FROM DocGen_Demo_Config__c
                    WHERE SetupOwnerId = :UserInfo.getOrganizationId()
                    WITH SYSTEM_MODE LIMIT 1
                ];
                if (!configs.isEmpty() && String.isNotBlank(configs[0].Access_Token__c) && String.isNotBlank(configs[0].Instance_Url__c)) {
                    return configs[0].Instance_Url__c + '/secur/frontdoor.jsp?sid=' + configs[0].Access_Token__c
                        + '&retURL=' + EncodingUtil.urlEncode(DEMO_RET_URL, 'UTF-8');
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'demoUrl getter failed: ' + e.getMessage());
            }
            return null;
        }
    }

    public Integer installCount {
        get {
            try {
                // PackageSubscriber tracks all orgs that have installed the managed package
                return [SELECT COUNT() FROM PackageSubscriber WHERE InstalledStatus = 'i'];
            } catch (Exception e) {
                return 0;
            }
        }
    }

    public DocGenLandingController() {}

    @RemoteAction
    public static String submitHelpRequest(String name, String email, String company, String message) {
        if (String.isBlank(name) || String.isBlank(email)) {
            throw new AuraHandledException('Name and email are required.');
        }

        // Check for existing Lead with same email to avoid duplicates
        List<Lead> existing = [SELECT Id, Description FROM Lead WHERE Email = :email WITH SYSTEM_MODE LIMIT 1];
        if (!existing.isEmpty()) {
            Lead existingLead = existing[0];
            existingLead.Description = 'Follow-up request (' + Datetime.now().format() + '):\n' + message
                + (String.isNotBlank(existingLead.Description) ? '\n\n---\n' + existingLead.Description : '');
            update existingLead; // NOPMD ApexCRUDViolation — landing page: updating existing Lead with follow-up message
            return 'updated';
        }

        String firstName = '';
        String lastName = name;
        if (name.contains(' ')) {
            Integer spaceIdx = name.indexOf(' ');
            firstName = name.substring(0, spaceIdx);
            lastName = name.substring(spaceIdx + 1);
        }

        Lead newLead = new Lead(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Company = String.isNotBlank(company) ? company : '[Not Provided]',
            Description = message,
            LeadSource = 'DocGen Website',
            Status = 'New'
        );
        insert newLead; // NOPMD ApexCRUDViolation — landing page: creating Lead from help request form
        return 'created';
    }

    @RemoteAction
    public static String submitInstallLead(String company, String industry, String country, String email, String utmSource, String utmMedium, String utmCampaign, String utmContent, String utmTerm) {
        if (String.isBlank(company) || String.isBlank(industry) || String.isBlank(country)) {
            throw new AuraHandledException('Organization, industry, and country are required.');
        }

        // Dedup by email if provided
        if (String.isNotBlank(email)) {
            List<Lead> existing = [SELECT Id, Industry, Country FROM Lead WHERE Email = :email WITH SYSTEM_MODE LIMIT 1];
            if (!existing.isEmpty()) {
                Lead existingLead = existing[0];
                if (String.isBlank(existingLead.Industry)) { existingLead.Industry = industry; }
                if (String.isBlank(existingLead.Country)) { existingLead.Country = country; }
                update existingLead; // NOPMD ApexCRUDViolation — landing page: enriching existing Lead with install data
                return 'existing';
            }
        }

        Lead newLead = new Lead(
            LastName = company,
            Company = company,
            Industry = industry,
            Country = country,
            Email = String.isNotBlank(email) ? email : null,
            LeadSource = 'DocGen Install',
            Status = 'New',
            UTM_Source__c = String.isNotBlank(utmSource) ? utmSource : null,
            UTM_Medium__c = String.isNotBlank(utmMedium) ? utmMedium : null,
            UTM_Campaign__c = String.isNotBlank(utmCampaign) ? utmCampaign : null,
            UTM_Content__c = String.isNotBlank(utmContent) ? utmContent : null,
            UTM_Term__c = String.isNotBlank(utmTerm) ? utmTerm : null
        );
        insert newLead; // NOPMD ApexCRUDViolation — landing page: creating Lead from install form
        return 'created';
    }

    public class CountryCount {
        public String country;
        public Integer count;
        public CountryCount(String c, Integer n) { this.country = c; this.count = n; }
    }

    @RemoteAction
    public static List<CountryCount> getInstallMapData() {
        List<CountryCount> results = new List<CountryCount>();
        for (AggregateResult ar : [
            SELECT Country, COUNT(Id) cnt FROM Lead
            WHERE LeadSource IN ('DocGen Install', 'Package Install') AND Country != null
            GROUP BY Country
        ]) {
            results.add(new CountryCount((String)ar.get('Country'), (Integer)ar.get('cnt')));
        }
        return results;
    }

    /**
     * Creates a Chatter Free user and adds them to all DocGen community groups.
     * Sets a temporary password to suppress SF's welcome email, then sends
     * a branded welcome email via Resend with a password reset link.
     */
    @RemoteAction
    public static String createChatterUser(String name, String email, String company) {
        if (String.isBlank(name) || String.isBlank(email)) {
            throw new AuraHandledException('Name and email are required.');
        }
        email = email.trim().toLowerCase();

        // Check if a User with this email already exists
        List<User> existingUsers = [SELECT Id, IsActive, Username FROM User WHERE Email = :email WITH SYSTEM_MODE LIMIT 1];
        if (!existingUsers.isEmpty()) {
            if (existingUsers[0].IsActive) {
                throw new AuraHandledException('An account with this email already exists. Log in at portwoodglobalsolutions.my.salesforce.com.');
            }
            // Reactivate inactive user
            User inactive = existingUsers[0];
            inactive.IsActive = true;
            update inactive; // NOPMD ApexCRUDViolation — reactivating existing Chatter user
            postSetupAsync(inactive.Id, name, email);
            return 'reactivated';
        }

        // Parse name
        String firstName = '';
        String lastName = name.trim();
        if (lastName.contains(' ')) {
            Integer spaceIdx = lastName.indexOf(' ');
            firstName = lastName.substring(0, spaceIdx);
            lastName = lastName.substring(spaceIdx + 1);
        }

        // Build unique username: email + .docgen suffix (must be globally unique)
        String username = email + '.docgen';
        List<User> usernameTaken = [SELECT Id FROM User WHERE Username = :username WITH SYSTEM_MODE LIMIT 1];
        if (!usernameTaken.isEmpty()) {
            username = email.substringBefore('@') + '.' + String.valueOf(Math.abs(Crypto.getRandomInteger())).left(6)
                + '@' + email.substringAfter('@') + '.docgen';
        }

        // Build alias (max 8 chars)
        String alias = (String.isNotBlank(firstName) ? firstName.left(1) : '') + lastName.left(7);
        alias = alias.left(8);

        // Get Chatter Free profile
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :CHATTER_PROFILE_NAME LIMIT 1];
        if (profiles.isEmpty()) {
            throw new AuraHandledException('Chatter Free profile not found. Please contact support.');
        }

        User newUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Username = username,
            Alias = alias,
            CompanyName = String.isNotBlank(company) ? company : null,
            ProfileId = profiles[0].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            IsActive = true
        );
        insert newUser; // NOPMD ApexCRUDViolation — creating Chatter Free user from community signup

        // Set a temp password to suppress SF's automatic welcome email
        String tempPw = EncodingUtil.base64Encode(Crypto.generateAesKey(128)).left(20) + '!1a';
        System.setPassword(newUser.Id, tempPw);

        // Add to groups + send welcome email via Resend (async — callout + mixed DML)
        postSetupAsync(newUser.Id, name, email);

        return 'created';
    }

    /**
     * Handles post-user-creation tasks: adds user to Chatter groups and
     * sends a branded welcome email via Resend. Uses @future(callout=true)
     * to avoid mixed DML errors and enable HTTP callout to Resend.
     */
    @future(callout=true)
    private static void postSetupAsync(Id userId, String displayName, String email) {
        // Add to all DocGen Chatter groups
        List<CollaborationGroup> groups = [
            SELECT Id FROM CollaborationGroup
            WHERE Name LIKE 'DocGen -%'
            WITH SYSTEM_MODE
        ];
        List<CollaborationGroupMember> members = new List<CollaborationGroupMember>();
        Set<Id> existingGroupIds = new Set<Id>();
        for (CollaborationGroupMember existing : [
            SELECT CollaborationGroupId FROM CollaborationGroupMember
            WHERE MemberId = :userId WITH SYSTEM_MODE
        ]) {
            existingGroupIds.add(existing.CollaborationGroupId);
        }
        for (CollaborationGroup g : groups) {
            if (!existingGroupIds.contains(g.Id)) {
                members.add(new CollaborationGroupMember(
                    CollaborationGroupId = g.Id,
                    MemberId = userId,
                    NotificationFrequency = 'P' // Each post
                ));
            }
        }
        if (!members.isEmpty()) {
            insert members; // NOPMD ApexCRUDViolation — adding Chatter user to community groups
        }

        // Send branded welcome email via Resend
        sendWelcomeEmail(displayName, email);
    }

    /**
     * Sends a branded welcome email via Resend API with a password reset link.
     * Does not consume Salesforce org email sends.
     */
    private static void sendWelcomeEmail(String displayName, String toEmail) {
        DocGen_Demo_Config__c config = DocGen_Demo_Config__c.getOrgDefaults();
        if (config == null || String.isBlank(config.Resend_API_Key__c)) {
            System.debug(LoggingLevel.ERROR, 'sendWelcomeEmail: No Resend API key configured');
            return;
        }

        String firstName = displayName.contains(' ') ? displayName.substringBefore(' ') : displayName;

        String htmlBody = '<div style="font-family: -apple-system, BlinkMacSystemFont, \'Segoe UI\', sans-serif; max-width: 560px; margin: 0 auto; background: #0f172a; border-radius: 12px; padding: 2.5rem; color: #e2e8f0;">' +
            '<h1 style="font-size: 1.5rem; font-weight: 800; color: #fff; margin-bottom: 0.5rem;">Welcome to the DocGen Community!</h1>' +
            '<p style="color: #94a3b8; margin-bottom: 1.5rem;">Hey ' + firstName.escapeHtml4() + ', your account is ready. You\'ve been added to all the community groups.</p>' +

            '<div style="background: #1e293b; border-radius: 8px; padding: 1.25rem; margin-bottom: 1.5rem;">' +
            '<p style="color: #94a3b8; font-size: 0.85rem; margin: 0 0 0.25rem;">Your login:</p>' +
            '<p style="color: #fff; font-weight: 600; margin: 0;">' + toEmail.escapeHtml4() + '</p>' +
            '</div>' +

            '<p style="color: #94a3b8; margin-bottom: 1rem;">Set your password to get started:</p>' +
            '<a href="' + RESET_URL + '" style="display: inline-block; padding: 14px 32px; background: linear-gradient(135deg, #2563eb, #1d4ed8); color: #fff; text-decoration: none; border-radius: 50px; font-weight: 700; font-size: 1rem;">Set Password &amp; Log In</a>' +

            '<div style="margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid rgba(255,255,255,0.06);">' +
            '<p style="color: #475569; font-size: 0.8rem; margin: 0;">Once logged in, you\'ll find your community groups in Chatter. Post questions, request features, share templates, and connect with other DocGen admins.</p>' +
            '</div>' +

            '<p style="color: #334155; font-size: 0.75rem; margin-top: 1.5rem;">Portwood DocGen &mdash; Free document generation for Salesforce</p>' +
            '</div>';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.resend.com/emails'); // NOPMD ApexSuggestUsingNamedCred — Resend REST API uses Bearer token
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + config.Resend_API_Key__c); // NOPMD ApexSuggestUsingNamedCred — Resend API
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String, String>{
            'from' => 'DocGen Community <hello@portwoodglobalsolutions.com>',
            'to' => toEmail,
            'subject' => 'Welcome to the DocGen Community',
            'html' => htmlBody
        }));
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() >= 400) {
            System.debug(LoggingLevel.ERROR, 'Resend welcome email failed: ' + res.getStatusCode() + ' ' + res.getBody());
        }
    }
}
