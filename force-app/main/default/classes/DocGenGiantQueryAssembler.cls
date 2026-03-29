/**
 * Queueable that progressively assembles Giant Query PDF fragments.
 * Chains to itself, each pass loading the previous accumulated HTML + next
 * batch of fragments. Final pass wraps in HTML and calls Blob.toPdf().
 * Peak heap stays under 12MB even for 10K+ rows.
 */
public with sharing class DocGenGiantQueryAssembler implements Queueable {

    private static final Integer FRAGS_PER_PASS = 50; // ~1.15MB per pass

    private Id jobId;
    private Id templateId;
    private Id recordId;
    private String giantRelationshipName;

    public DocGenGiantQueryAssembler(Id jobId, Id templateId, Id recordId, String giantRelationshipName) {
        this.jobId = jobId;
        this.templateId = templateId;
        this.recordId = recordId;
        this.giantRelationshipName = giantRelationshipName;
    }

    public void execute(QueueableContext ctx) {
        try {
            String prefix = 'docgen_giant_' + jobId + '_';
            String accumTitle = 'docgen_giant_' + jobId + '_accum';
            String partExclude = prefix + 'part_%';

            // Load the previous accumulation if it exists
            String accumulated = '';
            List<ContentVersion> accumCvs = [
                SELECT Id, VersionData, ContentDocumentId FROM ContentVersion
                WHERE Title = :accumTitle WITH SYSTEM_MODE LIMIT 1
            ];
            Id accumDocId = null;
            if (!accumCvs.isEmpty()) {
                accumulated = accumCvs[0].VersionData.toString();
                accumDocId = accumCvs[0].ContentDocumentId;
            }
            accumCvs = null;

            // Load next batch of HTML fragments
            List<ContentVersion> frags = [
                SELECT Title, VersionData, ContentDocumentId FROM ContentVersion
                WHERE Title LIKE :(prefix + '%') AND Title != :accumTitle
                AND (NOT Title LIKE :partExclude)
                ORDER BY Title LIMIT :FRAGS_PER_PASS // NOPMD
            ];

            if (frags.isEmpty()) {
                // No more fragments — render final PDF
                renderFinalPdf(accumulated, accumDocId);
                return;
            }

            // Append this batch to accumulated HTML
            Set<Id> fragDocIds = new Set<Id>();
            for (ContentVersion cv : frags) {
                accumulated += cv.VersionData.toString();
                fragDocIds.add(cv.ContentDocumentId);
            }
            frags = null;

            // Save updated accumulation (delete old, create new)
            if (accumDocId != null) {
                delete new ContentDocument(Id = accumDocId); // NOPMD
            }
            ContentVersion newAccum = new ContentVersion(
                Title = accumTitle,
                PathOnClient = accumTitle + '.html',
                VersionData = Blob.valueOf(accumulated),
                IsMajorVersion = false
            );
            insert newAccum; // NOPMD
            accumulated = null;

            // Delete consumed fragments
            if (!fragDocIds.isEmpty()) {
                delete [SELECT Id FROM ContentDocument WHERE Id IN :fragDocIds]; // NOPMD
            }

            // Chain to self for next pass
            System.enqueueJob(new DocGenGiantQueryAssembler(
                jobId, templateId, recordId, giantRelationshipName
            ));

        } catch (Exception e) {
            update new DocGen_Job__c(Id = jobId, Status__c = 'Failed', Label__c = e.getMessage().left(255)); // NOPMD
        }
    }

    /**
     * Final pass: wraps accumulated HTML rows in a complete document and renders PDF.
     */
    private void renderFinalPdf(String allRows, Id accumDocId) {
        // Clean up the accumulation CV
        if (accumDocId != null) {
            delete new ContentDocument(Id = accumDocId); // NOPMD
        }

        if (String.isBlank(allRows)) {
            update new DocGen_Job__c(Id = jobId, Status__c = 'Failed', Label__c = 'No data to render'); // NOPMD
            return;
        }

        // Build simple HTML document with the accumulated rows
        String html = '<html><head><style>' +
            '@page { size: letter; margin: 0.75in; }' +
            'body { font-family: Helvetica, Arial, sans-serif; font-size: 10pt; margin: 0; }' +
            'table { width: 100%; border-collapse: collapse; }' +
            'td, th { border: 0.5pt solid #999; padding: 4px 6px; text-align: left; }' +
            'tr { page-break-inside: avoid; }' +
            '</style></head><body>' +
            '<table>' + allRows + '</table>' +
            '</body></html>';
        allRows = null;
        allRows = null;

        Blob pdfBlob = Blob.toPdf(html);
        html = null;

        // Save final PDF and link to record
        ContentVersion pdfCv = new ContentVersion(
            Title = 'docgen_giant_' + jobId + '_final',
            PathOnClient = 'docgen_giant_' + jobId + '_final.pdf',
            VersionData = pdfBlob,
            IsMajorVersion = false
        );
        insert pdfCv; // NOPMD

        // Link PDF to the source record (some objects like Pricebook2 don't support file linking)
        try {
            Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :pdfCv.Id].ContentDocumentId;
            insert new ContentDocumentLink(
                ContentDocumentId = docId,
                LinkedEntityId = recordId,
                ShareType = 'V'
            ); // NOPMD
        } catch (Exception linkErr) {
            // Non-fatal — PDF is still saved, just not linked to the record
        }

        update new DocGen_Job__c(Id = jobId, Status__c = 'Completed'); // NOPMD
    }
}
