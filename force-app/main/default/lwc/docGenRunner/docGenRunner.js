import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTemplatesForObject from '@salesforce/apex/DocGenController.getTemplatesForObject';
import processAndReturnDocument from '@salesforce/apex/DocGenController.processAndReturnDocument';
import generatePdfDocument from '@salesforce/apex/DocGenController.generatePdfDocument';
import generateAndSavePdfDocument from '@salesforce/apex/DocGenController.generateAndSavePdfDocument';
import saveGeneratedDocument from '@salesforce/apex/DocGenController.saveGeneratedDocument';

export default class DocGenRunner extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track templateOptions = [];
    @track selectedTemplateId;
    @track outputMode = 'download';
    @track templateOutputFormat = 'Document';

    isLoading = false;
    error;
    _templateData = [];

    get outputOptions() {
        const formatLabel = this.templateOutputFormat || 'Document';
        return [
            { label: `Download ${formatLabel}`, value: 'download' },
            { label: `Save to Record (${formatLabel})`, value: 'save' }
        ];
    }

    @wire(getTemplatesForObject, { objectApiName: '$objectApiName' })
    wiredTemplates({ error, data }) {
        if (data) {
            this._templateData = data;
            this.templateOptions = data.map(t => ({
                label: t.Name + (t.Is_Default__c ? ' ★' : ''),
                value: t.Id
            }));
            this.error = undefined;

            // Auto-select default template (first with Is_Default__c = true)
            if (!this.selectedTemplateId) {
                const defaultTemplate = data.find(t => t.Is_Default__c);
                if (defaultTemplate) {
                    this.selectedTemplateId = defaultTemplate.Id;
                    this.templateOutputFormat = defaultTemplate.Output_Format__c || 'Document';
                }
            }
        } else if (error) {
            this.error = 'Error fetching templates: ' + (error.body ? error.body.message : error.message);
            this.templateOptions = [];
        }
    }

    handleTemplateChange(event) {
        this.selectedTemplateId = event.detail.value;
        this.error = null;
        const selected = this._templateData.find(t => t.Id === this.selectedTemplateId);
        if (selected) {
            this.templateOutputFormat = selected.Output_Format__c || 'Document';
        }
    }

    handleOutputModeChange(event) {
        this.outputMode = event.detail.value;
    }

    get isGenerateDisabled() {
        return !this.selectedTemplateId || this.isLoading;
    }

    async generateDocument() {
        this.isLoading = true;
        this.error = null;

        try {
            const selected = this._templateData.find(t => t.Id === this.selectedTemplateId);
            const templateType = selected ? selected.Type__c : 'Word';
            const isPPT = templateType === 'PowerPoint';
            const isPDF = this.templateOutputFormat === 'PDF' && !isPPT;

            if (isPDF) {
                // Server-side PDF generation
                if (this.outputMode === 'save') {
                    this.showToast('Info', 'Generating and saving PDF...', 'info');
                    await generateAndSavePdfDocument({
                        templateId: this.selectedTemplateId,
                        recordId: this.recordId
                    });
                    this.showToast('Success', 'PDF saved to record.', 'success');
                } else {
                    this.showToast('Info', 'Generating PDF...', 'info');
                    const result = await generatePdfDocument({
                        templateId: this.selectedTemplateId,
                        recordId: this.recordId
                    });
                    if (!result || !result.base64) {
                        throw new Error('PDF generation returned empty result.');
                    }
                    this.downloadBase64(result.base64, (result.title || 'Document') + '.pdf', 'application/pdf');
                    this.showToast('Success', 'PDF downloaded.', 'success');
                }
            } else {
                // Native DOCX/PPTX path
                const result = await processAndReturnDocument({
                    templateId: this.selectedTemplateId,
                    recordId: this.recordId
                });

                if (!result || !result.base64) {
                    throw new Error('Document generation returned empty result.');
                }

                const ext = isPPT ? 'pptx' : 'docx';
                const docTitle = result.title || 'Document';

                if (this.outputMode === 'save') {
                    this.showToast('Info', 'Saving to Record...', 'info');
                    await saveGeneratedDocument({
                        recordId: this.recordId,
                        fileName: docTitle,
                        base64Data: result.base64,
                        extension: ext
                    });
                    this.showToast('Success', `${ext.toUpperCase()} saved to record.`, 'success');
                } else {
                    this.downloadBase64(result.base64, docTitle + '.' + ext, 'application/octet-stream');
                    this.showToast('Success', `${isPPT ? 'PowerPoint' : 'Word document'} downloaded.`, 'success');
                }
            }
        } catch (e) {
            let msg = 'Unknown error during generation';
            if (e.body && e.body.message) {
                msg = e.body.message;
            } else if (e.message) {
                msg = e.message;
            } else if (typeof e === 'string') {
                msg = e;
            }
            this.error = 'Generation Error: ' + msg;
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * Downloads a base64-encoded file via an anchor element.
     */
    downloadBase64(base64Data, fileName, mimeType) {
        const binaryString = atob(base64Data);
        const bytes = new Uint8Array(binaryString.length);
        for (let i = 0; i < binaryString.length; i++) {
            bytes[i] = binaryString.charCodeAt(i);
        }
        const blob = new Blob([bytes], { type: mimeType });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
