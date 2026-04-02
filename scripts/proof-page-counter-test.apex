// Quick test: which CSS approach works for page counters in running headers?

// Approach A: content on element directly
String htmlA = '<html><head><style>' +
    '@page { size: 8.5in 11in; margin: 1in 1in 1in 1in; ' +
    '@top-center { content: element(rh); } }' +
    '#rh { position: running(rh); font-size: 10pt; }' +
    '.pn { content: counter(page); }' +
    '.pt { content: counter(pages); }' +
    'body { font-family: Arial, sans-serif; font-size: 11pt; }' +
    'p { margin: 0 0 8pt 0; }' +
    '</style></head><body>' +
    '<div id="rh">Page <span class="pn"></span> of <span class="pt"></span></div>';
for (Integer i = 1; i <= 60; i++) { htmlA += '<p>Line ' + i + ' content for page counter test approach A.</p>'; }
htmlA += '</body></html>';

// Approach B: content on ::after pseudo-element
String htmlB = '<html><head><style>' +
    '@page { size: 8.5in 11in; margin: 1in 1in 1in 1in; ' +
    '@top-center { content: element(rh); } }' +
    '#rh { position: running(rh); font-size: 10pt; }' +
    '.pn::after { content: counter(page); }' +
    '.pt::after { content: counter(pages); }' +
    'body { font-family: Arial, sans-serif; font-size: 11pt; }' +
    'p { margin: 0 0 8pt 0; }' +
    '</style></head><body>' +
    '<div id="rh">Page <span class="pn"></span> of <span class="pt"></span></div>';
for (Integer i = 1; i <= 60; i++) { htmlB += '<p>Line ' + i + ' content for page counter test approach B.</p>'; }
htmlB += '</body></html>';

// Approach C: Use -fs-move-to-flow for page counter directly in @page
// This uses content directly in the margin box alongside element()
String htmlC = '<html><head><style>' +
    '@page { size: 8.5in 11in; margin: 1.2in 1in 1.2in 1in; ' +
    '@top-left { content: element(rh); } ' +
    '@top-right { content: "Page " counter(page) " of " counter(pages); font-size: 10pt; } ' +
    '@bottom-center { content: element(rf); } }' +
    '#rh { position: running(rh); font-size: 10pt; font-weight: bold; color: #4472C4; }' +
    '#rf { position: running(rf); font-size: 9pt; color: #999; text-align: center; }' +
    'body { font-family: Arial, sans-serif; font-size: 11pt; }' +
    'p { margin: 0 0 8pt 0; }' +
    '</style></head><body>' +
    '<div id="rh">Portwood DocGen</div>' +
    '<div id="rf">Confidential Document</div>';
for (Integer i = 1; i <= 60; i++) { htmlC += '<p>Line ' + i + ' content for page counter test approach C.</p>'; }
htmlC += '</body></html>';

List<ContentVersion> cvs = new List<ContentVersion>();
Blob pA = Blob.toPdf(htmlA);
cvs.add(new ContentVersion(Title='PageCounter A — content on element', PathOnClient='counter-a.pdf', VersionData=pA));
System.debug('A: ' + pA.size() + ' bytes');

Blob pB = Blob.toPdf(htmlB);
cvs.add(new ContentVersion(Title='PageCounter B — content on after', PathOnClient='counter-b.pdf', VersionData=pB));
System.debug('B: ' + pB.size() + ' bytes');

Blob pC = Blob.toPdf(htmlC);
cvs.add(new ContentVersion(Title='PageCounter C — split margin boxes', PathOnClient='counter-c.pdf', VersionData=pC));
System.debug('C: ' + pC.size() + ' bytes');

insert cvs;
for (ContentVersion cv : cvs) { System.debug('Saved: ' + cv.Title + ' -> ' + cv.Id); }
