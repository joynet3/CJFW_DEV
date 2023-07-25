/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class MDMRegRequest_test {
    @TestSetup
    static void makeData(){
        /*
        Profile p = [SELECT Id FROM Profile WHERE Name='CJFW System Adminstrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        // insert u;
        */
        Account a = new Account();
        a.Name = 'test';
        insert a;
        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.Name = 'test';
        o.StageName = 'Open';
        o.CloseDate = Date.today();
        insert o;

        MDMCustomerOrderType__c objOrderType = new MDMCustomerOrderType__c();

        objOrderType.CUHR1__c = '3136';
        objOrderType.LOGISCENTER__c = '2042/2041';
        objOrderType.CLOSEGB__c = '22';

        insert objOrderType;

    }

    @IsTest
    static void test_001(){
        User u = [Select id from user LIMIT 1];
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


        MDMRegRequest.doInit(objOpportunity.Id, 'MDMParent');

        MDMRegRequestCustomer__c objCustomer = new MDMRegRequestCustomer__c();
        insert objCustomer;

        MDMRegRequest.doInit(objCustomer.Id, 'MDMParent');

        MDMRegRequest.doCheckOrderType('LOGIC', '2042', '3136');

        MDMRegRequest.pvadmChanged(u.Id);
        MDMRegRequest.changedMA(u.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_002(){
        Account a = [Select id from Account LIMIT 1];
        Test.startTest();
        MDMRegRequest.getCustomerId(a.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_003(){
        Opportunity o = [Select id from Opportunity LIMIT 1];
        Test.startTest();
        // MDMRegRequest.getAccountInfo(o.Id);
        // MDMRegRequest.getDefaultInfo(o.Id);
        MDMRegRequest.getContactsByOpportunity(o.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_004(){
        Account a = [select id from account LIMIT 1];
        Test.startTest();
        MDMRegRequest.getInitData(a.Id, 'ACCOUNT', 'Name', 'AccountNumber', 'AccountSource');
        Test.stopTest();
    }

    @IsTest
    static void test_005(){
        MDMRegRequest.WrapperDefault w1 = new MDMRegRequest.WrapperDefault();
        MDMRegRequest.WrapperResponse w2 = new MDMRegRequest.WrapperResponse();
        w2.sErrorCode = '';
        w2.sErrorMessage = '';
        w2.sTotalCount = '';
        w2.intCurrentPage = 0;
        w2.listWrapperAddress = new List<MDMRegRequest.WrapperAddress>();
        DN_AddrSearch_wb.Address add = new DN_AddrSearch_wb.Address();
        MDMRegRequest.WrapperAddress w3 = new MDMRegRequest.WrapperAddress(add);
        w3.sAddrDetail = '';
        w3.sAddr = '';
        Account a = [select id from account LIMIT 1];
        Test.startTest();
        // MDMRegRequest.getInitData(a.Id, 'ACCOUNT', 'Name', 'AccountNumber', 'AccountSource');
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
        MDMRegRequest.saveRecords(customer, contacts, banks);
        Test.stopTest();
    }

    @IsTest
    static void test_007(){
        Test.startTest();
        try {
            MDMRegRequest.doSearchAddress('', 1, 1);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
}