/*
* ==================================================================================
*   File Name   : ChildCareLeadFileCreateController_test.cls
*   Author      : Minje.Kim
*   Date        : 2022.11.19
*   Target      : QuoteFileCreateController.cls
*   Description : QuoteFileCreateController
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.19    Minje.Kim    Create
* ==================================================================================
*/
@isTest
private class ChildCareLeadFileCreateController_test {
    @testSetup
	static void setData() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = '123456';
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4700';
        objUser.Team__c = '325';

        update objUser;
       
        Set<String> setIFId = new Set<String>{'IF_IFRESH_SFDC_PRICE_CONTROL_INFO'};

        List<IFMaster__c> listIF = new List<IFMaster__c>();

       /*for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'POST';
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;*/
	}

    @isTest 
    static void itShould() {
        String recordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('KindergartenLead').getRecordTypeId();
        Lead objLead =  new Lead();
        objLead.recordTypeId = recordtypeId;
        objLead.Region__c = '서울특별시은평구';
        objLead.AuthorizationDate__c = date.today();
        objLead.NumberofChildren__c = 0;
        objLead.LastName = 'CJFW';
        objLead.Company = '어린이집';
        insert objLead;

        Test.startTest();

        PageReference pageRef = Page.ChildCareLeadExcelCreate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('region',objLead.Region__c);

        ChildCareLeadFileCreateController controller = new ChildCareLeadFileCreateController();
        System.debug(controller.mapField);
        System.debug(controller.listSelectedField);
        System.debug(controller.ExcelColummLength);
        System.debug(controller.listLead);
        Test.stopTest();
    }
}