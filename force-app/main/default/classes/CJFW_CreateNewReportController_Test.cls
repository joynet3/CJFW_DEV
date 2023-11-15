/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-14-2023
 * @last modified by  : jieun.lee3@dkbmc.com
 * Ver   Date         Author                    Modification
 * 1.0   10-10-2023   yeonji.lim@dkbmc.com      Initial Version
**/
@isTest
public class CJFW_CreateNewReportController_Test {
    
    @TestSetup
    static void makeData(){
        // 계정 
        Account objAcc = new Account();
        objAcc = COMM_ReportTestDataFactory.createAccount('test', 'ExistingCustomer');
        insert objAcc;

        // 기회
        Opportunity objOppty = new Opportunity();
        objOppty = COMM_ReportTestDataFactory.createOpportunity('General', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        insert objOppty;

        
    }

    @isTest
    public static void test(){
        
        Test.startTest();

        String opId = [SELECT Id FROM Opportunity Limit 1].Id;
        
        CJFW_CreateNewReportController.getAccountData(opId);

        Test.stopTest();


    }
}