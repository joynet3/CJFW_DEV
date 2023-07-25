/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-27-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SalesAccountSummary_test {
    @TestSetup
    static void testSetup(){
        Account objAccount = TestObjectCreator.objExAccount;

        insert objAccount;

        SalesLedgerInformation__c objSales = new SalesLedgerInformation__c();

        objSales.SLST__c = objAccount.Id;
        objSales.SALES_YMD__c = Date.today().addDays(-1);
        objSales.SALE_UNPRC__c = 1000;
        objSales.ORDR_REAL_BUY_UNPRC__c = 500;
        objSales.RLSTK_UNIT_RLSTK_QTY__c = 1;
        objSales.SALES_AT__c = 500;

        insert objSales;
    }

    @isTest
    static void itShouldSC() {
        Test.startTest();

        String CRON_EXP1 = '0 0 1 * * ? *'; 
        SalesAccountSummary_sc sc = new SalesAccountSummary_sc(50);
        System.schedule('매출원장정보 고객 Summary(SalesAccountSummary__c) 01:00', CRON_EXP1, sc);
        Test.stopTest();
    }

    /*
    @isTest
    static void itShould() {
        Test.startTest();

        SalesAccountSummary_ba ba = new SalesAccountSummary_ba(null, null);
        Database.executeBatch(ba);

        Test.stopTest();
    }
    */
}