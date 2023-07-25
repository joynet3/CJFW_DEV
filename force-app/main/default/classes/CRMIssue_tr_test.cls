/************************************************************************************
 * File Name   		    : CRMIssue_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.06
 * Target	  		    : CRMIssue_tr.cls
 * Description 		    : CRMIssue_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class CRMIssue_tr_test {
    @isTest 
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        Test.startTest();
        
        CRM_Issue__c objCRM_Issue = new CRM_Issue__c();
        objCRM_Issue.Name = '이슈사항 1';
        objCRM_Issue.Account__c = objAccount.Id;
        insert objCRM_Issue;

        String strServiceContentsId = objCRM_Issue.Id;
        objCRM_Issue.Id = strServiceContentsId;
        objCRM_Issue.Name = '이슈사항 2';
        update objCRM_Issue;
        Test.stopTest();
    }
}