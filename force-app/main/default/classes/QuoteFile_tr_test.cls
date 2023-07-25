/************************************************************************************
 * File Name   		    : QuoteFile_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : QuoteFile_tr.cls
 * Description 		    : QuoteFile_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class QuoteFile_tr_test {
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

        ContentVersion objContentVersion = new Contentversion();
        objContentVersion.Title = 'test';
        objContentVersion.PathOnClient = 'test';
        objContentVersion.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert objContentVersion;
    
        QuoteFile__c objQuoteFile = new QuoteFile__c();
        objQuoteFile.Quote__c = objQuote.Id;
        objQuoteFile.ContentDocumentId__c = objContentVersion.ContentDocumentId;
        insert objQuoteFile; 


        String strQuoteFileId = objQuoteFile.Id;
        objQuoteFile = new QuoteFile__c();
        objQuoteFile.Id = strQuoteFileId;
        delete objQuoteFile; 
        
        Test.stopTest();
    }
}