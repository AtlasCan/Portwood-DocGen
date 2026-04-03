// ==========================================================================
// RTL PROOF: Build a real DOCX template with Hebrew + Arabic + mixed content
// Generate PDF through full pipeline (Spring '26 Chromium renderer)
// ==========================================================================
String uid = String.valueOf(Crypto.getRandomLong()).right(6);

// Get or create test account
Database.DMLOptions dml = new Database.DMLOptions();
dml.DuplicateRuleHeader.allowSave = true;
Account acc = new Account(Name='חברת אקמה בע"מ', Industry='Technology', Phone='03-555-0142',
    BillingStreet='רחוב הרצל 42', BillingCity='תל אביב', BillingState='IL',
    Description='חברת טכנולוגיה מובילה');
Database.insert(acc, dml);

Contact c1 = new Contact(FirstName='יעקב', LastName='כהן', Title='מנכ"ל', Email='yaakov@acme.co.il', AccountId=acc.Id);
Contact c2 = new Contact(FirstName='Ahmed', LastName='Hassan', Title='مدير المبيعات', Email='ahmed@acme.co.il', AccountId=acc.Id);
Database.insert(new List<Contact>{c1, c2}, dml);

// Build the DOCX ZIP with RTL styles + content
String contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' +
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' +
    '<Default Extension="xml" ContentType="application/xml"/>' +
    '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>' +
    '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>' +
    '<Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"/>' +
    '</Types>';

String rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>' +
    '</Relationships>';

String docRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>' +
    '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Target="header1.xml"/>' +
    '</Relationships>';

// Styles with RTL Normal style
String stylesXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">' +
    '<w:name w:val="Normal"/><w:qFormat/>' +
    '<w:pPr><w:bidi/></w:pPr>' +
    '<w:rPr><w:sz w:val="24"/></w:rPr>' +
    '</w:style>' +
    '<w:style w:type="paragraph" w:styleId="Heading1">' +
    '<w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:qFormat/>' +
    '<w:pPr><w:keepNext/></w:pPr>' +
    '<w:rPr><w:b/><w:sz w:val="32"/></w:rPr>' +
    '</w:style>' +
    '</w:styles>';

// Header with page number (styled)
String headerXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="18"/><w:color w:val="666666"/></w:rPr>' +
    '<w:t>\u05D7\u05D1\u05E8\u05EA \u05D0\u05E7\u05DE\u05D4 \u05D1\u05E2"\u05DE — \u05E2\u05DE\u05D5\u05D3 </w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="18"/><w:color w:val="2E74B5"/></w:rPr>' +
    '<w:fldChar w:fldCharType="begin"/></w:r>' +
    '<w:r><w:instrText> PAGE </w:instrText></w:r>' +
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="18"/><w:color w:val="2E74B5"/></w:rPr>' +
    '<w:fldChar w:fldCharType="end"/></w:r>' +
    '<w:r><w:rPr><w:sz w:val="18"/><w:color w:val="666666"/></w:rPr><w:t> \u05DE\u05EA\u05D5\u05DA </w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="18"/><w:color w:val="2E74B5"/></w:rPr>' +
    '<w:fldChar w:fldCharType="begin"/></w:r>' +
    '<w:r><w:instrText> NUMPAGES </w:instrText></w:r>' +
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="18"/><w:color w:val="2E74B5"/></w:rPr>' +
    '<w:fldChar w:fldCharType="end"/></w:r>' +
    '</w:p></w:hdr>';

