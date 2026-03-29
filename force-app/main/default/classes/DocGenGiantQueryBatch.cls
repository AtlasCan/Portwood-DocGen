/**
 * Batch Apex that harvests child records in cursor-based pages and renders
 * each page as a standalone fragment. Each execute() queries one page of
 * children, renders the loop body XML, and saves as a ContentVersion.
 *
 * For PDF output: fragments are saved as raw XML text. In finish(), all
 * fragments are loaded, wrapped in one HTML document, and rendered to a
 * single PDF via Blob.toPdf(). One PDF, no client-side merge needed.
 *
 * For DOCX output: fragments are saved as raw XML, and the client fetches
 * each fragment one at a time to assemble the DOCX ZIP in JavaScript.
 */
public with sharing class DocGenGiantQueryBatch implements Database.Batchable<String>, Database.Stateful {

    private Id jobId;
    private Id templateId;
    private Id recordId;
    private String relationshipName;
    private String childObjectName;
    private String lookupField;
    private List<String> childFields;
    private List<String> parentFields;
    private String innerXml;
    private String lastCursorId;
    private Integer batchSize;
    private Integer fragmentSequence;
    private String outputFormat;
    private String giantRelationshipName;

    public DocGenGiantQueryBatch(Id jobId, Id templateId, Id recordId, Map<String, Object> childNodeConfig, String innerXml, String outputFormat) {
        this.jobId = jobId;
        this.templateId = templateId;
        this.recordId = recordId;
        this.innerXml = innerXml;
        this.outputFormat = outputFormat;
        this.fragmentSequence = 0;
        this.batchSize = 50;

        this.relationshipName = (String) childNodeConfig.get('relationshipName');
        this.giantRelationshipName = this.relationshipName;
        this.childObjectName = (String) childNodeConfig.get('object');
        this.lookupField = (String) childNodeConfig.get('lookupField');

        this.childFields = new List<String>();
        List<Object> flds = (List<Object>) childNodeConfig.get('fields');
        if (flds != null) {
            for (Object f : flds) { this.childFields.add(String.valueOf(f)); }
        }
        this.parentFields = new List<String>();
        List<Object> pFlds = (List<Object>) childNodeConfig.get('parentFields');
        if (pFlds != null) {
            for (Object f : pFlds) { this.parentFields.add(String.valueOf(f)); }
        }
    }

    public Iterable<String> start(Database.BatchableContext bc) {
        String countQuery = 'SELECT COUNT() FROM ' + String.escapeSingleQuotes(childObjectName) +
            ' WHERE ' + String.escapeSingleQuotes(lookupField) + ' = :recordId WITH USER_MODE';
        Integer totalChildren = Database.countQuery(countQuery);

        Integer totalPages = (Integer) Math.ceil((Decimal) totalChildren / batchSize);
        update new DocGen_Job__c( // NOPMD ApexCRUDViolation — package-internal
            Id = jobId,
            Status__c = 'Harvesting',
            Total_Records__c = totalChildren
        );

        List<String> pages = new List<String>();
        for (Integer i = 0; i < totalPages; i++) {
            pages.add('page:' + i);
        }
        if (pages.isEmpty()) {
            pages.add('page:0');
        }

        this.lastCursorId = null;
        return pages;
    }

    /**
     * Processes one page: queries children, renders loop body XML, saves as text CV.
     * Both PDF and DOCX save raw XML — PDF assembly happens in finish().
     */
    public void execute(Database.BatchableContext bc, List<String> scope) {
        for (String pageDescriptor : scope) {
            List<String> selectFields = new List<String>{ 'Id' };
            for (String f : childFields) {
                if (f != 'Id') { selectFields.add(f); }
            }
            for (String f : parentFields) { selectFields.add(f); }

            String query = 'SELECT ' + String.join(selectFields, ', ') +
                ' FROM ' + String.escapeSingleQuotes(childObjectName) +
                ' WHERE ' + String.escapeSingleQuotes(lookupField) + ' = :recordId';
            if (lastCursorId != null) {
                query += ' AND Id > :lastCursorId';
            }
            query += ' ORDER BY Id LIMIT :batchSize';

            List<SObject> records = Database.query(query, AccessLevel.USER_MODE); // NOPMD ApexSOQLInjection — validated by Schema.getGlobalDescribe; USER_MODE enforced
            if (records.isEmpty()) { continue; }

            lastCursorId = records[records.size() - 1].Id;

            List<String> allFields = new List<String>();
            allFields.addAll(childFields);
            allFields.addAll(parentFields);

            // Render loop body XML
            String renderedRows = DocGenService.renderLoopBodyForRecords(innerXml, relationshipName, records, allFields);

            String seq = String.valueOf(fragmentSequence++).leftPad(5, '0');
            Blob fragmentData;
            String fragExtension;

            if ('PDF'.equalsIgnoreCase(outputFormat)) {
                // PDF mode: convert 50 rows to HTML now (lightweight per-batch) so assembler
                // can skip the heavy DOCX XML parser on the full dataset
                String wrappedXml = '<w:body><w:tbl>' + renderedRows + '</w:tbl></w:body>';
                renderedRows = null;
                String html = DocGenHtmlRenderer.convertToHtml(wrappedXml);
                wrappedXml = null;
                // Extract just the table rows from the generated HTML
                Integer tblStart = html.indexOf('<table');
                Integer tblEnd = html.indexOf('</table>');
                String tableHtml = (tblStart != -1 && tblEnd != -1)
                    ? html.substring(html.indexOf('>', tblStart) + 1, tblEnd)
                    : html;
                fragmentData = Blob.valueOf(tableHtml);
                fragExtension = '.html';
            } else {
                // DOCX mode: save raw XML
                fragmentData = Blob.valueOf(renderedRows);
                fragExtension = '.xml';
            }

            ContentVersion cv = new ContentVersion(
                Title = 'docgen_giant_' + jobId + '_' + seq,
                PathOnClient = 'docgen_giant_' + jobId + '_' + seq + fragExtension,
                VersionData = fragmentData,
                IsMajorVersion = false
            );
            insert cv; // NOPMD ApexCRUDViolation — internal fragment for Giant Query

            update new DocGen_Job__c(Id = jobId, Success_Count__c = fragmentSequence); // NOPMD ApexCRUDViolation — package-internal
        }
    }

    /**
     * For PDF: chains to DocGenGiantQueryAssembler Queueable which gets its own
     * fresh 6MB heap for the HTML conversion + Blob.toPdf() assembly.
     * For DOCX: marks job as Completed for client-side assembly.
     */
    public void finish(Database.BatchableContext bc) {
        try {
            if ('PDF'.equalsIgnoreCase(outputFormat)) {
                // Chain to assembler Queueable — finish() heap is too constrained
                System.enqueueJob(new DocGenGiantQueryAssembler(jobId, templateId, recordId, giantRelationshipName));
            } else {
                update new DocGen_Job__c(Id = jobId, Status__c = 'Completed'); // NOPMD ApexCRUDViolation — package-internal
            }
        } catch (Exception e) {
            update new DocGen_Job__c(Id = jobId, Status__c = 'Failed', Label__c = e.getMessage().left(255)); // NOPMD ApexCRUDViolation — package-internal
        }
    }
}
