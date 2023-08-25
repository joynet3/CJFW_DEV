/************************************************************************************
 * File Name   		    : Account_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : Account_tr.cls
 * Description 		    : Account_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class Account_tr_test {

    @isTest 
    static void Account_tr_test() {
        User objUser = new User(Alias = 'standt', Email='CJFreshway_TEST@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles',
         UserName='CJFreshway_TEST@testorg.com');
        insert objUser;

        Test.startTest();
        System.runAs(objUser) {
            Account objAccount = TestObjectCreator.objHealthAccount;
            insert objAccount;

            Account objSchool = TestObjectCreator.objSchoolAccount;
            objSchool.Phone = '01012341234';
            objSchool.Address__c = 'Test Address';
            objSchool.AddressDetails__c = 'test';            
            objSchool.PostalCode__c = '12345';
            objSchool.sma_cust_bid_mtd_cd__c = 'A';
            objSchool.sma_cust_bid_cycl_cd__c = '1';
            objSchool.sma_cust_mng_frm_cd__c = '1';
            objSchool.dstfd_mtd_cd__c = '11';
            objSchool.LocationStateProvince__c = '11';
            objSchool.LocationState__c = '11560';
            objSchool.schl_cust_div_cd__c = 'E';
            objSchool.jrsdt_cido_eduofic_cd__c = '100';
            objSchool.jrsdt_gugun_eduofic_cd__c = '1007';
            objSchool.sma_cust_mng_grd_cd__c = 'C';
            objSchool.odd_txt__c = 'TEST';

            insert objSchool;

            String strAccountId = objAccount.Id;
            objAccount = TestObjectCreator.objHealthAccount;
            objAccount.Id = strAccountId;
            objAccount.Name = '고객';
            update objAccount; 

            objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();
            objAccount = TestObjectCreator.objHealthAccount;
            objAccount.Id = strAccountId;
            objAccount.Name = '고객';
            update objAccount;

            objAccount.Id = strAccountId;
            delete objAccount;

            objSchool.Name += 1;
            update objSchool;

            Account objFSAccount = new Account();
            objFSAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FSDiscoveryDepartment').getRecordTypeId();

            objFSAccount.Name = 'Test FS';
            objFSAccount.CompanyRegisterNumber__c = '1020412345';
            insert objFSAccount;
        }


        Test.stopTest();
    }
    
}