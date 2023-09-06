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
            Endpoint__c = 'http://localhost:8060/gwms/crm/rest/EIF1001/EC001/MD001'
        );

        insert ifMaster;
    }

    @isTest
    static void IFN_EIF1001_EC002_MD003_TEST(){
        Test.startTest();
        IFN_EIF1001_EC001_MD001 sendToMMS = new IFN_EIF1001_EC001_MD001();
        List<IFN_EIF1001_EC001_MD001.EC001RequstData> requestMsgList = new List<IFN_EIF1001_EC001_MD001.EC001RequstData>();
        IFN_EIF1001_EC001_MD001.EC001RequstData requestData = new IFN_EIF1001_EC001_MD001.EC001RequstData();
        requestData.msg_key = '1234567890';
        requestData.sender_number = '01071707086';
        requestData.receiver_number = '"01071707086';
        requestData.title = 'MMS Test';
        requestData.msg = 'MMS Test 1';
        
        requestMsgList.add(requestData);

        IFN_EIF1001_EC001_MD001.EC001RequstWrapper requestBody = new IFN_EIF1001_EC001_MD001.EC001RequstWrapper();
        requestBody.msg_type = 'MMS';
        requestBody.msg_data = requestMsgList;
        
		sendToMMS.param = requestBody;
        // Callout Interface
        IFN_CalloutResult calloutResult = sendToMMS.callout();
                
        String resultCode = calloutResult.result;

        IFN_EIF1001_EC001_MD001.EC001ResultWrapper resultResponse = (IFN_EIF1001_EC001_MD001.EC001ResultWrapper)calloutResult.response;
        List<Map<String, Object>> results = (List<Map<String, Object>>)resultResponse.results;

        if(resultCode.equals('S')) {
            // 메시지 발송 결과 수신
            for(Map<String,Object> result : results) {
                for(String key : result.keySet()){
                    System.debug(key + ':::::::' + result.get(key));
                }
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
}