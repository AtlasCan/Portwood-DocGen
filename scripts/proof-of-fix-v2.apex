// =====================================================================
// PROOF-OF-FIX V2: Stress tests — Complex RTL, Page Numbers, Edge Cases
// =====================================================================

List<ContentVersion> proofFiles = new List<ContentVersion>();

// =====================================================================
// PROOF 6 — Complex Hebrew: Tables, Multi-cell, Mixed, Long text
// =====================================================================
DocGenHtmlRenderer.stylesXml =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">' +
    '<w:name w:val="Normal"/><w:qFormat/>' +
    '<w:pPr><w:bidi/></w:pPr>' +
    '</w:style></w:styles>';

String xml6 = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +

    // Title
    '<w:p><w:pPr><w:bidi/><w:jc w:val="right"/></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>Complex RTL Stress Test</w:t></w:r></w:p>' +
    '<w:p/>' +

    // --- SECTION 1: Multi-paragraph Hebrew ---
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="24"/></w:rPr><w:t>Section 1: Multiple Hebrew Paragraphs</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:sz w:val="24"/></w:rPr>' +
    '<w:t>\u05E9\u05DC\u05D5\u05DD \u05DC\u05DB\u05D5\u05DC\u05DD. \u05D6\u05D4\u05D5 \u05DE\u05E1\u05DE\u05DA \u05E8\u05D0\u05E9\u05D5\u05DF \u05E9\u05DC \u05D1\u05D3\u05D9\u05E7\u05D4.</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:sz w:val="24"/></w:rPr>' +
    '<w:t>\u05D6\u05D4\u05D5 \u05DE\u05E1\u05DE\u05DA \u05E9\u05E0\u05D9. \u05D0\u05E0\u05D7\u05E0\u05D5 \u05D1\u05D5\u05D3\u05E7\u05D9\u05DD \u05E9\u05D4\u05E2\u05D1\u05E8\u05D9\u05EA \u05E0\u05DB\u05EA\u05D1\u05EA \u05DE\u05D9\u05DE\u05D9\u05DF \u05DC\u05E9\u05DE\u05D0\u05DC.</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:sz w:val="24"/></w:rPr>' +
    '<w:t>\u05D6\u05D4\u05D5 \u05DE\u05E1\u05DE\u05DA \u05E9\u05DC\u05D9\u05E9\u05D9. \u05D4\u05D8\u05E7\u05E1\u05D8 \u05D4\u05D6\u05D4 \u05D0\u05E8\u05D5\u05DA \u05D9\u05D5\u05EA\u05E8 \u05DB\u05D3\u05D9 \u05DC\u05D1\u05D3\u05D5\u05E7 \u05E9\u05D5\u05E8\u05D5\u05EA \u05D0\u05E8\u05D5\u05DB\u05D5\u05EA.</w:t></w:r></w:p>' +
    '<w:p/>' +

    // --- SECTION 2: Hebrew + English mixed in same paragraph ---
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="24"/></w:rPr><w:t>Section 2: Mixed Hebrew + English Content</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="22"/></w:rPr><w:t>\u05E9\u05DD \u05D4\u05DC\u05E7\u05D5\u05D7: </w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="22"/></w:rPr><w:t>Acme Corporation</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="22"/></w:rPr><w:t>\u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8: </w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="22"/></w:rPr><w:t>James Smith</w:t></w:r>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="22"/></w:rPr><w:t> (\u05DE\u05E0\u05D4\u05DC)</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="22"/></w:rPr><w:t>\u05D0\u05D9\u05DE\u05D9\u05D9\u05DC: </w:t></w:r>' +
    '<w:r><w:rPr><w:sz w:val="22"/></w:rPr><w:t>james@acme.com</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="22"/></w:rPr><w:t>\u05E1\u05DB\u05D5\u05DD: </w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="22"/><w:color w:val="008000"/></w:rPr><w:t>$150,000.00</w:t></w:r></w:p>' +
    '<w:p/>' +

    // --- SECTION 3: Complex RTL Table (Invoice-style) ---
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="24"/></w:rPr><w:t>Section 3: RTL Invoice Table</w:t></w:r></w:p>' +
    '<w:tbl><w:tblPr><w:bidiVisual/><w:tblW w:w="5000" w:type="pct"/><w:tblBorders>' +
    '<w:top w:val="single" w:sz="6" w:color="333333"/>' +
    '<w:bottom w:val="single" w:sz="6" w:color="333333"/>' +
    '<w:left w:val="single" w:sz="6" w:color="333333"/>' +
    '<w:right w:val="single" w:sz="6" w:color="333333"/>' +
    '<w:insideH w:val="single" w:sz="4" w:color="999999"/>' +
    '<w:insideV w:val="single" w:sz="4" w:color="999999"/>' +
    '</w:tblBorders></w:tblPr>' +
    // Header row
    '<w:tr>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:rtl/></w:rPr><w:t>\u05EA\u05D9\u05D0\u05D5\u05E8</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:rtl/></w:rPr><w:t>\u05DB\u05DE\u05D5\u05EA</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:rtl/></w:rPr><w:t>\u05DE\u05D7\u05D9\u05E8</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:rtl/></w:rPr><w:t>\u05E1\u05DB\u05D5\u05DD</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +
    // Data rows — mixed Hebrew product names + English/numbers
    '<w:tr>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/></w:rPr><w:t>\u05E9\u05D9\u05E8\u05D5\u05EA \u05D9\u05D9\u05E2\u05D5\u05E5</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:t>10</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:t>$5,000</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>$50,000</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +
    '<w:tr>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/></w:rPr><w:t>\u05EA\u05DE\u05D9\u05DB\u05D4 \u05E9\u05E0\u05EA\u05D9\u05EA</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:t>5</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:t>$1,000</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>$5,000</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +
    '<w:tr>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/></w:rPr><w:t>\u05D4\u05D8\u05DE\u05E2\u05D4 \u05DE\u05D5\u05EA\u05D0\u05DE\u05EA \u05D0\u05D9\u05E9\u05D9\u05EA</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:t>20</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:t>$2,500</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>$50,000</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +
    // Total row
    '<w:tr>' +
    '<w:tc><w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:rtl/></w:rPr><w:t>\u05E1\u05D4\u05F4\u05DB</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p/></w:tc>' +
    '<w:tc><w:p/></w:tc>' +
    '<w:tc><w:p><w:pPr><w:bidi/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="24"/><w:color w:val="008000"/></w:rPr><w:t>$105,000</w:t></w:r></w:p></w:tc>' +
    '</w:tr>' +
    '</w:tbl>' +
    '<w:p/>' +

    // --- SECTION 4: Arabic paragraph ---
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="24"/></w:rPr><w:t>Section 4: Arabic Content</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:sz w:val="24"/></w:rPr>' +
    '<w:t>\u0628\u0633\u0645 \u0627\u0644\u0644\u0647 \u0627\u0644\u0631\u062D\u0645\u0646 \u0627\u0644\u0631\u062D\u064A\u0645</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:sz w:val="22"/></w:rPr>' +
    '<w:t>\u0647\u0630\u0627 \u0627\u062E\u062A\u0628\u0627\u0631 \u0644\u0644\u063A\u0629 \u0627\u0644\u0639\u0631\u0628\u064A\u0629 \u0641\u064A \u0645\u0633\u062A\u0646\u062F \u0645\u064F\u0646\u0634\u0623 \u0628\u0648\u0627\u0633\u0637\u0629 DocGen.</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="22"/></w:rPr><w:t>\u0627\u0633\u0645 \u0627\u0644\u0634\u0631\u0643\u0629: </w:t></w:r>' +
    '<w:r><w:rPr><w:b/><w:sz w:val="22"/></w:rPr><w:t>Portwood Global Solutions</w:t></w:r></w:p>' +
    '<w:p/>' +

    // --- SECTION 5: Known limitation note ---
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="24"/><w:color w:val="CC0000"/></w:rPr>' +
    '<w:t>Known Limitation</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr>' +
    '<w:t>Long Hebrew/Arabic paragraphs that wrap to multiple lines may have continuation lines starting from the left. This is a Flying Saucer (PDF engine) limitation — it does not implement the Unicode Bidirectional Algorithm.</w:t></w:r></w:p>' +

    '</w:body></w:document>';

