public without sharing class DocGenSignatureService {

    public class SignatureException extends Exception {}

    /**
     * Injects a Base64 PNG image into an existing DOCX ContentVersion
     * @param sourceCvId The ContentVersion ID of the original unsigned document
     * @param base64Image The Base64 encoded PNG data of the signature
     * @param requestNumber The Signature Request Number (used for relationship IDs to ensure uniqueness)
     * @return The ContentVersion ID of the newly generated Signed DOCX
     */
    public static Id stampSignature(Id sourceCvId, String base64Image, String requestNumber, String relatedRecordId) {
        ContentVersion cv = [SELECT Id, VersionData, Title, FirstPublishLocationId FROM ContentVersion WHERE Id = :sourceCvId WITH SYSTEM_MODE LIMIT 1];
        if (cv == null || cv.VersionData == null) {
            throw new SignatureException('Source document not found or has no content.');
        }

        Blob docxBlob = cv.VersionData;
        Blob signatureBlob = EncodingUtil.base64Decode(base64Image);
        
        Compression.ZipReader reader = new Compression.ZipReader(docxBlob);
        Compression.ZipWriter writer = new Compression.ZipWriter();

        Boolean isSignatureInjected = false;
        String imageRelId = 'rIdSig' + String.valueOf(System.currentTimeMillis()).substring(8);
        String imageFileName = 'signature_' + imageRelId + '.png';

        for (Compression.ZipEntry entry : reader.getEntries()) {
            String name = entry.getName();
            
            if (name == '[Content_Types].xml') {
                // Ensure .png is registered
                String contentTypes = reader.extract(name).toString();
                if (!contentTypes.contains('Extension="png"')) {
                    contentTypes = contentTypes.replace('</Types>', '<Default Extension="png" ContentType="image/png"/></Types>');
                }
                writer.addEntry(name, Blob.valueOf(contentTypes));

            } else if (name == 'word/_rels/document.xml.rels') {
                // Add the image relationship
                String rels = reader.extract(name).toString();
                String newRel = '<Relationship Id="' + imageRelId + '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/' + imageFileName + '"/>';
                rels = rels.replace('</Relationships>', newRel + '</Relationships>');
                writer.addEntry(name, Blob.valueOf(rels));

            } else if (name == 'word/document.xml') {
                // Inject the drawing XML
                String docXml = reader.extract(name).toString();
                
                // Define the OpenXML Drawing structure
                // Approximate 200x50 pixels -> EMUs: 200 * 9525 = 1905000, 50 * 9525 = 476250
                String drawingXml = 
                    '<w:r><w:drawing>' +
                      '<wp:inline distT="0" distB="0" distL="0" distR="0">' +
                        '<wp:extent cx="1905000" cy="476250"/>' +
                        '<wp:effectExtent l="0" t="0" r="0" b="0"/>' +
                        '<wp:docPr id="888" name="Signature"/>' +
                        '<wp:cNvGraphicFramePr><a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/></wp:cNvGraphicFramePr>' +
                        '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
                          '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                            '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                              '<pic:nvPicPr><pic:cNvPr id="0" name="Signature"/><pic:cNvPicPr/></pic:nvPicPr>' +
                              '<pic:blipFill>' +
                                '<a:blip r:embed="' + imageRelId + '"/>' +
                                '<a:stretch><a:fillRect/></a:stretch>' +
                              '</pic:blipFill>' +
                              '<pic:spPr>' +
                                '<a:xfrm><a:off x="0" y="0"/><a:ext cx="1905000" cy="476250"/></a:xfrm>' +
                                '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom>' +
                              '</pic:spPr>' +
                            '</pic:pic>' +
                          '</a:graphicData>' +
                        '</a:graphic>' +
                      '</wp:inline>' +
                    '</w:drawing></w:r>';

                // Replace the tag or just append if tag missing? We assume tag {#Signature} exists.
                // It might be split across runs like {</w:t></w:r><w:r><w:t>#Signature</w:t></w:r><w:r><w:t>} 
                // Because DocGenService cleaned up most of it, we will just do a simple replacement.
                // If simple replace fails, we inject at the end.
                if (docXml.contains('{#Signature}')) {
                    // Properly close the text run, inject drawing, and reopen
                    String replacement = '</w:t></w:r>' + drawingXml + '<w:r><w:t xml:space="preserve">';
                    docXml = docXml.replace('{#Signature}', replacement);
                    isSignatureInjected = true;
                } else {
                    // Fallback to inserting at the bottom of the document
                    String fallback = '<w:p><w:r><w:t xml:space="preserve">Signature: </w:t></w:r>' + drawingXml + '</w:p>';
                    docXml = docXml.replace('</w:body>', fallback + '</w:body>');
                }

                writer.addEntry(name, Blob.valueOf(docXml));
            } else {
                // Copy all other files exactly as they are
                writer.addEntry(name, reader.extract(name));
            }
        }

        // Add the new image file to the media directory inside the ZIP
        writer.addEntry('word/media/' + imageFileName, signatureBlob);

        Blob resultBlob = writer.getArchive();

        // Save new Signed Document
        ContentVersion newCv = new ContentVersion();
        newCv.Title = cv.Title + ' - Signed';
        newCv.PathOnClient = newCv.Title + '.docx';
        newCv.VersionData = resultBlob;
        newCv.IsMajorVersion = true;
        // DO NOT set FirstPublishLocationId. Let System Context default it.
        insert newCv;
        
        // Find the newly generated ContentDocumentId
        Id newDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newCv.Id].ContentDocumentId;
        
        // Explicitly Link to the original Record so it shows up in the UI
        if (String.isNotBlank(relatedRecordId)) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = newDocId;
            cdl.LinkedEntityId = relatedRecordId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl; // System Mode inserts ignoring standard Guest User limits
        }

        return newCv.Id;
    }
    /**
     * @description Privileged entry point called by the Platform Event trigger.
     * Performs signature stamping and audit creation in Automated Process context.
     */
    public static void handleSignatureSubmission(String token, String base64Image) {
        List<DocGen_Signature_Request__c> requests = [
            SELECT Id, Status__c, Signer_Name__c, Source_Document_Id__c, Related_Record_Id__c
            FROM DocGen_Signature_Request__c
            WHERE Secure_Token__c = :token
            WITH SYSTEM_MODE
            LIMIT 1
        ];

        if (requests.isEmpty() || requests[0].Status__c == 'Signed' || requests[0].Status__c == 'Cancelled') {
            return; // Already processed or invalid
        }

        DocGen_Signature_Request__c req = requests[0];

        try {
            // 1. Inject the Signature into the DOCX
            Id signedCvId = stampSignature(req.Source_Document_Id__c, base64Image, req.Id, req.Related_Record_Id__c);

            // 2. Mark the exact SHA-256 Hash as pending the final PDF generation
            String fileHash = 'PENDING_RENDITION:' + signedCvId;

            // 3. Generate Audit Trail Record
            DocGen_Signature_Audit__c audit = new DocGen_Signature_Audit__c();
            audit.Signature_Request__c = req.Id;
            audit.Signed_Date__c = System.now();
            audit.Document_Hash_SHA256__c = fileHash;
            audit.IP_Address__c = 'Captured via Async Submission'; 
            audit.User_Agent__c = 'Automated Process Handler';
            insert audit;

            // 4. Mark Request as Signed
            req.Status__c = 'Signed';
            update req;

            // 5. Trigger PDF Rendition of the specific signed document
            DocGenRenditionService.addPendingRendition(signedCvId);
            DocGenRenditionService.enqueueRenditions();

        } catch (Exception e) {
            System.debug('Error in privileged signature handling: ' + e.getMessage());
        }
    }
}
