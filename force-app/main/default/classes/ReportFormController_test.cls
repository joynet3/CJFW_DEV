/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 10-16-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
@IsTest
public with sharing class ReportFormController_test {

    @isTest
    static void ReportFormController_test() {
        Account objAccount = TestObjectCreator.getObjAccount();
        insert objAccount;

        Opportunity objOppty = new Opportunity();
        objOppty.Name = 'Test Oppty';
        objOppty.AccountId = objAccount.Id;
        objOppty.CloseDate = date.valueOf('2023-10-01');
        objOppty.StageName = 'Negotiation';
        insert objOppty;

        CJFW_ExpectedIncomeExpenses__c objIncome = new CJFW_ExpectedIncomeExpenses__c();
        objIncome.Opportunity__c = objOppty.Id;
        objIncome.Version__c = 1;
        insert objIncome;

        CJFW_ExpectedIncomeManager__c objIncomeManager = new CJFW_ExpectedIncomeManager__c();
        objIncomeManager.StartDate__c = date.valueOf('2023-01-01');
        insert objIncomeManager;

        CJFW_DistributionCost__c objCost = new CJFW_DistributionCost__c();
        objCost.StartDate__c = date.valueOf('2023-01-01');
        insert objCost;

        // User objUser = new User();
        
        // objUser = COMM_TestDataFactory.createUser([SELECT Id,Name FROM Profile WHERE Name ='System Administrator' limit 1].Id);
        // insert objUser;


        Test.startTest();

        ReportFormController controller = new ReportFormController();

        controller.getAccountInfo();
        controller.getIncomeExpenses();
        // ReportFormController.getPicklistValues();

        // ReportFormController.getIncomeExpenses();
        
        // ReportFormController.getExpectManager();

        // ReportFormController.getDistributeCost();
        

        Test.stopTest();
    }
}