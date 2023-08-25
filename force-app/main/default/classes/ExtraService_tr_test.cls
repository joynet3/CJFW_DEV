/************************************************************************************
 * File Name   		    : ExtraService_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : ExtraService_tr.cls
 * Description 		    : ExtraService_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class ExtraService_tr_test {
    @isTest 
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();
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
        
        ExtraService__c objExtraService = new ExtraService__c();
        objExtraService.ServiceContents__c = objServiceContents.Id;
        objExtraService.Customer__c = objAccount.Id;
        insert objExtraService;

        String strExtraService = objExtraService.Id;
        objExtraService = new ExtraService__c();
        objExtraService.Id = strExtraService;
        objExtraService.ServiceContents__c = objServiceContents.Id;
        objExtraService.Customer__c = objAccount.Id;
        objExtraService.Status__c = 'A';
        update objExtraService;

        Test.stopTest();
    }
}