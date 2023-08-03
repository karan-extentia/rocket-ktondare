/**
 * @description       : Get replacement parts for a product from the client's REST API
 * @author            : gmcmann@shift7digital.com
 * @group             : 
 * @last modified on  : 04-01-2023
 * @last modified by  : gmcmann@shift7digital.com
**/
public with sharing class Rocket_GetReplacementParts {

    /**
    * @description Send a request to get replacement parts given a product serial number
    * @param serialNumber Serial number like "0014173123"
    * @return Replacement part numbers
    **/
    public static String[] send(String serialNumber) {

        String escaped = EncodingUtil.urlEncode(serialNumber, 'UTF-8');

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Client_Api/api/salesforce/service/v2.0/replacementParts?serialNumber=' + escaped);
        request.setMethod('GET');
        request.setHeader('content-type', 'application/json');
        request.setHeader('client_id', '{!$Credential.Username}');
        request.setHeader('client_secret', '{!$Credential.Password}');

        Http http = new Http();
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return (String[]) System.JSON.deserialize(response.getBody(), String[].class);
        } else {
            throw new CalloutException('Failed to get replacement parts for "' + serialNumber + '"');
        }
    }
}