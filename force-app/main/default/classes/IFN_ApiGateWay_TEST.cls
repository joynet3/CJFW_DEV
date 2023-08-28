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
        ifmst.Header__c = '{"111":"222"}';
        ifmst.Param1__c = 'test';
        ifmst.Param2__c = 'test';
        ifmst.Param3__c = 'test';
        ifmst.Param4__c = 'test';    
        insert ifmst;


        ifmst = new IFMaster__c();
        ifmst.Name = 'test02';
        ifmst.InterfaceId__c = 'test02';
        ifmst.Type__c = 'Inbound';
        ifmst.WebserviceType__c = 'REST'; 
        ifmst.Endpoint__c = 'test';
        ifmst.Method__c = 'PUT';
        ifmst.ContentType__c = 'application/json';
        ifmst.ifKeyId__c = 'test';
        ifmst.Header__c = '{"111":"222"}';
        ifmst.Param1__c = 'test';
        ifmst.Param2__c = 'test';
        ifmst.Param3__c = 'test';
        ifmst.Param4__c = 'test';    
        insert ifmst;


        ifmst = new IFMaster__c();
        ifmst.Name = 'test03';
        ifmst.InterfaceId__c = 'test03';
        ifmst.Type__c = 'Inbound';
        ifmst.WebserviceType__c = 'REST'; 
        ifmst.Endpoint__c = 'test';
        ifmst.Method__c = 'GET';
        ifmst.ContentType__c = 'application/json';
        ifmst.ifKeyId__c = 'test';
        ifmst.Header__c = '{"111":"222"}';
        ifmst.Param1__c = 'test';
        ifmst.Param2__c = 'test';
        ifmst.Param3__c = 'test';
        ifmst.Param4__c = 'test';    
        insert ifmst;


        IF_RELAY_INFO__c objRelayInfo = new IF_RELAY_INFO__c();
        objRelayInfo.Interface_id__c = 'test';
        objRelayInfo.Interface_auth_key__c = 'test';
        insert objRelayInfo;

    }

    @isTest
    static void test01()
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


    @isTest
    static void test02()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock()); 
        IFN_ApiGateWay gateway = new IFN_ApiGateWay('test02');
        String requestBody = '{"1":"1"}';
        Map<String,String> dynamicHd = new Map<String,String>();
        Boolean isLogInsert = false;

        gateway.webCallout(requestBody,dynamicHd,isLogInsert);

        Test.stopTest();
    }


    @isTest
    static void test03()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock()); 
        IFN_ApiGateWay gateway = new IFN_ApiGateWay('test03');
        Map<String,String> dynamicHd = new Map<String,String>();
        Boolean isLogInsert = false;

        gateway.webCallout('',dynamicHd,isLogInsert);

        Test.stopTest();
    }    


    @isTest
    static void test04()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutErrorMock()); 
        IFN_ApiGateWay gateway = new IFN_ApiGateWay('test03');
        Map<String,String> dynamicHd = new Map<String,String>();
        Boolean isLogInsert = false;

        gateway.webCallout('',dynamicHd,isLogInsert);

        Test.stopTest();
    }    

    // Mock3 : ERR_CD":"9999"
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);
            return response;
        }
    }


    // Mock3 : ERR_CD":"9999"
    private class HttpCalloutErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(500);
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