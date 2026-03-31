# Privacy Policy

**Portwood Global Solutions — Portwood DocGen**
*Last updated: March 31, 2026*

## The Short Version

Portwood DocGen runs entirely inside your Salesforce org. We cannot see your records, templates, or documents. The only data we receive is what Salesforce automatically provides to all managed package publishers: your org ID, org name, and install status. No analytics, no tracking, no external servers.

## 1. What Data We Collect

Portwood DocGen is a 100% native Salesforce application. All document generation processing occurs within your Salesforce org. We do not operate external servers, APIs, or data collection systems. We do not have access to your Salesforce records, templates, generated documents, or any data inside your org.

**What Salesforce provides to us automatically:** As a managed package publisher, Salesforce provides us with limited subscriber information through the PackageSubscriber system object. This is a standard Salesforce platform feature for all managed packages and is not something we can opt out of. The data Salesforce provides includes:

- Org ID (the 15/18-character Salesforce org identifier)
- Org name (the name of your Salesforce org as set in Company Information)
- Org type (Production, Sandbox, Developer Edition, etc.)
- Install status (installed or uninstalled)
- Package version installed
- Salesforce instance name

We use this data to track install counts displayed on our website, understand adoption, and provide support when you reach out. We store this information in our DevHub org and may create internal Account records from org names for support tracking purposes.

We do NOT collect:
- Your Salesforce record data (Accounts, Contacts, Opportunities, etc.)
- Template content or generated documents
- Usage analytics or telemetry from within the package
- Personal information of your org's users
- IP addresses or device information
- Cookies (outside of standard Salesforce session cookies)

## 2. How the Software Works

Portwood DocGen reads data from your Salesforce records, merges it into document templates, and saves the generated documents back to your Salesforce org as ContentVersion records. This entire process happens within the Salesforce platform boundary using standard Apex and Lightning Web Components. No data is transmitted externally at any point.

## 3. Data Storage

All data created or used by Portwood DocGen is stored in standard Salesforce objects within your org:
- Templates: DocGen_Template__c and ContentVersion
- Generated documents: ContentVersion linked to source records
- Job records: DocGen_Job__c
- Saved queries: DocGen_Saved_Query__c
- Settings: DocGen_Settings__c (hierarchy custom setting)

This data is subject to your org's Salesforce security settings, sharing rules, field-level security, and data retention policies. We have no access to any of it.

## 4. Third-Party Services

The Portwood DocGen package installed in your org does not make external callouts, webhooks, or API connections. No data from your org is transmitted to any third-party service. The package operates entirely within the Salesforce platform boundary.

Separately, we use **Slack** (Slack Technologies, Inc.) to host the DocGen community workspace. If you choose to join the Slack community, your interactions there are governed by Slack's own privacy policy. The Slack workspace is not connected to and has no access to your Salesforce org.

## 5. Salesforce Platform

Your use of Portwood DocGen is subject to Salesforce's own Privacy Policy and Terms of Service. Salesforce processes and stores your org data according to their policies. We recommend reviewing Salesforce's privacy documentation at salesforce.com/company/privacy.

## 6. Open Source

The full source code of Portwood DocGen is publicly available at github.com/Portwood-Global-Solutions/Portwood-DocGen under the Apache License 2.0. You can audit every line of code to verify our privacy claims.

## 7. Slack Community

We operate a Slack workspace for the DocGen community. When you join, Slack Technologies, Inc. collects and processes your account information (name, email, profile data, messages, files) according to their Privacy Policy. Portwood Global Solutions can see messages and files posted in the workspace but does not export, sell, or share this data. We use it solely to provide community support and improve the product.

## 8. Support Communications

If you contact us for support via Slack, hello@portwoodglobalsolutions.com, or GitHub Issues, we will receive and store the information you voluntarily provide (name, email, description of your issue). We use this information solely to provide support and will not sell or share it with third parties.

## 9. Partner Referrals

If you request implementation services, we may refer you to third-party Salesforce consulting partners. In doing so, we may share your name and contact information with the referred partner so they can reach out to you. We will only do this with your explicit consent.

## 10. Website

Our website at portwoodglobalsolutions.com is hosted on Salesforce Sites. Standard Salesforce session cookies are used for site functionality. We do not use Google Analytics, Facebook Pixel, or any third-party tracking tools on our website.

## 11. Children's Privacy

Portwood DocGen is a business application and is not directed at children under 13. We do not knowingly collect information from children.

## 12. International Data

Because all data stays within your Salesforce org, data residency is determined by your Salesforce instance location and your Salesforce contract. We do not transfer data across borders.

## 13. Changes

We may update this Privacy Policy from time to time. Changes will be posted at portwoodglobalsolutions.com/DocGenPrivacy. The "Last updated" date at the top reflects the most recent revision.

## 14. Contact

Portwood Global Solutions
hello@portwoodglobalsolutions.com
portwoodglobalsolutions.com
