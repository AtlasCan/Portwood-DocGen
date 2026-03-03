import { LightningElement, track, wire } from 'lwc';
import getOrgUrl from '@salesforce/apex/DocGenSetupController.getOrgUrl';
import getSettings from '@salesforce/apex/DocGenSetupController.getSettings';
import saveSettings from '@salesforce/apex/DocGenSetupController.saveSettings';
import buildProvisionPackage from '@salesforce/apex/DocGenSetupController.buildProvisionPackage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DocGenSetupWizard extends LightningElement {
    @track orgUrl = '';
    @track experienceSiteUrl = '';
    @track isLoaded = false;
    @track currentStep = '1';

    // Provision state
    @track consumerKey = '';
    @track consumerSecret = '';
    @track isProvisioning = false;
    @track provisionError = '';
    @track provisionSucceeded = false;

    _messageHandler;

    get callbackUrl() {
        return this.orgUrl + '/services/authcallback/DocGen_Auth_Provider';
    }

    get provisionPageUrl() {
        return '/apex/DocGenProvision';
    }

    get isProvisionDisabled() {
        return this.isProvisioning || !this.consumerKey || !this.consumerSecret;
    }

    @wire(getOrgUrl)
    wiredOrgUrl({ error, data }) {
        if (data) {
            this.orgUrl = data;
        } else if (error) {
            /* handled silently */
        }
    }

    @wire(getSettings)
    wiredSettings({ error, data }) {
        if (data) {
            this.experienceSiteUrl = data.Experience_Site_Url__c || '';
            this.isLoaded = true;
        } else if (error) {
            this.isLoaded = true;
        }
    }

    connectedCallback() {
        this._messageHandler = this.handleMessage.bind(this);
        window.addEventListener('message', this._messageHandler);
    }

    disconnectedCallback() {
        if (this._messageHandler) {
            window.removeEventListener('message', this._messageHandler);
        }
    }

    handleMessage(event) {
        if (!event.data || event.data.type !== 'provision_result') return;

        this.isProvisioning = false;
        if (event.data.status === 'Succeeded') {
            this.provisionSucceeded = true;
            this.provisionError = '';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Auth Provider, External Credential, and Named Credential created successfully.',
                    variant: 'success'
                })
            );
        } else {
            this.provisionError = event.data.error || 'Unknown error during deployment.';
            this.provisionSucceeded = false;
        }
    }

    handleStepClick(event) {
        this.currentStep = event.target.value;
    }

    get isStep1() { return this.currentStep === '1'; }
    get isStep2() { return this.currentStep === '2'; }
    get isStep3() { return this.currentStep === '3'; }

    nextStep() {
        let stepNum = parseInt(this.currentStep, 10);
        if (stepNum < 3) {
            this.currentStep = String(stepNum + 1);
        }
    }

    prevStep() {
        let stepNum = parseInt(this.currentStep, 10);
        if (stepNum > 1) {
            this.currentStep = String(stepNum - 1);
        }
    }

    handleConsumerKeyChange(event) {
        this.consumerKey = event.target.value;
    }

    handleConsumerSecretChange(event) {
        this.consumerSecret = event.target.value;
    }

    handleUrlChange(event) {
        this.experienceSiteUrl = event.target.value;
    }

    handleProvision() {
        this.isProvisioning = true;
        this.provisionError = '';
        this.provisionSucceeded = false;

        buildProvisionPackage({
            consumerKey: this.consumerKey,
            consumerSecret: this.consumerSecret
        })
            .then(zipBase64 => {
                const iframe = this.template.querySelector('iframe');
                if (iframe && iframe.contentWindow) {
                    iframe.contentWindow.postMessage(
                        { action: 'deploy', apiBase: this.orgUrl, zipBase64: zipBase64 },
                        '*'
                    );
                } else {
                    this.isProvisioning = false;
                    this.provisionError = 'Provision engine not ready. Please wait a moment and try again.';
                }
            })
            .catch(error => {
                this.isProvisioning = false;
                this.provisionError = error.body ? error.body.message : error.message;
            });
    }

    handleSaveSettings() {
        this.isLoaded = false;
        saveSettings({ experienceSiteUrl: this.experienceSiteUrl })
            .then(() => {
                this.isLoaded = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Settings saved successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.isLoaded = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error'
                    })
                );
            });
    }
}
