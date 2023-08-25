/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SalesSummaryDel_test {
    @TestSetup
    static void testSetup(){
        Account objAccount = TestObjectCreator.objExAccount;

        insert objAccount;

        SalesAccountSummary__c objSales = new SalesAccountSummary__c();

        //objSales.CRG_MA_ID__c = objUser.EmployeeNumber;
        objSales.SalesDate__c = Date.today().addMonths(-14);
        objSales.TotalNetAmount__c = 1000;
        objSales.TotalSalesAmount__c = 1100;
        objSales.TotalSalesProfit__c = 100;
        objSales.ExtId__c = 'test1234';

        insert objSales;

        SalesProductSummary__c objPro = new SalesProductSummary__c();

        //objPro.CRG_MA_ID__c = objUser.EmployeeNumber;
        objPro.SalesDate__c = Date.today().addMonths(-14);
        objPro.TotalNetAmount__c = 1000;
        objPro.TotalSalesAmount__c = 1100;
        objPro.TotalSalesProfit__c = 100;
        objPro.ExtId__c = 'test1234';

        insert objPro;

        SalesMonthOfMASummary__c objMA = new SalesMonthOfMASummary__c();

        //objMA.CRG_MA_ID__c = objUser.EmployeeNumber;
        objMA.SalesDate__c = Date.today().addMonths(-14);
        objMA.TotalNetAmount__c = 1000;
        objMA.TotalSalesAmount__c = 1100;
        objMA.TotalSalesProfit__c = 100;
        objMA.ExtId__c = 'test1234';

        insert objMA;

        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = 'test1234';

        update objUser;


    }

    @isTest
    static void itShouldSC() {
        Test.startTest();

        String CRON_EXP = '0 45 0 1 * ? *';
        SalesSummaryDel_sc sc = new SalesSummaryDel_sc();
        System.schedule('매출합계(고객/상품/MA별) 데이터 삭제(SalesSummaryDel_ba) 매월 1일 00:45 Test', CRON_EXP, sc);
    }

    
    @isTest
    static void itShould() {
        Test.startTest();

        SalesSummaryDel_ba ba = new SalesSummaryDel_ba(null, null);
        Database.executeBatch(ba, 1000);

        Test.stopTest();
    }
}