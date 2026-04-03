// ==========================================================================
// REBUILD SAMPLE TEMPLATES: Build correct DOCX from scratch
// Header row + data row with {#tag} in first cell, {/tag} in last cell
// ==========================================================================

String contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>';
String rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>';
String docRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>';
String stylesXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:rPr><w:sz w:val="22"/></w:rPr></w:style></w:styles>';

String ns = ' xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"';

// Helpers for building styled content
String BLUE = '1E3A8A';
String GRAY = '6B7280';
String LGRAY = 'D1D5DB';
String LTBLUE = 'EBF0FA';
String WHITE_ON_BLUE = '<w:shd w:val="clear" w:color="auto" w:fill="' + BLUE + '"/>';
String cellMar = '<w:tcMar><w:top w:w="40" w:type="dxa"/><w:bottom w:w="40" w:type="dxa"/><w:left w:w="80" w:type="dxa"/><w:right w:w="80" w:type="dxa"/></w:tcMar>';
String tblBorders = '<w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="' + LGRAY + '"/><w:left w:val="single" w:sz="4" w:space="0" w:color="' + LGRAY + '"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="' + LGRAY + '"/><w:right w:val="single" w:sz="4" w:space="0" w:color="' + LGRAY + '"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="' + LGRAY + '"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="' + LGRAY + '"/></w:tblBorders>';

// =====================================================================
// 1. ACCOUNT OVERVIEW
// =====================================================================
String acctDoc = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document' + ns + '><w:body>' +

    // Title
    '<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/><w:caps/><w:color w:val="' + BLUE + '"/><w:sz w:val="36"/></w:rPr><w:t>Account Overview</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:color w:val="' + GRAY + '"/><w:sz w:val="22"/></w:rPr><w:t>{Name}</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="' + LGRAY + '"/></w:pBdr><w:spacing w:after="200"/></w:pPr></w:p>' +

    // Account Info section
    '<w:p><w:pPr><w:shd w:val="clear" w:fill="' + LTBLUE + '"/></w:pPr><w:r><w:rPr><w:b/><w:color w:val="' + BLUE + '"/><w:sz w:val="24"/></w:rPr><w:t>Account Information</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="374151"/><w:sz w:val="20"/></w:rPr><w:t xml:space="preserve">Industry: </w:t></w:r><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>{Industry}</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="374151"/><w:sz w:val="20"/></w:rPr><w:t xml:space="preserve">Phone: </w:t></w:r><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>{Phone}</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="374151"/><w:sz w:val="20"/></w:rPr><w:t xml:space="preserve">Website: </w:t></w:r><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>{Website}</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="374151"/><w:sz w:val="20"/></w:rPr><w:t xml:space="preserve">Account Owner: </w:t></w:r><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>{Owner.Name}</w:t></w:r></w:p>' +

    // Contacts section
    '<w:p><w:pPr><w:spacing w:before="240"/><w:shd w:val="clear" w:fill="' + LTBLUE + '"/></w:pPr><w:r><w:rPr><w:b/><w:color w:val="' + BLUE + '"/><w:sz w:val="24"/></w:rPr><w:t>Contacts</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:color w:val="' + GRAY + '"/><w:sz w:val="20"/></w:rPr><w:t>Total Contacts: {COUNT:Contacts}</w:t></w:r></w:p>' +

    // Contacts TABLE — header row, then data row with {#Contacts} in first cell, {/Contacts} in last
    '<w:tbl><w:tblPr><w:tblW w:w="5000" w:type="pct"/>' + tblBorders + '</w:tblPr>' +
    '<w:tblGrid><w:gridCol w:w="3200"/><w:gridCol w:w="2400"/><w:gridCol w:w="2400"/><w:gridCol w:w="2400"/></w:tblGrid>' +

    // Header row
    '<w:tr>' +
    '<w:tc><w:tcPr>' + WHITE_ON_BLUE + cellMar + '</w:tcPr><w:p><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:r><w:rPr><w:b/><w:color w:val="FFFFFF"/><w:sz w:val="18"/></w:rPr><w:t>Name</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:tcPr>' + WHITE_ON_BLUE + cellMar + '</w:tcPr><w:p><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:r><w:rPr><w:b/><w:color w:val="FFFFFF"/><w:sz w:val="18"/></w:rPr><w:t>Title</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:tcPr>' + WHITE_ON_BLUE + cellMar + '</w:tcPr><w:p><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:r><w:rPr><w:b/><w:color w:val="FFFFFF"/><w:sz w:val="18"/></w:rPr><w:t>Email</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:tcPr>' + WHITE_ON_BLUE + cellMar + '</w:tcPr><w:p><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:r><w:rPr><w:b/><w:color w:val="FFFFFF"/><w:sz w:val="18"/></w:rPr><w:t>Phone</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +

    // Data row — {#Contacts} in first cell text, {/Contacts} in last cell text
    '<w:tr>' +
    '<w:tc><w:tcPr>' + cellMar + '</w:tcPr><w:p><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:r><w:rPr><w:color w:val="374151"/><w:sz w:val="18"/></w:rPr><w:t>{#Contacts}{FirstName} {LastName}</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:tcPr>' + cellMar + '</w:tcPr><w:p><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:r><w:rPr><w:color w:val="374151"/><w:sz w:val="18"/></w:rPr><w:t>{Title}</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:tcPr>' + cellMar + '</w:tcPr><w:p><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:r><w:rPr><w:color w:val="374151"/><w:sz w:val="18"/></w:rPr><w:t>{Email}</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:tcPr>' + cellMar + '</w:tcPr><w:p><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:r><w:rPr><w:color w:val="374151"/><w:sz w:val="18"/></w:rPr><w:t>{Phone}{/Contacts}</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +
    '</w:tbl>' +

    // Footer
    '<w:p><w:pPr><w:pBdr><w:top w:val="single" w:sz="6" w:space="1" w:color="' + LGRAY + '"/></w:pBdr><w:spacing w:before="300"/><w:jc w:val="center"/></w:pPr>' +
    '<w:r><w:rPr><w:i/><w:color w:val="9CA3AF"/><w:sz w:val="16"/></w:rPr><w:t>Generated on {TODAY} | Powered by DocGen</w:t></w:r></w:p>' +

    '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1080" w:right="1080" w:bottom="1080" w:left="1080" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>' +
    '</w:body></w:document>';

