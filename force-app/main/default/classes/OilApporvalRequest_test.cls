/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class OilApporvalRequest_test {
    @testSetup
	static void setData() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = '123456';
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4700';
        objUser.Team__c = '325';

        update objUser;

        Event objEvent = new Event();
        objEvent.ActivityDate = Date.today();
        objEvent.WorkType__c = '외근';
        objEvent.Category__c = '기타';
        objEvent.Subject = 'Test';
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now().addHours(1);

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

        Map<String, String> mapParam = new Map<String, String>();

        OilApporvalRequest.doInit();

        mapParam.put('selectedStatus', 'Request');
        mapParam.put('selectedYear', String.valueOf(Date.today().year()));
        mapParam.put('selectedMonth', String.valueOf(Date.today().month()));

        User objUser = [
            SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, Team__c
            FROM    User
            WHERE   Id =: UserInfo.getUserId()
        ];
        
        mapParam.put('selectedSU', objUser.SU__c);
        mapParam.put('selectedTeam', objUser.Team__c);

        OilApporvalRequest.getDataTable(mapParam);

        List<OilApporvalRequest.SearchWrapper> listWrapper = new List<OilApporvalRequest.SearchWrapper>();
        OilApporvalRequest.SearchWrapper objWrapper = new OilApporvalRequest.SearchWrapper();
        objWrapper.objActivityReport = objAR;

        listWrapper.add(objWrapper);

        String strJSON = JSON.serialize(listWrapper);

        OilApporvalRequest.doSave(strJSON, 'Approved');

        Test.stopTest();
    }

}