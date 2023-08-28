@isTest
public class IFN_LIF1002_OD002_MD003_TEST {

    @TestSetup
    static void makeData(){
        IFN_TestDataFactory.createIfPrograms();

        MDMReferenceCode__c code = new MDMReferenceCode__c();
        code.GROUPID__c = 'GROUPID__c';
        code.CODE__c = '0001';
        code.NAME_KO__c = 'Test';
        code.Name = 'Test';
        insert code;

        OrderServiceRequest__c osr = new OrderServiceRequest__c();
        osr.ReqRecordId__c = '1';
        osr.Status__c = 'R';
        osr.ResponseDate__c = Date.today();
        osr.ResponseTitle__c = '1';
        osr.Title__c = '1';
        osr.RequestMessage__c = 'a';
        osr.RequestDate__c = Date.today();
        osr.MDMReferenceCode__c = code.id;
        insert osr;
        
    }

    @isTest
    static void test01() {
        Test.startTest();
        OrderServiceRequest__c osr = [select id from OrderServiceRequest__c  Limit 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{ '
                         +'   "reqId": "1", '
                         +'   "resId": "" '
                         +'}';

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD003.doPost();
        
        Test.stopTest();
    }


    @isTest
    static void test02() {
        Test.startTest();
        OrderServiceRequest__c osr = [select id from OrderServiceRequest__c  Limit 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{ '
                         +'   "reqId": "2", '
                         +'   "resId": "" '
                         +'}';

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD003.doPost();
        
        Test.stopTest();
    }


    @isTest
    static void test03() {
        Test.startTest();
        OrderServiceRequest__c osr = [select id from OrderServiceRequest__c  Limit 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{ '
                         +'   "reqId": "", '
                         +'   "resId": "" '
                         +'}';

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD003.doPost();
        
        Test.stopTest();
    }    

}