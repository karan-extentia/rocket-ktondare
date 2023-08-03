public with sharing class Rocket_WSF_Constants {

     // Endpoint Constants
     public static final String PRICE_ENDPOINT = '/pricing'; // PLACEHOLDER: endpoint for pricing service
     public static final String ORDER_ENDPOINT = '/orders'; // PLACEHOLDER: endpoint for order submit
     public static final String INVENTORY_ENDPOINT = '/inventory'; // PLACEHOLDER: endpoint for inventory service
     public static final String ORDER_LIST_ENDPOINT = '/orderheaders'; // PLACEHOLDER: endpoint for Order headers
     public static final String SHIPPING_ADDRESS_ENDPOINT = '/shippingaddresses';
     // PLACEHOLDER: endpoint for shipping addresses service
     public static final String INVOICE_ENDPOINT = '/invoices'; // PLACEHOLDER: endpoint for invoices
     public static final String AUTH_TOKEN_ENDPOINT = '/api-oauth-provider/token'; // PLACEHOLDER: this is an example of an endpoint used to retrieve an auth token
     public static final String HEARTBEAT_ENDPOINT = '/ecommerce-eapi/api/status'; // PLACEHOLDER: endpoint for a heartbeat/status to check to see if API is up/down
     public static final String STRIPE_CUSTOMER_ENDPOINT = '/v1/customers'; // PLACEHOLDER: endpoint for inventory service
     public static final String STRIPE_BASE_PATH = '/v1/'; // PLACEHOLDER: endpoint for inventory service


     // Authentication Constants
     public static final String NAMED_CREDENTIAL = 'callout:rocket_mock_api_named_cred'; // PLACEHOLDER: This is the reference to your named credential. Currently set to rocket mock APIs
     public static final String STRIPE_CREDENTIAL = 'callout:stripe_payment_cred'; // PLACEHOLDER: This is the reference to your named credential. Currently set to rocket mock APIs
     public static final String API_BASE_PATH = '/rocket/lwr'; // PLACEHOLDER: This should be the base path of the API you are connecting to for all endpoints



     // Request Constants
     public static final Integer REQUEST_TIMEOUT_LIMIT = 120000; // Defaulted to the max amount before the HTTP request times out
     public static final String REQUEST_GET = 'GET';
     public static final String REQUEST_POST = 'POST';
     public static final String REQUEST_DELETE = 'DELETE';
     public static final String REQUEST_PUT = 'PUT';
     public static final String CONTENT_TYPE_JSON = 'application/json';
}
