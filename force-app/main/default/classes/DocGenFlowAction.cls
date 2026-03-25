/**
 * Invocable action for generating a single document from a Flow.
 * Supports PDF, DOCX, PPTX, and XLSX output. Full merge tag support
 * including loops, conditionals, images, barcodes, and aggregates.
 */
public with sharing class DocGenFlowAction {

    public class Request {
        @InvocableVariable(label='Template ID' required=true description='The DocGen Template record ID')
        public Id templateId;

        @InvocableVariable(label='Record ID' required=true description='The source record ID to merge data from')
        public Id recordId;

        @InvocableVariable(label='Save to Record' description='If true, attach the generated file to the source record via ContentDocumentLink. Default: false')
        public Boolean saveToRecord;

        @InvocableVariable(label='Document Title' description='Override the generated file name. Leave blank to use the template default.')
        public String documentTitle;
    }

    public class Response {
        @InvocableVariable(label='Content Document ID')
        public Id contentDocumentId;

        @InvocableVariable(label='Content Version ID')
        public Id contentVersionId;

        @InvocableVariable(label='Error Message')
        public String errorMessage;

        @InvocableVariable(label='Success')
        public Boolean success;
    }

    @InvocableMethod(label='Generate Document' description='Generates a document (PDF, DOCX, PPTX, XLSX) from a DocGen template and record. Supports all merge tags including loops, images, barcodes, QR codes, and aggregates.')
    public static List<Response> generateDocument(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            try {
                Id docId = DocGenService.generateDocument(req.templateId, req.recordId);
                res.contentDocumentId = docId;
                res.success = true;

                // Get the ContentVersion ID for the generated file
                List<ContentVersion> cvs = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docId LIMIT 1];
                if (!cvs.isEmpty()) {
                    res.contentVersionId = cvs[0].Id;
                }

                // Optionally link to the source record
                if (req.saveToRecord == true && docId != null) {
                    ContentDocumentLink link = new ContentDocumentLink(
                        ContentDocumentId = docId,
                        LinkedEntityId = req.recordId,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    );
                    insert link; // NOPMD ApexCRUDViolation - ContentDocumentLink for file attachment
                }
            } catch (Exception e) {
                res.errorMessage = e.getMessage();
                res.success = false;
            }
            responses.add(res);
        }

        return responses;
    }
}