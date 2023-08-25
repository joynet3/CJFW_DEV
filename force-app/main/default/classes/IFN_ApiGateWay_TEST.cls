@isTest 
private class IFN_ApiGateWay_TEST {
    
    @TestSetup
    static void setup(){
        IFMaster__c ifmst = new IFMaster__c();
        ifmst.Name = 'test';
        ifmst.InterfaceId__c = 'test';
        ifmst.Type__c = 'Inbound';
        ifmst.WebserviceType__c = 'REST'; 
        ifmst.Endpoint__c = 'test';
        ifmst.Method__c = 'POST';
        ifmst.ContentType__c = 'application/json';
        ifmst.ifKeyId__c = 'test';
        ifmst.Header__c = '';
        ifmst.Param1__c = 'test';
        ifmst.Param2__c = 'test';
        ifmst.Param3__c = 'test';
        ifmst.Param4__c = 'test';    
        insert ifmst;
    }

    @isTest
    static void testOne()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock()); 
        IFN_ApiGateWay gateway = new IFN_ApiGateWay('test');
        String requestBody = '{"1":"1"}';
        Map<String,String> dynamicHd = new Map<String,String>();
        Boolean isLogInsert = false;

        gateway.webCallout(requestBody,dynamicHd,isLogInsert);

        Test.stopTest();
    }


    // Mock3 : ERR_CD":"9999"
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);
            return response;
        }
    }

    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{"ERR_CD":"9999","ERR_MSG_CTT":"검색된 결과가 없습니다."}');
        return response;
    }


}