import { LightningElement, api, track } from "lwc";
import { getLanguage, isPreview, getEndpointData } from "c/serviceAdapter";
import { deleteRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
// mock data
import {
  shippingAddressListData,
  billingAddressListData,
} from "./designTimeData";
import getShippingAddress from "@salesforce/apex/Rocket_WSF_ShippingAddress.getShippingAddress";

//labels
import shippingLabel from "@salesforce/label/c.Rocket_Shipping_Label";
import billingLabel from "@salesforce/label/c.Rocket_Billing_Label";
import deleteAddressTitle from "@salesforce/label/c.Rocket_DeleteAddress_Title";
import deleteAddressMessage from "@salesforce/label/c.Rocket_DeleteAddress_Message";
import deleteLabel from "@salesforce/label/c.Rocket_Delete_Label";
import cancelLabel from "@salesforce/label/c.Rocket_Cancel_Label";

export default class RocketAddressList extends NavigationMixin(
  LightningElement
) {
  @api previewAccountId;
  @api showAddressType;
  @api shippingTabLabel;
  @api billingTabLabel;
  @api cardSpacing;
  @api addressesPerPage;
  @api noAddressMessageTitle;
  @api noAddressMessageText;

  @api defaultBadgeColor;
  @api defaultBadgeBorderRadius;
  @api defaultBadgeLabel;

  @api editButtonLabel;
  @api deleteButtonLabel;

  @api showNewAddressLabel;
  @api showMoreLabel;
  @api showMoreButtonStyle;
  @api showMoreButtonSize;
  @api showMoreButtonWidth;
  @api showMoreButtonAlign;

  // used to determine version of component - address list VS checkout shipping selector
  @api showCheckoutShippingAddress;
  @api showDefaultAddressOnly;

  // used to determine the number of show more addresses on shipping selector
  @api additionalAddressesShown;

  @track addresses = [];
  @track showModal = false;
  @track showMoreButton;
  @track addressType = "Shipping"; // used to determine active tab/endpoint. 'Shipping' is the default value when the component loads first
  @track addressIdToDelete;

  label = {
    shippingLabel,
    billingLabel,
    deleteAddressTitle,
    deleteAddressMessage,
    deleteLabel,
    cancelLabel,
  };

  connectedCallback() {
    this.init();
  }

  async init() {
    try {
      this.initCSSVariables();

      await this.getAddressList();
    } catch (error) {
      console.error(error);
    }
  }

  async getAddressList() {
    let previewMode = await isPreview();

    if (previewMode) {
      this.showMoreButton = true;

      if (this.addressType == "Shipping" || this.showCheckoutShippingAddress) {
        this.addresses = shippingAddressListData();
      } else {
        this.addresses = billingAddressListData();
      }
    } else {
      let data = await getShippingAddress();
      let response = JSON.parse(data);
      this.addresses = response.items;

      if (this.addresses.length < this.addressesPerPage) {
        this.showMoreButton = false;
      } else {
        this.showMoreButton = true;
      }
    }

    if (this.showDefaultAddressOnly) {
      // filter addresses to show only the default one
      this.addresses = this.addresses.filter(function (item) {
        return item.isDefault != false;
      });
    }

    this.addresses.forEach((address) => {
      if (address.isDefault) {
        const index = this.addresses.indexOf(address);
        this.addresses.splice(index, 1);
        this.addresses.unshift(address);
      }
    });

    const shippingAddresses = this.template.querySelectorAll(
      'input[name="shippingAddresses"]'
    );
    console.log("whagt is shiippingaddresess" + shippingAddresses);
    console.dir(shippingAddresses);
    for (var i = 0, length = this.addresses.length; i < length; i++) {
      if (this.addresses[i].isDefault) {
        this.addresses[i].checked = true;
      }
    }
  }

  // determine active tab
  async handleAddresses(e) {
    this.addressType = e.currentTarget.getAttribute("data-tab-value");
    this.handleActiveTab();

    await this.getAddressList();
  }

  // connect to endpoint and delete selected address
  async deleteAddress() {
    let previewMode = await isPreview();

    if (!previewMode) {
      deleteRecord(this.addressIdToDelete).then(() => {
        this.handleClose();
        this.init();
      });
    }
  }

  @api
  getSelected() {
    const shippingAddresses = this.template.querySelectorAll(
      'input[name="shippingAddresses"]'
    );
    let selectedAddressObj;
    for (var i = 0, length = shippingAddresses.length; i < length; i++) {
      if (shippingAddresses[i].checked) {
        selectedAddressObj = this.addresses.filter((address) => {
          return address.addressId === shippingAddresses[i].value;
        });
        break;
      }
    }

    console.log(selectedAddressObj);
    return selectedAddressObj;
  }

  handleActiveTab() {
    //remove existing active
    var elements = this.template.querySelectorAll(
      ".addressList__tabs .slds-is-active"
    );
    Array.prototype.forEach.call(elements, function (el, i) {
      el.classList.remove("slds-is-active");
    });
    this.template
      .querySelector(`[data-tab-value=${this.addressType}]`)
      .classList.add("slds-is-active");
  }

  async buildEndPoint() {
    let lang = await getLanguage();
    let endPoint = "";

    if (this.addressType == "Shipping" || this.showCheckoutShippingAddress) {
      // Currently excludeUnsupportedCountries param is supported only when addressType param is Shipping
      endPoint = `accounts/current/addresses?addressType=${this.addressType}&language=${lang}&pageSize=${this.addressesPerPage}&asGuest=false&sortOrder=CreatedDateDesc&excludeUnsupportedCountries=true`;
    } else {
      endPoint = `accounts/current/addresses?addressType=${this.addressType}&language=${lang}&pageSize=${this.addressesPerPage}&asGuest=false&sortOrder=CreatedDateDesc`;
    }

    return endPoint;
  }

  // show more addresses based on the configuration parameter addressesPerPage
  async handleShowMore() {
    // use the unary plus operator, to force an eventual string to be treated as number
    let counter = +this.addressesPerPage;

    if (this.additionalAddressesShown) {
      let addMore = +this.additionalAddressesShown;
      counter += addMore;
    } else {
      counter += counter;
    }

    this.addressesPerPage = counter;

    await this.getAddressList();
  }

  // shows the modal for deleting a shipping or billing address
  handleDelete(event) {
    this.addressIdToDelete = event.currentTarget.getAttribute(
      "data-delete-address"
    );
    this.showModal = true;
  }

  handleEdit(event) {
    let addressIdToEdit = event.currentTarget.getAttribute("data-edit-address");

    if (this.showCheckoutShippingAddress) {
      // create the event with the address Id data.
      const selectedEvent = new CustomEvent("editaddress", {
        detail: addressIdToEdit,
      });

      // dispatch the event.
      this.dispatchEvent(selectedEvent);
    } else {
      // Navigate to the Address Form page.
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: "/addressForm?addressId=" + addressIdToEdit,
        },
      });
    }
  }

  handleNewAddress() {
    this.dispatchEvent(new CustomEvent("newaddress"));
  }

  handleClose() {
    this.showModal = false;
  }

  initCSSVariables() {
    var css = this.template.host.style;

    // Set default badge styles
    css.setProperty("--defaultBadgeColor", this.defaultBadgeColor);
    css.setProperty(
      "--defaultBadgeBorderRadius",
      this.defaultBadgeBorderRadius + "px"
    );
  }

  // determine when to show billing addresses
  get showBilling() {
    // we do not show Billing tab on Checkout view
    if (this.showCheckoutShippingAddress) {
      return false;
    }

    return this.showAddressType == "Shipping and billing" ? true : false;
  }

  // if checkout view return neutral buttons else use all of the authorable button styles in list view
  get buttonClass() {
    if (this.showCheckoutShippingAddress) {
      return `show-more-button slds-button slds-button_neutral`;
    } else {
      return `show-more-button slds-button ${this.getVariant()} ${this.getButtonSize()} ${this.getButtonAlignment()} ${this.getButtonWidth()}`;
    }
  }

  get addressGridClass() {
    return `address-container ${this.getCardSpacing()}`;
  }

  // find appropriate grid class for Small, None, Medium or Large property value
  getCardSpacing() {
    if (this.cardSpacing == "Small") {
      return "address-grid-gap-small";
    }
    if (this.cardSpacing == "Medium") {
      return "address-grid-gap-medium";
    }
    if (this.cardSpacing == "Large") {
      return "address-grid-gap-large";
    }
    return "address-grid-gap-none"; // None
  }

  // find appropriate variant class for Primary, Secondary or Tertiary property value
  getVariant() {
    if (this.showMoreButtonStyle == "Secondary") {
      return "slds-button_outline-brand";
    }
    if (this.showMoreButtonStyle == "Tertiary") {
      return "slds_button-tertiary";
    }
    return "slds-button_brand"; // Primary
  }

  // find appropriate size class for Small, Standard, Large property value
  getButtonSize() {
    if (this.showMoreButtonSize == "Small") {
      return "dxp-button-small";
    }
    if (this.showMoreButtonSize == "Standard") {
      return "dxp-button-medium";
    }
    return "dxp-button-large"; // Large
  }

  // find appropriate width class Full Width or Default
  getButtonWidth() {
    if (this.showMoreButtonWidth == "Full Width") {
      return "slds-button_stretch";
    }
    return "";
  }

  // find appropriate alignment class for Left, Right, Center
  getButtonAlignment() {
    if (this.showMoreButtonAlign == "Left") {
      return "show-more-button_left";
    }
    if (this.showMoreButtonAlign == "Right") {
      return "show-more-button_right";
    }
    return "slds-align_absolute-center"; // Center
  }
}