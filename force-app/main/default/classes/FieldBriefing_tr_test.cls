/************************************************************************************
 * File Name   		    : FieldBriefing_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : FieldBriefing_tr.cls
 * Description 		    : FieldBriefing_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class FieldBriefing_tr_test {
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
        FieldBriefing__c objFieldBriefing = new FieldBriefing__c();
        objFieldBriefing.Opportunity__c = objOpportunity.Id;
        objFieldBriefing.Name = '현장설명회';
        objFieldBriefing.StartDateTime__c = datetime.valueOf('2022-01-01 15:00:00.000Z');
        objFieldBriefing.EndDateTime__c = datetime.valueOf('2022-01-02 15:00:00.000Z');
        insert objFieldBriefing;

        String strFieldBriefingId = objFieldBriefing.Id;
        objFieldBriefing = new FieldBriefing__c();
        objFieldBriefing.Id = strFieldBriefingId;
        objFieldBriefing.Name = '현장설명회 EDIT';
        update objFieldBriefing;

        Test.stopTest();
    }
}