/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 11-09-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
@isTest
public with sharing class CJFW_ExpectedExpenRelatedController_Test {
    
    @TestSetup
    static void makeData(){
        // 계정
        Account objAcc = new Account();
        objAcc = COMM_ReportTestDataFactory.createAccount('Test','ExistingCustomer');
        insert objAcc;

        // 사용자
        User objUser = new User();
        objUser = COMM_ReportTestDataFactory.createUser('00e5i0000022sAxAAI');
        insert objUser;

        // 기회
        Opportunity objOppty = new Opportunity();
        objOppty = COMM_ReportTestDataFactory.createOpportunity('0120w0000022cWgAAI', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        objOppty.Owner = objUser;
        objOppty.Owner.HeadOffice__c = '3001';
        insert objOppty;

        // 신규개설품의
        CJFW_ExpectedIncomeExpenses__c objExIncome = new CJFW_ExpectedIncomeExpenses__c();
        objExIncome = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);
        objExIncome.ReportType__c = 'CRM009';
        insert objExIncome;

        
    }

    @isTest
    public static void test1(){

        User objUser = [SELECT Id FROM User LIMIT 1];
        Test.startTest();

        System.runAs(objUser){

            Opportunity objOppty = [SELECT Id FROM Opportunity LIMIT 1]; 
            
            CJFW_ExpectedIncomeExpenses__c objExIncome = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c LIMIT 1];
            objOppty.Owner = objUser;
            objOppty.Owner.HeadOffice__c = '3001';
            objExIncome.Opportunity__c = objOppty.Id;
            objExIncome.ReportType__c = 'CRM008';
            CJFW_ExpectedIncoExpenRelatedController.getList(objOppty.Id);

        }

        Test.stopTest();  
    }

    @isTest
    public static void test2(){

        Test.startTest();

        Opportunity objOppty = [SELECT Id FROM Opportunity LIMIT 1]; 
        CJFW_ExpectedIncomeExpenses__c objExIncome = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c LIMIT 1];

        objExIncome.ReportType__c = 'CRM008';
        CJFW_ExpectedIncoExpenRelatedController.getList(objOppty.Id);

        Test.stopTest();  
    }
}