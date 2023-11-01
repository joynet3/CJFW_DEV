@isTest
public with sharing class IFN_EIF1001_EC001_MD001_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_EIF1001_EC001_MD001',
            Type__c = 'Outbound',
            WebserviceType__c = 'REST',
            Method__c = 'POST',
            ContentType__c = 'application/json',
            Endpoint__c = 'TEST'
        );

        insert ifMaster;
    }

    @isTest
    static void IFN_EIF1001_EC001_MD001_TEST(){
        Test.startTest();
        IFN_EIF1001_EC001_MD001 sendToMMS = new IFN_EIF1001_EC001_MD001();
        List<IFN_EIF1001_EC001_MD001.EC001RequstData> requestMsgList = new List<IFN_EIF1001_EC001_MD001.EC001RequstData>();
        IFN_EIF1001_EC001_MD001.EC001RequstData requestData = new IFN_EIF1001_EC001_MD001.EC001RequstData();
        requestData.msg_key = 'dummy-msg-key';
        requestData.sub_id = 'dummy-sub-id';
        requestData.sender_number = '01012345678';
        requestData.receiver_number = '01012345678';
        requestData.title = 'MMS Tile';
        requestData.msg = 'MMS Message';
        requestData.image_key = 'dummy-image-key';
        requestData.origin_cid = 'dummy-cid';
        
        requestMsgList.add(requestData);

        IFN_EIF1001_EC001_MD001.EC001RequstWrapper requestBody = new IFN_EIF1001_EC001_MD001.EC001RequstWrapper();
        requestBody.msg_type = 'MMS';
        requestBody.msg_data = requestMsgList;
        
		sendToMMS.param = requestBody;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Callout Interface
        IFN_CalloutResult calloutResult = sendToMMS.callout();
                
        String resultCode = calloutResult.result;

        IFN_EIF1001_EC001_MD001.EC001ResultWrapper resultResponse = (IFN_EIF1001_EC001_MD001.EC001ResultWrapper)calloutResult.response;
        //List<Map<String, Object>> results = (List<Map<String, Object>>)resultResponse.results;

        if(resultCode.equals('S')) {
            // 메시지 발송 결과 수신
            for(IFN_EIF1001_EC001_MD001.results result : resultResponse.results) {
                
                System.debug('msg_key :::::::' + result.msg_key);
                System.debug('code :::::::' + result.code);
                System.debug('result_desc :::::::' + result.result_desc);
            }
        } else {
            // 메시지 발송 결과 수신 실패
            if(resultCode.equals('F')){
                // Exception 발생
                System.debug('Receive Failed :::::: ' + calloutResult.message); 
            } else {
                // Exception 발생
                System.debug('CallOut Error :::::: ' + calloutResult.message);
            }
        }
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "results": [ { "msg_key": "1234567890", "code": "C100", "desc": "Success" }, { "msg_key": "1234567891", "code": "C307", "desc": "Sender_numberIsEmpty" } ] }');
            res.setStatusCode(200);
            return res;
        }
    }
}