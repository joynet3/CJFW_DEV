/************************************************************************************
 * File Name   		    : PT_tr_test.cls
 * Author	  		    : Yooree.Lee
 * Date				    : 2023.01.30
 * Target	  		    : PT_tr.cls
 * Description 		    : PT_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.01.30      Yooree.Lee       Create
 *************************************************************************************/

@IsTest
private class PT_tr_test {
    @IsTest
    static void PT_tr_test() {
        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2023-01-31');
        objOpportunity.StageName = 'Negotiation';
        insert objOpportunity;

        Test.startTest();

        PT__c objPT = new PT__c();
        objPT.Opportunity__c = objOpportunity.Id;
        objPT.Name = 'PT';
        objPT.StartDateTime__c = Datetime.newInstance(System.now().year(), System.now().month(),System.now().day(),0,0,0);
        objPT.EndDateTime__c = Datetime.newInstance(System.now().year(), System.now().month(),System.now().day() + 1,0,0,0);
        objPT.WorkType__c = '내근';
        objPT.ActivityInfo__c = 'test';
        insert objPT;

        String strPTId = objPT.Id;
        objPT = new PT__c();
        objPT.Id = strPTId;
        objPT.Name = 'PT Edit';
        objPT.StartDateTime__c = Datetime.newInstance(System.now().year(), System.now().month(),System.now().day() +2,0,0,0);
        objPT.EndDateTime__c = Datetime.newInstance(System.now().year(), System.now().month(),System.now().day() +3,0,0,0);
        objPT.WorkType__c = '외근';
        objPT.ActivityInfo__c = 'test2';
        update objPT;
        
        delete objPT;

        Test.stopTest();
    }
}