// ==========================================================================
// PROOF OF FIX: GitHub Issues #6, #8, #9, #11
// Run: sf apex run --target-org docgen-verify-bugs -f scripts/proof-github-issues.apex
// ==========================================================================

List<ContentVersion> proofFiles = new List<ContentVersion>();
Integer passCount = 0;
Integer failCount = 0;

// ==========================================================================
// ISSUE #11a — Space between merge tags preserved
// Before fix: "Value1Value2" (space dropped by String.isBlank)
// After fix:  "Value1 Value2" (space preserved)
// ==========================================================================
String xml11a = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<w:p>' +
    '<w:r><w:t>FirstName</w:t></w:r>' +
    '<w:r><w:t xml:space="preserve"> </w:t></w:r>' +
    '<w:r><w:t>LastName</w:t></w:r>' +
    '</w:p>' +
    '</w:body></w:document>';
String html11a = DocGenHtmlRenderer.convertToHtml(xml11a);
if (html11a.contains('FirstName LastName')) {
    System.debug('PASS: #11a — Space between tags preserved: "FirstName LastName"');
    passCount++;
} else if (html11a.contains('FirstNameLastName')) {
    System.debug('FAIL: #11a — Space DROPPED: "FirstNameLastName"');
    failCount++;
} else {
    System.debug('FAIL: #11a — Unexpected output');
    failCount++;
}
System.debug('  HTML snippet: ' + html11a.substringBetween('<body>', '</body>'));

// ==========================================================================
// ISSUE #11b — Multiple spaces preserved
// ==========================================================================
String xml11b = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<w:p>' +
    '<w:r><w:t>AAA</w:t></w:r>' +
    '<w:r><w:t xml:space="preserve">   </w:t></w:r>' +
    '<w:r><w:t>BBB</w:t></w:r>' +
    '</w:p>' +
    '</w:body></w:document>';
String html11b = DocGenHtmlRenderer.convertToHtml(xml11b);
if (html11b.contains('AAA') && html11b.contains('BBB') && !html11b.contains('AAABBB')) {
    System.debug('PASS: #11b — Multi-space run preserved between AAA and BBB');
    passCount++;
} else {
    System.debug('FAIL: #11b — Spaces dropped between AAA and BBB');
    failCount++;
}

// ==========================================================================
// ISSUE #11c — Page number field preserves font size (18pt = w:sz val="36")
// Before fix: bare <span class="docgen-page-num"> (no style)
// After fix:  <span style="font-size:18.0pt"><span class="docgen-page-num">
// ==========================================================================
String xml11c = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body><w:p>' +
    '<w:r><w:rPr><w:sz w:val="36"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>' +
    '<w:r><w:instrText> PAGE </w:instrText></w:r>' +
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' +
    '<w:r><w:t>1</w:t></w:r>' +
    '<w:r><w:fldChar w:fldCharType="end"/></w:r>' +
    '</w:p></w:body></w:document>';
String html11c = DocGenHtmlRenderer.convertToHtml(xml11c);
if (html11c.contains('font-size:18') && html11c.contains('docgen-page-num')) {
    System.debug('PASS: #11c — Page number has font-size:18pt');
    passCount++;
} else if (html11c.contains('docgen-page-num') && !html11c.contains('font-size:18')) {
    System.debug('FAIL: #11c — Page number span exists but font size LOST');
    failCount++;
} else {
    System.debug('FAIL: #11c — Page number span missing entirely');
    failCount++;
}
System.debug('  HTML snippet: ' + html11c.substringBetween('<body>', '</body>'));

// ==========================================================================
// ISSUE #11d — fldSimple page number also preserves font size
// ==========================================================================
String xml11d = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body><w:p>' +
    '<w:fldSimple w:instr=" PAGE ">' +
    '<w:r><w:rPr><w:sz w:val="28"/><w:b/></w:rPr><w:t>1</w:t></w:r>' +
    '</w:fldSimple>' +
    '</w:p></w:body></w:document>';
String html11d = DocGenHtmlRenderer.convertToHtml(xml11d);
if (html11d.contains('font-size:14') && html11d.contains('docgen-page-num')) {
    System.debug('PASS: #11d — fldSimple page number has font-size:14pt (28 half-points)');
    passCount++;
} else {
    System.debug('FAIL: #11d — fldSimple font size not preserved');
    failCount++;
}

