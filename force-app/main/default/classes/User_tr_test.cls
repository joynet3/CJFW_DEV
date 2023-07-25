/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class User_tr_test {
    @testSetup
	static void setData() {
        User objUser = new User();

        objUser.Id = UserInfo.getUserId();
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = null;
        objUser.Team__c = null;
        objUser.CJTitle__c = 'MA';

        update objUser;

        UserRole objUserRole = new UserRole();
        objUserRole.Name = 'TestRole';
        objUserRole.DeveloperName = 'CJFW_3001_4100_153_MA';

        insert objUserRole;

	}

    @isTest 
    static void itShoud() {
        Test.startTest();

        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4100';
        objUser.Team__c = '153';
        objUser.CJTitle__c = 'MA';        

        update objUser;

        Test.stopTest();
    }
}