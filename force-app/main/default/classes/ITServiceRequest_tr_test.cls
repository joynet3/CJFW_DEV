/************************************************************************************
 * File Name   		    : ITServiceRequest_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.06
 * Target	  		    : ITServiceRequest_tr.cls
 * Description 		    : ITServiceRequest_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class ITServiceRequest_tr_test {
    @isTest 
    static void itShould() {
        Test.startTest();
        
        ITServiceRequest__c objITServiceRequest = new ITServiceRequest__c();
        objITServiceRequest.Title__c = 'CRM 서비스 요청 1';
        objITServiceRequest.RequestType__c = '개선';
        objITServiceRequest.Severity__c = '보통';
        insert objITServiceRequest;
        
        String strServiceContentsId = objITServiceRequest.Id;
        objITServiceRequest.Title__c = 'CRM 서비스 요청 2';
        update objITServiceRequest;
        Test.stopTest();
    }
}