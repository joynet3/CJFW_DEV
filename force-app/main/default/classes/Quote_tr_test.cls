/************************************************************************************
 * File Name   		    : Quote_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : Quote_tr.cls
 * Description 		    : Quote_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class Quote_tr_test {
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

        Test.startTest();
        
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

        Quote objUpdateQuote = new Quote();
        objUpdateQuote = [ SELECT    OpportunityId, Pricebook2Id, Name
                           FROM      Quote
                           LIMIT 1
                         ];
        objUpdateQuote.Name = '견적서 EDIT';
        update objUpdateQuote;

        Test.stopTest();
    }
}