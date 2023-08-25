/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-30-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class MIG_Account_ba_test {
    @testSetup
    static void makeData() {

        Account objExAccount = TestObjectCreator.objExAccount;
        objExAccount.CustomerID__c = 'test1234';
        insert objExAccount;

        Account objAccount = new Account();
        objAccount.Name = 'Test';
        objAccount.PaymentAccountCode__c = 'test1234';
        objAccount.ShippingAccountCode__c = 'test1234';

        insert objAccount;
    }

    @isTest
    static void itShould() {
        Test.startTest();
        MIG_Account_ba b = new MIG_Account_ba();
        Database.executeBatch(b, 200);
        
        Test.stopTest();
    }
}