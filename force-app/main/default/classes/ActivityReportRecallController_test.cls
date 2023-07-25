/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class ActivityReportRecallController_test {
    @testSetup
	static void setData() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = '123456';
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4700';
        objUser.Team__c = '325';

        update objUser;

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        Event objEvent = new Event();
        objEvent.ActivityDate = Date.today();
        objEvent.Subject = 'Test';
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now().addHours(1);
        objEvent.WhatId = objAccount.Id;

        insert objEvent;
	}

    @isTest 
    static void itShould() {

        List<ActivityReport__c> listAR = new List<ActivityReport__c>();

        listAR = [
            SELECT  Id
            FROM    ActivityReport__c
            LIMIT 1            
        ];

        ActivityReport__c objAR = new ActivityReport__c();

        if(listAR <> null && listAR.size() > 0) {
            objAR = listAR[0];
        }else {
            
        }

        objAR.ApprovalStatus__c = 'Request';
        objAR.EventStartDate__c = Date.today();        
        objAR.OilTotalAmount__c = 1000;
        objAR.OilTotalDistance__c = 10;
        objAR.User__c = UserInfo.getUserId();
        upsert objAR;

        Test.startTest();

        ActivityReportRecallController.getInitData(objAR.Id);
        ActivityReportRecallController.doRecall(objAR.Id);

        // catch
        try {
            ActivityReportRecallController.getInitData(UserInfo.getUserId());
        } catch (Exception e) {
            system.debug('ActivityReportRecallApprovalController_test : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }

        // catch
        try {
            ActivityReportRecallController.doRecall(UserInfo.getUserId());
        } catch (Exception e) {
            system.debug('ActivityReportRecallApprovalController_test : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        } 

        Test.stopTest();
    }

}