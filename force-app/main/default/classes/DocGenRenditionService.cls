public with sharing class DocGenRenditionService {
    
    public class RenditionException extends Exception {}

    private static List<Id> cvIdsCollector = new List<Id>();

    /**
     * Adds a ContentVersion ID to the collection for later rendition capture.
     */
    public static void addPendingRendition(Id cvId) {
        cvIdsCollector.add(cvId);
    }

    /**
     * Enqueues a single background job for all collected ContentVersion IDs.
     */
    public static void enqueueRenditions() {
        if (cvIdsCollector.isEmpty()) return;
        
        List<DocGen_Rendition_Event__e> events = new List<DocGen_Rendition_Event__e>();
        for (Id cvId : cvIdsCollector) {
            events.add(new DocGen_Rendition_Event__e(Source_CV_Id__c = (String)cvId));
        }
        
        if (!events.isEmpty()) {
            EventBus.publish(events);
        }
        cvIdsCollector.clear();
    }

    /**
     * Attempts to retrieve a PDF rendition for a given ContentVersion ID.
     * Returns a new (unsaved) ContentVersion record containing the PDF data.
     */
    public static ContentVersion capturePdfRendition(Id cvId) {
        ContentVersion cv = [SELECT ContentDocumentId, Title, PathOnClient FROM ContentVersion WHERE Id = :cvId WITH SYSTEM_MODE LIMIT 1];
        String fileId = cv.ContentDocumentId;
        
        // Use a secure Named Credential instead of the Visualforce Session Hack
        // This is the AppExchange-approved architecture for REST API Loopbacks.
        String endpoint = 'callout:DocGen_Loopback/services/data/v65.0/connect/files/' + fileId + '/rendition?type=PDF';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        // The Authorization Bearer header is automatically injected by the Named Credential
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        if (res.getStatusCode() == 200) {
            Blob pdfBlob = res.getBodyAsBlob();
            
            ContentVersion pdfCv = new ContentVersion();
            pdfCv.Title = cv.Title + ' (PDF)';
            pdfCv.PathOnClient = cv.Title + '.pdf';
            pdfCv.VersionData = pdfBlob;
            
            return pdfCv;
        } else if (res.getStatusCode() == 202 || res.getStatusCode() == 404 || res.getStatusCode() == 301 || res.getStatusCode() == 302) {
            throw new RenditionException('Rendition not ready yet (Status: ' + res.getStatusCode() + '). Retrying...');
        } else {
            throw new RenditionException('Failed to capture rendition: ' + res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
        }
    }
}
