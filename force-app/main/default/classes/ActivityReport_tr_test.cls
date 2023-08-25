/************************************************************************************
 * File Name   		    : ActivityReport_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : ActivityReport_tr.cls`
 * Description 		    : ActivityReport_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class ActivityReport_tr_test {
    @isTest 
    static void itShould() {
        Test.startTest();
        Account objExAccount = TestObjectCreator.objExAccount;
        insert objExAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objExAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;


        Event objEvent = new Event();
        objEvent.ActivityDate = Date.today();
        objEvent.Subject = 'Test';
        objEvent.Opportunity__c = objOpportunity.Id;
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now().addHours(1);
        objEvent.WorkType__c = '외근';
        insert objEvent;

        ActivityReport__c objActivityReport = [
            SELECT Id, ApprovalStatus__c  FROM ActivityReport__c LIMIT 1
        ];

        objActivityReport.ApprovalStatus__c = 'Request';

        update objActivityReport;

        Test.stopTest();
    }
}