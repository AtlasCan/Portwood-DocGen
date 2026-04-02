// =====================================================================
// PROOF-OF-FIX: Visual evidence that bug fixes work
// Generates real PDFs exercising each reported bug, saves as Files
// Open the scratch org and check "Files" to download and inspect each.
// =====================================================================

List<ContentVersion> proofFiles = new List<ContentVersion>();

// =====================================================================
// PROOF 1 — Issue #5: Ampersands render as & (not &amp;)
// =====================================================================
String xml1 = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>Issue #5 — Ampersand Rendering</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>If this bug is fixed, the ampersands below render as &amp; not &amp;amp;</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Test cases:</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>1. AT&amp;T Corporation</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>2. Johnson &amp; Johnson</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>3. Procter &amp; Gamble</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>4. Ben &amp; Jerry&apos;s Ice Cream</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>5. R&amp;D Department — Q1 &amp; Q2 Results</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>6. Terms &amp; Conditions: &lt;section 4.2&gt;</w:t></w:r></w:p>' +
    '<w:p/>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>EXPECTED: Each &amp; above should display as a single ampersand character.</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>BUG BEHAVIOR: Would show &amp;amp; (literal text) instead.</w:t></w:r></w:p>' +
    '</w:body></w:document>';

String html1 = DocGenHtmlRenderer.convertToHtml(xml1);
Blob pdf1 = Blob.toPdf(html1);
proofFiles.add(new ContentVersion(
    Title = 'PROOF 1 — Issue 5 — Ampersand Rendering',
    PathOnClient = 'proof-1-ampersand.pdf',
    VersionData = pdf1
));
System.debug('PROOF 1 generated: ' + pdf1.size() + ' bytes');

// =====================================================================
// PROOF 2 — Issue #9a: Numbered Lists (not bullets)
// =====================================================================
DocGenHtmlRenderer.numberingXml =
    '<w:numbering xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:abstractNum w:abstractNumId="0"><w:lvl w:ilvl="0"><w:numFmt w:val="bullet"/></w:lvl></w:abstractNum>' +
    '<w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num>' +
    '<w:abstractNum w:abstractNumId="1"><w:lvl w:ilvl="0"><w:numFmt w:val="decimal"/></w:lvl></w:abstractNum>' +
    '<w:num w:numId="2"><w:abstractNumId w:val="1"/></w:num>' +
    '<w:abstractNum w:abstractNumId="2"><w:lvl w:ilvl="0"><w:numFmt w:val="upperRoman"/></w:lvl></w:abstractNum>' +
    '<w:num w:numId="3"><w:abstractNumId w:val="2"/></w:num>' +
    '</w:numbering>';

String xml2 = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>Issue #9b — Numbered Lists</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>If this bug is fixed, numbered lists render as 1. 2. 3. (not bullet points).</w:t></w:r></w:p>' +
    '<w:p/>' +
    '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Bullet List (should be bullets):</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr><w:r><w:t>Unordered item A</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr><w:r><w:t>Unordered item B</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr><w:r><w:t>Unordered item C</w:t></w:r></w:p>' +
    '<w:p/>' +
    '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Numbered List (should be 1. 2. 3.):</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="2"/></w:numPr></w:pPr><w:r><w:t>First numbered step</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="2"/></w:numPr></w:pPr><w:r><w:t>Second numbered step</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="2"/></w:numPr></w:pPr><w:r><w:t>Third numbered step</w:t></w:r></w:p>' +
    '<w:p/>' +
    '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Roman Numeral List (should be I. II. III.):</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="3"/></w:numPr></w:pPr><w:r><w:t>Roman item alpha</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="3"/></w:numPr></w:pPr><w:r><w:t>Roman item beta</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="3"/></w:numPr></w:pPr><w:r><w:t>Roman item gamma</w:t></w:r></w:p>' +
    '<w:p/>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>EXPECTED: Bullets = dots, Numbered = 1/2/3, Roman = I/II/III</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>BUG BEHAVIOR: All three would render as bullet points.</w:t></w:r></w:p>' +
    '</w:body></w:document>';

String html2 = DocGenHtmlRenderer.convertToHtml(xml2);
Blob pdf2 = Blob.toPdf(html2);
proofFiles.add(new ContentVersion(
    Title = 'PROOF 2 — Issue 9b — Numbered Lists',
    PathOnClient = 'proof-2-numbered-lists.pdf',
    VersionData = pdf2
));
DocGenHtmlRenderer.numberingXml = null;
System.debug('PROOF 2 generated: ' + pdf2.size() + ' bytes');

