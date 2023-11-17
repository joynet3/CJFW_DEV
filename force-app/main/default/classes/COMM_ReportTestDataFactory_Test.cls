/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 11-16-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
@isTest
public with sharing class COMM_ReportTestDataFactory_Test {


    @isTest
    static void test() {

        Test.startTest();

        //UserRole
        UserRole objRole = new UserRole();
        objRole = COMM_ReportTestDataFactory.getUserRole('SFDC_3001_4100_153_S_MA');
        
        // 계정
        Account objAcc = new Account();
        objAcc = COMM_ReportTestDataFactory.createAccount('Test','ExistingCustomer');
        insert objAcc;

        // 기회
        Opportunity objOppty = new Opportunity();
        objOppty = COMM_ReportTestDataFactory.createOpportunity('General', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        insert objOppty;

        // 물류비관리
        CJFW_DistributionCost__c objCost = new CJFW_DistributionCost__c();
        objCost = COMM_ReportTestDataFactory.createDistributeCost('General');
        insert objCost;

        // 예상손익관리
        CJFW_ExpectedIncomeManager__c objManage = new CJFW_ExpectedIncomeManager__c();
        objManage = COMM_ReportTestDataFactory.createExpectedIncomeManager();
        insert objManage;

        // 신규개설품의
        CJFW_ExpectedIncomeExpenses__c objExIncome = new CJFW_ExpectedIncomeExpenses__c();
        objExIncome = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);

        Test.stopTest();  
    }
}