/**
 * @author Shift7 Digital
 * @date 5/10/2023
 * @description Class used to facilitate all external callouts within an implementation. This should be leveraged
 * to make callouts to systems like SAP, Mulesoft, etc.
 * This will use the new external credentials/named credentials for authentication
 */
public without sharing class Rocket_WSF_Request {

    /**
     * @description processRequest is an invocable method that is used to take in a request obj to perform the 
     *              appropriate REST request to the middleware. It is invocable to be leveraged by flows, actions, etc.
     * 
     * @param  wsfReqObjList List of Rocket_WSF_RequestObj which should really just be a list of one
     * @return            returns a List<String> which is the json response returned by Mulesoft
     */
    @InvocableMethod(label='Process WSFRequest' callout=true)
    public static List<String> processRequest(List<Rocket_WSF_RequestObj> wsfReqObjList) {
        
        HttpRequest req = new HttpRequest();
        List<String> result = new List<String>();

        // Only process if a request object was sent
        if(wsfReqObjList.isEmpty()){
            result.add('No request object to process was found. Please pass in a valid request object.');
        } else {
            // Should only ever have one request object. The reason it is a list is due to SF requiring all invocable methods to be Lists
            Rocket_WSF_RequestObj wsfReqObj = wsfReqObjList.get(0); 

            // Build out the full path to the endpoint
            String fullPath = (wsfReqObj.credential != null ? wsfReqObj.credential : '') + wsfReqObj.endpoint;
            
            // Build out any query string params
            String params = (wsfReqObj.filterParamJson != null) ? buildFilterParams(wsfReqObj.filterParamJson) : '';

            // Set the official endpoint with the path and query params
            req.setEndpoint(fullPath + params);

            // Set the method protocol
            req.setMethod((String) wsfReqObj.method); //GET | POST | DELETE etc.

            // Set the body if applicable
            if (String.isNotBlank(wsfReqObj.requestBody)) {
                req.setBody(wsfReqObj.requestBody);
            }
            
            // Check to see if the object is using any custom request object headers
            if(wsfReqObj.headerMap != null)
            {
                // If there are filter params then add those to the request
                if(wsfReqObj.headerMap != null) {
                    Map<String,Object> headerMap = (Map<String, Object>) JSON.deserializeUntyped(wsfReqObj.headerMap);
                    Set<String> mapKeys = headerMap.keySet();
                    for(String headerKey : mapKeys){
                        req.setHeader(headerKey, (String) headerMap.get(headerKey));
                    }
                }
            } 
            // Some examples of common headers that might be necessary
            //     req.setHeader('Accept-Language', 'en-us');
            //     req.setHeader('Content-Type', 'application/json');
            //     req.setHeader('Accept', 'application/json');     
            
            
            try {
                // Send actual http request and capture the response
                Http http = new Http();

                // These debugs should be left in to help debug issues that may occur during testing
                System.debug('WSF Request endpoint ====> ' + req.getEndpoint());
                System.debug('WSF Request body ====> ' + req.getBody());
                System.debug('WSF Request Authorization header ====> ' + req.getHeader('Authorization'));

                // Set the timeout of the http request, default is 10 sec
                req.setTimeout(Rocket_WSF_Constants.REQUEST_TIMEOUT_LIMIT); // timeout in milliseconds (rocket sets timeout to 2 min)
                
                // Perform request and store response
                HTTPResponse res = http.send(req);    
                result.add(res.getBody()); // return body as string
            } catch(Exception ex) {
                result.add('An error occurred when attempting to make callout to endpoint. Error: ' + ex.getMessage());
                // Rocket_Event_Logger.error(ex, 'An error occurred when attempting to make callout to endpoint');
            }
        }
        return result;
    }

    /**
     * @description buildFilterParams Method used to construct the filter parameters (query string)
     * @param  filterParamJson JSON representation of query parameters
     * @return                 Constructed query parameter string
     */
    private static String buildFilterParams(String filterParamJson){
        String paramString = '?';
        try{
            // If there are filter params then add those to the request
            if(filterParamJson != null) {
                Map<String,Object> filterMap = (Map<String, Object>) JSON.deserializeUntyped(filterParamJson);
                Set<String> filterKeySet = filterMap.keySet();

                // Loop through each filter param and append to param string
                for(String key : filterKeySet){
                    paramString += key + '=' + filterMap.get(key) + '&';
                }
            }
        }
        catch (Exception ex) {
            Rocket_Event_Logger.error(ex, 'An error occurred when building the filter params for the callout');
            return null;
        }
         
        return paramString;
    }
}