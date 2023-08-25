/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SalesMonthOfMASummary_test {
    @TestSetup
    static void testSetup(){
        Account objAccount = TestObjectCreator.objExAccount;

        insert objAccount;

        SalesLedgerInformation__c objSales = new SalesLedgerInformation__c();

        objSales.SLST__c = objAccount.Id;
        objSales.SALES_YMD__c = Date.today();
        objSales.CRG_MA_ID__c = 'test1234';
        objSales.SALE_UNPRC__c = 1000;
        objSales.ORDR_REAL_BUY_UNPRC__c = 500;
        objSales.RLSTK_UNIT_RLSTK_QTY__c = 1;
        objSales.SALES_AT__c = 500;

        insert objSales;

        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = 'test1234';

        update objUser;
    }

    @isTest
    static void itShouldSC() {
        Test.startTest();
        String CRON_EXP1 = '0 0 3 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
        SalesMonthOfMASummary_sc sc = new SalesMonthOfMASummary_sc(5);
        System.schedule('test', CRON_EXP1, sc);
        Test.stopTest();
    }
    
    @isTest
    static void itShould() {
        Test.startTest();

        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().addDays(1).day());

        SalesMonthOfMASummary_ba ba = new SalesMonthOfMASummary_ba(Date.today().addDays(-1), endDate, UserInfo.getUserId(), true, 5);
        Database.executeBatch(ba);

        Test.stopTest();
    }
}