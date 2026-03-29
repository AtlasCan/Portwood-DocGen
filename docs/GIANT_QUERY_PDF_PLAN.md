# Giant Query PDF — Server Batch + Client Merge

## The Problem

Giant Query currently works for DOCX (client-side ZIP assembly) but not PDF. Users with 15,000+ child records need PDF output. Server-side PDF stitching hits heap limits trying to merge hundreds of PDFs in Apex.

## The Solution

Render PDF fragments server-side (Blob.toPdf()), merge them client-side (mergePdfs()). Every piece already exists — we're just wiring them together differently.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  1. USER CLICKS GENERATE (PDF + Giant Query detected)   │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│  2. SERVER: Generate Shell PDF                          │
│     - generateDocumentPartsGiantQuery() already returns │
│       template with <!--DOCGEN_GIANT_LOOP_PLACEHOLDER-->│
│     - Remove placeholder, render shell to PDF via       │
│       Blob.toPdf() — parent data, header, logo, title  │
│     - Save as ContentVersion: docgen_giant_{jobId}_shell│
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│  3. SERVER: DocGenGiantQueryBatch (PDF mode)            │
│     - Cursor pagination: 50 rows per batch              │
│     - Each batch:                                       │
│       a. renderLoopBodyForRecords() → merged XML rows   │
│       b. Wrap in HTML table with matching styles        │
│       c. Blob.toPdf() → PDF fragment                   │
│       d. Save as ContentVersion:                        │
│          docgen_giant_{jobId}_00001.pdf                  │
│     - 25,000 rows ÷ 50/batch = 500 fragment PDFs       │
│     - Each batch gets fresh 6MB heap                    │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│  4. JOB COMPLETE → User notified                        │
│     - Job status: "Ready to Assemble"                   │
│     - DocGen Runner shows the job with fragment count   │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│  5. CLIENT: Fetch + Merge                               │
│     - Fetch shell PDF via getContentVersionBase64()     │
│     - Fetch each fragment PDF (one call each = fresh    │
│       6MB heap per call on server side)                 │
│     - mergePdfs([shellPdf, frag1, frag2, ...frag500])  │
│     - Download merged PDF                               │
│     - Optional: user uploads back to record manually    │
└─────────────────────────────────────────────────────────┘
```

## What Already Exists

| Component | File | Status |
|-----------|------|--------|
| Giant Query scout | DocGenController.scoutChildCounts() | ✅ Built |
| Giant Query batch | DocGenGiantQueryBatch.cls | ✅ Built (saves XML fragments) |
| Giant Query stitch | DocGenGiantQueryStitchJob.cls | ✅ Built (server-side, hits heap) |
| Shell template generation | DocGenService.generateDocumentPartsGiantQuery() | ✅ Built (returns XML with placeholder) |
| Row rendering | DocGenService.renderLoopBodyForRecords() | ✅ Built |
| PDF merger (JS) | docGenRunner/docGenPdfMerger.js | ✅ Built (pure JS, no dependencies) |
| Fragment fetcher | DocGenController.getContentVersionBase64() | ✅ Built (fresh heap per call) |
| Fragment list | DocGenController.getGiantQueryFragments() | ✅ Built |
| Fragment cleanup | DocGenController.cleanupGiantQueryFragments() | ✅ Built |
| Job status polling | DocGenController.getGiantQueryJobStatus() | ✅ Built |
| Blob.toPdf() | Salesforce platform | ✅ Available |
| HTML renderer | DocGenHtmlRenderer.convertToHtml() | ✅ Built |

## What Needs to Change

### 1. DocGenGiantQueryBatch.cls — PDF fragment mode

Currently saves XML fragments. Needs a PDF mode that:

- Takes the rendered XML rows from `renderLoopBodyForRecords()`
- Wraps them in a minimal HTML document with table styling that matches the template
- Calls `Blob.toPdf()` to render to PDF
- Saves the PDF as a ContentVersion (not XML)

Key consideration: The HTML wrapper needs to match the template's table styling (column widths, fonts, borders) so the fragments look consistent when merged. We can extract the table style from the template XML during shell generation and pass it to the batch.

### 2. Shell PDF generation — New method or modify existing

Need a method that:
- Takes the merged template XML (parent data filled, giant loop removed)
- Converts to HTML via DocGenHtmlRenderer.convertToHtml()
- Renders to PDF via Blob.toPdf()
- Saves as ContentVersion with title `docgen_giant_{jobId}_shell`

This runs BEFORE the batch starts. Could be in the batch's start() method or in the controller before launching the batch.

### 3. DocGen Runner — PDF assembly flow

The LWC needs a flow for PDF Giant Query:

```
User clicks Generate (PDF template, Giant Query detected)
  → "Generating your document... This may take a few minutes for large datasets."
  → Poll getGiantQueryJobStatus() every 5 seconds
  → Job status = "Ready to Assemble"
  → "Your document is ready! 500 pages generated. Click to assemble."
  → User clicks "Assemble & Download"
  → Fetch shell PDF + all fragment PDFs sequentially
  → Progress bar: "Assembling... 47/500 fragments"
  → mergePdfs() → download
  → "Done! Your 25,000-row document has been downloaded."
  → Optional: cleanupGiantQueryFragments()
