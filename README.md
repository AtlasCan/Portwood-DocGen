# Salesforce Document Generation Platform

**A free, native, production-ready document engine for Salesforce.**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#quick-install)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Salesforce-00A1E0.svg)](https://www.salesforce.com)
[![API Version](https://img.shields.io/badge/API-v66.0-orange.svg)](#)
[![Dependencies](https://img.shields.io/badge/JS%20dependencies-zero-brightgreen.svg)](#)

Generate DOCX, PPTX, and PDF documents from any Salesforce record. Merge fields, loop over child records, inject images from rich text fields, collect legally-binding electronic signatures, and render PDFs -- all 100% server-side, without leaving Salesforce, and without paying a dime.

---

## Table of Contents

- [Why This Exists](#why-this-exists)
- [Quick Install](#quick-install)
- [What's New in v1.0.0](#whats-new-in-v100)
- [Features at a Glance](#features-at-a-glance)
- [Admin Guide](#admin-guide)
  - [Initial Setup](#initial-setup)
  - [Permission Sets](#permission-sets)
  - [PDF Engine Setup](#pdf-engine-setup)
  - [Electronic Signature Setup](#electronic-signature-setup)
  - [Template Management](#template-management)
  - [Bulk Generation](#bulk-generation)
  - [Flow Integration](#flow-integration)
  - [Template Sharing](#template-sharing)
- [User Guide](#user-guide)
  - [Generating Documents from a Record](#generating-documents-from-a-record)
  - [Sending Documents for Signature](#sending-documents-for-signature)
  - [Signing a Document](#signing-a-document)
- [Template Authoring Guide](#template-authoring-guide)
  - [Tag Syntax Reference](#tag-syntax-reference)
  - [Creating Your First Template](#creating-your-first-template)
  - [Working with Child Records](#working-with-child-records)
  - [Table Row Expansion](#table-row-expansion)
  - [Conditional Sections](#conditional-sections)
  - [Image Injection](#image-injection)
  - [Date Formatting](#date-formatting)
  - [Document Title Formatting](#document-title-formatting)
  - [Signature Placeholders](#signature-placeholders)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [License](#license)

---

## Why This Exists

Document generation in Salesforce is expensive. The market leaders charge per-user, per-month fees that quickly add up across an organization. We believe basic document needs should be accessible to everyone.

This project gives you a professional-grade document engine -- template management, bulk generation, flow integration, server-side PDF rendering, rich text with embedded images, and multi-signer electronic signatures -- entirely for free and fully open-source.

---

## Quick Install

**Subscriber Package Version ID**: `04tdL000000Or6PQAS`

> Update this ID after publishing the v1.0.0 package version.

**CLI:**
```bash
sf package install --package 04tdL000000Or6PQAS --wait 10 --installation-key-bypass
```

**Browser:**
- [Install in Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tdL000000Or6PQAS)
- [Install in Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tdL000000Or6PQAS)

> Select **Install for Admins Only** during installation, then assign permission sets to your users afterward.

---

## What's New in v1.0.0

This is a major release that eliminates all client-side JavaScript dependencies and moves the entire PDF pipeline server-side.

### Server-Side PDF Generation
- PDF documents are now generated entirely in Apex using `Blob.toPdf()` with the new `DocGenHtmlRenderer` engine
- No more iframe rendering, postMessage communication, or browser-side conversion
- PDFs generate instantly in bulk, flow, and signature contexts

### Zero JavaScript Dependencies
- Removed `docx-preview.js`, `html2pdf.js`, `jszip.min.js`, and `filesaver.js`
- The entire `DocGenEngine` static resource bundle has been removed
- No third-party JS libraries remain in the package

### Simplified Architecture
- Removed the async rendition pipeline (Queueable, Finalizer, Platform Event)
- Removed `DocGenPDFEngine.page` (client-side PDF rendering page)
- Removed `DocGenRenditionService`, `DocGenRenditionQueueable`, `DocGenRenditionFinalizer`, and `DocGenRenditionTrigger`
- Single-path PDF generation: DOCX XML -> HTML -> `Blob.toPdf()`

### Signature Flow Improvements
- Signature page no longer loads any JavaScript libraries for document preview
- Document preview is rendered as pre-built HTML from the server
- Signed PDFs are generated and saved server-side immediately after signing

### Security & AppExchange Readiness
- All metadata upgraded to API version 66.0 (Spring '26)
- All DML operations use `Security.stripInaccessible()` for CRUD/FLS enforcement
- All dynamic SOQL uses `AccessLevel.USER_MODE` for user data queries
- Verbose debug logging removed; only ERROR/WARN level logging remains
- Dev artifacts and test scripts cleaned from the repository

---

## Features at a Glance

| Feature | Description |
|---------|-------------|
| **Template Manager** | Create, edit, version, and share document templates with a visual query builder |
| **Record Page Generator** | Drop-in LWC component -- users select a template and generate from any record |
| **PDF Generation** | Server-side conversion from DOCX to PDF via `Blob.toPdf()` |
| **Bulk Generation** | Generate documents for thousands of records with real-time progress tracking |
| **Flow Integration** | Invocable actions for single-record and bulk generation in any Flow |
| **Electronic Signatures** | Multi-signer, role-based, legally-binding signatures with audit trails |
| **Image Injection** | Embed images from rich text fields, ContentVersion files, or URLs |
| **Template Versioning** | Full version history with restore and activate capabilities |
| **Template Sharing** | Share templates with specific users or groups |

---

## Admin Guide

### Initial Setup

After installing the package:

1. **Assign permission sets** to yourself and your users (see [Permission Sets](#permission-sets))
2. **Add the generator component** to record pages (see [Adding to Record Pages](#adding-the-generator-to-record-pages))
3. **Configure the PDF engine** if you need PDF output or image support (see [PDF Engine Setup](#pdf-engine-setup))
4. **Configure signatures** if you want electronic signatures (see [Electronic Signature Setup](#electronic-signature-setup))

### Permission Sets

Assign these from **Setup > Permission Sets > Manage Assignments**:

| Permission Set | Who Gets It | What It Grants |
|---------------|-------------|----------------|
| **DocGen Admin** | Admins, template managers | Create/edit/delete templates, bulk generation, sharing management, setup wizard access |
| **DocGen User** | End users | Generate documents from existing templates, download/save documents |
| **DocGen Guest Signature** | Site guest user profile | Signature submission via public VF pages (assigned to the Site guest user, not individual users) |

### PDF Engine Setup

The PDF engine requires a Named Credential so Salesforce can make authenticated loopback calls (needed for rich text image resolution). If you only generate DOCX/PPTX files and don't use images from rich text fields, you can skip this.

1. Navigate to the **DocGen Setup** tab in the DocGen app
2. Follow the 3-step wizard:

**Step 1: Create an External Client App**
- Go to **Setup > App Manager > New Connected App** (or **External Client App** in newer orgs)
- App name: `DocGen Loopback`
- Enable OAuth: checked
- Callback URL: your org's login URL (e.g., `https://yourorg.my.salesforce.com/services/oauth2/callback`)
- OAuth Scopes: `api`, `refresh_token`
- Enable PKCE: checked
- Save and wait for the app to propagate

**Step 2: Provision Credentials**
- Copy the Consumer Key and Consumer Secret from your new app
- Paste them into the setup wizard
- Click **Provision Credentials** -- this automatically creates the Auth Provider, External Credential, and Named Credential
- Wait up to 10 minutes for metadata propagation
- Click **Authenticate** to authorize the named principal
- Go to **Setup > Named Credentials > External Credentials > DocGen Loopback Auth > [Principal Name]**, and add both `DocGen Admin` and `DocGen User` permission sets under **Permission Set Mappings**

**Step 3: Configure Site URL**
- Enter your Salesforce Site base URL (see [Electronic Signature Setup](#electronic-signature-setup) if you're using signatures)
- This is used to generate public signing links

### Electronic Signature Setup

E-signatures require a Salesforce Site (Digital Experience is **not** required):

1. **Create a Salesforce Site**
   - Go to **Setup > Sites > New**
   - Site label: `DocGen Signatures` (or your preference)
   - Site name: `DocGenSignatures`
   - Default page: `DocGenSignature`
   - Active Site Home Page: `DocGenSignature`
   - Check **Active**
   - Save

2. **Configure the Guest User Profile**
   - From the Site detail page, click **Public Access Settings**
   - Under **Enabled Visualforce Page Access**, add:
     - `DocGenSignature`
     - `DocGenSign`
     - `DocGenVerify`
   - Go back to the guest user profile and assign the `DocGen Guest Signature` permission set

3. **Save the Site URL**
   - Copy your site's base URL (e.g., `https://yourorg.my.salesforce-sites.com`)
   - Enter it in the DocGen Setup wizard (Step 3)

4. **Create Signature Templates** (optional)
   - From the **Signature Sender** component on any record page, click the template management icon
   - Define reusable signer role configurations (e.g., Buyer + Seller + Witness)

> No Experience Cloud site, Screen Flow, or embedded component is required. The VF pages handle the entire signing experience natively.

### Template Management

Access: Navigate to the **DocGen Template Manager** tab.

**Creating a Template:**
1. Click **New Template**
2. Fill in:
   - **Name**: Display name for the template
   - **Category**: Organizational grouping (e.g., Sales, Legal, HR)
   - **Type**: Word or PowerPoint
   - **Base Object**: The Salesforce object this template generates from (e.g., Account, Opportunity)
   - **Output Format**: Native (DOCX/PPTX) or PDF
   - **Description**: Optional notes about the template
3. Upload your `.docx` or `.pptx` template file (see [Template Authoring Guide](#template-authoring-guide))
4. Use the **Query Builder** to select which fields and relationships to include
5. Click **Save**

**Testing a Template:**
1. Enter a Test Record ID in the template settings
2. Click **Test Generate**
3. The document downloads immediately for review

**Versioning:**
- Each time you save a template with changes, you can create a new version
- Previous versions are listed with timestamps and the author
- Click **Activate** on any previous version to roll back

**Document Title Formatting:**
- Set a custom title pattern using merge tags: `{Name} - Invoice {CloseDate:yyyy-MM-dd}`
- If blank, the title defaults to the record's Name field

### Bulk Generation

Access: Navigate to the **DocGen Bulk Gen** tab.

1. Select a template from the dropdown
2. Optionally enter a WHERE clause to filter records (e.g., `StageName = 'Closed Won' AND CloseDate = THIS_QUARTER`)
3. Click **Validate** to preview the record count
4. Click **Generate** to start the batch job
5. Monitor progress in real-time -- the UI updates with success/error counts

**Saved Queries:**
- Save frequently-used filter conditions for reuse
- Access saved queries from the dropdown menu
- Each saved query stores a name, description, and filter condition

### Flow Integration

Two invocable actions for embedding document generation in any Salesforce Flow:

**Single Record -- `Generate Document (DocGen)`:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | Input | The ID of the DocGen_Template__c record |
| `recordId` | Input | The ID of the source record |
| `contentDocumentId` | Output | The ContentDocumentId of the generated file |
| `errorMessage` | Output | Error details if generation fails |

**Bulk/Batch -- `Generate Documents Bulk (DocGen)`:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | Input | The ID of the DocGen_Template__c record |
| `queryCondition` | Input | Optional WHERE clause to filter records |
| `jobId` | Output | The ID of the DocGen_Job__c record for progress tracking |
| `errorMessage` | Output | Error details if the job fails to start |

**Example: Auto-generate a PDF when an Opportunity closes:**
1. Create a Record-Triggered Flow on Opportunity
2. Entry criteria: `StageName = 'Closed Won'`
3. Add a **Generate Document** action
4. Map `templateId` to your quote template
5. Map `recordId` to `{!$Record.Id}`

### Template Sharing

Templates support user and group-level sharing:

1. Open a template in the Template Manager
2. Click the **Sharing** tab
3. Search for users or public groups
4. Grant **Read** or **Edit** access
5. Users with Edit access can modify the template; Read-only users can generate but not change it

---

## User Guide

### Generating Documents from a Record

1. Navigate to any record page that has the **DocGen** component (your admin adds this via Lightning App Builder)
2. Select a template from the dropdown -- only templates configured for this object type appear
3. Choose the output format:
   - **Download** -- generates and downloads the file to your browser
   - **Save to Record** -- generates and attaches the file to the record's Files related list
4. Click the generate button
5. For DOCX/PPTX: the file downloads immediately
6. For PDF: the document is converted server-side and downloads or saves automatically

### Sending Documents for Signature

1. On a record page, find the **Signature Sender** component
2. Click **New Signature Request**
3. Select the document to be signed (must be a `.docx` file attached to the record)
4. Add signers:
   - Enter each signer's **name**, **email**, and **role** (if using multi-signer templates)
   - Use the contact lookup to auto-fill from existing contacts
   - Or load a saved signature template for predefined role configurations
5. Click **Send**
6. Each signer receives a unique secure URL
7. Copy the URLs and share them with signers (via email, Slack, etc.)
8. Track signing progress from the **Previous Requests** section

### Signing a Document

When you receive a signature link:

1. Open the URL in any browser (mobile or desktop)
2. Review the document displayed on the page
3. Draw your signature in the signature pad at the bottom
4. Click **Submit Signature**
5. If you're the last signer, the system:
   - Stamps all signatures into the document at the designated placeholders
   - Converts the signed document to PDF
   - Saves the PDF to the Salesforce record
   - Creates an audit trail with a SHA-256 hash of the final PDF
6. If other signers are still pending, you'll see a confirmation that your signature was saved

---

## Template Authoring Guide

### Tag Syntax Reference

Place these tags directly in your `.docx` or `.pptx` template file:

| Tag | Purpose | Example |
|-----|---------|---------|
| `{FieldName}` | Simple field merge | `{Name}`, `{Email}` |
| `{Parent.Field}` | Parent record lookup | `{Account.Name}`, `{Owner.Email}` |
| `{#ChildList}...{/ChildList}` | Loop over child records | `{#Contacts}{FirstName} {LastName}{/Contacts}` |
| `{#BooleanField}...{/BooleanField}` | Conditional section | `{#IsActive}Active member{/IsActive}` |
| `{FieldName:format}` | Date/DateTime with format | `{CloseDate:MM/dd/yyyy}` |
| `{%ImageField}` | Image injection (default 4"x3") | `{%Company_Logo__c}` |
| `{%ImageField:WxH}` | Image with pixel dimensions | `{%Photo__c:400x300}` |
| `{#Signature}` | Single-signer signature placeholder | |
| `{#Signature_RoleName}` | Multi-signer role placeholder | `{#Signature_Buyer}` |

### Creating Your First Template

1. Open Microsoft Word or Google Docs (export as .docx)
2. Type your document content normally
3. Where you want dynamic data, insert a merge tag:
   ```
   Dear {Name},

   Thank you for your order dated {CloseDate:MMMM d, yyyy}.
   Your total is {Amount}.

   Regards,
   {Owner.Name}
   ```
4. Save as `.docx`
5. Upload to a DocGen template configured for the matching object (e.g., Opportunity)

### Working with Child Records

To repeat a block of content for each child record:

```
Line Items:
{#OpportunityLineItems}
  - {Name}: {Quantity} x {UnitPrice} = {TotalPrice}
{/OpportunityLineItems}
```

The content between `{#OpportunityLineItems}` and `{/OpportunityLineItems}` repeats once for each child record. Use the **relationship name** (not the object API name) as the loop tag.

### Table Row Expansion

When loop tags are placed inside a table row, the entire row is automatically repeated:

| Product | Qty | Price |
|---------|-----|-------|
| {#OpportunityLineItems}{Name} | {Quantity} | {TotalPrice}{/OpportunityLineItems} |

This produces one row per line item. Place `{#LoopName}` at the start and `{/LoopName}` at the end of the same row.

### Conditional Sections

Show or hide content based on boolean (checkbox) fields:

```
{#HasSpecialTerms}
SPECIAL TERMS AND CONDITIONS
This agreement includes the following special provisions...
{/HasSpecialTerms}
```

The content only appears if the field value is `true`.

### Image Injection

Images can come from several sources:

- **Rich text fields**: HTML `<img>` tags are automatically extracted and converted
- **ContentVersion IDs**: `{%MyImageField__c}` where the field contains a ContentVersion ID (starts with `068`)
- **Base64 data URIs**: Fields containing `data:image/png;base64,...`
- **Salesforce file URLs**: `/servlet/rtaImage` or `/sfc/servlet.shepherd/` URLs

**Sizing:**
- Default size: 4 inches x 3 inches
- Custom size: `{%Photo__c:200x150}` (width x height in pixels)

> Image resolution requires the Named Credential (DocGen Loopback) to be configured. See [PDF Engine Setup](#pdf-engine-setup).

### Date Formatting

Append a format string after a colon:

| Example | Output |
|---------|--------|
| `{CloseDate:MM/dd/yyyy}` | 03/15/2026 |
| `{CreatedDate:MMMM d, yyyy}` | March 15, 2026 |
| `{CreatedDate:yyyy-MM-dd HH:mm}` | 2026-03-15 14:30 |
| `{CloseDate:EEE, MMM d}` | Sun, Mar 15 |

Format strings follow Salesforce's `DateTime.format()` patterns (Java SimpleDateFormat).

### Document Title Formatting

In the template settings, set a **Document Title Format** to control the generated file name:

| Format | Result |
|--------|--------|
| `{Name} - Quote` | Acme Corp - Quote |
| `Invoice {CloseDate:yyyy-MM}` | Invoice 2026-03 |
| `{Account.Name} - {Name}` | Acme Corp - Big Deal |

If blank, the title defaults to the record's Name field value.

### Signature Placeholders

**Single signer:** Place `{#Signature}` in your template where the signature image should appear.

**Multiple signers:** Use role-specific placeholders:
- `{#Signature_Buyer}`
- `{#Signature_Seller}`
- `{#Signature_Witness}`

The role name in the placeholder must match the role assigned to the signer (with spaces replaced by underscores).

If a placeholder is not found in the document, the signature is appended to the end of the document with a label.

---

## Architecture

### Document Generation Pipeline

All document generation runs **100% server-side in Apex** -- no client-side JavaScript is involved at any stage.

```
Template (.docx/.pptx)
    |
    v
Decompress ZIP (Salesforce Compression API)
    |
    v
Pre-process XML
    |-- Merge split text runs (<w:r> elements)
    |-- Normalize template tags across formatting boundaries
    |
    v
Tag Processing (Apex)
    |-- Simple substitution: {Field} -> value
    |-- Loop expansion: {#List}...{/List} -> repeated content
    |-- Conditional rendering: {#Bool}...{/Bool}
    |-- Image injection: {%Image} -> DrawingML <w:drawing> elements
    |-- Rich text HTML -> extracted images + inline text
    |
    v
Recompress ZIP -> DOCX/PPTX Blob
    |
    v
PDF path (if output format = PDF):
    |-- DocGenHtmlRenderer converts DOCX XML -> HTML
    |-- Blob.toPdf(html) generates PDF natively in Apex
    |
    v
Save as ContentVersion (attached to record)
```

### Signature Flow

```
Admin generates signature links from record page
    |
    v
Each signer receives a unique URL with a cryptographic token
    |
    v
Signer opens link -> VF page validates token
    |-- Server renders DOCX as HTML via DocGenHtmlRenderer
    |-- HTML displayed directly in the page (no JS libraries)
    |
    v
Signer draws signature on canvas -> submits PNG
    |
    v
All signers complete?
    |-- Yes -> Stamp all signature PNGs into DOCX at role placeholders
    |       -> Convert stamped DOCX to HTML -> Blob.toPdf()
    |       -> Save PDF to record
    |       -> Create audit trail with SHA-256 hash per signer
    |-- No  -> Save signature data, wait for remaining signers
```

### Key Classes

| Class | Responsibility |
|-------|---------------|
| `DocGenService` | Core template merge engine -- tag processing, image injection, ZIP assembly |
| `DocGenHtmlRenderer` | Converts DOCX XML to HTML for `Blob.toPdf()` conversion |
| `DocGenController` | LWC controller -- template CRUD, document generation, PDF generation |
| `DocGenDataRetriever` | Dynamic SOQL execution with field validation |
| `DocGenTemplateManager` | Template file retrieval with version support |
| `DocGenBatch` | Batch Apex for bulk document generation |
| `DocGenSignatureController` | VF page controller for the signing portal |
| `DocGenSignatureService` | Signature stamping into DOCX via OpenXML manipulation |
| `DocGenSignatureSenderController` | Multi-signer request creation and management |

---

## Project Structure

```
force-app/main/default/
  classes/              Apex classes (services, controllers, batch, tests)
  lwc/                  Lightning Web Components
    docGenAdmin/          Template manager UI
    docGenRunner/         Record page document generator
    docGenBulkRunner/     Bulk generation UI
    docGenSignatureSender/ Signature request sender
    docGenSignaturePad/   Signature drawing canvas
    docGenQueryBuilder/   Visual SOQL query builder
    docGenFilterBuilder/  Bulk filter condition builder
    docGenSetupWizard/    Credential provisioning wizard
    docGenSharing/        Template sharing UI
    docGenTitleEditor/    Document title format editor
    docGenWelcome/        App welcome page
    docGenAuthenticator/  Named credential authentication
  objects/              Custom objects + custom settings
    DocGen_Template__c/     Template definitions
    DocGen_Template_Version__c/ Template version history
    DocGen_Job__c/          Bulk generation job tracking
    DocGen_Saved_Query__c/  Saved filter conditions
    DocGen_Signature_Request__c/ Signature requests
    DocGen_Signer__c/       Individual signer records
    DocGen_Signature_Audit__c/ Signed document audit trail
    DocGen_Signature_Template__c/ Reusable signer role templates
    DocGen_Signature_Template_Role__c/ Template role definitions
    DocGen_Settings__c/     Custom settings (site URL)
  pages/                Visualforce pages
    DocGenSignature       Main signature portal
    DocGenSign            Signature submission endpoint
    DocGenVerify          Signature verification page
    DocGenProvision       Credential provisioning endpoint
  permissionsets/       Permission sets (Admin, User, Guest Signature)
  applications/         DocGen Lightning App
  tabs/                 Custom tabs

unpackaged/             Post-install metadata (not in package)
  flows/                Signature submission flow
```

---

## Changelog

### v1.0.0
- **Server-Side PDF** -- All PDF generation now uses `DocGenHtmlRenderer` + `Blob.toPdf()`. Zero client-side JavaScript.
- **Removed** -- `DocGenEngine` bundle, `html2pdf.js`, `docx-preview.js`, `jszip.min.js`, `filesaver.js`, `DocGenPDFEngine.page`, rendition pipeline (Queueable/Finalizer/Platform Event/Trigger)
- **Security** -- All DML uses `Security.stripInaccessible()`. Verbose debug logging removed. API version 66.0.
- **Signature** -- Server-side document preview and PDF generation for the signing portal.

### v0.9.1
- PKCE Auth Fix for credential provisioning
- Wizard UX improvements with propagation delay warnings

### v0.9.0
- One-click credential provisioning via setup wizard
- Streamlined 3-step setup process

### v0.8.0
- Fixed package uninstall blockers (moved auth metadata to `unpackaged/`)
- Updated terminology to External Client App

### v0.7.0
- Bulk PDF generation fix (all records now get PDFs)
- Transaction Finalizer retries for rendition pipeline

### v0.6.0
- Security hardening (CRUD/FLS, SOQL injection, postMessage validation, HTTPS enforcement)

### v0.5.0
- 100% server-side document generation via Salesforce Compression API
- Multi-signer signature roles
- Rich text and image support
- Background PDF rendition
- 2GP package ready

---

## Contributing

This is an open-source project under the MIT license. We welcome contributions:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with a clear description of your changes

Please report bugs and feature requests via [GitHub Issues](https://github.com/DaveMoudy/SalesforceDocGen/issues).

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
