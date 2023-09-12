@isTest
public with sharing class IFN_LIF1002_OD002_MD003_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_LIF1002_OD002_MD003',
            InterfaceId__c = 'IFN_LIF1002_OD002_MD003',
            Type__c = 'Inbound',
            WebserviceType__c = 'REST',
            Method__c = 'POST',
            ContentType__c = 'application/json'
        );

        insert ifMaster;

        Date requestDate = IFN_Util.convertDate('2023-08-21');
        Id osrRcdTp = Schema.SObjectType.OrderServiceRequest__c.getRecordTypeInfosByDeveloperName().get('01').getRecordTypeId();

        OrderServiceRequest__c orderServiceReq = new OrderServiceRequest__c(
                            Title__c = '식료품신청'
                        , ReqType__c = '01'
                        , ReqTypeCode__c = '01' 
                        , RequestMessage__c = '식료품신청'
                        , SampleitemText1__c = '샘플상품1'
                        , SampleitemText2__c = '샘플상품2'
                        , SampleitemText3__c = '샘플상품3'
                        , ExtraServiceCategory__c = '가공류'
                        // , ExtraServiceCategoryCode__c = input.ExtSvcCd
                        , CustomerID__c = 'AAA'
                        , RequestDate__c = requestDate
                        , Finder__c = '[36110]세종시'
                        , ReqRecordId__c = '1223334'
                        , RecordTypeId = osrRcdTp
        );

        insert orderServiceReq;
    }

    @isTest
    static void IFN_LIF1002_OD002_MD003_TEST(){
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        OrderServiceRequest__c orderServiceReq = [select Id from OrderServiceRequest__c Where ReqRecordId__c = '1223334' Limit 1];

        // Success Test 1
        String strBody = '{"reqId": "1223334","resId": '+ orderServiceReq.Id +'}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD003.doPost();
        
        // Success Test 2
        strBody = '{"reqId": "1223334"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD003.doPost();

        // Error Test 1
        strBody = '';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD003.doPost();

        // Error Test 2
        strBody = '{"dummy1": "1223334","dummy2": '+ orderServiceReq.Id +'}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD002_MD003.doPost();

        Test.stopTest();
    }
}