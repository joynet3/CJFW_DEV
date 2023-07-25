/************************************************************************************
 * File Name   		    : BusinessPlan_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.06
 * Target	  		    : BusinessPlan_tr.cls
 * Description 		    : BusinessPlan_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class BusinessPlan_tr_test {
    @isTest 
    static void itShould() {
        Test.startTest();
        
        BusinessPlan__c objBusinessPlan = new BusinessPlan__c();
        objBusinessPlan.Name = '경영계획 1';
        objBusinessPlan.Year__c = 2021;
        objBusinessPlan.Month__c = '1';
        insert objBusinessPlan;

        String strBusinessPlanId = objBusinessPlan.Id;
        objBusinessPlan = new BusinessPlan__c();
        objBusinessPlan.Id = strBusinessPlanId;
        objBusinessPlan.Name = '경영계획 2';
        update objBusinessPlan;
        Test.stopTest();
    }
}