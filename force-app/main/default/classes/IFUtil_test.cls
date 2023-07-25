/**
 * @description       : 
 * @author            : youngmin.kim@daeunextier.com
 * @group             : 
 * @last modified on  : 06-21-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
@isTest
private class IFUtil_test {
    @testSetup
	static void setData() {

        Set<String> setIFId = new Set<String>{'IF_HOME_TEST', 'IF_HOME_TEST2', 'IF_MDM_TEST',  'IF_NAVER_TEST'};

        List<IFMaster__c> listIF = new List<IFMaster__c>();

        for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            if ( obj.Name == 'IF_HOME_TEST2'){
            	obj.Method__c = 'PUT';
            } else {
            	obj.Method__c = 'POST';
            }
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;
	}
    @isTest 
    static void test_setLogFuture() {
        Test.startTest();

        LogWrapper LogWrapper = new LogWrapper();

        LogWrapper.status = 'SUCCESS';
        LogWrapper.resultCode = '0';
        LogWrapper.resultMessage = 'TEST';
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestHeader = 'test';
        LogWrapper.requestBody = 'test';
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseHeader = 'test';
        LogWrapper.responseBody = 'test';
        
        IFUtil.setLogFuture('IF_HOME_TEST', JSON.serialize(LogWrapper));

        Test.stopTest();
    }

    @isTest 
    static void itShould() {
        Test.startTest();


        String str = 'Test';

        LogWrapper LogWrapper = new LogWrapper();

        LogWrapper.status = 'SUCCESS';
        LogWrapper.resultCode = '0';
        LogWrapper.resultMessage = 'TEST';
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestHeader = 'test';
        LogWrapper.requestBody = 'test';
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseHeader = 'test';
        LogWrapper.responseBody = 'test';

        IFUtil clsIF = new IFUtil('IF_HOME_TEST');        
        clsIF.setLog(LogWrapper);
    }

    @isTest 
    static void testSyncSAPSuccess() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAP());
        
        IFUtil clsIF = new IFUtil('IF_MDM_TEST');

        String strBody = '{"Test":"Test"}';
                
        clsIF.webCallout(strBody, false);        
    }
    
    @isTest 
    static void testSyncSAPSuccess2() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAP());
        
        IFUtil clsIF = new IFUtil('IF_HOME_TEST2');

        String strBody = '{"Test":"Test"}';
                
        clsIF.webCallout(strBody, false);        
    }
    
    @isTest 
    static void testSyncSAPError() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAPError());
        
        IFUtil clsIF = new IFUtil('IF_HOME_TEST');

        String strBody = '{"Test":"Test"}';
                
        clsIF.webCallout(strBody, false);
    }

    @isTest 
    static void testSyncOtherSuccess() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockOther());
        
        IFUtil clsIF = new IFUtil('IF_HOME_TEST');

        String strBody = '{"Test":"Test"}';
                
        clsIF.webCallout(strBody, false);        
    }
    
    @isTest 
    static void testSyncOtherError() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockOtherError());
        
        IFUtil clsIF = new IFUtil('IF_HOME_TEST');

        String strBody = '{"Test":"Test"}';
                
        clsIF.webCallout(strBody, false);
    }

    @isTest 
    static void testASyncSAPSuccess() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAP());

        String strJsonBody = '';

        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, Object> mapData = new Map<String, Object>();                

        mapBody.put('Test', 'Test');

        mapData.put('if_id', 'IF_HOME_TEST');
        mapData.put('body', mapBody);

        IFUtil.webCalloutFuture(JSON.serialize(mapData));

        Test.stopTest();
    }

    @isTest 
    static void testASyncSAPError() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAPError());

        String strJsonBody = '';

        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, Object> mapData = new Map<String, Object>();                

        mapBody.put('Test', 'Test');

        mapData.put('if_id', 'IF_HOME_TEST');
        mapData.put('body', mapBody);

        IFUtil.webCalloutFuture(JSON.serialize(mapData));

        Test.stopTest();
    }

    @isTest 
    static void testASyncOtherSuccess() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockOther());
        
        IFUtil clsIF = new IFUtil('IF_NAVER_TEST');

        String strBody = '{"Test":"Test"}';
                
        clsIF.webCallout(strBody, true);
        
        String strJsonBody = '';

        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, Object> mapData = new Map<String, Object>();                

        mapBody.put('Test', 'Test');

        mapData.put('if_id', 'IF_NAVER_TEST');
        mapData.put('body', mapBody);

        IFUtil.webCalloutFuture(JSON.serialize(mapData));

        Test.stopTest();
    }

    @isTest 
    static void testASyncOtherError() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockOtherError());
        
        IFUtil clsIF = new IFUtil('IF_NAVER_TEST');

        String strBody = '{"Test":"Test"}';
                
        clsIF.webCallout(strBody, true);
        
        String strJsonBody = '';

        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, Object> mapData = new Map<String, Object>();                

        mapBody.put('Test', 'Test');

        mapData.put('if_id', 'IF_NAVER_TEST');
        mapData.put('body', mapBody);

        IFUtil.webCalloutFuture(JSON.serialize(mapData));

        Test.stopTest();
    }

    private class HttpCalloutSuccessMockSAP implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseSAP(200);

            return response;
        }
    }

    private static HTTPResponse newResponseSAP(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"resultCode":"0000", "resultMessage":"Test"}');

        return response;
    }
    
    private class HttpCalloutSuccessMockSAPError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseErrorSAP(200);

            return response;
        }
    }

    private static HTTPResponse newResponseErrorSAP(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"resultCode":"-1", "resultMessage":"Error Test"}');        

        return response;
    }

    private class HttpCalloutSuccessMockOther implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseOther(200);

            return response;
        }
    }

    private static HTTPResponse newResponseOther(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"data":{"ES_RESULT":{"CODE":"0","MESSAGE":"Success"}}}');

        return response;
    }

    private class HttpCalloutSuccessMockOtherError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseErrorOther(200);

            return response;
        }
    }

    private static HTTPResponse newResponseErrorOther(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"data":{"ES_RESULT":{"CODE":"-1","MESSAGE":"Error"}}}');

        return response;
    }
}