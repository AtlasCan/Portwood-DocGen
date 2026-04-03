// ==========================================================================
// FIX SAMPLE TEMPLATES v2: Put {#Section} and {/Section} tags in the
// data row cells so the merge engine's row container expansion kicks in
// ==========================================================================

Integer fixed = 0;
List<portwoodglobal__DocGen_Template__c> tmpls = [
    SELECT Id, Name FROM portwoodglobal__DocGen_Template__c
    WHERE Name LIKE 'Sample:%' ORDER BY Name
];

for (portwoodglobal__DocGen_Template__c tmpl : tmpls) {
    List<portwoodglobal__DocGen_Template_Version__c> vers = [
        SELECT Id, portwoodglobal__Content_Version_Id__c
        FROM portwoodglobal__DocGen_Template_Version__c
        WHERE portwoodglobal__Template__c = :tmpl.Id AND portwoodglobal__Is_Active__c = true LIMIT 1
    ];
    if (vers.isEmpty()) continue;

    ContentVersion cv = [SELECT Id, VersionData, Title, PathOnClient
        FROM ContentVersion WHERE Id = :vers[0].portwoodglobal__Content_Version_Id__c LIMIT 1];

    Compression.ZipReader zr = new Compression.ZipReader(cv.VersionData);
    String docXml = zr.extract('word/document.xml').toString();
    String originalDoc = docXml;

    for (String section : new String[]{'Contacts', 'OpportunityLineItems'}) {
        String openTag = '{#' + section + '}';
        String closeTag = '{/' + section + '}';

        Integer openIdx = docXml.indexOf(openTag);
        Integer closeIdx = docXml.indexOf(closeTag);
        if (openIdx == -1 || closeIdx == -1) continue;

        // Check if there's a <w:tbl> between open and close
        Integer tblStart = docXml.indexOf('<w:tbl>', openIdx);
        if (tblStart == -1 || tblStart > closeIdx) continue;

        // The repeat tags wrap a table — need to move them INTO the data row
        System.debug(LoggingLevel.ERROR, tmpl.Name + ': Fixing ' + section);

        // Step 1: Remove the paragraph containing {#Section}
        Integer openParaStart = docXml.lastIndexOf('<w:p>', openIdx);
        // Handle <w:p> and <w:p ...> variants
        if (openParaStart == -1) openParaStart = docXml.lastIndexOf('<w:p ', openIdx);
        Integer openParaEnd = docXml.indexOf('</w:p>', openIdx) + 6;

        // Step 2: Remove the paragraph containing {/Section}
        Integer closeParaStart = docXml.lastIndexOf('<w:p>', closeIdx);
        if (closeParaStart == -1) closeParaStart = docXml.lastIndexOf('<w:p ', closeIdx);
        Integer closeParaEnd = docXml.indexOf('</w:p>', closeIdx) + 6;

        // Also check for tag rows from previous fix attempt
        // If the tag is inside a <w:tr><w:tc><w:p>..., remove the whole <w:tr>
        Integer openTrStart = docXml.lastIndexOf('<w:tr>', openIdx);
        Integer openTrEnd = docXml.indexOf('</w:tr>', openIdx);
        Boolean openInTagRow = false;
        if (openTrStart != -1 && openTrEnd != -1) {
            String openTrContent = docXml.substring(openTrStart, openTrEnd + 7);
            // If this row ONLY contains the tag (no field merge tags), it's a tag-only row
            if (openTrContent.contains(openTag) && !openTrContent.contains('{FirstName}') && !openTrContent.contains('{Product2')) {
                openParaStart = openTrStart;
                openParaEnd = openTrEnd + 7;
                openInTagRow = true;
            }
        }

        Integer closeTrStart = docXml.lastIndexOf('<w:tr>', closeIdx);
        Integer closeTrEnd = docXml.indexOf('</w:tr>', closeIdx);
        if (closeTrStart != -1 && closeTrEnd != -1) {
            String closeTrContent = docXml.substring(closeTrStart, closeTrEnd + 7);
            if (closeTrContent.contains(closeTag) && !closeTrContent.contains('{FirstName}') && !closeTrContent.contains('{Product2')) {
                closeParaStart = closeTrStart;
                closeParaEnd = closeTrEnd + 7;
            }
        }

        // Remove open and close tag blocks
        // Process close first (higher position) to avoid index shifting
        docXml = docXml.substring(0, closeParaStart) + docXml.substring(closeParaEnd);
        docXml = docXml.substring(0, openParaStart) + docXml.substring(openParaEnd);

        // Now find the table — it should have a header row and a data row
        // Find the data row (second <w:tr>) and inject tags into it
        Integer newTblStart = docXml.indexOf('<w:tbl>', openParaStart);
        if (newTblStart == -1) { System.debug(LoggingLevel.ERROR, 'No table found after removal'); continue; }

        // Find first row (header)
        Integer firstTrStart = docXml.indexOf('<w:tr>', newTblStart);
        if (firstTrStart == -1) firstTrStart = docXml.indexOf('<w:tr ', newTblStart);
        Integer firstTrEnd = docXml.indexOf('</w:tr>', firstTrStart) + 7;

        // Find second row (data row — the one to repeat)
        Integer secondTrStart = docXml.indexOf('<w:tr>', firstTrEnd);
        if (secondTrStart == -1) secondTrStart = docXml.indexOf('<w:tr ', firstTrEnd);
        Integer secondTrEnd = docXml.indexOf('</w:tr>', secondTrStart) + 7;

        if (secondTrStart == -1 || secondTrEnd <= secondTrStart) {
            System.debug(LoggingLevel.ERROR, 'Could not find data row');
            continue;
        }

        String dataRow = docXml.substring(secondTrStart, secondTrEnd);

        // Find the first <w:t> in the data row and prepend {#Section} to its content
        Integer firstWt = dataRow.indexOf('<w:t');
        if (firstWt == -1) continue;
        Integer firstWtClose = dataRow.indexOf('>', firstWt);
        Integer firstWtEnd = dataRow.indexOf('</w:t>', firstWtClose);
        String firstText = dataRow.substring(firstWtClose + 1, firstWtEnd);
        dataRow = dataRow.substring(0, firstWtClose + 1) + openTag + firstText + dataRow.substring(firstWtEnd);

        // Find the LAST <w:t>...</w:t> in the data row and append {/Section}
        Integer lastWtEnd = dataRow.lastIndexOf('</w:t>');
        dataRow = dataRow.substring(0, lastWtEnd) + closeTag + dataRow.substring(lastWtEnd);

        // Replace the data row in the document
        docXml = docXml.substring(0, secondTrStart) + dataRow + docXml.substring(secondTrEnd);
        fixed++;
    }

    if (docXml != originalDoc) {
        Compression.ZipWriter zw = new Compression.ZipWriter();
        for (Compression.ZipEntry ze : zr.getEntries()) {
            String entryName = ze.getName();
            if (entryName == 'word/document.xml') {
                zw.addEntry(entryName, Blob.valueOf(docXml));
            } else {
                zw.addEntry(entryName, zr.extract(entryName));
            }
        }
        Blob newDocx = zw.getArchive();

        ContentVersion newCv = new ContentVersion(
            Title = cv.Title, PathOnClient = cv.PathOnClient,
            VersionData = newDocx, IsMajorVersion = true, FirstPublishLocationId = tmpl.Id
        );
        insert newCv;
        newCv = [SELECT Id FROM ContentVersion WHERE Id = :newCv.Id];

        vers[0].portwoodglobal__Content_Version_Id__c = newCv.Id;
        update vers[0];

        try { DocGenService.extractAndSaveTemplateImages(tmpl.Id, vers[0].Id); } catch (Exception e) {}

        System.debug(LoggingLevel.ERROR, 'FIXED: ' + tmpl.Name + ' CV=' + newCv.Id + ' size=' + newDocx.size());
    } else {
        System.debug(LoggingLevel.ERROR, 'SKIP: ' + tmpl.Name);
    }
}

System.debug(LoggingLevel.ERROR, 'Done — fixed ' + fixed);
