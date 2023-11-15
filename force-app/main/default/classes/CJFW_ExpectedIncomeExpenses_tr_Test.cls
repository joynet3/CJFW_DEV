/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 11-14-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
@IsTest
public with sharing class CJFW_ExpectedIncomeExpenses_tr_Test {
    

    @isTest 
    static void test(){
        
        Test.startTest();

        // 계정
        Account objAcc = new Account();
        objAcc = COMM_ReportTestDataFactory.createAccount('Test','ExistingCustomer');
        insert objAcc;

        // 기회
        Opportunity objOppty = new Opportunity();
        objOppty = COMM_ReportTestDataFactory.createOpportunity('General', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        insert objOppty;

        // 신규개설품의(품의지정된 레코드 없을 경우)
        CJFW_ExpectedIncomeExpenses__c objExIncome = new CJFW_ExpectedIncomeExpenses__c();
        objExIncome = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);
        insert objExIncome;
        
        update objExIncome;
        
        delete objExIncome;


        Test.stopTest();
    }

    @isTest 
    static void test2(){
        
        Test.startTest();

        // 계정
        Account objAcc = new Account();
        objAcc = COMM_ReportTestDataFactory.createAccount('Test','ExistingCustomer');
        insert objAcc;

        // 기회
        Opportunity objOppty = new Opportunity();
        objOppty = COMM_ReportTestDataFactory.createOpportunity('General', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        insert objOppty;

        // 신규개설품의(품의지정된 레코드가 있을 경우)
        CJFW_ExpectedIncomeExpenses__c objExIncome = new CJFW_ExpectedIncomeExpenses__c();
        objExIncome = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);
        objExIncome.IsReportCheck__c = true; 
        insert objExIncome;
        
        update objExIncome;

        delete objExIncome;


        Test.stopTest();
    }
    
}