// =====================================================================
// PROOF 3 — Issue #9c: Theme Colors
// =====================================================================
String xml3 = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>Issue #9c — Theme Colors</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>If this bug is fixed, each line below appears in the correct color.</w:t></w:r></w:p>' +
    '<w:p/>' +
    // Direct hex color (always worked)
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="FF0000"/></w:rPr><w:t>Direct Red (#FF0000) — always worked</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="0000FF"/></w:rPr><w:t>Direct Blue (#0000FF) — always worked</w:t></w:r></w:p>' +
    '<w:p/>' +
    // Theme colors (the bug — these showed as black before the fix)
    '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Theme colors (were broken — showed as black):</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="auto" w:themeColor="accent1"/></w:rPr><w:t>Theme Accent 1 — should be BLUE (#4472C4)</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="auto" w:themeColor="accent2"/></w:rPr><w:t>Theme Accent 2 — should be ORANGE (#ED7D31)</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="auto" w:themeColor="accent3"/></w:rPr><w:t>Theme Accent 3 — should be GRAY (#A5A5A5)</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="auto" w:themeColor="accent4"/></w:rPr><w:t>Theme Accent 4 — should be GOLD (#FFC000)</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="auto" w:themeColor="accent5"/></w:rPr><w:t>Theme Accent 5 — should be TEAL (#5B9BD5)</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="auto" w:themeColor="accent6"/></w:rPr><w:t>Theme Accent 6 — should be GREEN (#70AD47)</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:b/><w:color w:val="auto" w:themeColor="hyperlink"/></w:rPr><w:t>Theme Hyperlink — should be LINK BLUE (#0563C1)</w:t></w:r></w:p>' +
    '<w:p/>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>EXPECTED: Each line is its labeled color.</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>BUG BEHAVIOR: Theme color lines would all be black.</w:t></w:r></w:p>' +
    '</w:body></w:document>';

String html3 = DocGenHtmlRenderer.convertToHtml(xml3);
Blob pdf3 = Blob.toPdf(html3);
proofFiles.add(new ContentVersion(
    Title = 'PROOF 3 — Issue 9c — Theme Colors',
    PathOnClient = 'proof-3-theme-colors.pdf',
    VersionData = pdf3
));
System.debug('PROOF 3 generated: ' + pdf3.size() + ' bytes');

// =====================================================================
// PROOF 4 — Issue #8: RTL Arabic/Hebrew Text
// =====================================================================
DocGenHtmlRenderer.stylesXml =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">' +
    '<w:name w:val="Normal"/><w:qFormat/>' +
    '<w:pPr><w:bidi/></w:pPr>' +
    '</w:style></w:styles>';

String xml4 = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<w:p><w:pPr><w:bidi/><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>Issue #8 — RTL Text Rendering</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:t>If this bug is fixed, Hebrew and Arabic text renders correctly (not blank).</w:t></w:r></w:p>' +
    '<w:p/>' +
    // Hebrew text
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>Hebrew:</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:rFonts w:cs="David"/><w:sz w:val="28"/></w:rPr>' +
    '<w:t>\u05E9\u05DC\u05D5\u05DD \u05E2\u05D5\u05DC\u05DD</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:sz w:val="28"/></w:rPr>' +
    '<w:t>\u05D1\u05E8\u05D5\u05DA \u05D4\u05D1\u05D0 \u05DC\u05E9\u05DC\u05D5\u05DD</w:t></w:r></w:p>' +
    '<w:p/>' +
    // Arabic text
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>Arabic:</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:sz w:val="28"/></w:rPr>' +
    '<w:t>\u0645\u0631\u062D\u0628\u0627 \u0628\u0627\u0644\u0639\u0627\u0644\u0645</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:rtl/><w:sz w:val="28"/></w:rPr>' +
    '<w:t>\u0627\u0644\u0633\u0644\u0627\u0645 \u0639\u0644\u064A\u0643\u0645</w:t></w:r></w:p>' +
    '<w:p/>' +
    // Mixed content
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>Mixed (Hebrew + English):</w:t></w:r></w:p>' +
    '<w:p><w:pPr><w:bidi/></w:pPr>' +
    '<w:r><w:rPr><w:rtl/><w:sz w:val="28"/></w:rPr><w:t>\u05E9\u05DD: </w:t></w:r>' +
    '<w:r><w:rPr><w:sz w:val="28"/></w:rPr><w:t>James Smith</w:t></w:r></w:p>' +
    '<w:p/>' +
    // RTL Table
    '<w:p><w:pPr><w:bidi/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>RTL Table (columns should be right-to-left):</w:t></w:r></w:p>' +
    '<w:tbl><w:tblPr><w:bidiVisual/><w:tblW w:w="5000" w:type="pct"/><w:tblBorders>' +
    '<w:top w:val="single" w:sz="4" w:color="000000"/>' +
    '<w:bottom w:val="single" w:sz="4" w:color="000000"/>' +
    '<w:left w:val="single" w:sz="4" w:color="000000"/>' +
    '<w:right w:val="single" w:sz="4" w:color="000000"/>' +
    '<w:insideH w:val="single" w:sz="4" w:color="000000"/>' +
    '<w:insideV w:val="single" w:sz="4" w:color="000000"/>' +
    '</w:tblBorders></w:tblPr>' +
    '<w:tr>' +
    '<w:tc><w:p><w:r><w:rPr><w:rtl/></w:rPr><w:t>\u05E2\u05DE\u05D5\u05D3\u05D4 1</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:r><w:rPr><w:rtl/></w:rPr><w:t>\u05E2\u05DE\u05D5\u05D3\u05D4 2</w:t></w:r></w:p></w:tc>' +
    '<w:tc><w:p><w:r><w:rPr><w:rtl/></w:rPr><w:t>\u05E2\u05DE\u05D5\u05D3\u05D4 3</w:t></w:r></w:p></w:tc>' +
    '</w:tr></w:tbl>' +
    '<w:p/>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>EXPECTED: Hebrew and Arabic glyphs visible, right-aligned, table columns RTL.</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>BUG BEHAVIOR: All non-Latin text would be blank/invisible.</w:t></w:r></w:p>' +
    '</w:body></w:document>';

String html4 = DocGenHtmlRenderer.convertToHtml(xml4);
Blob pdf4 = Blob.toPdf(html4);
proofFiles.add(new ContentVersion(
    Title = 'PROOF 4 — Issue 8 — RTL Arabic Hebrew',
    PathOnClient = 'proof-4-rtl-arabic-hebrew.pdf',
    VersionData = pdf4
));
DocGenHtmlRenderer.stylesXml = null;
System.debug('PROOF 4 generated: ' + pdf4.size() + ' bytes');

// =====================================================================
// PROOF 5 — Issue #9a: Headers/Footers on EVERY page
// =====================================================================
// Build enough content to force multiple pages
String longContent = '';
for (Integer i = 1; i <= 60; i++) {
    longContent += '<w:p><w:r><w:t>Paragraph ' + i + ': This line exists to push content onto multiple pages so we can verify headers and footers repeat on every single page of the document.</w:t></w:r></w:p>';
}

String xml5 = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<!-- DOCGEN_HEADER_START -->' +
    '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="4" w:color="4472C4"/></w:pBdr></w:pPr>' +
    '<w:r><w:rPr><w:b/><w:color w:val="4472C4"/></w:rPr><w:t>PORTWOOD GLOBAL — DocGen Proof Document</w:t></w:r></w:p>' +
    '<!-- DOCGEN_HEADER_END -->' +
    '<!-- DOCGEN_FOOTER_START -->' +
    '<w:p><w:pPr><w:jc w:val="center"/><w:pBdr><w:top w:val="single" w:sz="4" w:color="999999"/></w:pBdr></w:pPr>' +
    '<w:r><w:rPr><w:color w:val="999999"/><w:sz w:val="18"/></w:rPr><w:t>Confidential — Issue #9a Header/Footer Proof</w:t></w:r></w:p>' +
    '<!-- DOCGEN_FOOTER_END -->' +
    '<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>Issue #9a — Headers &amp; Footers on Every Page</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>If this bug is fixed, scroll through all pages — the blue header and gray footer should appear on EVERY page, not just the first.</w:t></w:r></w:p>' +
    '<w:p/>' +
    longContent +
    '<w:p/>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>EXPECTED: Header and footer on every page.</w:t></w:r></w:p>' +
    '<w:p><w:r><w:rPr><w:i/><w:color w:val="666666"/></w:rPr><w:t>BUG BEHAVIOR: Header/footer only on page 1.</w:t></w:r></w:p>' +
    '</w:body></w:document>';

String html5 = DocGenHtmlRenderer.convertToHtml(xml5);
Blob pdf5 = Blob.toPdf(html5);
proofFiles.add(new ContentVersion(
    Title = 'PROOF 5 — Issue 9a — Headers on Every Page',
    PathOnClient = 'proof-5-headers-every-page.pdf',
    VersionData = pdf5
));
System.debug('PROOF 5 generated: ' + pdf5.size() + ' bytes');

// =====================================================================
// SAVE ALL PROOF FILES
// =====================================================================
insert proofFiles;
System.debug('=== ALL 5 PROOF PDFs SAVED TO FILES ===');
System.debug('Open the scratch org and go to Files tab to download and inspect each one.');

for (ContentVersion cv : proofFiles) {
    System.debug('  → ' + cv.Title + ' (' + cv.Id + ')');
}
