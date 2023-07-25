/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-27-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SalesSummaryBefore_test {
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
    static void itShouldSC1() {
        Test.startTest();

        String CRON_EXP1 = '0 0 1 * * ? *'; 
        SalesAccountSummaryBefore_sc sca = new SalesAccountSummaryBefore_sc(10);
        System.schedule('TEST A', CRON_EXP1, sca);

        Test.stopTest();
    }

    @isTest
    static void itShouldSC2() {
        Test.startTest();

        String CRON_EXP1 = '0 0 1 * * ? *';
        SalesProductSummaryBefore_sc scp = new SalesProductSummaryBefore_sc(10);
        System.schedule('TEST P', CRON_EXP1, scp);

        Test.stopTest();
    }

    @isTest
    static void itShouldSC3() {
        Test.startTest();

        String CRON_EXP1 = '0 0 1 * * ? *';
        SalesMonthOfMASummaryBefore_sc scm = new SalesMonthOfMASummaryBefore_sc(10);
        System.schedule('TEST M', CRON_EXP1, scm);
        
        Test.stopTest();
    }
}