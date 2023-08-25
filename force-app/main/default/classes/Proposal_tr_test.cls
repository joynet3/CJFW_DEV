/************************************************************************************
 * File Name   		    : Proposal_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : Proposal_tr.cls
 * Description 		    : Proposal_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class Proposal_tr_test {
    @isTest 
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;

        insert objAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;


        Test.startTest();
        Proposal__c objProposal = new Proposal__c();
        objProposal.Opportunity__c = objOpportunity.Id;
        objProposal.StartDateTime__c = datetime.valueOf('2022-01-01 15:00:00.000Z');
        objProposal.EndDateTime__c = datetime.valueOf('2022-01-02 15:00:00.000Z');
        objProposal.Name = '제안';
        insert objProposal;

        String strProposalId = objProposal.Id;
        objProposal = new Proposal__c();
        objProposal.Id = strProposalId;
        objProposal.Name = '제안 EDIT';
        update objProposal;

        Test.stopTest();
    }
}