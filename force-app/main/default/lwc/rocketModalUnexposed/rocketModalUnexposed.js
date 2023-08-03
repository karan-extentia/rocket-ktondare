import { LightningElement, api } from 'lwc';
import basePath from '@salesforce/community/basePath';

//labels
import close from '@salesforce/label/c.Rocket_CloseDialog_Label';

export default class RocketModalUnexposed extends LightningElement {
    @api showModal;
    headerRegionClassNames;
    contentRegionClassNames;
    footerRegionClassNames;

    label = {
        close
    };

    renderedCallback() {
        this.initModalClasses();
    }

    initModalClasses() {
        let header = 'slds-modal__header';
        let content = 'slds-modal__content slds-p-around_medium';
        let footer = 'slds-modal__footer';
        /* if the parent doesn't include an element with the attribute
        * 'name' = headerRegion in the modal, use slds to hide the header and
        * modify the content region styles
        */
        if (this.template.querySelector('[name="headerRegion"]') && !this.template.querySelector('[name="headerRegion"]').innerText) {
            content += ' slds-modal__content_headless';
            header += ' slds-hide';
        }
        /* if the parent doesn't include a footer region, use slds to hide
        * the footer and modify the content styles
        */
        if (this.template.querySelector('[name="footerRegion"]') && !this.template.querySelector('[name="footerRegion"]').innerText) {
            content += ' slds-modal__content_has-hidden-footer';
            footer += ' slds-hide';
        }
        /* if the parent doesn't include a content region, use slds to hide
        * the region
        */
        if (this.template.querySelector('[name="contentRegion"]') && !this.template.querySelector('[name="contentRegion"]').innerText) {
            content += ' slds-hide';
            this.template.querySelector('.slds-modal__header').style.cssText = 'border-bottom: none;';
        }
        this.headerRegionClassNames = header;
        this.contentRegionClassNames = content;
        this.footerRegionClassNames = footer;
    }

    get iconUrl() {
        return basePath +'/assets/icons/utility-sprite/svg/symbols.svg#close';
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}