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
        objUser.HeadOffice__c = '6000';
        insert objUser;

        // 기회
        Opportunity objOppty = new Opportunity();
        objOppty = COMM_ReportTestDataFactory.createOpportunity('0120w0000022cWgAAI', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        objOppty.Owner = objUser;
        System.debug('objOppty.Owner'+objOppty.Owner);
        objOppty.Owner.HeadOffice__c = '6000';
        insert objOppty;

        // 신규개설품의
        CJFW_ExpectedIncomeExpenses__c objExIncome1 = new CJFW_ExpectedIncomeExpenses__c();
        objExIncome1 = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);
        objExIncome1.Opportunity__c = objOppty.Id;
        objExIncome1.ReportType__c = 'CRM008';
        insert objExIncome1;

        CJFW_ExpectedIncomeExpenses__c objExIncome2 = new CJFW_ExpectedIncomeExpenses__c();
        objExIncome2 = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);
        objExIncome2.Opportunity__c = objOppty.Id;
        objExIncome2.ReportType__c = 'CRM009';
        insert objExIncome2;

        // objExIncome3 = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);
        // objExIncome3.ReportType__c = 'CRM010';
        // insert objExIncome3;

        
    }

    @isTest
    public static void test1(){

        User objUser = [SELECT Id FROM User LIMIT 1];
        Test.startTest();


        Opportunity objOppty = [SELECT Id FROM Opportunity LIMIT 1]; 
        
        CJFW_ExpectedIncomeExpenses__c objExIncome1 = [SELECT Id, ReportType__c  FROM CJFW_ExpectedIncomeExpenses__c LIMIT 1];
        System.debug('objExIncome1'+objExIncome1.ReportType__c);
        objOppty.Owner = objUser;
        objOppty.Owner.HeadOffice__c = '3001';
        // objExIncome.Opportunity__c = objOppty.Id;
        // objExIncome.ReportType__c = 'CRM008';

        // System.debug('HeadOffice__c !!'+ objOppty.Owner.HeadOffice__c);
        // System.debug('retype Id !!'+ objExIncome.ReportType__c);
        CJFW_ExpectedIncoExpenRelatedController.getList(objOppty.Id);


        Test.stopTest();  
    }

    @isTest
    public static void test2(){

        Test.startTest();

        Opportunity objOppty = [SELECT Id FROM Opportunity LIMIT 1]; 
        CJFW_ExpectedIncomeExpenses__c objExIncome2 = [SELECT Id, ReportType__c FROM CJFW_ExpectedIncomeExpenses__c LIMIT 1];
        System.debug('objExIncome2'+objExIncome2.ReportType__c);

        // objExIncome.ReportType__c = 'CRM008';
        CJFW_ExpectedIncoExpenRelatedController.getList(objOppty.Id);

        Test.stopTest();  
    }

    @isTest
    public static void test3(){
        Test.startTest();

        Opportunity objOppty = [SELECT Id, Type, OwnerId, Owner.HeadOffice__c FROM Opportunity LIMIT 1];
        CJFW_ExpectedIncomeExpenses__c objExIncome = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c LIMIT 1];

        objOppty.Owner.HeadOffice__c = '6000';
        objOppty.Type = 'New Business';
        objExIncome.ReportType__c = 'CRM009';
        System.debug('HeadOffice__c !!'+ objOppty.Owner.HeadOffice__c);
        System.debug('retype Id !!'+ objExIncome.ReportType__c);

        List<CJFW_ExpectedIncomeExpenses__c> result = CJFW_ExpectedIncoExpenRelatedController.getList(objOppty.Id);

        System.assertEquals(1, result.size());

        Test.stopTest();
    }

    @isTest
    public static void test4(){
        Test.startTest();

        Opportunity objOppty = [SELECT Id, Type, OwnerId, Owner.HeadOffice__c FROM Opportunity LIMIT 1];
        CJFW_ExpectedIncomeExpenses__c objExIncome = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c LIMIT 1];

        objOppty.Owner.HeadOffice__c = '6000';
        objOppty.Type = 'Existing Business';
        objExIncome.ReportType__c = 'CRM010';
        System.debug('HeadOffice__c !!'+ objOppty.Owner.HeadOffice__c);
        System.debug('retype Id !!'+ objExIncome.ReportType__c);

        List<CJFW_ExpectedIncomeExpenses__c> result = CJFW_ExpectedIncoExpenRelatedController.getList(objOppty.Id);

        System.assertEquals(1, result.size());

        Test.stopTest();
    }
}