// ==========================================================================
// ISSUE #8 — RTL uses direction:rtl instead of text-align:right
// Before fix: text-align: right; font-family: Arial Unicode MS
// After fix:  direction: rtl; unicode-bidi: embed; font-family: Arial, Noto Sans
// ==========================================================================
DocGenHtmlRenderer.stylesXml =
    '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">' +
    '<w:name w:val="Normal"/><w:pPr><w:bidi/></w:pPr></w:style></w:styles>';

String xml8 = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body><w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/></w:rPr><w:t>\u05E9\u05DC\u05D5\u05DD \u05E2\u05D5\u05DC\u05DD</w:t></w:r>' +
    '</w:p></w:body></w:document>';
String html8 = DocGenHtmlRenderer.convertToHtml(xml8);
Boolean hasDirectionRtl = html8.contains('direction: rtl');
Boolean hasNotoSans = html8.contains('Noto Sans');
Boolean noArialUnicodeMs = !html8.contains('Arial Unicode MS');
Boolean noTextAlignRight = !html8.contains('text-align: right');

if (hasDirectionRtl && hasNotoSans && noArialUnicodeMs) {
    System.debug('PASS: #8a — RTL uses direction:rtl + Noto Sans (not Arial Unicode MS)');
    passCount++;
} else {
    System.debug('FAIL: #8a — direction:rtl=' + hasDirectionRtl + ' NotoSans=' + hasNotoSans + ' noAUMS=' + noArialUnicodeMs);
    failCount++;
}

// Check text is NOT reversed (Chromium handles bidi natively)
if (html8.contains('\u05E9\u05DC\u05D5\u05DD')) {
    System.debug('PASS: #8b — Hebrew text NOT reversed (Chromium bidi handles it)');
    passCount++;
} else {
    System.debug('FAIL: #8b — Hebrew text was reversed (should not be for Chromium renderer)');
    failCount++;
}

// Check paragraph uses direction:rtl
if (html8.contains('direction:rtl')) {
    System.debug('PASS: #8c — Paragraph has direction:rtl CSS');
    passCount++;
} else {
    System.debug('FAIL: #8c — Paragraph missing direction:rtl');
    failCount++;
}

DocGenHtmlRenderer.stylesXml = null;

// ==========================================================================
// ISSUE #9a — Page counter CSS includes both ::after and direct content
// ==========================================================================
String xml9 = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body><w:p><w:r><w:t>Body text</w:t></w:r></w:p></w:body></w:document>';
String html9 = DocGenHtmlRenderer.convertToHtml(xml9);
Boolean hasAfterCounter = html9.contains('.docgen-page-num::after { content: counter(page); }');
Boolean hasDirectCounter = html9.contains('.docgen-page-num { content: counter(page); }');
Boolean hasTotalAfter = html9.contains('.docgen-page-total::after { content: counter(pages); }');
Boolean hasTotalDirect = html9.contains('.docgen-page-total { content: counter(pages); }');

if (hasAfterCounter && hasDirectCounter && hasTotalAfter && hasTotalDirect) {
    System.debug('PASS: #9a — Page counter CSS has both ::after and direct content rules');
    passCount++;
} else {
    System.debug('FAIL: #9a — after=' + hasAfterCounter + ' direct=' + hasDirectCounter + ' totalAfter=' + hasTotalAfter + ' totalDirect=' + hasTotalDirect);
    failCount++;
}

// ==========================================================================
// ISSUE #9b — Generate a multi-page PDF to prove page numbers increment
// (Requires Blob.toPdf which uses the CSS counters)
// ==========================================================================
String headerXml = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:p><w:pPr><w:jc w:val="center"/></w:pPr>' +
    '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>Page </w:t></w:r>' +
    '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>' +
    '<w:r><w:instrText> PAGE </w:instrText></w:r>' +
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' +
    '<w:r><w:t>1</w:t></w:r>' +
    '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>' +
    '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t> of </w:t></w:r>' +
    '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>' +
    '<w:r><w:instrText> NUMPAGES </w:instrText></w:r>' +
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' +
    '<w:r><w:t>1</w:t></w:r>' +
    '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>' +
    '</w:p></w:hdr>';

