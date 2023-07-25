/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-30-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class BusinessPlanAutoCreate_ba_test {
    @TestSetup
    static void testSetup(){

        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = 'test1234';
        update objUser;
    }

    @isTest
    static void itShould() {
        Test.startTest();

        //Date dtTarget = Date.newInstance(2023, 1, 1);
        BusinessPlanAutoCreate_ba ba = new BusinessPlanAutoCreate_ba(null, null);
        Database.executeBatch(ba);

        Test.stopTest();
    }
}