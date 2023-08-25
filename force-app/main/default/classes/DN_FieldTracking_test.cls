/************************************************************************************
 * File Name   		    : DN_FieldTracking_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.25
 * Target	  		    : DN_FieldTracking.cls
 * Description 		    : DN_FieldTracking Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.25      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class DN_FieldTracking_test {
    @isTest 
    static void itShould() {
        
        User objUser = new User(Alias = 'standt', Email='CJFreshway_TEST@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles',
         UserName='CJFreshway_TEST@testorg.com');

        insert objUser;

        ActivityReport__c objOldActivityReport = new ActivityReport__c();
        objOldActivityReport.EventStartDate__c = Date.valueOf('2022-01-01');
        objOldActivityReport.ApprovalStatus__c = 'Writing';
        objOldActivityReport.CommentForApproval__c = '설명';
        objOldActivityReport.OilTotalAmount__c = 1000;
        objOldActivityReport.OwnerId = UserInfo.getUserId();        
        objOldActivityReport.EventStartDate__c = Date.today().addDays(-1);
        objOldActivityReport.IsApprovalRequest__c = false;
        objOldActivityReport.DescriptionRichText__c = 'test';
        insert objOldActivityReport;

        ActivityReport__c objNewActivityReport = objOldActivityReport.clone();
        objNewActivityReport.EventStartDate__c = Date.valueOf('2022-01-02');
        objNewActivityReport.ApprovalStatus__c = 'Request';
        objNewActivityReport.CommentForApproval__c = '설명';
        objNewActivityReport.OilTotalAmount__c = 2000;
        objNewActivityReport.OwnerId = objUser.Id;        
        objNewActivityReport.EventStartDate__c = Date.today();
        objOldActivityReport.IsApprovalRequest__c = true;
        objOldActivityReport.DescriptionRichText__c = 'test1234';
        insert objNewActivityReport;

        Map<Id, SObject> mapOld = new Map<Id, SObject>();
        mapOld.put(objNewActivityReport.Id, objOldActivityReport);

        List<SObject> listNew = new List<SObject>();
        listNew.add(objNewActivityReport);

        Test.startTest();

        DN_FieldTracking.doFieldTrackingInsert('ActivityReport__c', 'ActivityReportTracking', listNew, mapOld);

        List<FieldTracking__c> listFieldTracking = new List<FieldTracking__c>();
        listFieldTracking = [
                SELECT      Id, ActivityReport__c, Name, Label__c, OriginalValue__c, NewValue__c, User__c, fm_User__c, ChangeDT__c
                FROM        FieldTracking__c
                ORDER BY    ChangeDT__c DESC
                LIMIT       1
        ];
        if(!listFieldTracking.isEmpty()) {
            DN_FieldTracking.getData(listFieldTracking[0].Id);
        }

        Test.stopTest();


    }
}