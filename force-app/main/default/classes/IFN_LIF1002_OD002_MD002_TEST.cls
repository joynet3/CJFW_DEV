@isTest
public class IFN_LIF1002_OD002_MD002_TEST {

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

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        IFN_LIF1002_OD002_MD002.Input reqdata = new IFN_LIF1002_OD002_MD002.Input();

        reqdata.ttl='2';        
        reqdata.reqTp='샘플요청';      
        reqdata.reqTpCd='샘플요청';    
        reqdata.reqMsg='2';     
        reqdata.spItmTxt1='2';  
        reqdata.spItmTxt2='2';  
        reqdata.spItmTxt3='2';  
        reqdata.ExtSrvcCtgr='2';
        reqdata.ExtSvcCd='2';   
        reqdata.mdmId='2';      
        reqdata.reqDt='2023-02-02';      
        reqdata.rcvNm='2';      
        reqdata.reqId='2';      


        String strBody =  Json.serialize(reqdata);

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();
        
        Test.stopTest();
    }


    
    @isTest
    static void test02() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        IFN_LIF1002_OD002_MD002.Input reqdata = new IFN_LIF1002_OD002_MD002.Input();

        reqdata.ttl='1';        
        reqdata.reqTp='샘플요청';      
        reqdata.reqTpCd='샘플요청';  
        reqdata.reqMsg='1';     
        reqdata.spItmTxt1='1';  
        reqdata.spItmTxt2='1';  
        reqdata.spItmTxt3='1';  
        reqdata.ExtSrvcCtgr='1';
        reqdata.ExtSvcCd='1';   
        reqdata.mdmId='1';      
        reqdata.reqDt='2023-02-02';      
        reqdata.rcvNm='1';      
        reqdata.reqId='1';      


        String strBody =  Json.serialize(reqdata);

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();
        
        Test.stopTest();
    }


    @isTest
    static void test03() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        IFN_LIF1002_OD002_MD002.Input reqdata = new IFN_LIF1002_OD002_MD002.Input();

        reqdata.ttl='';        
        reqdata.reqTp='';      
        reqdata.reqTpCd='';    
        reqdata.reqMsg='';     
        reqdata.spItmTxt1='';  
        reqdata.spItmTxt2='';  
        reqdata.spItmTxt3='';  
        reqdata.ExtSrvcCtgr='';
        reqdata.ExtSvcCd='1';   
        reqdata.mdmId='1';      
        reqdata.reqDt='';      
        reqdata.rcvNm='1';      
        reqdata.reqId='1';      


        String strBody =  Json.serialize(reqdata);

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();
        
        Test.stopTest();
    }


    @isTest
    static void test04() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
       
       req.requestBody = null;
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD002.doPost();
        
        Test.stopTest();
    }

}