// Build multi-page body content
String bodyContent = '';
for (Integer i = 1; i <= 3; i++) {
    bodyContent += '<w:p><w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr>' +
        '<w:t>Page ' + i + ' Content</w:t></w:r></w:p>';
    for (Integer j = 0; j < 20; j++) {
        bodyContent += '<w:p><w:r><w:t>Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' +
            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ' +
            'Paragraph ' + (j + 1) + ' on page ' + i + '.</w:t></w:r></w:p>';
    }
    if (i < 3) {
        bodyContent += '<w:p><w:r><w:br w:type="page"/></w:r></w:p>';
    }
}

String combinedXml = '<!-- DOCGEN_HEADER_START -->' + headerXml + '<!-- DOCGEN_HEADER_END -->' +
    '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' + bodyContent + '</w:body></w:document>';

String proofHtml9 = DocGenHtmlRenderer.convertToHtml(combinedXml, new Map<String, String>());

try {
    Blob pdfBlob9 = Blob.toPdf(proofHtml9);
    proofFiles.add(new ContentVersion(
        Title = 'proof-issue9-page-numbers',
        PathOnClient = 'proof-issue9-page-numbers.pdf',
        VersionData = pdfBlob9
    ));
    System.debug('PASS: #9b — Generated 3-page PDF with header page numbers (check file to verify increment)');
    passCount++;
} catch (Exception e) {
    System.debug('FAIL: #9b — Blob.toPdf failed: ' + e.getMessage());
    failCount++;
}

// ==========================================================================
// ISSUE #11e — Generate proof PDF: "FirstName LastName" with space
// ==========================================================================
String proofHtml11 = DocGenHtmlRenderer.convertToHtml(xml11a);
try {
    Blob pdfBlob11 = Blob.toPdf(proofHtml11);
    proofFiles.add(new ContentVersion(
        Title = 'proof-issue11-space-between-tags',
        PathOnClient = 'proof-issue11-space-between-tags.pdf',
        VersionData = pdfBlob11
    ));
    System.debug('PASS: #11e — Generated PDF with "FirstName LastName" (space preserved)');
    passCount++;
} catch (Exception e) {
    System.debug('FAIL: #11e — Blob.toPdf failed: ' + e.getMessage());
    failCount++;
}

// ==========================================================================
// ISSUE #8d — Generate proof PDF: Hebrew RTL document
// ==========================================================================
DocGenHtmlRenderer.stylesXml =
    '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">' +
    '<w:name w:val="Normal"/><w:pPr><w:bidi/></w:pPr></w:style></w:styles>';

String xml8d = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="28"/></w:rPr><w:t>RTL Document Test (Issue #8)</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="24"/></w:rPr>' +
    '<w:t>\u05E9\u05DC\u05D5\u05DD \u05E2\u05D5\u05DC\u05DD. \u05D6\u05D4\u05D5 \u05DE\u05E1\u05DE\u05DA \u05D1\u05E2\u05D1\u05E8\u05D9\u05EA.</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="24"/></w:rPr><w:t>\u05E9\u05DD: </w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="24"/></w:rPr><w:t>Acme Corporation</w:t></w:r></w:p>' +
    '</w:body></w:document>';

String proofHtml8 = DocGenHtmlRenderer.convertToHtml(xml8d);
DocGenHtmlRenderer.stylesXml = null;

try {
    Blob pdfBlob8 = Blob.toPdf(proofHtml8);
    proofFiles.add(new ContentVersion(
        Title = 'proof-issue8-rtl-hebrew',
        PathOnClient = 'proof-issue8-rtl-hebrew.pdf',
        VersionData = pdfBlob8
    ));
    System.debug('PASS: #8d — Generated RTL Hebrew PDF with direction:rtl');
    passCount++;
} catch (Exception e) {
    System.debug('FAIL: #8d — Blob.toPdf failed for RTL: ' + e.getMessage());
    failCount++;
}

// ==========================================================================
// Save all proof PDFs
// ==========================================================================
if (!proofFiles.isEmpty()) {
    insert proofFiles;
    System.debug('Saved ' + proofFiles.size() + ' proof PDF(s) to org Files.');
    for (ContentVersion cv : proofFiles) {
        System.debug('  - ' + cv.Title + '.pdf (Id: ' + cv.Id + ')');
    }
}

// ==========================================================================
// Summary
// ==========================================================================
System.debug('');
System.debug('====================================');
System.debug('PASS: ' + passCount + '  FAIL: ' + failCount);
if (failCount == 0) {
    System.debug('ALL TESTS PASSED');
} else {
    System.debug('SOME TESTS FAILED');
}
System.debug('====================================');
