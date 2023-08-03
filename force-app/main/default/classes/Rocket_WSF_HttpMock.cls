@isTest
global class Rocket_WSF_HttpMock implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        return res;
    }
}