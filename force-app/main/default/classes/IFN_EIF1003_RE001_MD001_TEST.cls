/**
 * Created by 박지오사원 on 2023-09-11.
 */
@IsTest
public with sharing class IFN_EIF1003_RE001_MD001_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
                Name = 'IFN_EIF1003_RE001_MD001',
                Type__c = 'Outbound',
                WebserviceType__c = 'Callout',
                Method__c = 'GET',
                ContentType__c = 'application/json',
                Header__c = '{"API-CLIENT-ID" : "76e500f61681efbf243cc89181bedbfb", "API-CLIENT-SECRET" : "9d2ae4b0dc2bd85800584bcf7932a3e2"}',
                Endpoint__c = 'https://open-api-teambook.rememberapp.co.kr/stacks.json'
        );

        insert ifMaster;
    }

    @isTest
    static void IFN_EIF1003_RE001_MD001_TEST() {
        Test.startTest();
        IFN_EIF1003_RE001_MD001 getRemember = new IFN_EIF1003_RE001_MD001();

        IFN_EIF1003_RE001_MD001.RE001RequestWrapper request = new IFN_EIF1003_RE001_MD001.RE001RequestWrapper();

        String yesterday = String.valueOf(System.today().addDays(-1));
        request.start_at = yesterday;

        getRemember.param = request;

        // Callout Interface
        IFN_CalloutResult calloutResult = getRemember.callout();

        String resultCode = calloutResult.result;

        IFN_EIF1003_RE001_MD001.RE001ResultWrapper resultResponse = (IFN_EIF1003_RE001_MD001.RE001ResultWrapper) calloutResult.response;
        Map<String, Object> result = (Map<String, Object>) resultResponse.result;

        System.debug('calloutResult' + calloutResult);
        System.debug('resultResponse' + resultResponse);
        System.debug(result);
        if (resultCode.equals('S')) {
            // 메시지 발송 결과 수신
                for (String key : result.keySet()) {
                    System.debug(key + ':::::::' + result.get(key));
                }
        } else {
            // 메시지 발송 결과 수신 실패
            if (resultCode.equals('F')) {
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