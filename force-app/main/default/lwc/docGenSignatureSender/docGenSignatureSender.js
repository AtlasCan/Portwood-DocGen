import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedDocuments from '@salesforce/apex/DocGenSignatureSenderController.getRelatedDocuments';
import createSignatureRequest from '@salesforce/apex/DocGenSignatureSenderController.createSignatureRequest';

export default class DocGenSignatureSender extends LightningElement {
    @api recordId;
    @track documentOptions = [];
    @track selectedDocId = '';
    @track signerName = '';
    @track signerEmail = '';
    @track isLoading = true;
    @track error;
    @track finalUrl;

    @wire(getRelatedDocuments, { recordId: '$recordId' })
    wiredDocs({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.documentOptions = data.map(doc => {
                return { label: `${doc.Title}.${doc.FileExtension}`, value: doc.ContentDocumentId };
            });
            if (this.documentOptions.length > 0) {
                this.selectedDocId = this.documentOptions[0].value;
            }
            this.error = undefined;
        } else if (error) {
            this.error = 'Error loading documents: ' + error.body.message;
            this.documentOptions = [];
        }
        this.isLoading = false;
    }

    get isGenerateDisabled() {
        return !this.selectedDocId || !this.signerName || !this.signerEmail;
    }

    handleDocChange(event) {
        this.selectedDocId = event.detail.value;
    }

    handleNameChange(event) {
        this.signerName = event.target.value;
    }

    handleEmailChange(event) {
        this.signerEmail = event.target.value;
    }

    async handleGenerate() {
        this.isLoading = true;
        this.error = undefined;
        try {
            this.finalUrl = await createSignatureRequest({
                contentDocumentId: this.selectedDocId,
                relatedRecordId: this.recordId,
                signerName: this.signerName,
                signerEmail: this.signerEmail
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Signature request generated.',
                    variant: 'success'
                })
            );
        } catch (err) {
            this.error = 'Error generating link: ' + (err.body ? err.body.message : err.message);
        } finally {
            this.isLoading = false;
        }
    }

    handleCopyUrl() {
        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(this.finalUrl);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Copied',
                    message: 'Link copied to clipboard.',
                    variant: 'success'
                })
            );
        } else {
            // Fallback for older browsers
            let textArea = document.createElement("textarea");
            textArea.value = this.finalUrl;
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            try {
                document.execCommand('copy');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Copied',
                        message: 'Link copied to clipboard.',
                        variant: 'success'
                    })
                );
            } catch (err) {
                console.error('Fallback: Oops, unable to copy', err);
            }
            document.body.removeChild(textArea);
        }
    }
}