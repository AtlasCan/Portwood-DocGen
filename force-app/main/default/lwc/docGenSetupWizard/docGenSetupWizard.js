import { LightningElement, track, wire } from 'lwc';
import getSettings from '@salesforce/apex/DocGenSetupController.getSettings';
import getFonts from '@salesforce/apex/DocGenSetupController.getFonts';
import uploadFont from '@salesforce/apex/DocGenSetupController.uploadFont';
import deleteFont from '@salesforce/apex/DocGenSetupController.deleteFont';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class DocGenSetupWizard extends LightningElement {
    @track isLoaded = false;
    @track fonts = [];
    @track showFontUpload = false;

    // Font upload form
    @track fontFamily = '';
    @track fontWeight = 'normal';
    @track fontStyle = 'normal';
    @track fontFormat = 'truetype';
    @track fontFileName = '';
    @track fontBase64 = '';
    @track isUploading = false;

    _wiredFonts;

    @wire(getSettings)
    wiredSettings({ error, data }) {
        if (data || error) {
            this.isLoaded = true;
        }
    }

    @wire(getFonts)
    wiredFonts(result) {
        this._wiredFonts = result;
        if (result.data) {
            this.fonts = result.data.map(f => ({
                ...f,
                label: f.Font_Family__c + ' (' + f.Font_Weight__c + ', ' + f.Font_Style__c + ')',
                formatLabel: (f.Font_Format__c || 'truetype').toUpperCase()
            }));
        }
    }

    get hasFonts() {
        return this.fonts.length > 0;
    }

    get fontWeightOptions() {
        return [
            { label: 'Normal (400)', value: 'normal' },
            { label: 'Bold (700)', value: 'bold' }
        ];
    }

    get fontStyleOptions() {
        return [
            { label: 'Normal', value: 'normal' },
            { label: 'Italic', value: 'italic' }
        ];
    }

    get fontFormatOptions() {
        return [
            { label: 'TrueType (.ttf)', value: 'truetype' },
            { label: 'WOFF (.woff)', value: 'woff' },
            { label: 'WOFF2 (.woff2)', value: 'woff2' }
        ];
    }

    get isUploadDisabled() {
        return !this.fontFamily || !this.fontBase64 || this.isUploading;
    }

    handleShowUpload() {
        this.showFontUpload = true;
    }

    handleCancelUpload() {
        this.showFontUpload = false;
        this.resetUploadForm();
    }

    handleFontFamilyChange(e) { this.fontFamily = e.target.value; }
    handleFontWeightChange(e) { this.fontWeight = e.detail.value; }
    handleFontStyleChange(e) { this.fontStyle = e.detail.value; }
    handleFontFormatChange(e) { this.fontFormat = e.detail.value; }

    handleFontFileChange(e) {
        const file = e.target.files[0];
        if (!file) return;

        const allowedTypes = ['.ttf', '.woff', '.woff2'];
        const ext = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();
        if (!allowedTypes.includes(ext)) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Invalid File',
                message: 'Only TTF, WOFF, and WOFF2 font files are supported.',
                variant: 'error'
            }));
            return;
        }

        // Auto-detect format from extension
        if (ext === '.ttf') this.fontFormat = 'truetype';
        else if (ext === '.woff') this.fontFormat = 'woff';
        else if (ext === '.woff2') this.fontFormat = 'woff2';

        this.fontFileName = file.name;
        const reader = new FileReader();
        reader.onload = () => {
            this.fontBase64 = reader.result.split(',')[1];
        };
        reader.readAsDataURL(file);
    }

    handleUploadFont() {
        if (this.isUploadDisabled) return;
        this.isUploading = true;

        uploadFont({
            fontFamily: this.fontFamily,
            fontWeight: this.fontWeight,
            fontStyle: this.fontStyle,
            fontFormat: this.fontFormat,
            fileName: this.fontFileName,
            base64Data: this.fontBase64
        })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Font Uploaded',
                    message: this.fontFamily + ' has been added successfully.',
                    variant: 'success'
                }));
                this.showFontUpload = false;
                this.resetUploadForm();
                return refreshApex(this._wiredFonts);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Upload Failed',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                }));
            })
            .finally(() => {
                this.isUploading = false;
            });
    }

    handleDeleteFont(e) {
        const fontId = e.target.dataset.id;
        deleteFont({ fontId })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Font Deleted',
                    message: 'Font removed successfully.',
                    variant: 'success'
                }));
                return refreshApex(this._wiredFonts);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                }));
            });
    }

    resetUploadForm() {
        this.fontFamily = '';
        this.fontWeight = 'normal';
        this.fontStyle = 'normal';
        this.fontFormat = 'truetype';
        this.fontFileName = '';
        this.fontBase64 = '';
    }
}
