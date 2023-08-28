@isTest
public class IFN_LIF1002_OD001_MD001_TEST {

    @TestSetup
    static void makeData(){
        IFN_TestDataFactory.createIfPrograms();

        // MDMReferenceCode__c code = new MDMReferenceCode__c();
        // code.GROUPID__c = 'GROUPID__c';
        // code.CODE__c = '0001';
        // code.NAME_KO__c = 'Test';
        // code.Name = 'Test';
        // insert code;

        // OrderServiceRequest__c osr = new OrderServiceRequest__c();
        // osr.ReqRecordId__c = '1';
        // osr.Status__c = 'R';
        // osr.ResponseDate__c = Date.today();
        // osr.ResponseTitle__c = '1';
        // osr.Title__c = '1';
        // osr.RequestMessage__c = 'a';
        // osr.RequestDate__c = Date.today();
        // osr.MDMReferenceCode__c = code.id;
        // insert osr;
        
    }

    @isTest
    static void test01() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        IFN_LIF1002_OD001_MD001.Input reqdata = new IFN_LIF1002_OD001_MD001.Input();
        reqdata.cstTp='외식사업자';  
        reqdata.cstTpCd='food_service_business';
        reqdata.cstNm='1';  
        reqdata.callNo='02-000-0000'; 
        reqdata.bsnsNo='1'; 
        reqdata.cpnNm='1';  
        reqdata.sect='1';   
        reqdata.addr='1';   
        reqdata.agrYn='Y';          
        String strBody = Json.serialize(reqdata);
        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD001_MD001.doPost();
        
        Test.stopTest();
    }


    @isTest
    static void test02() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        IFN_LIF1002_OD001_MD001.Input reqdata = new IFN_LIF1002_OD001_MD001.Input();
        reqdata.cstTp='사업자';  
        reqdata.cstTpCd='food_service_business';
        reqdata.cstNm='1';  
        reqdata.callNo='02-000-0000'; 
        reqdata.bsnsNo='1'; 
        reqdata.cpnNm='1';  
        reqdata.sect='1';   
        reqdata.addr='1';   
        reqdata.agrYn='Y';          
        String strBody = Json.serialize(reqdata);
        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD001_MD001.doPost();
        
        Test.stopTest();
    }

    @isTest
    static void test03() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        IFN_LIF1002_OD001_MD001.Input reqdata = new IFN_LIF1002_OD001_MD001.Input();
        reqdata.cstTp='';  
        reqdata.cstTpCd='';
        reqdata.cstNm='';  
        reqdata.callNo=''; 
        reqdata.bsnsNo=''; 
        reqdata.cpnNm='';  
        reqdata.sect='';   
        reqdata.addr='';   
        reqdata.agrYn='Y';          
        String strBody = Json.serialize(reqdata);
        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD001_MD001.doPost();
        
        Test.stopTest();
    }


 

}