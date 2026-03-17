@isTest
private class DocGenHtmlRendererTest {

    @isTest
    static void testBasicParagraph() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:p><w:r><w:t>Hello World</w:t></w:r></w:p>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('<body>'), 'Should contain body tag');
        System.assert(html.contains('Hello World'), 'Should contain text');
        System.assert(html.contains('<p>'), 'Should contain paragraph tag');
    }

    @isTest
    static void testBoldItalicUnderline() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:p><w:r><w:rPr><w:b/><w:i/><w:u w:val="single"/></w:rPr><w:t>Styled</w:t></w:r></w:p>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('<b>'), 'Should contain bold');
        System.assert(html.contains('<i>'), 'Should contain italic');
        System.assert(html.contains('<u>'), 'Should contain underline');
        System.assert(html.contains('Styled'), 'Should contain text');
    }

    @isTest
    static void testParagraphAlignment() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:t>Centered</w:t></w:r></w:p>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('text-align:center'), 'Should have center alignment');
    }

    @isTest
    static void testFontSizeAndColor() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:p><w:r><w:rPr><w:sz w:val="28"/><w:color w:val="FF0000"/></w:rPr><w:t>Big Red</w:t></w:r></w:p>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('font-size:14'), 'Should have 14pt font (28/2)');
        System.assert(html.contains('#FF0000'), 'Should have red color');
    }

    @isTest
    static void testTable() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:tbl>' +
            '<w:tblPr><w:tblBorders><w:top w:val="single"/></w:tblBorders></w:tblPr>' +
            '<w:tr>' +
            '<w:tc><w:p><w:r><w:t>Cell 1</w:t></w:r></w:p></w:tc>' +
            '<w:tc><w:p><w:r><w:t>Cell 2</w:t></w:r></w:p></w:tc>' +
            '</w:tr>' +
            '</w:tbl>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('<table'), 'Should contain table');
        System.assert(html.contains('<tr>'), 'Should contain row');
        System.assert(html.contains('<td'), 'Should contain cell');
        System.assert(html.contains('Cell 1'), 'Should contain cell text');
        System.assert(html.contains('Cell 2'), 'Should contain cell text');
    }

    @isTest
    static void testTableCellShading() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:tbl><w:tblPr></w:tblPr>' +
            '<w:tr><w:tc><w:tcPr><w:shd w:val="clear" w:fill="E2EFDA"/></w:tcPr>' +
            '<w:p><w:r><w:t>Shaded</w:t></w:r></w:p></w:tc></w:tr>' +
            '</w:tbl>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('#E2EFDA'), 'Should contain shading color');
    }

    @isTest
    static void testLineBreak() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:p><w:r><w:t>Before</w:t></w:r><w:r><w:br/></w:r><w:r><w:t>After</w:t></w:r></w:p>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('<br/>'), 'Should contain line break');
        System.assert(html.contains('Before'), 'Should contain text before break');
        System.assert(html.contains('After'), 'Should contain text after break');
    }

    @isTest
    static void testImageWithBase64() {
        String fakeBase64 = EncodingUtil.base64Encode(Blob.valueOf('fake image data'));
        Map<String, String> images = new Map<String, String>{
            'rIdImg1' => fakeBase64
        };

        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:p><w:r><w:drawing>' +
            '<wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">' +
            '<wp:extent cx="1905000" cy="952500"/>' +
            '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
            '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
            '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
            '<pic:blipFill><a:blip r:embed="rIdImg1" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/></pic:blipFill>' +
            '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml, images);

        System.assert(html.contains('<img'), 'Should contain image tag');
        System.assert(html.contains('data:image/png;base64,'), 'Should contain base64 data URI');
    }

    @isTest
    static void testEmptyDocument() {
        String html = DocGenHtmlRenderer.convertToHtml('');
        System.assert(html.contains('<body>'), 'Should return valid HTML for empty input');
        System.assert(html.contains('</body>'), 'Should close body tag');
    }

    @isTest
    static void testNullDocument() {
        String html = DocGenHtmlRenderer.convertToHtml(null);
        System.assert(html.contains('<body>'), 'Should return valid HTML for null input');
    }

    @isTest
    static void testNoImagesOverload() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body><w:p><w:r><w:t>Test</w:t></w:r></w:p></w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);
        System.assert(html.contains('Test'), 'Should handle no-image overload');
    }

    @isTest
    static void testMultipleRuns() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:p>' +
            '<w:r><w:t>Hello </w:t></w:r>' +
            '<w:r><w:rPr><w:b/></w:rPr><w:t>World</w:t></w:r>' +
            '</w:p>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('Hello '), 'Should contain first run text');
        System.assert(html.contains('<b>'), 'Should contain bold tag');
        System.assert(html.contains('World'), 'Should contain second run text');
    }

    @isTest
    static void testSpacingAndIndent() {
        String xml = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
            '<w:body>' +
            '<w:p><w:pPr><w:spacing w:before="120" w:after="240"/><w:ind w:left="720"/></w:pPr>' +
            '<w:r><w:t>Indented</w:t></w:r></w:p>' +
            '</w:body></w:document>';

        String html = DocGenHtmlRenderer.convertToHtml(xml);

        System.assert(html.contains('margin-top:'), 'Should have top margin');
        System.assert(html.contains('margin-bottom:'), 'Should have bottom margin');
        System.assert(html.contains('margin-left:'), 'Should have left indent');
    }
}