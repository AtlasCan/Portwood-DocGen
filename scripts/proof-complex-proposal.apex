// Complex real-world proposal: cover page, tables, mixed styles, headers, footers, page numbers
String h='<?xml version="1.0" encoding="UTF-8"?><w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="16"/><w:color w:val="2E74B5"/></w:rPr><w:t>PORTWOOD GLOBAL</w:t></w:r><w:r><w:rPr><w:sz w:val="16"/><w:color w:val="808080"/></w:rPr><w:t> | Pg </w:t></w:r><w:r><w:rPr><w:b/><w:sz w:val="16"/><w:color w:val="2E74B5"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:rPr><w:b/><w:sz w:val="16"/><w:color w:val="2E74B5"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r><w:r><w:rPr><w:sz w:val="16"/><w:color w:val="808080"/></w:rPr><w:t> of </w:t></w:r><w:r><w:rPr><w:b/><w:sz w:val="16"/><w:color w:val="2E74B5"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText> NUMPAGES </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:rPr><w:b/><w:sz w:val="16"/><w:color w:val="2E74B5"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:hdr>';
String f='<?xml version="1.0" encoding="UTF-8"?><w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:i/><w:sz w:val="14"/><w:color w:val="999999"/></w:rPr><w:t>CONFIDENTIAL — April 2026 — Portwood Global Solutions</w:t></w:r></w:p></w:ftr>';

String b = '';
// Cover page
b += '<w:p><w:pPr><w:spacing w:before="4000"/><w:jc w:val="center"/></w:pPr></w:p>';
b += '<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="52"/><w:color w:val="1F4E79"/></w:rPr><w:t>Enterprise Proposal</w:t></w:r></w:p>';
b += '<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="26"/><w:color w:val="808080"/></w:rPr><w:t>Acme Corporation — April 2026</w:t></w:r></w:p>';
b += '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:color="2E74B5"/></w:pBdr><w:spacing w:before="500"/></w:pPr></w:p>';
b += '<w:p><w:pPr><w:jc w:val="center"/><w:spacing w:before="200"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="18"/></w:rPr><w:t>Contact: </w:t></w:r><w:r><w:rPr><w:sz w:val="18"/><w:color w:val="2E74B5"/></w:rPr><w:t>Dave Moudy — dave@portwoodglobalsolutions.com</w:t></w:r></w:p>';
b += '<w:p><w:r><w:br w:type="page"/></w:r></w:p>';

// Executive Summary
b += '<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:rPr><w:color w:val="1F4E79"/></w:rPr><w:t>1. Executive Summary</w:t></w:r></w:p>';
b += '<w:p><w:r><w:t>We deliver </w:t></w:r><w:r><w:rPr><w:b/></w:rPr><w:t>document automation</w:t></w:r><w:r><w:t> reducing effort by </w:t></w:r><w:r><w:rPr><w:b/><w:color w:val="008000"/><w:sz w:val="24"/></w:rPr><w:t>73%</w:t></w:r><w:r><w:t>.</w:t></w:r></w:p>';
for (String bl : new String[]{'500+ document types from Salesforce data','Zero-code drag-and-drop template builder','PDF, DOCX, and PPTX output formats','RTL language support (Arabic, Hebrew)','10,000+ documents per batch generation'}) {
    b += '<w:p><w:pPr><w:pStyle w:val="ListParagraph"/><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr><w:r><w:t>' + bl + '</w:t></w:r></w:p>';
}
b += '<w:p><w:r><w:br w:type="page"/></w:r></w:p>';

// Pricing table
b += '<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:rPr><w:color w:val="1F4E79"/></w:rPr><w:t>2. Pricing Summary</w:t></w:r></w:p>';
b += '<w:p><w:r><w:t>All prices </w:t></w:r><w:r><w:rPr><w:b/></w:rPr><w:t>USD</w:t></w:r><w:r><w:t>, excluding taxes.</w:t></w:r></w:p>';
b += '<w:tbl><w:tblPr><w:tblW w:w="5000" w:type="pct"/><w:tblBorders><w:top w:val="single" w:sz="8" w:color="1F4E79"/><w:bottom w:val="single" w:sz="8" w:color="1F4E79"/><w:insideH w:val="single" w:sz="4" w:color="DDDDDD"/><w:insideV w:val="single" w:sz="4" w:color="DDDDDD"/></w:tblBorders></w:tblPr>';

