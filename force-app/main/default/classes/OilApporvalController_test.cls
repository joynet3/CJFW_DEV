/************************************************************************************
 * File Name   		    : OilApporvalController_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.12.04
 * Target	  		    : OilApporvalController.cls
 * Description 		    : OilApporvalController Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.12.04      Minje.kim       Create
 *************************************************************************************/

@isTest
private class OilApporvalController_test {
    @testSetup
	static void setData() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = '123456';
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4700';
        objUser.Team__c = '325';

        update objUser;

	}

    @isTest 
    static void itShould() {

        Test.startTest();
        OilApporvalController.doInit();
        Test.stopTest();
    }

}