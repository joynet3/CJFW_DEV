/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
@isTest
public with sharing class CJFW_ExpectedIncoRelatedController_Test {
    
    @TestSetup
    static void makeData(){
        // 계정
        Account objAcc = new Account();
        objAcc = COMM_ReportTestDataFactory.createAccount('Test','ExistingCustomer');
        insert objAcc;

        // 기회
        Opportunity objOppty = new Opportunity();
        objOppty = COMM_ReportTestDataFactory.createOpportunity('General', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        insert objOppty;

        
    }

    @isTest
    public static void test1(){

        Test.startTest();

        Opportunity objOppty = [SELECT Id FROM Opportunity LIMIT 1]; 
        CJFW_ExpectedIncoExpenRelatedController.getList(objOppty.Id);

        Test.stopTest();  
    }

   
}