@IsTest
private class Rocket_WSF_Request_Test {
    @IsTest
    static void testProcessRequest() {
        // Create a test Rocket_WSF_RequestObj
        Rocket_WSF_RequestObj testRequestObj = new Rocket_WSF_RequestObj();
        testRequestObj.credential = Rocket_WSF_Constants.NAMED_CREDENTIAL;
        testRequestObj.endpoint = Rocket_WSF_Constants.HEARTBEAT_ENDPOINT;
        testRequestObj.method = Rocket_WSF_Constants.REQUEST_GET; 
        testRequestObj.requestBody = '';
        testRequestObj.filterParamJson = '{"param1": "value1", "param2": "value2"}';
        testRequestObj.headerMap = '{"Content-Type": "application/json"}';
        
        // Add the testRequestObj to a list
        List<Rocket_WSF_RequestObj> testRequestObjList = new List<Rocket_WSF_RequestObj>();
        testRequestObjList.add(testRequestObj);
        
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new Rocket_WSF_HttpMock());  

        // Call the processRequest method
        List<String> result = Rocket_WSF_Request.processRequest(testRequestObjList);
        
        // Assertions
        System.assertEquals(1, result.size());
        Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(result[0]);        
        System.assertEquals('test', responseMap.get('example'));
    }
}