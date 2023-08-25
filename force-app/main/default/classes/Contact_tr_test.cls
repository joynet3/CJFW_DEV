/************************************************************************************
 * File Name   		    : Contact_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.30
 * Target	  		    : Contact_tr.cls
 * Description 		    : Contact_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.30      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class Contact_tr_test {

    @isTest 
    static void itShould() {

        User objUser = new User(Alias = 'standt', Email='CJFreshway_TEST@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles',
         UserName='CJFreshway_TEST@testorg.com');

        insert objUser;

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;
        
        Test.startTest();
        System.runAs(objUser) {

            Contact objContact = new Contact();
            objContact.AccountId = objAccount.Id;
            objContact.LastName = '고객';
            insert objContact;
            
            String strContactId = objContact.Id;
            objContact = new Contact();
            objContact.Id = strContactId;
            objContact.LastName = '고객 Edit';
            update objContact;

            // String strAccountId = objAccount.Id;
            // objAccount = TestObjectCreator.objHealthAccount;
            // objAccount.Id = strAccountId;
            // objAccount.Name = '고객';
            // update objAccount;

            // objAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();
            // objAccount = TestObjectCreator.objHealthAccount;
            // objAccount.Id = strAccountId;
            // objAccount.Name = '고객';
            // update objAccount;

            // objAccount.Id = strAccountId;
            // delete objAccount;
        }


        Test.stopTest();
    }
}