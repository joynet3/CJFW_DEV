/**
 * Created by 천유정 on 2023-01-29.
 */

@IsTest
private class AfterOperation_tr_test {
    @TestSetup
    static void AfterOperation_tr_testSetUp() {
        try{

        } catch (Exception e) {
            System.debug('AfterOperation_tr_test line : ' + e.getLineNumber());
            System.debug('AfterOperation_tr_test message : ' + e.getMessage());
            System.debug('AfterOperation_tr_test cause : ' + e.getCause());
        }
    }

    @IsTest
    static void AfterOperation_tr_test() {
        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = Date.valueOf('2023-01-31');
        objOpportunity.StageName = 'Negotiation';
        insert objOpportunity;

        AfterOperation__c objAfterOperation = new AfterOperation__c();
        objAfterOperation.Name = 'test';
        objAfterOperation.StartDateTime__c = Datetime.valueOf('2022-01-01 15:00:00.000Z');
        objAfterOperation.EndDateTime__c = Datetime.valueOf('2022-01-02 15:00:00.000Z');
        objAfterOperation.WorkType__c = '외근';
        objAfterOperation.ActivityInfo__c = 'test';
        objAfterOperation.Opportunity__c = objOpportunity.Id;


        Test.startTest();
        insert objAfterOperation;
        objAfterOperation.Name = 'test2';
        update objAfterOperation;
        delete objAfterOperation;
        Test.stopTest();
    }
}