String html6 = DocGenHtmlRenderer.convertToHtml(xml6);
Blob pdf6 = Blob.toPdf(html6);
proofFiles.add(new ContentVersion(
    Title = 'PROOF 6 — Complex RTL Hebrew Arabic Tables',
    PathOnClient = 'proof-6-complex-rtl.pdf',
    VersionData = pdf6
));
DocGenHtmlRenderer.stylesXml = null;
System.debug('PROOF 6 generated: ' + pdf6.size() + ' bytes');

// =====================================================================
// PROOF 7 — Dynamic Header/Footer with Page Numbers (CSS counters)
// Tests if Flying Saucer supports counter(page)/counter(pages) in
// running elements. This is NOT currently implemented — this proof
// shows whether the PDF engine even supports it.
// =====================================================================

// Build long content for multiple pages
String longContent = '';
for (Integer i = 1; i <= 80; i++) {
    String color = Math.mod(i, 2) == 0 ? 'F5F5F5' : 'FFFFFF';
    longContent += '<w:p><w:r><w:t>Line item ' + i + ' — Sample content row for testing dynamic page numbering across a multi-page document output.</w:t></w:r></w:p>';
}

// Manually inject CSS page counters into the HTML AFTER conversion
// since the renderer doesn't handle DOCX PAGE fields
String xml7body = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<w:p><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>Issue #9 — Dynamic Page Numbers in Headers/Footers</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>This document tests whether page numbers increment dynamically. Check the header and footer on each page.</w:t></w:r></w:p>' +
    '<w:p/>' +
    longContent +
    '</w:body></w:document>';

