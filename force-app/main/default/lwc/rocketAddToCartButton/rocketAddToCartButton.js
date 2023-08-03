import { LightningElement, api, track, wire } from "lwc";
import { addItemToCart } from "commerce/cartApi";
import { trackAddProductToCart } from "commerce/activitiesApi";
import { NavigationMixin } from "lightning/navigation";
import { ProductAdapter } from "commerce/productApi";
import getInventory from "@salesforce/apex/Rocket_WSF_Inventory.getInventory";

// labels
import loadingLabel from "@salesforce/label/c.Rocket_Loading_Label";
import continueLabel from "@salesforce/label/c.Rocket_Continue_Shopping_Label";
import viewCartLabel from "@salesforce/label/c.Rocket_View_Cart_Label";
import itemAddedTitle from "@salesforce/label/c.Rocket_ItemAdded_Title";
import quantitySelectedMessage from "@salesforce/label/c.Rocket_QuantitySelected_Message";
import inventoryDataUnavailableLabel from "@salesforce/label/c.Rocket_InventoryDataUnavailable_Label";
import errorAddToCartTitleLabel from "@salesforce/label/c.Rocket_AddToCart_Error_AddToCartTitle_Label";
import errorAddToCartDescLabel from "@salesforce/label/c.Rocket_AddToCart_Error_AddToCartDesc_Label";
import errorAccessInsufficient from "@salesforce/label/c.Rocket_AddToCart_errorAccessInsufficient";
import errorLimitMinimum from "@salesforce/label/c.Rocket_AddToCart_errorLimitMinimum";
import errorLimitMaximum from "@salesforce/label/c.Rocket_AddToCart_errorLimitMaximum";
import errorLimitIncrement from "@salesforce/label/c.Rocket_AddToCart_errorLimitIncrement";
import errorLimitExceeded from "@salesforce/label/c.Rocket_AddToCart_errorLimitExceeded";
import errorDefault from "@salesforce/label/c.Rocket_AddToCart_errorDefault";

