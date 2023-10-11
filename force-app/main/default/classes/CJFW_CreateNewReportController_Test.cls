/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-10-2023
 * @last modified by  : yeonji.lim@dkbmc.com
 * Ver   Date         Author                    Modification
 * 1.0   10-10-2023   yeonji.lim@dkbmc.com      Initial Version
**/
@isTest
public class CJFW_CreateNewReportController_Test {
    
    @TestSetup
    static void makeData(){
        // 계정 
        Account objAccount = new Account();
            objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HealthyNuriDepartment').getRecordTypeId();
            objAccount.Name = 'HealthAccount';//TestObjectCreator.objHealthAccount;
        insert objAccount;

        // 기회
        Opportunity objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'NaraMarket';
            objOpportunity.BidQualifyRegistCloseDateTime__c = date.valueOf('2022-01-01');
        insert objOpportunity;

        // 고객
        User u = new User();
            u = COMM_TestDataFactory.createUser([SELECT Id,Name FROM Profile WHERE Name ='Platform Administrator' limit 1].Id);
        insert u;

        
    }

    @isTest
    public static void test(){
        
        Test.startTest();

        String opId = [SELECT Id FROM Opportunity Limit 1].Id;
        String uId = [SELECT Id FROM User Limit 1].Id;

        /* 
        * Oppty에 연결된 Account 데이터 가져오기
        * public static List<Opportunity> getAccountData(String OpptyId)  
        */
        CJFW_CreateNewReportController.getAccountData(opId);
        // CJFW_CreateNewReportController.getAccountData('error');

        /* 
        * User Obj에서 영업경로 가져오기 
        * public static List<User> getSulLabel(String UserId)
        */
        CJFW_CreateNewReportController.getSulLabel(uId);
        // CJFW_CreateNewReportController.getSulLabel('error');

        /* 
        * 품의이력 저장 
        * public static String saveDecision(Map<String,Object> saveData)
        */
        Map<String,Object> saveData = new Map<String,Object>();
        saveData.put('Name', '품의서');

        CJFW_CreateNewReportController.saveDecision(saveData);

        Test.stopTest();


    }
}