// Convert body to HTML, then manually construct full HTML with page counter CSS
String bodyOnly = DocGenHtmlRenderer.convertToHtml(xml7body);

// Now build a custom HTML with CSS page counters in running headers/footers
// This tests Flying Saucer's actual counter(page)/counter(pages) support
String html7 = '<html><head><style>' +
    '@page { size: 8.5in 11in; margin: 1.2in 1in 1.2in 1in; ' +
    '@top-center { content: element(running-header); } ' +
    '@bottom-center { content: element(running-footer); } }' +
    '#running-header { position: running(running-header); font-size: 10pt; font-family: Arial, sans-serif; ' +
    'border-bottom: 2px solid #4472C4; padding-bottom: 4pt; color: #4472C4; font-weight: bold; }' +
    '#running-footer { position: running(running-footer); font-size: 9pt; font-family: Arial, sans-serif; ' +
    'border-top: 1px solid #999; padding-top: 4pt; color: #666; text-align: center; }' +
    'body { font-family: Arial, sans-serif; font-size: 11pt; line-height: 1.15; }' +
    'p { margin: 0 0 8pt 0; }' +
    '</style></head><body>' +
    '<div id="running-header">Portwood DocGen — Proof Document &nbsp;&nbsp;&nbsp; Page <span style="content-placeholder">N</span></div>' +
    '<div id="running-footer">Page <span class="page-num"></span> of <span class="page-total"></span> &mdash; Generated by DocGen</div>' +
    '<h1 style="font-size:18pt;font-weight:bold;">Issue #9 — Dynamic Page Numbers</h1>' +
    '<p>Check header and footer on every page. If page counters work, you will see "Page 1 of X", "Page 2 of X", etc.</p>' +
    '<p>If they do NOT work, you will see blank or static text instead of incrementing numbers.</p><br/>';

// Add 80 lines
for (Integer i = 1; i <= 80; i++) {
    html7 += '<p>Line ' + i + ': Sample content for testing dynamic page numbering across pages.</p>';
}
html7 += '</body></html>';

Blob pdf7 = Blob.toPdf(html7);
proofFiles.add(new ContentVersion(
    Title = 'PROOF 7 — Dynamic Page Numbers Attempt',
    PathOnClient = 'proof-7-page-numbers.pdf',
    VersionData = pdf7
));
System.debug('PROOF 7 generated: ' + pdf7.size() + ' bytes');

// =====================================================================
// PROOF 8 — Page numbers using CSS counter(page) — the right way
// Flying Saucer supports content: "Page " counter(page) " of " counter(pages)
// inside @page margin boxes directly
// =====================================================================
String html8 = '<html><head><style>' +
    '@page { size: 8.5in 11in; margin: 1.2in 1in 1.2in 1in; ' +
    '@top-left { content: "Portwood DocGen"; font-size: 10pt; font-weight: bold; color: #4472C4; } ' +
    '@top-right { content: "Page " counter(page) " of " counter(pages); font-size: 10pt; color: #666; } ' +
    '@bottom-center { content: "Confidential — DocGen Proof Document"; font-size: 8pt; color: #999; } ' +
    '@bottom-right { content: counter(page) " / " counter(pages); font-size: 8pt; color: #999; } }' +
    'body { font-family: Arial, sans-serif; font-size: 11pt; line-height: 1.4; }' +
    'p { margin: 0 0 8pt 0; }' +
    'h1 { font-size: 20pt; margin-bottom: 12pt; }' +
    'h2 { font-size: 14pt; margin-top: 16pt; margin-bottom: 8pt; color: #333; }' +
    '</style></head><body>' +
    '<h1>Dynamic Page Counters — CSS counter(page)</h1>' +
    '<p><b>Look at the top-right corner of each page.</b> You should see "Page 1 of N", "Page 2 of N", etc. incrementing on every page.</p>' +
    '<p>Also check the bottom-right: "1 / N", "2 / N", etc.</p>' +
    '<p>If these numbers are static or missing, then Flying Saucer does not support CSS counters in @page margin boxes.</p>' +
    '<hr/>';

for (Integer i = 1; i <= 100; i++) {
    if (Math.mod(i, 25) == 1) {
        html8 += '<h2>Section — Lines ' + i + ' to ' + Math.min(i + 24, 100) + '</h2>';
    }
    html8 += '<p>' + i + '. Content line for page counter verification. Each page should show a different page number in the header.</p>';
}
html8 += '</body></html>';

Blob pdf8 = Blob.toPdf(html8);
proofFiles.add(new ContentVersion(
    Title = 'PROOF 8 — CSS Page Counters in Margins',
    PathOnClient = 'proof-8-css-page-counters.pdf',
    VersionData = pdf8
));
System.debug('PROOF 8 generated: ' + pdf8.size() + ' bytes');

// =====================================================================
// SAVE ALL
// =====================================================================
insert proofFiles;
System.debug('=== ALL V2 PROOF PDFs SAVED ===');
for (ContentVersion cv : proofFiles) {
    System.debug('  -> ' + cv.Title + ' (' + cv.Id + ')');
}