export default class RocketAddToCartButton extends NavigationMixin(
  LightningElement
) {
  // authored values
  @api buttonText;
  @api buttonVariant;
  @api buttonSize;
  @api buttonWidth;
  @api buttonAlignment;
  @api recordId;
  @api preventAddToCart;
  @api buttonTextColor;
  @api buttonTextHoverColor;
  @api buttonProcessingText;
  @api buttonBackgroundColor;
  @api buttonBackgroundHoverColor;
  @api buttonBorderColor;
  @api buttonBorderRadius;
  @api errorMessage;
  @api minimumValueGuideText;
  @api maximumValueGuideText;
  @api incrementValueGuideText;
  @api outOfStockButtonText;
  @api inventoryProductAttributeField;

  // vars used by this component
  @track errorMessageBoolean = false;
  @track showModal = false;
  @track productRules;
  quantityRuleString;
  displayQuantityRulesText = false;
  addToCartDisabled = false;

  loading = false;
  quantity;
  style;

  // labels for template
  label = {
    continueLabel,
    viewCartLabel,
    itemAddedTitle,
    quantitySelectedMessage,
    loadingLabel,
  };

  // error message mapping to labels for use in toast when addToCart fails
  errorMessageToLabelMap = new Map([
    ["INSUFFICIENT_ACCESS", errorAccessInsufficient],
    ["MAX_LIMIT_EXCEEDED", errorLimitMaximum],
    ["LIMIT_EXCEEDED", errorLimitExceeded],
    ["MISSING_RECORD", errorLimitMinimum],
    ["INVALID_BATCH_SIZE", errorLimitIncrement],
  ]);

  // template error display message
  get showErrorMessage() {
    return this.errorMessageBoolean;
  }

  // handle when component is rendered
  connectedCallback() {
    this.init();
  }

  // initial settings for component on render
  async init() {
    try {
      this.initCSSVariables();
    } catch (error) {
      console.error(error);
    }
  }

  // wire to the product
  @wire(ProductAdapter, { productId: "$recordId" })
  wiredAccount({ error, data }) {
    if (data) {
      this.productRules = data;
      this.error = undefined;
      // setup the purchase quantity rule string for display
      this.getQuantityRuleString(data);

      // see if the product is in stock if we have prevent add to cart checked
      // since its an async call, do it like so inside the wire
      const callBusinessLogic = async () => {
        const passedLogic = await this.checkBusinessLogic();
        this.addToCartDisabled = !passedLogic;
      };

      // call the above
      callBusinessLogic();
    } else if (error) {
      this.error = error;
      this.productRules = undefined;
    }
  }

  // handle the add to cart function
  async handleAddToCart(event) {
    // if everything is valid according to the rules
    if (this.isValidQuantity()) {
      try {
        this.loading = true;
        await addItemToCart(this.recordId, this.quantity)
          .then((result) => {
            this.showModal = true;
            this.errorMessageBoolean = false;
            trackAddProductToCart(result.productId);
          })
          .catch((error) => {
            const err = error?.error ?? error;
            this.showToastEvent(
              errorAddToCartTitleLabel,
              this.getErrorMessage(err?.code),
              "error"
            );
          });
      } catch (error) {
        this.showToastEvent(
          errorAddToCartTitleLabel,
          errorAddToCartDescLabel,
          "error"
        );
      } finally {
        this.loading = false;
      }
    }
  }

  /**
   * @param {string} [errorCode] An error code to retrieve an error message for
   * @returns {string} An error message for the given _`errorCode`_ or a default error message in case no specific message exists
   */
  getErrorMessage(errorCode) {
    return this.errorMessageToLabelMap.get(errorCode) || errorDefault;
  }

  //put business logic in here
  async checkBusinessLogic() {
    let canAddToCart = true;
    // check for stock availability before add to cart
    if (this.preventAddToCart) {
      canAddToCart = await this.isInStock();
    }
    return canAddToCart;
  }

  // validate the entries based on the rules
  checkQtyError(qty, min, max, step) {
    // check if the qty value meets the purchase qty rules
    return qty > max || qty < min || (qty - min) % step !== 0;
  }

  // make sure we comply with the purchase quantity rules for the selected product
  //   isValidQuantity() {
  //     // find the specific product quantity selector matching this add to cart button.
  //     let attribute = `input[data-nameid="productquantityselector"][data-pdpid="${this.recordId}"]`;
  //     // this.quantity =
  //     //   document.querySelector(attribute) != null
  //     //     ? document.querySelector(attribute)?.value
  //     //     : "1";
  //     this.quantity =
  //       document.querySelector(".number-input__input") != null
  //         ? document.querySelector(".number-input__input").value
  //         : "1";

  //     var minQuantityRule =
  //       this.productRules != null && this.productRules.purchaseQuantityRule
  //         ? parseInt(this.productRules.purchaseQuantityRule.minimum)
  //         : 1;
  //     var maxQuantityRule =
  //       this.productRules != null && this.productRules.purchaseQuantityRule
  //         ? parseInt(this.productRules.purchaseQuantityRule.maximum)
  //         : 99999;
  //     var increment =
  //       this.productRules != null && this.productRules.purchaseQuantityRule
  //         ? parseInt(this.productRules.purchaseQuantityRule.increment)
  //         : 1;

  //     let hasError = this.checkQtyError(
  //       this.quantity,
  //       minQuantityRule,
  //       maxQuantityRule,
  //       increment
  //     );

  //     return !hasError;
  //   }
  isValidQuantity() {
    console.debug("Inside IsValid Quantity");
    // find the specific product quantity selector matching this add to cart button.
    this.quantity =
      document.querySelector(".number-input__input") != null
        ? document.querySelector(".number-input__input").value
        : "1";
    //this.quantity = document.querySelector(attribute) != null ? document.querySelector(attribute)?.value : '1';
    var minQuantityRule =
      this.productRules != null && this.productRules.purchaseQuantityRule
        ? parseInt(this.productRules.purchaseQuantityRule.minimum)
        : 1;
    var maxQuantityRule =
      this.productRules != null && this.productRules.purchaseQuantityRule
        ? parseInt(this.productRules.purchaseQuantityRule.maximum)
        : 99999;
    var increment =
      this.productRules != null && this.productRules.purchaseQuantityRule
        ? parseInt(this.productRules.purchaseQuantityRule.increment)
        : 1;
    let hasError = this.checkQtyError(
      this.quantity,
      minQuantityRule,
      maxQuantityRule,
      increment
    );
    console.debug("Last Line of IsValidQuantity");
    return !hasError;
  }

  // if business rules are run, check if the product is in stock
  //   async isInStock() {
  //     const now = new Date();
  //     let products = [];
  //     let inStock = false;

  //     if (this.productRules !== undefined) {
  //       // if internal product field is authored for tracking inventory, use that.
  //       if (this.inventoryProductAttributeField != null) {
  //         try {
  //           let invCount =
  //             this.productRules.fields[this.inventoryProductAttributeField];
  //           if (invCount > 0) {
  //             inStock = true;
  //           } else {
  //             this.errorMessageBoolean = true;
  //             this.errorMessage = inventoryDataUnavailableLabel;
  //           }
  //         } catch (ex) {
  //           this.errorMessageBoolean = true;
  //           this.errorMessage = inventoryDataUnavailableLabel;
  //         }
  //         return inStock;
  //       }

  //       // otherwise, get the product sku(s) for the call to getInventory
  //       let productSku = this.productRules.fields
  //         ? this.productRules.fields?.StockKeepingUnit
  //         : null;

  //       if (productSku == null) {
  //         this.errorMessageBoolean = true;
  //         this.errorMessage = inventoryDataUnavailableLabel;
  //       } else {
  //         products.push(productSku);
  //       }
  //     }

  //     // call getInventory endpoint to check the status of the product(s)
  //     await getInventory({ products: products })
  //       .then((result) => {
  //         if (result) {
  //           let inventory = JSON.parse(result)[0];
  //           let stockEndDate = new Date(inventory.etaStockDate);
  //           let stockQty = inventory.qty;

  //           // check if stock date has not expired and there is quantity available in stock
  //           if (stockEndDate >= now && stockQty > 0) {
  //             inStock = true;
  //           } else {
  //             this.errorMessageBoolean = true;
  //             this.errorMessage = inventoryDataUnavailableLabel;
  //           }
  //         }
  //       })
  //       .catch((error) => {
  //         this.errorMessageBoolean = true;
  //         this.errorMessage = error;
  //       });

  //     return inStock;
  //   }
  async isInStock() {
    const now = new Date(); //***** DONT FORGET TO ADD THIS *****
    let products = [];
    let inStock = true;

    if (this.productRules !== undefined) {
      // if internal product field is authored for tracking inventory, use that.
      if (this.inventoryProductAttributeField != null) {
        try {
          let invCount =
            this.productRules.fields[this.inventoryProductAttributeField];
          if (invCount > 0) {
            inStock = true;
          } else {
            this.errorMessageBoolean = true;
            this.errorMessage = inventoryDataUnavailableLabel;
          }
        } catch (ex) {
          this.errorMessageBoolean = true;
          this.errorMessage = inventoryDataUnavailableLabel;
        }
        // return inStock;
      }
    }

    //****** ADD THIS LOGIC  TO GATHER THE PRODUCTS BY SKU ******
    // otherwise, get the product sku(s) for the call to getInventory
    let productSku = this.productRules.fields
      ? this.productRules.fields?.StockKeepingUnit
      : null;

    if (productSku == null) {
      this.errorMessageBoolean = true;
      this.errorMessage = inventoryDataUnavailableLabel;
    } else {
      products.push(productSku);
    }

    //****** ADD THIS LOGIC TO MAKE A CALL TO PULL REALTIME INVENTORY ******
    await getInventory({ products: products })
      .then((result) => {
        if (result) {
          let inventory = JSON.parse(result)[0];
          let stockEndDate = new Date(inventory.etaStockDate);
          let stockQty = inventory.qty;

          // check if stock date has not expired and there is quantity available in stock
          if (stockEndDate >= now && stockQty > 0) {
            inStock = true;
          } else {
            this.errorMessageBoolean = true;
            this.errorMessage = inventoryDataUnavailableLabel;
          }
        }
      })
      .catch((error) => {
        this.errorMessageBoolean = true;
        this.errorMessage = error;
      });
    return inStock;
  }

  // initial css setup
  initCSSVariables() {
    var css = this.template.host.style;
    css.setProperty(
      "--addtocart-button-background-color",
      this.buttonBackgroundColor
    );
    css.setProperty(
      "--addtocart-button-background-color-hover",
      this.buttonBackgroundHoverColor
    );
    css.setProperty("--addtocart-button-color-text", this.buttonTextColor);
    css.setProperty(
      "--addtocart-button-color-text-hover",
      this.buttonTextHoverColor
    );
    css.setProperty("--addtocart-button-border-color", this.buttonBorderColor);
    this.getButtonRadius(css);
  }

  // for closing the modal
  handleClose() {
    this.showModal = false;
  }

  // for navigation to the cart page
  handleNavCart() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/cart",
      },
    });
  }

  // pop toast events
  showToastEvent(title, body, level) {
    this.template.querySelector("c-rocket-toast").showToast(title, body, level);
  }

  // set the button class
  get buttonClass() {
    return `addtocart-button slds-button ${this.getButtonVariant()} ${this.getButtonSize()} ${this.getButtonAlignment()} ${this.getButtonWidth()}`;
  }

  /// find appropriate variant class for Primary, Secondary or Tertiary property value
  getButtonVariant() {
    if (this.buttonVariant == "Secondary") {
      return "slds-button_outline-brand";
    }
    if (this.buttonVariant == "Tertiary") {
      return "slds_button-tertiary";
    }
    return "slds-button_brand"; // Primary
  }

  // find appropriate size class for Small, Standard, Large property value
  getButtonSize() {
    if (this.buttonSize == "Small") {
      return "dxp-button-small";
    }
    if (this.buttonSize == "Standard") {
      return "dxp-button-medium";
    }
    return "dxp-button-large"; // Large
  }

  // find appropriate width class Full Width or Default
  getButtonWidth() {
    if (this.buttonWidth == "Full Width") {
      return "slds-button_stretch";
    }
    return "";
  }

  // find appropriate alignment class for Left, Right, Center
  getButtonAlignment() {
    if (this.buttonAlignment == "Left") {
      return "show-more-button_left";
    }
    if (this.buttonAlignment == "Right") {
      return "show-more-button_right";
    }
    return "slds-align_absolute-center"; // Center
  }

  // checks if value for buttonBorderRadius is a variable with px already in it, else append px
  getButtonRadius(css) {
    if (this.buttonBorderRadius.toString().includes("var")) {
      css.setProperty(
        "--addtocart-button-border-radius",
        this.buttonBorderRadius
      );
    } else {
      css.setProperty(
        "--addtocart-button-border-radius",
        this.buttonBorderRadius + "px"
      );
    }
  }

  // set up button text
  get buttonDisplayText() {
    if (this.addToCartDisabled) {
      return this.outOfStockButtonText;
    }
    return this.loading ? this.buttonProcessingText : this.buttonText;
  }

  // show the quantity rules
  get displayQuantityRulesText() {
    return this.displayQuantityRulesText;
  }

  // set button state
  get buttonDisabled() {
    return this.addToCartDisabled;
  }

  // build the quantity rules text
  getQuantityRuleString(data) {
    this.displayQuantityRulesText = false;

    var minQuantityRule =
      data != null && data.purchaseQuantityRule
        ? parseInt(data.purchaseQuantityRule.minimum)
        : null;
    var maxQuantityRule =
      data != null && data.purchaseQuantityRule
        ? parseInt(data.purchaseQuantityRule.maximum)
        : null;
    var increment =
      data != null && data.purchaseQuantityRule
        ? parseInt(data.purchaseQuantityRule.increment)
        : null;
    var returnString = "";

    if (
      minQuantityRule != null &&
      maxQuantityRule != null &&
      increment != null
    ) {
      let text = this.minimumValueGuideText;
      var minString = text ? text.replace("{0}", minQuantityRule) : "";

      text = this.maximumValueGuideText;
      var maxString = text ? text.replace("{0}", maxQuantityRule) : "";

      text = this.incrementValueGuideText;
      var incString = text ? text.replace("{0}", increment) : "";

      returnString = minString + " • " + maxString + " • " + incString;
      this.quantityRuleString = returnString;

      this.displayQuantityRulesText = true;
    }
  }
}