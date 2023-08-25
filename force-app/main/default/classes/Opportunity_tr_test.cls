/************************************************************************************
 * File Name   		    : Opportunity_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : Opportunity_tr.cls
 * Description 		    : Opportunity_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class Opportunity_tr_test {
    @isTest 
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        PricebookEntry objPriceBookEntry = TestObjectCreator.objPricebookEntry;
        insert objPriceBookEntry;

        Test.startTest();

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'NaraMarket';
            objOpportunity.BidQualifyRegistCloseDateTime__c = date.valueOf('2022-01-01');
            insert objOpportunity;
            
            objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'NaraMarket';
            objOpportunity.BidQualifyRegistCloseDateTime__c = null;
            objOpportunity.BidCloseDateTime__c = date.valueOf('2022-01-01');
            insert objOpportunity;

            objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'NaraMarket';
            objOpportunity.BidQualifyRegistCloseDateTime__c = null;
            objOpportunity.BidCloseDateTime__c = null;
            objOpportunity.BidOpenDateTime__c = date.valueOf('2022-01-01');
            insert objOpportunity;

            objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'Military';
            objOpportunity.BidRegistCloseDateTime__c = date.valueOf('2022-01-01');
            insert objOpportunity;
            
            objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'Military';
            objOpportunity.BidRegistCloseDateTime__c = null;
            objOpportunity.BidLetterSubmitCloseDateTime__c = date.valueOf('2022-01-01');
            insert objOpportunity;

            objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'Military';
            objOpportunity.BidQualifyRegistCloseDateTime__c = null;
            objOpportunity.BidCloseDateTime__c = null;
            objOpportunity.BidOpenDateTime__c = date.valueOf('2022-01-01');

            insert objOpportunity;

            Contract objContract = new Contract();
            objContract.AccountId = objAccount.Id;
            insert objContract;

            objOpportunity.ContractId = objContract.Id;
            update objOpportunity;

            Opportunity objClone = new Opportunity();
            objClone = objOpportunity.Clone();
            insert objClone;

        Test.stopTest();
    }
}