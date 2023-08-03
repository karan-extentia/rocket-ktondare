/**
 * @author            : Shift7 Digital
 * @description       : This class makes a callout to an external service to retrieve inventory based on a list of product SKUs
**/
public with sharing class Rocket_WSF_Inventory {

    /**
    * @description This method takes a list of product SKUs and makes an external request callout to retrieve inventory data
    * @param List<String> products
    * @return JSON formatted string
    **/
    @AuraEnabled
    public static String getInventory(List<String> products){

        Rocket_WSF_RequestObj wsfReqObj = new Rocket_WSF_RequestObj();
        wsfReqObj.credential = Rocket_WSF_Constants.NAMED_CREDENTIAL;
        wsfReqObj.endpoint = Rocket_WSF_Constants.API_BASE_PATH + Rocket_WSF_Constants.INVENTORY_ENDPOINT;
        wsfReqObj.method = Rocket_WSF_Constants.REQUEST_POST;
        wsfReqObj.requestBody = JSON.serializePretty(products);

        List<Rocket_WSF_RequestObj> wsfReqObjList = new List<Rocket_WSF_RequestObj>();
        wsfReqObjList.add(wsfReqObj);

        List<String> responseString = Rocket_WSF_Request.processRequest(wsfReqObjList);
        System.debug('inventory response' + responseString);

       return responseString[0];
    }
}