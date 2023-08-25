/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-23-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class MIG_SalesOwnerChange_ba_test {
    @TestSetup
    static void testSetup(){
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = 'test1234';
        update objUser;

        Account objAccount = TestObjectCreator.objExAccount;

        insert objAccount;

        SalesLedgerInformation__c objSales = new SalesLedgerInformation__c();

        objSales.SLST__c = objAccount.Id;
        objSales.SALES_YMD__c = Date.today();
        objSales.SALE_UNPRC__c = 1000;
        objSales.ORDR_REAL_BUY_UNPRC__c = 500;
        objSales.RLSTK_UNIT_RLSTK_QTY__c = 1;
        objSales.SALES_AT__c = 500;
        objSales.CRG_MA_ID__c = 'test1234';

        insert objSales;
    }

    @isTest
    static void itShould() {
        Test.startTest();

        MIG_SalesOwnerChange_ba ba = new MIG_SalesOwnerChange_ba(null);
        Database.executeBatch(ba);

        Test.stopTest();
    }
}