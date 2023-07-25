/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class MDMRegRequestMain_test {
    @TestSetup
    static void makeData() {
    }
    @IsTest
    static void itShould() {
        Test.startTest();

        Account objAccount = TestObjectCreator.objHealthAccount;
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();
        insert objAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;

        MDMRegRequestMain.doInit(objOpportunity.Id);

        MDMRegRequestCustomer__c objCustomer = new MDMRegRequestCustomer__c();
        insert objCustomer;

        MDMRegRequestMain.doInit(objCustomer.Id);

        List<workflow__c> listWorkFlow = new List<workflow__c>();

        for(Integer i=1 ; i<3 ;i++) {
            workflow__c objWorkflow = new workflow__c();
            objWorkflow.Name = 'Test';
            objWorkflow.Level__c = String.valueOf(i);        
            objWorkflow.MidCategory__c = '고객(본점) 생성 프로세스';
            objWorkflow.LargeCode__c = '본점';
            listWorkFlow.add(objWorkflow);
        }

        insert listWorkFlow;

        MDMRegRequestMain.getCategoryLevel1();
        MDMRegRequestMain.getCategoryLevel2('본점');
        MDMRegRequestMain.getCategoryLevel3('test', listWorkFlow);



        Test.stopTest();
    }
}