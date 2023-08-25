/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SalesBusinessPlan_ba_test {
    @TestSetup
    static void testSetup(){

        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = 'test1234';
        update objUser;

        SalesMonthOfMASummary__c objSales = new SalesMonthOfMASummary__c();

        //objSales.CRG_MA_ID__c = objUser.EmployeeNumber;
        objSales.SalesDate__c = Date.today().addDays(-1);
        objSales.TotalNetAmount__c = 1000;
        objSales.TotalSalesAmount__c = 1100;
        objSales.TotalSalesProfit__c = 100;

        insert objSales;
    }

    @isTest
    static void itShould() {
        Test.startTest();

        //Date dtTarget = Date.newInstance(2023, 1, 1);
        SalesBusinessPlan_ba ba = new SalesBusinessPlan_ba(UserInfo.getUserId(), Date.today().year(), Date.today().month());
        Database.executeBatch(ba);

        Test.stopTest();
    }
}