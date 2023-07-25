/*
* ==================================================================================
*   File Name   : QuoteFileCreateController_test.cls
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
private class QuoteFileCreateController_test {
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

        for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'POST';
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;
	}

    @isTest 
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        PricebookEntry objPriceBookEntry = TestObjectCreator.objPricebookEntry;
        insert objPriceBookEntry;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.Pricebook2Id = objPriceBookEntry.Pricebook2Id;
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;

        Quote objQuote = new Quote();
        objQuote.OpportunityId = objOpportunity.Id;
        objQuote.Pricebook2Id = objPriceBookEntry.Pricebook2Id;
        objQuote.Name = '견적서';
        insert objQuote;

        QuoteLineItem objQuoteLineItem = new QuoteLineItem();
        objQuoteLineItem.QuoteId = objQuote.Id;
        objQuoteLineItem.PricebookEntryId = objPriceBookEntry.Id;
        objQuoteLineItem.UnitPrice = 2000;
        objQuoteLineItem.Quantity = 1;
        insert objQuoteLineItem;

        OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
        objOpportunityLineItem.OpportunityId = objOpportunity.Id;
        objOpportunityLineItem.PricebookEntryId = objPriceBookEntry.Id;
        objOpportunityLineItem.UnitPrice = 2000;
        objOpportunityLineItem.Quantity = 1;
        insert objOpportunityLineItem;

        Test.startTest();

        PageReference pageRef = Page.QuotePDFCreate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', objQuote.Id);
        ApexPages.currentPage().getParameters().put('listSelectedField', 'fm_PriceBookEntryName__c');

        QuoteFileCreateController controller = new QuoteFileCreateController();
        System.debug(controller.recordId);
        System.debug(controller.objQuote);
        System.debug(controller.objOwner);
        System.debug(controller.mapField);
        System.debug(controller.listSelectedField);
        System.debug(controller.listQuoteLineItem);

        QuoteFileCreateController.doCreateFile(objQuote.Id, 'PDF', 'fm_PriceBookEntryName__c');
        QuoteFileCreateController.doCreateFile(objQuote.Id, 'Excel', 'fm_PriceBookEntryName__c');
        QuoteFileCreateController.getInitData();
        

        Test.stopTest();
    }
}