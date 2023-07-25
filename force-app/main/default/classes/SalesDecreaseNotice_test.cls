/**
 * Created by kw on 2023-01-06.
 */
@IsTest
public with sharing class SalesDecreaseNotice_test {
    @TestSetup
    static void makeData() {
        User objUser = new User();
        String username = 'test00';
        objUser.Username = username + '@test.com';
        objUser.LastName = 'LastTest';
        objUser.Email = 'testemail@test.com';
        objUser.Alias = 'test';
        objUser.TimeZoneSidKey = 'America/New_York';
        objUser.LocaleSidKey = 'en_US';
        objUser.EmailEncodingKey = 'ISO-8859-1';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.ProfileId = [SELECT Id FROM Profile WHERE Name = '시스템 관리자' OR Name = 'System Administrator' LIMIT 1].Id;
        Account objAccount = TestObjectCreator.objExAccount;
        insert objAccount;
        Date today = Date.today();
        List<SalesLedgerInformation__c> listSLI = new List<SalesLedgerInformation__c>();
        SalesLedgerInformation__c objSLI = new SalesLedgerInformation__c();
        objSLI.SLST__c = objAccount.Id;
        objSLI.SALES_YMD__c = today - 1;
        objSLI.SALES_AT__c = 10;
        SalesLedgerInformation__c objSLI2 = objSLI.clone();
        objSLI2.SALES_YMD__c = today - 8;
        objSLI2.SALES_AT__c = 1000;
        listSLI.add(objSLI);
        listSLI.add(objSLI2);
        insert listSLI;



    }

    @IsTest
    static void SalesDecreaseNotice_test() {
        Test.startTest();
        SalesDecreaseNotice_sc sc = new SalesDecreaseNotice_sc();
        String sch = '0 0 * * * ?';
        String jobID = System.schedule('Merge Job', sch, sc);
        Test.stopTest();
    }
}