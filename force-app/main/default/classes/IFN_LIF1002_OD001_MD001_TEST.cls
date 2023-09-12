@isTest
public with sharing class IFN_LIF1002_OD001_MD001_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_LIF1002_OD001_MD001',
            InterfaceId__c = 'IFN_LIF1002_OD001_MD001',
            Type__c = 'Inbound',
            WebserviceType__c = 'REST',
            Method__c = 'POST',
            ContentType__c = 'application/json'
        );

        insert ifMaster;
    }

    @isTest
    static void IFN_LIF1002_OD001_MD001_TEST(){
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{"cstTp": "외식사업자","cstTpCd": "01","cstNm": "김동영","callNo": "010-1234-5678","bsnsNo": "000-11-22222","cpnNm": "CJ프레시웨이","sect": "식자재유통","addr": "서울특별시 마포구 상암동 상암산로 76","agrYn": "Y"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD001_MD001.doPost();
        
        Test.stopTest();
    }
}