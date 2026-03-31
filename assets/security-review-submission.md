# Portwood DocGen — Security Review Submission (v1.12.0)

## Describe Your Solution

Portwood DocGen is a 100% native Salesforce document generation app. It creates PDFs, Word documents, Excel spreadsheets, and PowerPoint presentations from any Salesforce record using merge tags in uploaded templates. The app runs entirely within the Salesforce platform — no external callouts, no middleware, no external data storage, no APIs consumed or exposed.

Users create templates in Word/Excel/PowerPoint with merge tags like {Name}, {Account.Owner.Email}, and {#Contacts}{FirstName}{/Contacts}. The app merges record data into the template and outputs a finished document as a ContentVersion attached to the record.

Key technical details:
- All document rendering uses native Apex (Blob.toPdf() for PDF, XML manipulation for DOCX/XLSX/PPTX)
- All data access uses WITH USER_MODE to enforce CRUD/FLS
- All classes use "with sharing" to enforce sharing rules
- No external endpoints are called — all processing is on-platform
- Custom objects: DocGen_Template__c, DocGen_Template_Version__c, DocGen_Job__c, DocGen_Saved_Query__c
- Custom setting: DocGen_Settings__c (hierarchy, global/user-level configuration)
- Two permission sets control access: DocGen Admin (full CRUD) and DocGen User (read templates, create jobs)
- 615 Apex tests, 76% org-wide coverage, 0 Critical/0 High on Code Analyzer (recommended rules)
- 24 E2E integration tests passing
- Package namespace: portwoodglobal
- Package type: Managed 2GP

## Web App / Web Services Frameworks and Languages

None. The app does not include or use any web application frameworks, web services, or server-side languages outside of Salesforce. All logic is implemented in Apex and Lightning Web Components (JavaScript).

## Other Platforms Used

None. The app runs entirely on the Salesforce platform. No external platforms, cloud services, or third-party infrastructure is used.

## External Integrations

None. The app makes zero external HTTP callouts. No external APIs are consumed or exposed. No webhooks, no REST/SOAP endpoints, no external authentication. All data stays within the Salesforce org.

## API-Only App

No. The app includes a full user interface built with Lightning Web Components (LWC). It provides a Command Hub tab, template manager, visual query builder, bulk runner, and document generation runner — all accessible through the Salesforce Lightning UI.

## Salesforce Platform Technology

- **Lightning Web Components (LWC):** docGenRunner, docGenAdmin, docGenCommandHub, docGenBulkRunner, docGenColumnBuilder, docGenQueryBuilder, docGenFilterBuilder, docGenSharing, docGenTitleEditor, docGenSetupWizard, docGenAdminGuide, docGenUtils
- **Apex Classes:**
  - Controllers: DocGenController, DocGenBulkController, DocGenSetupController
  - Core Engine: DocGenService, DocGenDataRetriever, DocGenHtmlRenderer, DocGenTemplateManager
  - Giant Query: DocGenGiantQueryBatch, DocGenGiantQueryAssembler, DocGenGiantQueryStitchJob, DocGenGiantQueryFlowAction
  - Batch/Async: DocGenBatch, DocGenMergeJob
  - Flow Actions: DocGenFlowAction, DocGenBulkFlowAction, DocGenGiantQueryFlowAction
  - Utilities: BarcodeGenerator, DocGenDataProvider (interface), DocGenException
  - Client-side JS: docGenPdfMerger.js (PDF merge), docGenZipWriter.js (DOCX/XLSX assembly)
- **Custom Objects:** DocGen_Template__c, DocGen_Template_Version__c, DocGen_Job__c, DocGen_Saved_Query__c
- **Custom Settings:** DocGen_Settings__c (hierarchy — global/user-level configuration)
- **Custom Fields on Standard Objects:** Product2.Product_Image__c (optional, for product image merge tags)
- **Invocable Actions:** DocGenFlowAction (single generation), DocGenBulkFlowAction (bulk generation), DocGenGiantQueryFlowAction (giant query generation) — all @InvocableMethod with global access for Flow/Process Builder visibility
- **Batch Apex:** DocGenBatch (implements Database.Batchable, Database.Stateful, Database.AllowsCallouts), DocGenGiantQueryBatch
- **Queueable:** DocGenMergeJob (PDF merging with Finalizer), DocGenGiantQueryAssembler, DocGenGiantQueryStitchJob
- **Custom Tabs:** DocGen Command Hub, Job History, Template Manager, Bulk Generation, Setup, Admin Guide, DocGen Template, DocGen Template Version
- **Custom App:** DocGen (Lightning app with all tabs)
- **Permission Sets:** DocGen Admin, DocGen User
- **Visualforce Pages:** None in the distributed package
- **Aura Components:** None — all LWC

## OAuth / Access Token Storage

The app does not use OAuth, does not store access tokens, and does not perform any authentication operations. All data access uses the running user's Salesforce session via standard Apex SOQL/DML with WITH USER_MODE enforcement.

## Salesforce Data Stored Outside the Platform

None. Zero data leaves the Salesforce platform. All templates, generated documents, job records, and configuration are stored as standard Salesforce records (custom objects and ContentVersion/ContentDocument). No external storage, no external databases, no file hosting services.

## Japanese Text

The app does not specifically handle Japanese text but supports any text content that Salesforce and the Blob.toPdf() rendering engine support. The PDF engine supports Arial Unicode MS for CJK characters. DOCX/XLSX/PPTX output preserves whatever fonts are in the template file.

## Mobile App Availability

No standalone mobile app. The Lightning Web Components are configured with mobile form factor support (Small + Large) on Record Pages and App Pages, so the DocGen Runner works within the Salesforce mobile app. No separate mobile binary is distributed.

## Browser Extension

None. The app does not include or require any browser extensions.

## Desktop / Client App

None. The app does not include or require any desktop applications or client-side installations. All functionality is accessed through the standard Salesforce Lightning UI in a web browser.