// Document with rich RTL content
String ns = ' xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"';
String docXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:document' + ns + '>' +
    '<w:body>' +

    // === Title (Hebrew) ===
    '<w:p><w:pPr><w:pStyle w:val="Heading1"/><w:bidi/><w:jc w:val="center"/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="40"/><w:color w:val="1F4E79"/></w:rPr>' +
    '<w:t>\u05D3\u05D5\u05D7 \u05E1\u05E7\u05D9\u05E8\u05EA \u05D7\u05E9\u05D1\u05D5\u05DF</w:t></w:r></w:p>' +

    // === Company name from merge tag ===
    '<w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="28"/><w:color w:val="808080"/></w:rPr>' +
    '<w:t>{Name}</w:t></w:r></w:p>' +

    '<w:p/>' +

    // === Section 1: Company Info (Hebrew) with line breaks ===
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:rtl/><w:sz w:val="28"/><w:color w:val="1F4E79"/></w:rPr>' +
    '<w:t>\u05E4\u05E8\u05D8\u05D9 \u05D4\u05D7\u05D1\u05E8\u05D4</w:t></w:r></w:p>' +

    // Address with line break
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:rtl/></w:rPr><w:t>\u05DB\u05EA\u05D5\u05D1\u05EA: </w:t></w:r>' +
    '<w:r><w:rPr><w:rtl/></w:rPr><w:t>{BillingStreet}</w:t></w:r>' +
    '<w:r><w:br/></w:r>' +
    '<w:r><w:rPr><w:rtl/></w:rPr><w:t>{BillingCity}</w:t></w:r></w:p>' +

    // Phone
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:rtl/></w:rPr><w:t>\u05D8\u05DC\u05E4\u05D5\u05DF: </w:t></w:r>' +
    '<w:r><w:t>{Phone}</w:t></w:r></w:p>' +

    // Industry — mixed Hebrew label + English value
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:rtl/></w:rPr><w:t>\u05EA\u05E2\u05E9\u05D9\u05D9\u05D4: </w:t></w:r>' +
    '<w:r><w:rPr><w:color w:val="2E74B5"/></w:rPr><w:t>{Industry}</w:t></w:r></w:p>' +

    '<w:p/>' +

    // === Section 2: Contacts Table (Hebrew headers, mixed data) ===
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:rtl/><w:sz w:val="28"/><w:color w:val="1F4E79"/></w:rPr>' +
    '<w:t>\u05D0\u05E0\u05E9\u05D9 \u05E7\u05E9\u05E8</w:t></w:r></w:p>' +

    // Contacts table
    '<w:tbl><w:tblPr><w:bidiVisual/><w:tblW w:w="5000" w:type="pct"/><w:tblBorders>' +
    '<w:top w:val="single" w:sz="6" w:color="1F4E79"/>' +
    '<w:bottom w:val="single" w:sz="6" w:color="1F4E79"/>' +
    '<w:insideH w:val="single" w:sz="4" w:color="D6E4F0"/>' +
    '<w:insideV w:val="single" w:sz="4" w:color="D6E4F0"/>' +
    '</w:tblBorders></w:tblPr>' +

    // Table header row
    '<w:tr>' +
    '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="1F4E79"/></w:tcPr>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:rtl/><w:color w:val="FFFFFF"/></w:rPr><w:t>\u05E9\u05DD</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="1F4E79"/></w:tcPr>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:rtl/><w:color w:val="FFFFFF"/></w:rPr><w:t>\u05EA\u05E4\u05E7\u05D9\u05D3</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="1F4E79"/></w:tcPr>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:rtl/><w:color w:val="FFFFFF"/></w:rPr><w:t>\u05D0\u05D9\u05DE\u05D9\u05D9\u05DC</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +

    // Repeating contact rows
    '{#Contacts}' +
    '<w:tr>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:b/></w:rPr><w:t>{FirstName}</w:t></w:r>' +
    '<w:r><w:t xml:space="preserve"> </w:t></w:r>' +
    '<w:r><w:t>{LastName}</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:t>{Title}</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:color w:val="2E74B5"/></w:rPr><w:t>{Email}</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +
    '{/Contacts}' +
    '</w:tbl>' +

    '<w:p/>' +

    // === Section 3: Arabic paragraph ===
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:rtl/><w:sz w:val="28"/><w:color w:val="1F4E79"/></w:rPr>' +
    '<w:t>\u0645\u0639\u0644\u0648\u0645\u0627\u062A \u0625\u0636\u0627\u0641\u064A\u0629</w:t></w:r></w:p>' +

    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/></w:rPr>' +
    '<w:t>\u0647\u0630\u0647 \u0641\u0642\u0631\u0629 \u0628\u0627\u0644\u0644\u063A\u0629 \u0627\u0644\u0639\u0631\u0628\u064A\u0629 \u0644\u0627\u062E\u062A\u0628\u0627\u0631 \u0627\u0644\u0639\u0631\u0636 \u0645\u0646 \u0627\u0644\u064A\u0645\u064A\u0646 \u0625\u0644\u0649 \u0627\u0644\u064A\u0633\u0627\u0631.</w:t></w:r>' +
    '<w:r><w:br/></w:r>' +
    '<w:r><w:rPr><w:rtl/></w:rPr>' +
    '<w:t>\u0647\u0630\u0627 \u0633\u0637\u0631 \u062B\u0627\u0646\u064A \u0628\u0639\u062F \u0641\u0627\u0635\u0644 \u0633\u0637\u0631.</w:t></w:r>' +
    '<w:r><w:br/></w:r>' +
    '<w:r><w:rPr><w:b/><w:rtl/><w:color w:val="CC0000"/></w:rPr>' +
    '<w:t>\u0647\u0630\u0627 \u0646\u0635 \u0639\u0631\u0628\u064A \u063A\u0627\u0645\u0642 \u0628\u0627\u0644\u0644\u0648\u0646 \u0627\u0644\u0623\u062D\u0645\u0631.</w:t></w:r></w:p>' +

    // === Mixed Hebrew + English in one paragraph ===
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/></w:rPr><w:t>\u05EA\u05D9\u05D0\u05D5\u05E8: </w:t></w:r>' +
    '<w:r><w:rPr><w:rtl/></w:rPr><w:t>{Description}</w:t></w:r></w:p>' +

    // === Signature line ===
    '<w:p/><w:p/>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:color w:val="808080"/></w:rPr>' +
    '<w:t>___________________________</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="18"/><w:color w:val="808080"/></w:rPr>' +
    '<w:t>\u05D7\u05EA\u05D9\u05DE\u05D4 / \u05EA\u05D0\u05E8\u05D9\u05DA</w:t></w:r></w:p>' +

    // Section properties with header reference
    '<w:sectPr><w:headerReference w:type="default" r:id="rId2" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>' +
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720"/>' +
    '</w:sectPr>' +
    '</w:body></w:document>';

