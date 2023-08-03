/**
 * @typedef {{[key: string]: *}} JsonData
 */

/**
 * @returns {JsonData} shipping address list data
 */
export function shippingAddressListData() {
    return [{
        "addressId": "8lWDn000000HXpIMAW",
        "addressType": "Shipping",
        "city": "New York",
        "country": "United States",
        "countryCode": "US",
        "fields": {},
        "firstName": "Jane",
        "isDefault": true,
        "lastName": "Doe",
        "name": "Jane Doe",
        "postalCode": "11000",
        "region": "NY",
        "regionCode": "NY",
        "street": "123 Broadway"
    }, {
        "addressId": "8lWDn000000HXp8MAG",
        "addressType": "Shipping",
        "city": "New York",
        "country": "United States",
        "countryCode": "US",
        "fields": {},
        "firstName": "John",
        "isDefault": false,
        "lastName": "Doe",
        "name": "John Doe",
        "postalCode": "01803",
        "region": "NY",
        "regionCode": "NY",
        "street": "5 Wall Street"
    }, {
        "addressId": "8lWDn000000HXp8MYT",
        "addressType": "Shipping",
        "city": "New York",
        "country": "United States",
        "countryCode": "US",
        "fields": {},
        "firstName": "Janice",
        "isDefault": false,
        "lastName": "Doe",
        "name": "Janice Doe",
        "postalCode": "11000",
        "region": "NY",
        "regionCode": "NY",
        "street": "500 Broadway"
    }];
}
/**
 * @returns {JsonData} billing address list data
 */
export function billingAddressListData() {
    return [{
        "addressId": "8lWDn000000HXpIMAW",
        "addressType": "Billing",
        "city": "New York",
        "country": "United States",
        "countryCode": "US",
        "fields": {},
        "firstName": "Jane",
        "isDefault": true,
        "lastName": "Doe",
        "name": "Jane Doe",
        "postalCode": "11000",
        "region": "NY",
        "regionCode": "NY",
        "street": "123 Broadway"
    }, {
        "addressId": "8lWDn000000HXp8MAG",
        "addressType": "Billing",
        "city": "New York",
        "country": "United States",
        "countryCode": "US",
        "fields": {},
        "firstName": "John",
        "isDefault": false,
        "lastName": "Doe",
        "name": "John Doe",
        "postalCode": "01803",
        "region": "NY",
        "regionCode": "NY",
        "street": "25 Wall Street"
    }];
}