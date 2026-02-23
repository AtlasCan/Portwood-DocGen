import { LightningElement, api } from 'lwc';

export default class DocGenSignaturePad extends LightningElement {
    @api secureToken; // Passed from the public Site Controller
    @api documentUrl;
    @api signatureData; // Output to Flow

    // State Flags
    isLocked = false;
    isDrawing = false;
    isCanvasEmpty = true;
    
    // Canvas Context
    ctx;
    canvasRect;
    lastX = 0;
    lastY = 0;

    renderedCallback() {
        if (!this.ctx && !this.isLocked) {
            this.initCanvas();
        }
    }

    initCanvas() {
        const canvas = this.template.querySelector('.signature-pad');
        if (canvas) {
            // Set actual internal dimensions to match the DOM size for accurate mapping
            const wrapper = this.template.querySelector('.canvas-wrapper');
            canvas.width = wrapper.offsetWidth;
            canvas.height = 300; // Match the CSS height

            this.ctx = canvas.getContext('2d');
            
            // Set brush style
            this.ctx.strokeStyle = '#000000'; // Black ink
            this.ctx.lineJoin = 'round';
            this.ctx.lineCap = 'round';
            this.ctx.lineWidth = 3; 
        }
    }

    // --- Mouse Events ---
    handleMousedown(e) {
        this.ctx.beginPath();
        this.isDrawing = true;
        this.updateCoordinates(e.clientX, e.clientY);
    }

    handleMousemove(e) {
        if (!this.isDrawing) return;
        this.draw(e.clientX, e.clientY);
    }

    handleMouseup() {
        this.isDrawing = false;
    }

    // --- Touch Events (Mobile Support) ---
    handleTouchstart(e) {
        e.preventDefault(); // Prevent scrolling
        if (e.touches.length > 0) {
            this.ctx.beginPath();
            this.isDrawing = true;
            this.updateCoordinates(e.touches[0].clientX, e.touches[0].clientY);
        }
    }

    handleTouchmove(e) {
        e.preventDefault(); // Prevent scrolling
        if (!this.isDrawing) return;
        if (e.touches.length > 0) {
            this.draw(e.touches[0].clientX, e.touches[0].clientY);
        }
    }

    handleTouchend(e) {
        e.preventDefault();
        this.isDrawing = false;
    }

    // --- Drawing Engine ---
    updateCoordinates(clientX, clientY) {
        const canvas = this.template.querySelector('.signature-pad');
        this.canvasRect = canvas.getBoundingClientRect();
        
        // Calculate exact point inside canvas
        this.lastX = clientX - this.canvasRect.left;
        this.lastY = clientY - this.canvasRect.top;
    }

    draw(clientX, clientY) {
        const canvas = this.template.querySelector('.signature-pad');
        const currentX = clientX - this.canvasRect.left;
        const currentY = clientY - this.canvasRect.top;

        this.ctx.moveTo(this.lastX, this.lastY);
        this.ctx.lineTo(currentX, currentY);
        this.ctx.stroke();

        this.lastX = currentX;
        this.lastY = currentY;
        
        if (this.isCanvasEmpty) {
            this.isCanvasEmpty = false;
        }
    }

    clearSignature() {
        const canvas = this.template.querySelector('.signature-pad');
        this.ctx.clearRect(0, 0, canvas.width, canvas.height);
        this.isCanvasEmpty = true;
    }

    handleDownloadDoc() {
        if (this.documentUrl) {
            window.open(this.documentUrl, '_blank');
        }
    }

    saveSignature() {
        if (this.isCanvasEmpty) return;

        // Extract Base64 PNG data from the canvas
        const canvas = this.template.querySelector('.signature-pad');
        const dataUrl = canvas.toDataURL('image/png');
        
        // The dataUrl comes encoded as "data:image/png;base64,iVBORw0KGgo..."
        // We only want the raw base64 string
        const base64Data = dataUrl.split(',')[1];

        // Expose to Flow
        this.signatureData = base64Data;

        // Ensure we dispatch this to a parent component (or an Apex call later)
        this.dispatchEvent(new CustomEvent('signaturesave', {
            detail: {
                token: this.secureToken,
                base64Image: base64Data
            }
        }));

        this.isLocked = true;
    }
}