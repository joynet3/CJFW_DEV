/************************************************************************************
 * File Name   		    : CurrentPartner_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.06
 * Target	  		    : CurrentPartner_tr.cls
 * Description 		    : CurrentPartner_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class CurrentPartner_tr_test {
    @isTest 
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        Test.startTest();
        
        CurrentPartner__c objCurrentPartner = new CurrentPartner__c();
        objCurrentPartner.Account__c = objAccount.Id;
        objCurrentPartner.Name = '현거래처 1';
        objCurrentPartner.Year__c = '2020';
        insert objCurrentPartner;

        String strCurrentPartnerId = objCurrentPartner.Id;
        objCurrentPartner = new CurrentPartner__c();
        objCurrentPartner.Id = strCurrentPartnerId;
        objCurrentPartner.Name = '현거래처 2';
        objCurrentPartner.Year__c = '2021';
        update objCurrentPartner;
        Test.stopTest();
    }
}