// Build DOCX ZIP
Compression.ZipWriter zw = new Compression.ZipWriter();
zw.addEntry('[Content_Types].xml', Blob.valueOf(contentTypes));
zw.addEntry('_rels/.rels', Blob.valueOf(rels));
zw.addEntry('word/_rels/document.xml.rels', Blob.valueOf(docRels));
zw.addEntry('word/styles.xml', Blob.valueOf(stylesXml));
zw.addEntry('word/document.xml', Blob.valueOf(acctDoc));
Blob acctDocx = zw.getArchive();

// Update the Account Overview template
portwoodglobal__DocGen_Template__c tmpl = [SELECT Id FROM portwoodglobal__DocGen_Template__c WHERE Name = 'Sample: Account Overview' LIMIT 1];
portwoodglobal__DocGen_Template_Version__c ver = [SELECT Id, portwoodglobal__Content_Version_Id__c FROM portwoodglobal__DocGen_Template_Version__c WHERE portwoodglobal__Template__c = :tmpl.Id AND portwoodglobal__Is_Active__c = true LIMIT 1];

ContentVersion newCv = new ContentVersion(Title='Sample: Account Overview', PathOnClient='Account_Overview.docx', VersionData=acctDocx, IsMajorVersion=true, FirstPublishLocationId=tmpl.Id);
insert newCv;
newCv = [SELECT Id FROM ContentVersion WHERE Id = :newCv.Id];
ver.portwoodglobal__Content_Version_Id__c = newCv.Id;
update ver;
try { DocGenService.extractAndSaveTemplateImages(tmpl.Id, ver.Id); } catch (Exception e) {}

System.debug(LoggingLevel.ERROR, 'Account Overview REBUILT — CV=' + newCv.Id);

// Generate proof
Account acc = [SELECT Id FROM Account WHERE Name LIKE 'Proof Corp%' ORDER BY CreatedDate DESC LIMIT 1];
Map<String, Object> result = DocGenService.generatePdfBlob(tmpl.Id, acc.Id);
Blob pdfBlob = (Blob) result.get('blob');
insert new ContentVersion(Title='PROOF-REBUILT-AccountOverview', PathOnClient='proof.pdf', VersionData=pdfBlob, FirstPublishLocationId=acc.Id);
System.debug(LoggingLevel.ERROR, 'PROOF generated: ' + pdfBlob.size() + ' bytes — acc=' + acc.Id);
