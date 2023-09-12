@isTest
public with sharing class IFN_EIF1001_EC001_MD002_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_EIF1001_EC001_MD002',
            InterfaceId__c = 'IFN_EIF1001_EC001_MD002',
            Type__c = 'Inbound',
            WebserviceType__c = 'REST',
            Method__c = 'POST',
            ContentType__c = 'application/json'
        );

        insert ifMaster;
    }

    @isTest
    static void IFN_EIF1001_EC001_MD002_TEST(){
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        // Success Test 1
        String strBody = '{ "results": [ { "msg_key": "1234567890", "code": "0", "desc": "Success", "dest": "SKT", "done_date": "20200716140000" }, { "msg_key": "1234567891", "code": "0", "desc": "Success", "dest": "SKT", "done_date": "20200716140000" }, { "msg_key": "1234567892", "code": "0", "desc": "Success", "dest": "SKT", "done_date": "20200716140000" }, { "msg_key": "1234567893", "code": "0", "desc": "Success", "dest": "SKT", "done_date": "20200716140000" } ] }';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_EIF1001_EC001_MD002.doPost();

        // Error Test 1
        strBody = '';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_EIF1001_EC001_MD002.doPost();

        // Error Test 2
        strBody = '{ "results": [ { "msg_key": "1234567890", "code": "0"';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_EIF1001_EC001_MD002.doPost();

        Test.stopTest();
    }
}