```

### 4. HTML table wrapper for fragments

Each fragment PDF needs consistent styling. Create a helper method:

```apex
public static String wrapRowsAsHtml(String renderedRows, String tableStyle) {
    return '<html><head><style>' +
        'body { font-family: Helvetica, sans-serif; font-size: 10px; margin: 0; padding: 0; }' +
        'table { width: 100%; border-collapse: collapse; }' +
        'td, th { border: 1px solid #ccc; padding: 4px 8px; text-align: left; }' +
        tableStyle +
        '</style></head><body><table>' +
        renderedRows +
        '</table></body></html>';
}
```

The `tableStyle` comes from parsing the template's table formatting during shell generation.

## Limits & Math

| Metric | Value | Notes |
|--------|-------|-------|
| Rows per fragment | 50 | Keeps Blob.toPdf() HTML under size limit |
| Fragments for 25K rows | 500 | 25,000 ÷ 50 |
| Heap per batch execute | 6MB | Fresh per Database.Batchable execute() |
| Blob.toPdf() per fragment | ~50-200KB | Depends on column count |
| Total fragment storage | ~25-100MB | 500 × 50-200KB |
| Client fetch calls | 501 | 1 shell + 500 fragments |
| Browser memory for merge | ~100-200MB | Comfortable for any modern browser |
| Estimated batch time (25K) | 3-8 minutes | ~1 second per batch execution |

## File Naming Convention

```
docgen_giant_{jobId}_shell.pdf     — The template with parent data, no table rows
docgen_giant_{jobId}_00001.pdf     — Fragment 1 (rows 1-50)
docgen_giant_{jobId}_00002.pdf     — Fragment 2 (rows 51-100)
...
docgen_giant_{jobId}_00500.pdf     — Fragment 500 (rows 24,951-25,000)
```

## Edge Cases

- **Images in template**: Shell PDF handles via buildPdfImageMap() — already works
- **Images in child rows**: Zero-heap. Each fragment uses relative URLs (`/sfc/servlet.shepherd/version/download/<cvId>`), Blob.toPdf() resolves internally. No blob loading = no heap. 25,000 rows with images = no problem.
- **Barcodes ({*Field})**: Rendered as Code 128 barcode images by processXml() — works in Blob.toPdf()
- **QR codes ({%QR:Field})**: Rendered as QR code images by processXml() — works in Blob.toPdf()
- **Barcode FONTS**: Won't render in PDF (Blob.toPdf() limitation) — use {*Field} merge tags instead, or use DOCX path for font-based barcodes
- **Column widths**: Need to extract from template XML and carry through to fragment HTML
- **Page breaks**: Each fragment starts on a new page naturally since they're separate PDFs being merged
- **Empty fragments**: If a batch returns 0 rows (shouldn't happen with cursor), skip it
- **Job timeout**: If batch fails mid-way, partial fragments exist. Show "X of Y fragments generated" and let user retry or download partial.

## UX Flow Summary

1. User on a record page, opens DocGen Runner
2. Selects a PDF template
3. Clicks Generate
4. Scout detects >2000 children → Giant Query mode
5. For PDF output: kicks off server batch (shows spinner + progress)
6. Batch completes → notification "Document ready to assemble"
7. User clicks "Assemble & Download"
8. Client fetches shell + fragments, merges, downloads
9. User has a single merged PDF with parent data + 25K rows
10. Fragments auto-cleaned up

## Why This Works

- **No heap limit**: Each batch gets fresh 6MB, client has unlimited memory
- **No timeout**: Batchable runs asynchronously, no 120-second limit
- **No external dependencies**: Blob.toPdf() + mergePdfs() = 100% native
- **Already proven**: DOCX Giant Query path validates the pagination + client assembly pattern
- **PDF merger proven**: docGenPdfMerger.js already merges PDFs for packet mode and bulk runner