// Header row
b += '<w:tr>';
for (String col : new String[]{'Service','Qty','Unit Price','Total'}) {
    String jc2 = (col == 'Qty' ? '<w:jc w:val="center"/>' : (col != 'Service' ? '<w:jc w:val="right"/>' : ''));
    b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="1F4E79"/></w:tcPr><w:p><w:pPr>' + jc2 + '</w:pPr><w:r><w:rPr><w:b/><w:sz w:val="20"/><w:color w:val="FFFFFF"/></w:rPr><w:t>' + col + '</w:t></w:r></w:p></w:tc>';
}
b += '</w:tr>';

// Data rows
for (String[] r : new String[][]{
    new String[]{'DocGen Enterprise License','1','$24,000.00','$24,000.00','F8F9FA'},
    new String[]{'Implementation & Config','40 hrs','$250.00/hr','$10,000.00','FFFFFF'},
    new String[]{'Templates (Complex)','12','$500.00','$6,000.00','F8F9FA'},
    new String[]{'Templates (Standard)','25','$200.00','$5,000.00','FFFFFF'},
    new String[]{'Admin Training (half-day)','2','$1,500.00','$3,000.00','F8F9FA'},
    new String[]{'End User Training (virtual)','4','$750.00','$3,000.00','FFFFFF'},
    new String[]{'Premium Support (12 months)','1','$6,000.00','$6,000.00','F8F9FA'}
}) {
    b += '<w:tr>';
    for (Integer c = 0; c < 4; c++) {
        String al = (c >= 2 ? '<w:jc w:val="right"/>' : (c == 1 ? '<w:jc w:val="center"/>' : ''));
        b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="' + r[4] + '"/></w:tcPr><w:p><w:pPr>' + al + '</w:pPr><w:r><w:rPr><w:sz w:val="19"/></w:rPr><w:t>' + r[c] + '</w:t></w:r></w:p></w:tc>';
    }
    b += '</w:tr>';
}

// Subtotal
b += '<w:tr><w:tc><w:tcPr><w:shd w:val="clear" w:fill="E8EEF4"/></w:tcPr><w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Subtotal</w:t></w:r></w:p></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="E8EEF4"/></w:tcPr><w:p/></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="E8EEF4"/></w:tcPr><w:p/></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="E8EEF4"/></w:tcPr><w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>$57,000.00</w:t></w:r></w:p></w:tc></w:tr>';

// Discount (green)
b += '<w:tr><w:tc><w:tcPr><w:shd w:val="clear" w:fill="E8F5E9"/></w:tcPr><w:p><w:r><w:rPr><w:i/><w:color w:val="2E7D32"/></w:rPr><w:t>Early Signing Discount (15%)</w:t></w:r></w:p></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="E8F5E9"/></w:tcPr><w:p/></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="E8F5E9"/></w:tcPr><w:p/></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="E8F5E9"/></w:tcPr><w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:b/><w:color w:val="2E7D32"/></w:rPr><w:t>-$8,550.00</w:t></w:r></w:p></w:tc></w:tr>';

// Grand total
b += '<w:tr><w:tc><w:tcPr><w:shd w:val="clear" w:fill="1F4E79"/></w:tcPr><w:p><w:r><w:rPr><w:b/><w:sz w:val="24"/><w:color w:val="FFFFFF"/></w:rPr><w:t>TOTAL</w:t></w:r></w:p></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="1F4E79"/></w:tcPr><w:p/></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="1F4E79"/></w:tcPr><w:p/></w:tc>';
b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="1F4E79"/></w:tcPr><w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="26"/><w:color w:val="FFFFFF"/></w:rPr><w:t>$48,450.00</w:t></w:r></w:p></w:tc></w:tr>';
b += '</w:tbl>';

// Terms
b += '<w:p><w:pPr><w:spacing w:before="200"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>Payment Terms: </w:t></w:r><w:r><w:t>Net 30 from signed SOW. </w:t></w:r><w:r><w:rPr><w:i/><w:color w:val="CC0000"/></w:rPr><w:t>This proposal expires May 2, 2026.</w:t></w:r></w:p>';
b += '<w:p><w:r><w:br w:type="page"/></w:r></w:p>';

// Timeline page
b += '<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:rPr><w:color w:val="1F4E79"/></w:rPr><w:t>3. Implementation Timeline</w:t></w:r></w:p>';
b += '<w:tbl><w:tblPr><w:tblW w:w="5000" w:type="pct"/><w:tblBorders><w:top w:val="single" w:sz="4" w:color="2E74B5"/><w:bottom w:val="single" w:sz="4" w:color="2E74B5"/><w:insideH w:val="single" w:sz="4" w:color="D6E4F0"/></w:tblBorders></w:tblPr>';

