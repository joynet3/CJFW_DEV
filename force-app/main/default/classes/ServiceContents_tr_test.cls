/************************************************************************************
 * File Name   		    : ServiceContents_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : ServiceContents_tr.cls
 * Description 		    : ServiceContents_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class ServiceContents_tr_test {
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
        
        ServiceContents__c objServiceContents = new ServiceContents__c();
        objServiceContents.Name = '부가서비스 컨텐츠';
        insert objServiceContents;

        String strServiceContentsId = objServiceContents.Id;
        objServiceContents = new ServiceContents__c();
        objServiceContents.Id = strServiceContentsId;
        objServiceContents.Name = '부가서비스 컨텐츠';
        update objServiceContents;
        Test.stopTest();
    }
}