/************************************************************************************
 * File Name   		    : QuoteLineItem_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : QuoteLineItem_tr.cls
 * Description 		    : QuoteLineItem_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class QuoteLineItem_tr_test {
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

        Test.startTest();
        
        OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
        objOpportunityLineItem.OpportunityId = objOpportunity.Id;
        objOpportunityLineItem.PricebookEntryId = objPriceBookEntry.Id;
        objOpportunityLineItem.UnitPrice = 2000;
        objOpportunityLineItem.Quantity = 1;
        insert objOpportunityLineItem;

        QuoteLineItem objQuoteLineItem = new QuoteLineItem();
        objQuoteLineItem.QuoteId = objQuote.Id;
        objQuoteLineItem.OpportunityLineItemId = objOpportunityLineItem.Id;
        objQuoteLineItem.PricebookEntryId = objPriceBookEntry.Id;
        objQuoteLineItem.UnitPrice = 2000;
        objQuoteLineItem.Quantity = 1;
        insert objQuoteLineItem;

        Test.stopTest();
    }
}