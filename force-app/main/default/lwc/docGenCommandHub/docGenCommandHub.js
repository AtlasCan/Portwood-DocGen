import { LightningElement, track, wire } from 'lwc';
import getAllTemplates from '@salesforce/apex/DocGenController.getAllTemplates';

export default class DocGenCommandHub extends LightningElement {
    @track templateCount = 0;
    @track showBanner = true;
    @track bannerDismissed = false;
    @track showHelp = false;
    @track showBulk = false;
    @track isLoaded = false;

    _wiredTemplates;

    @wire(getAllTemplates)
    wiredTemplates(result) {
        this._wiredTemplates = result;
        if (result.data) {
            this.templateCount = result.data.length;
            // Show welcome banner if < 10 templates and user hasn't dismissed it
            if (!this.bannerDismissed) {
                this.showBanner = this.templateCount < 10;
            }
            this.isLoaded = true;
        } else if (result.error) {
            this.isLoaded = true;
        }
    }

    get templateCountLabel() {
        if (this.templateCount === 0) return 'No templates yet';
        if (this.templateCount === 1) return '1 template ready';
        return this.templateCount + ' templates ready';
    }

    get bulkSectionIcon() {
        return this.showBulk ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get bannerHeading() {
        if (this.templateCount === 0) return 'Welcome to DocGen';
        return 'DocGen';
    }

    get bannerSubtext() {
        if (this.templateCount === 0) return "Let's create your first template. It takes about 3 minutes.";
        return 'Upload a Word template with merge tags, generate PDFs or DOCX from any record.';
    }

    handleDismissBanner() {
        this.showBanner = false;
        this.bannerDismissed = true;
    }

    handleScrollToTemplates() {
        const el = this.template.querySelector('[data-section="templates"]');
        if (el) el.scrollIntoView({ behavior: 'smooth' });
    }

    handleToggleBulk() {
        this.showBulk = !this.showBulk;
        if (this.showBulk) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                const el = this.template.querySelector('[data-section="bulk"]');
                if (el) el.scrollIntoView({ behavior: 'smooth' });
            }, 100);
        }
    }

    handleToggleHelp() {
        this.showHelp = !this.showHelp;
    }

    handleCopyTag(event) {
        const TAG_MAP = {
            'loop-contacts': '{#Contacts}...{/Contacts}',
            'conditional-isactive': '{#IsActive}...{/IsActive}'
        };
        let tag = event.currentTarget.dataset.tag;
        tag = TAG_MAP[tag] || tag;
        if (navigator.clipboard) {
            navigator.clipboard.writeText(tag);
        }
    }
}