// Assemble DOCX ZIP
Compression.ZipWriter zw = new Compression.ZipWriter();
zw.addEntry('[Content_Types].xml', Blob.valueOf(contentTypes));
zw.addEntry('_rels/.rels', Blob.valueOf(rels));
zw.addEntry('word/_rels/document.xml.rels', Blob.valueOf(docRels));
zw.addEntry('word/document.xml', Blob.valueOf(docXml));
zw.addEntry('word/styles.xml', Blob.valueOf(stylesXml));
zw.addEntry('word/header1.xml', Blob.valueOf(headerXml));
Blob docxBlob = zw.getArchive();

System.debug(LoggingLevel.ERROR, 'DOCX built: ' + docxBlob.size() + ' bytes');

// Create template
String v3Config = '{"v":3,"root":"Account","nodes":[' +
    '{"id":"n0","object":"Account","fields":["Name","Industry","Phone","BillingStreet","BillingCity","Description"],"parentFields":[],"parentNode":null,"lookupField":null,"relationshipName":null},' +
    '{"id":"n1","object":"Contact","fields":["FirstName","LastName","Title","Email"],"parentFields":[],"parentNode":"n0","lookupField":"AccountId","relationshipName":"Contacts"}]}';

DocGen_Template__c tmpl = new DocGen_Template__c(
    Name = 'RTL Proof ' + uid,
    Base_Object_API__c = 'Account',
    Type__c = 'Word',
    Output_Format__c = 'PDF',
    Query_Config__c = v3Config,
    Test_Record_Id__c = acc.Id
);
insert tmpl;

ContentVersion docxCv = new ContentVersion(Title='RTL-Tmpl-'+uid, PathOnClient='rtl_'+uid+'.docx',
    VersionData=docxBlob, IsMajorVersion=true, FirstPublishLocationId=tmpl.Id);
insert docxCv;
docxCv = [SELECT Id FROM ContentVersion WHERE Id = :docxCv.Id];

DocGen_Template_Version__c ver = new DocGen_Template_Version__c(
    Template__c=tmpl.Id, Content_Version_Id__c=docxCv.Id, Is_Active__c=true);
insert ver;

System.debug(LoggingLevel.ERROR, 'Template created: ' + tmpl.Id);

// Generate PDF through full pipeline
try {
    Map<String, Object> result = DocGenService.generatePdfBlob(tmpl.Id, acc.Id);
    Blob pdfBlob = (Blob) result.get('blob');
    String title = (String) result.get('title');

    ContentVersion pdfCv = new ContentVersion(
        Title = 'PROOF-RTL-Hebrew-Arabic-' + uid,
        PathOnClient = 'rtl_proof.pdf',
        VersionData = pdfBlob,
        FirstPublishLocationId = acc.Id
    );
    insert pdfCv;

    System.debug(LoggingLevel.ERROR, 'SUCCESS: PDF generated, ' + pdfBlob.size() + ' bytes');
    System.debug(LoggingLevel.ERROR, 'Account: ' + acc.Id);
    System.debug(LoggingLevel.ERROR, 'Open: /lightning/r/Account/' + acc.Id + '/view');
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'FAIL: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack: ' + e.getStackTraceString());
}
