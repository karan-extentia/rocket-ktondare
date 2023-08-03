import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import ToastContainer from 'lightning/toastContainer';

export default class RocketToast extends LightningElement {
    @api maxShown;
    //Toast position will take top-left, top-right, top-center, bottom-left, bottom-right, bottom-center
    @api toastPosition;
    
    @api
    showToast(title, message, variant) {
        const toastContainer = ToastContainer.instance();
            if (toastContainer) {
                toastContainer.maxShown = (this.maxShown ? this.maxShown : 3);
                toastContainer.toastPosition = (this.toastPosition ? this.toastPosition : 'top-center'); 
            }
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}