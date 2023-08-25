/************************************************************************************
 * File Name   		    : Negotiation_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : Negotiation_tr.cls
 * Description 		    : Negotiation_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@isTest
public with sharing class Negotiation_tr_test {
    @isTest
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;

        insert objAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = Date.valueOf('2022-01-01');
        objOpportunity.StageName = 'PreSales';
        insert objOpportunity;


        Test.startTest();
        Negotiation__c objNegotiation = new Negotiation__c();
        objNegotiation.Opportunity__c = objOpportunity.Id;
        objNegotiation.StartDateTime__c = Datetime.valueOf('2022-01-01 15:00:00.000Z');
        objNegotiation.EndDateTime__c = Datetime.valueOf('2022-01-02 15:00:00.000Z');
        objNegotiation.Name = '사전영업';
        
        insert objNegotiation;

        String strNegotiationId = objNegotiation.Id;
        objNegotiation = new Negotiation__c();
        objNegotiation.Id = strNegotiationId;
        objNegotiation.StartDateTime__c = Datetime.valueOf('2022-01-01 15:00:00.000Z');
        objNegotiation.EndDateTime__c = Datetime.valueOf('2022-01-02 15:00:00.000Z');
        objNegotiation.Name = '사전영업 EDIT';
        update objNegotiation;

        Test.stopTest();
    }
}