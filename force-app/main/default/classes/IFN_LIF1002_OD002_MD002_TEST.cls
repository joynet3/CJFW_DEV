@isTest
public with sharing class IFN_LIF1002_OD002_MD002_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_LIF1002_OD002_MD002',
            InterfaceId__c = 'IFN_LIF1002_OD002_MD002',
            Type__c = 'Inbound',
            WebserviceType__c = 'REST',
            Method__c = 'POST',
            ContentType__c = 'application/json'
        );

        insert ifMaster;
    }

    @isTest
    static void IFN_LIF1002_OD002_MD002_TEST(){
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        // Success Test 1
        String strBody = '{"ttl": "식료품신청","reqTp": "샘플신청","reqTpCd": "01","reqMsg": "식료품신청","spItmTxt1": "샘플상품1","spItmTxt2": "샘플상품2","spItmTxt3": "샘플상품3","ExtSrvcCtgr": "가공류","mdmId": "ABC","reqDt": "2023-08-21","rcvNm": "[36110]세종시","reqId": "1223334"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();
        
        // Success Test 2
        strBody = '{"ttl": "식료품신청","reqTp": "샘플신청","reqTpCd": "02","reqMsg": "식료품신청","spItmTxt1": "샘플상품1","spItmTxt2": "샘플상품2","spItmTxt3": "샘플상품3","ExtSrvcCtgr": "가공류","mdmId": "ABC","reqDt": "2023-08-21","rcvNm": "[36110]세종시","reqId": "1223334"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();

        // Error Test 1
        strBody = '';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();

        // Error Test 2
        strBody = '{"dummy1": "식료품신청","dummy2": "샘플신청","dummy3": "02","dummy4": "식료품신청","dummy5": "샘플상품1","dummy6": "샘플상품2","dummy7": "샘플상품3","dummy8": "가공류","dummy9": "ABC","dummy10": "2023-08-21","dummy11": "[36110]세종시","dummy12": "1223334"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();

        // Error Test 3
        strBody = '{"ttl": "식료품신청","reqTp": "샘플신청","reqTpCd": "04","reqMsg": "식료품신청","spItmTxt1": "샘플상품1","spItmTxt2": "샘플상품2","spItmTxt3": "샘플상품3","ExtSrvcCtgr": "가공류","mdmId": "ABC","reqDt": "2023-08-21","rcvNm": "[36110]세종시","reqId": "1223334"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();

        Test.stopTest();
    }
}