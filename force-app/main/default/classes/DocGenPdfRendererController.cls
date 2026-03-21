/**
 * Controller for DocGenPdfRenderer.page — generates PDF by rendering HTML via
 * the VF renderAs="pdf" engine (Flying Saucer).
 *
 * Uses 'without sharing' because this runs in VF page context for PDF rendering.
 * The page is accessed by system processes (Queueable jobs, platform event triggers)
 * that need to read ContentVersion and template data regardless of the running user's
 * sharing rules. Access is gated by requiring valid templateId/recordId params.
 */
public without sharing class DocGenPdfRendererController {

    public String htmlContent { get; private set; }

    public DocGenPdfRendererController() {
        String mode = ApexPages.currentPage().getParameters().get('mode');

        if (mode == 'document') {
            renderDocumentPdf();
        } else {
            htmlContent = '<html><body><p>Invalid mode.</p></body></html>';
        }
    }

    /**
     * Renders a document PDF by merging a template with record data.
     * Uses pre-committed template image CVs for URL-based rendering.
     * URL params: templateId, recordId
     */
    private void renderDocumentPdf() {
        String templateId = ApexPages.currentPage().getParameters().get('templateId');
        String recordId = ApexPages.currentPage().getParameters().get('recordId');

        if (String.isBlank(templateId) || String.isBlank(recordId)) {
            htmlContent = '<html><body><p>Error: Missing template or record ID.</p></body></html>';
            return;
        }

        try {
            htmlContent = DocGenService.renderDocumentHtml(templateId, recordId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'DocGen: Document PDF render error: ' + e.getMessage());
            htmlContent = '<html><body><p>Error generating document: ' + e.getMessage().escapeHtml4() + '</p></body></html>';
        }
    }
}
