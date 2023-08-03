public class Rocket_WSF_ShippingAddress {
    /**
    * @description This method takes an address detail and makes an external request callout to retrieve shipping addresses
    * @param List<String> products
    * @return JSON formatted string
    **/
    @AuraEnabled
    public static String getShippingAddress(){
        Rocket_WSF_RequestObj wsfReqObj = new Rocket_WSF_RequestObj();
        wsfReqObj.credential = Rocket_WSF_Constants.NAMED_CREDENTIAL;
        wsfReqObj.endpoint = Rocket_WSF_Constants.API_BASE_PATH + Rocket_WSF_Constants.SHIPPING_ADDRESS_ENDPOINT;
        wsfReqObj.method = Rocket_WSF_Constants.REQUEST_POST;
        wsfReqObj.requestBody = '{"BusinessUnit": "SW", "CustomerId": "1024", "NumberOfRecords": 25 }';
        List<Rocket_WSF_RequestObj> wsfReqObjList = new List<Rocket_WSF_RequestObj>();
        wsfReqObjList.add(wsfReqObj);
        List<String> responseString = Rocket_WSF_Request.processRequest(wsfReqObjList);
        System.debug('inventory response' + responseString);
        return responseString[0];
    }
}