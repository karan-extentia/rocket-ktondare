global without sharing class Rocket_WSF_RequestObj {
    
    /**
     * This is the endpoint of the service you wish to invoke. It shouldn't include the base path, but should include params in the url.
     * Examples: heartbeat
     *          transactions/billandhold
     *          products/{productId}/inventory
     */
    @InvocableVariable(label='endpoint' description='Complete fullpath endpoint to invoke' required='true')
    global String endpoint;

    @InvocableVariable(label='restMethod' description='Method protocol GET/POST/PUT/DELETE' required='true')
    global String method;

    @InvocableVariable(label='credential' description='Named credential used for callout' required='true')
    global String credential;

    @InvocableVariable(label='filterParams' description='These are parameters that are used as filters for the data set returned by Mulesoft. Omit or make null if not necessary in request.')
    global String filterParamJson;

    @InvocableVariable(label='Request Body' description='' required='false')
    global String requestBody;

    @InvocableVariable(label='Request Header Map' description='Request header map in JSON form' required='false')
    global String headerMap;
}