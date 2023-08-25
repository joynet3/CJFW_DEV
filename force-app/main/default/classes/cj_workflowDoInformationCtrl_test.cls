@isTest
public class cj_workflowDoInformationCtrl_test {
    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CJFW System Adminstrator' OR Name='시스템 관리자' OR Name='System Adminstrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        // insert u;
        Account a = new Account();
        a.Name = 'test';
        insert a;
        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.Name = 'test';
        o.StageName = 'Open';
        o.CloseDate = Date.today();
        insert o;
    }
    @IsTest
    static void test_001(){
        User u = [Select id from user LIMIT 1];
        Test.startTest();
        cj_workflowDoInformationCtrl.pvadmChanged(u.Id);
        cj_workflowDoInformationCtrl.changedMA(u.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_002(){
        Account a = [Select id from Account LIMIT 1];
        Test.startTest();
        cj_workflowDoInformationCtrl.getCustomerId(a.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_003(){
        Opportunity o = [Select id from Opportunity LIMIT 1];
        Test.startTest();
        cj_workflowDoInformationCtrl.doInit(o.Id, 'MDMParent');
        cj_workflowDoInformationCtrl.getAccountInfo(o.Id);
        cj_workflowDoInformationCtrl.getDefaultInfo(o.Id);
        cj_workflowDoInformationCtrl.getContactsByOpportunity(o.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_004(){
        Account a = [select id from account LIMIT 1];
        Test.startTest();
        cj_workflowDoInformationCtrl.getInitData(a.Id, 'ACCOUNT', 'Name', 'AccountNumber', 'AccountSource');
        Test.stopTest();
    }

    @IsTest
    static void test_005(){
        cj_workflowDoInformationCtrl.WrapperDefault w1 = new cj_workflowDoInformationCtrl.WrapperDefault();
        cj_workflowDoInformationCtrl.WrapperResponse w2 = new cj_workflowDoInformationCtrl.WrapperResponse();
        w2.sErrorCode = '';
        w2.sErrorMessage = '';
        w2.sTotalCount = '';
        w2.intCurrentPage = 0;
        w2.listWrapperAddress = new List<cj_workflowDoInformationCtrl.WrapperAddress>();
        DN_AddrSearch_wb.Address add = new DN_AddrSearch_wb.Address();
        cj_workflowDoInformationCtrl.WrapperAddress w3 = new cj_workflowDoInformationCtrl.WrapperAddress(add);
        w3.sAddrDetail = '';
        w3.sAddr = '';
        Account a = [select id from account LIMIT 1];
        Test.startTest();
        // cj_workflowDoInformationCtrl.getInitData(a.Id, 'ACCOUNT', 'Name', 'AccountNumber', 'AccountSource');
        Test.stopTest();
    }

    @IsTest
    static void test_006(){
        MDMRegRequestCustomer__c customer = new MDMRegRequestCustomer__c();
        MDMRegRequestContact__c contact = new MDMRegRequestContact__c();
        List<MDMRegRequestContact__c> contacts = new List<MDMRegRequestContact__c>();
        contacts.add(contact);
        MDMRegRequestBank__c bank = new MDMRegRequestBank__c();
        List<MDMRegRequestBank__c> banks = new List<MDMRegRequestBank__c>();
        banks.add(bank);
        Test.startTest();
        cj_workflowDoInformationCtrl.saveRecords(customer, contacts, banks);
        Test.stopTest();
    }

    @IsTest
    static void test_007(){
        Test.startTest();
        try {
            cj_workflowDoInformationCtrl.doSearchAddress('', 1, 1);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
}