// Timeline header
b += '<w:tr>';
for (String col : new String[]{'Phase','Duration','Deliverables','Status'}) {
    String jc3 = (col == 'Status' ? '<w:jc w:val="center"/>' : '');
    b += '<w:tc><w:tcPr><w:shd w:val="clear" w:fill="D6E4F0"/></w:tcPr><w:p><w:pPr>' + jc3 + '</w:pPr><w:r><w:rPr><w:b/><w:color w:val="1F4E79"/></w:rPr><w:t>' + col + '</w:t></w:r></w:p></w:tc>';
}
b += '</w:tr>';

for (String[] t : new String[][]{
    new String[]{'Discovery & Requirements','1 week','Requirements doc, field mapping','Complete','008000'},
    new String[]{'Package Installation','1 day','Sandbox + production install','Complete','008000'},
    new String[]{'Template Development','3 weeks','37 templates (12 complex, 25 standard)','In Progress','E68A00'},
    new String[]{'Integration & Testing','2 weeks','UAT signoff, Flow automation','Pending','808080'},
    new String[]{'Training & Go-Live','1 week','Admin + end user training sessions','Pending','808080'},
    new String[]{'Post-Launch Support','4 weeks','Bug fixes, optimization, tweaks','Pending','808080'}
}) {
    b += '<w:tr><w:tc><w:p><w:r><w:rPr><w:b/></w:rPr><w:t>' + t[0] + '</w:t></w:r></w:p></w:tc>';
    b += '<w:tc><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:t>' + t[1] + '</w:t></w:r></w:p></w:tc>';
    b += '<w:tc><w:p><w:r><w:rPr><w:sz w:val="18"/></w:rPr><w:t>' + t[2] + '</w:t></w:r></w:p></w:tc>';
    b += '<w:tc><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:b/><w:color w:val="' + t[4] + '"/></w:rPr><w:t>' + t[3] + '</w:t></w:r></w:p></w:tc></w:tr>';
}
b += '</w:tbl>';

// Next Steps with mixed inline formatting
b += '<w:p><w:pPr><w:spacing w:before="400"/><w:pStyle w:val="Heading2"/></w:pPr><w:r><w:rPr><w:color w:val="2E74B5"/></w:rPr><w:t>Next Steps</w:t></w:r></w:p>';
b += '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>1.</w:t></w:r><w:r><w:t xml:space="preserve"> Review this proposal and the attached </w:t></w:r><w:r><w:rPr><w:b/><w:i/><w:color w:val="2E74B5"/></w:rPr><w:t>Statement of Work</w:t></w:r><w:r><w:t>.</w:t></w:r></w:p>';
b += '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>2.</w:t></w:r><w:r><w:t xml:space="preserve"> Schedule a </w:t></w:r><w:r><w:rPr><w:u w:val="single"/></w:rPr><w:t>30-minute call</w:t></w:r><w:r><w:t> to finalize requirements.</w:t></w:r></w:p>';
b += '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t>3.</w:t></w:r><w:r><w:t xml:space="preserve"> Sign and return SOW by </w:t></w:r><w:r><w:rPr><w:b/><w:color w:val="CC0000"/></w:rPr><w:t>May 2, 2026</w:t></w:r><w:r><w:t> for the early signing discount.</w:t></w:r></w:p>';

// Signature block
b += '<w:p><w:pPr><w:spacing w:before="500"/></w:pPr><w:r><w:rPr><w:color w:val="808080"/></w:rPr><w:t>___________________________          ___________________________</w:t></w:r></w:p>';
b += '<w:p><w:r><w:rPr><w:sz w:val="16"/><w:color w:val="808080"/></w:rPr><w:t>Client Signature / Date                                    Portwood Global / Date</w:t></w:r></w:p>';

// Assemble
String doc = '<!-- DOCGEN_HEADER_START -->' + h + '<!-- DOCGEN_HEADER_END -->' +
    '<!-- DOCGEN_FOOTER_START -->' + f + '<!-- DOCGEN_FOOTER_END -->' +
    '<?xml version="1.0" encoding="UTF-8"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>' + b + '</w:body></w:document>';

String html = DocGenHtmlRenderer.convertToHtml(doc, new Map<String, String>());
Blob pdf = Blob.toPdf(html);
insert new ContentVersion(Title = 'PROOF-Complex-Proposal-AllFixes', PathOnClient = 'proof.pdf', VersionData = pdf);
System.debug('SAVED: ' + pdf.size() + ' bytes — check Files tab in org');
