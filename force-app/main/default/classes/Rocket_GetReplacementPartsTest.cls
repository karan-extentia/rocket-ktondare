/**
 * @description       : Test coverage for Rocket_GetReplacementParts
 * @author            : gmcmann@shift7digital.com
 * @group             : 
 * @last modified on  : 04-01-2023
 * @last modified by  : gmcmann@shift7digital.com
**/
@IsTest
public with sharing class Rocket_GetReplacementPartsTest {

    /**
     * @description HTTP callout mock that returns a pre-determined response.
    **/
    private class MockHttpResponse implements HttpCalloutMock {

        private HttpResponse response;
    
        /**
        * @description Initialize the mock with a response
        * @param response HTTP response to return for any request
        **/
        public MockHttpResponse(HTTPResponse response) {
            this.response = response;
        }
    
        /**
        * @description Returns HTTP Response for a given HTTP Request
        * @param request HTTP request
        * @return HTTPResponse
        **/
        public HTTPResponse respond(HTTPRequest request) {
            return this.response;
        }
    }
    
    /**
    * @description Test coverage for a success response.
    **/
    @IsTest
    static void success() {
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('["300SS"]');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(response));

        Test.startTest();
        String[] results = Rocket_GetReplacementParts.send('0014173123');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Should return a list');
        System.assertEquals(1, results.size(), 'Should return a single result');
        System.assertEquals('300SS', results[0], 'Should return part number from API response');
    }

    /**
    * @description Test coverage for a failure response.
    **/
    @IsTest
    static void fail() {

        HttpResponse response = new HttpResponse();
        response.setStatusCode(400);
        response.setBody(
            '{'
          + '  "Error: {'
          + '     "message": "errorType: BAD_REQUEST"'
          + '  }'
          + '}'
        );

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(response));

        String exceptionType;

        Test.startTest();
        try {
            Rocket_GetReplacementParts.send('');
        } catch (System.Exception e) {
            exceptionType = e.getTypeName();
        }
        Test.stopTest();

        System.assertEquals('System.CalloutException', exceptionType, 'Should throw CalloutException');
    }
}