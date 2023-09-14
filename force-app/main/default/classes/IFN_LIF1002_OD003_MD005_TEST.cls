@isTest
public class IFN_LIF1002_OD003_MD005_TEST {

    @TestSetup
    static void makeData(){
        IFN_TestDataFactory.createIfPrograms();


        ServiceContents__c svccont = new ServiceContents__c();
        svccont.IsUsage__c = true;
        svccont.Region__c = 'A';
        svccont.Category__c = 'SH';
        svccont.OpenDate__c = Date.today();
        svccont.Name = '1';
        insert svccont;

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        ClassService__c cls = new ClassService__c();
        cls.ServiceContent__c = svccont.id;
        cls.MDMCode__c = '1';
        cls.Status__c = 'H';
        cls.Manager__c = '1';
        cls.CustomerPhone__c = '02-000-0000';
        cls.TargetGroup__c = 'DIRECTOR';
        cls.ApplicantsNumber__c = '1';
        cls.GroupMealAge__c = '1';
        cls.Address__c = '1';
        cls.Description__c = '1';
        cls.Customer__c    =objAccount.id;
        insert cls;

        ExtraService__c exs = new ExtraService__c();
        exs.ServiceStartDateTime__c = Datetime.now();
        exs.ProgressTime__c =12;
        insert exs;
    }

    @isTest
    static void test01() {
        Test.startTest();
        ServiceContents__c svccont = [select id from ServiceContents__c  Limit 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{'
                        +' "cttId":"'+svccont.id+'",'
                        +' "mdmCd":"1"'
                        +' }';

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD003_MD005.doPost();
        
        Test.stopTest();
    }


    
    @isTest
    static void test02() {
        Test.startTest();
        ServiceContents__c svccont = [select id from ServiceContents__c  Limit 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{'
                        +' "cttId":"12312312" ,'
                        +' "mdmCd":""'
                        +' }';

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD003_MD005.doPost();
        
        Test.stopTest();
    }


    @isTest
    static void test03() {
        Test.startTest();
        ServiceContents__c svccont = [select id from ServiceContents__c  Limit 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestBody = null;
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD003_MD005.doPost();
        
        Test.stopTest();
    }


}