/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-02-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SalesProductSummary_test {
    @TestSetup
    static void testSetup(){
        Account objAccount = TestObjectCreator.objExAccount;
        objAccount.CustomerPath__c = '3000';
        insert objAccount;

        SalesLedgerInformation__c objSales = new SalesLedgerInformation__c();

        objSales.SLST__c = objAccount.Id;
        objSales.SALES_YMD__c = Date.today().addDays(-1);
        objSales.SALE_UNPRC__c = 1000;
        objSales.ORDR_REAL_BUY_UNPRC__c = 500;
        objSales.RLSTK_UNIT_RLSTK_QTY__c = 1;
        objSales.SALES_AT__c = 500;
        objSales.GD_NO__c = '123123';
        objSales.GD_NM__c = '테스트상품';
        objSales.LAR_GD_CLS_ID__c = '10';
        objSales.MID_GD_CLS_ID__c = '1004';
        objSales.SML_GD_CLS_ID__c = '100405';

        insert objSales;
    }

    @isTest
    static void itShouldSC() {
        Test.startTest();

        String CRON_EXP1 = '0 0 2 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
        SalesProductSummary_sc sc = new SalesProductSummary_sc(5);
        System.schedule('매출원장정보 상품별 Summary(SalesProductSummary__c) 02:00', CRON_EXP1, sc);

        Test.stopTest();
    }

    /*
    @isTest
    static void itShould() {
        Test.startTest();

        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().addDays(-1).day());

        SalesProductSummary_ba ba = new SalesProductSummary_ba(startDate, endDate, true, 5);
        Database.executeBatch(ba, 5);

        Test.stopTest();
    }
    */
}