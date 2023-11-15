@isTest
public with sharing class CJFW_SchoolCafeteriaDetailsCon_TEST {
    
    @testSetup
    static void makeData() {
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        IFMaster__c objIFMaster = new IFMaster__c();
        objIFMaster.Name                = 'IFN_EIF1004_DT001_MD001';
        objIFMaster.Type__c             = 'Outbound';
        objIFMaster.WebserviceType__c   = 'REST';
        objIFMaster.Method__c           = 'GET';
        objIFMaster.ContentType__c      = 'application/json';
        objIFMaster.Endpoint__c         = 'https://dotop.kr/Service/API/';
        listIFMaster.add(objIFMaster);

        IFMaster__c objIFMaster2 = new IFMaster__c();
        objIFMaster2.Name                = 'IFN_EIF1004_DT001_MD002';
        objIFMaster2.Type__c             = 'Outbound';
        objIFMaster2.WebserviceType__c   = 'REST';
        objIFMaster2.Method__c           = 'GET';
        objIFMaster2.ContentType__c      = 'application/json';
        objIFMaster2.Endpoint__c         = 'https://dotop.kr/Service/API/';
        listIFMaster.add(objIFMaster2);
		
        insert listIFMaster;
    }
    
    @isTest
    static void getInitOptionList_TEST() {
        test.startTest();
        CJFW_SchoolCafeteriaDetailsController.getInitOptionList();
        test.stopTest();
    }

    @isTest
    static void getDistrictCountryOptionList_TEST() {
        test.startTest();
        CJFW_SchoolCafeteriaDetailsController.getDistrictCountryOptionList('강원');
        test.stopTest();
    }

    @isTest
    static void getRegionalShoolInfo_TEST() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new IFN_EIF1004_DT001_MD001_TEST.MockHttpResponseGenerator());
        Map<String,Object> params = new Map<String,Object>();
        params.put('citiyCountry', '서울');
        CJFW_SchoolCafeteriaDetailsController.getRegionalShoolInfo(params);
        test.stopTest();
    }

    @isTest
    static void getSchoolCafeteriaDetails_TEST() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new IFN_EIF1004_DT001_MD002_TEST.MockHttpResponseGenerator());
        Map<String,Object> params = new Map<String,Object>();
        params.put('schoolCode', '7569036');
        params.put('fromDateStr', '20231001');
        params.put('toDateStr', '20231030');
        CJFW_SchoolCafeteriaDetailsController.getSchoolCafeteriaDetails(params);
        test.stopTest();
    }
    
    
}