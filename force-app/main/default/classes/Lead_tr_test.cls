/************************************************************************************
 * File Name   		    : Lead_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : Lead_tr.cls
 * Description 		    : Lead_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class Lead_tr_test {

    @isTest 
    static void itShould() {

        User objUser = new User(Alias = 'standt', Email='CJFreshway_TEST@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles',
         UserName='CJFreshway_TEST@testorg.com');

        insert objUser;

        Test.startTest();

        Lead objLead = new Lead();
        objLead.Company = '잠재고객';
        objLead.LastName = '잠재고객';
        objLead.Status = 'New';
        objLead.OwnerId = UserInfo.getUserId();
        insert objLead;

        String strLeadId = objLead.Id;
        objLead = new Lead();
        objLead.Id = strLeadId;
        objLead.OwnerId = objUser.Id;
        update objLead;

        Test.stopTest();
    }
}