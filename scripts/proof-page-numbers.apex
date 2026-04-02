// =====================================================================
// PROOF: Dynamic page numbers via Word field codes in headers/footers
// Tests both complex fields (fldChar) and simple fields (fldSimple)
// =====================================================================

// Build enough body content for 3-4 pages
String bodyParagraphs = '';
for (Integer i = 1; i <= 80; i++) {
    bodyParagraphs += '<w:p><w:r><w:t>Content line ' + i + ': This is sample body text for testing dynamic page numbering. The header should show "Page X of Y" with incrementing page numbers on every page of this document.</w:t></w:r></w:p>';
}

// Header with complex field codes for PAGE and NUMPAGES
// This is how Word actually stores page numbers in headers:
// "Page [PAGE] of [NUMPAGES]"
String headerXml =
    '<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="4" w:color="4472C4"/></w:pBdr></w:pPr>' +
    // "Portwood DocGen" in bold blue
    '<w:r><w:rPr><w:b/><w:color w:val="4472C4"/></w:rPr><w:t xml:space="preserve">Portwood DocGen    </w:t></w:r>' +
    // "Page " text
    '<w:r><w:rPr><w:color w:val="666666"/></w:rPr><w:t xml:space="preserve">Page </w:t></w:r>' +
    // PAGE field (complex field code)
    '<w:r><w:fldChar w:fldCharType="begin"/></w:r>' +
    '<w:r><w:instrText> PAGE </w:instrText></w:r>' +
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' +
    '<w:r><w:t>1</w:t></w:r>' +
    '<w:r><w:fldChar w:fldCharType="end"/></w:r>' +
    // " of " text
    '<w:r><w:rPr><w:color w:val="666666"/></w:rPr><w:t xml:space="preserve"> of </w:t></w:r>' +
    // NUMPAGES field (complex field code)
    '<w:r><w:fldChar w:fldCharType="begin"/></w:r>' +
    '<w:r><w:instrText> NUMPAGES </w:instrText></w:r>' +
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' +
    '<w:r><w:t>1</w:t></w:r>' +
    '<w:r><w:fldChar w:fldCharType="end"/></w:r>' +
    '</w:p></w:hdr>';

// Footer with fldSimple style for PAGE (alternative Word format)
String footerXml =
    '<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:p><w:pPr><w:jc w:val="center"/><w:pBdr><w:top w:val="single" w:sz="4" w:color="999999"/></w:pBdr></w:pPr>' +
    '<w:r><w:rPr><w:color w:val="999999"/><w:sz w:val="18"/></w:rPr><w:t xml:space="preserve">Confidential — Page </w:t></w:r>' +
    '<w:fldSimple w:instr=" PAGE "><w:r><w:t>1</w:t></w:r></w:fldSimple>' +
    '<w:r><w:rPr><w:color w:val="999999"/><w:sz w:val="18"/></w:rPr><w:t xml:space="preserve"> of </w:t></w:r>' +
    '<w:fldSimple w:instr=" NUMPAGES "><w:r><w:t>1</w:t></w:r></w:fldSimple>' +
    '</w:p></w:ftr>';

String documentXml = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:body>' +
    '<!-- DOCGEN_HEADER_START -->' + headerXml + '<!-- DOCGEN_HEADER_END -->' +
    '<!-- DOCGEN_FOOTER_START -->' + footerXml + '<!-- DOCGEN_FOOTER_END -->' +
    '<w:p><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>Dynamic Page Numbers — Proof of Fix</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>The header should show "Portwood DocGen    Page X of Y" with incrementing numbers.</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>The footer should show "Confidential — Page X of Y" centered, also incrementing.</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t>Both use Word field codes (PAGE/NUMPAGES) — the header uses complex fields (fldChar), the footer uses simple fields (fldSimple).</w:t></w:r></w:p>' +
    '<w:p/>' +
    bodyParagraphs +
    '</w:body></w:document>';

String html = DocGenHtmlRenderer.convertToHtml(documentXml);

// Debug: show the generated HTML header/footer section to verify spans are present
Integer headerDiv = html.indexOf('docgen-header');
if (headerDiv != -1) {
    Integer endDiv = html.indexOf('</div>', headerDiv);
    if (endDiv != -1) {
        System.debug('HEADER HTML: ' + html.substring(headerDiv, Math.min(endDiv + 6, html.length())));
    }
}

Blob pdfBlob = Blob.toPdf(html);
System.debug('PDF generated: ' + pdfBlob.size() + ' bytes');

ContentVersion cv = new ContentVersion(
    Title = 'PROOF 9 — Dynamic Page Numbers in Headers',
    PathOnClient = 'proof-9-page-numbers.pdf',
    VersionData = pdfBlob
);
insert cv;
System.debug('Saved: ' + cv.Id);
