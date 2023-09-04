/************************************************************************************
 * File Name   		    : FoodPrice_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : FoodPrice_tr.cls
 * Description 		    : FoodPrice_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class FoodPrice_tr_test {
    @isTest 
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;


        Test.startTest();
        FoodPrice__c objFoodPrice = new FoodPrice__c();
        objFoodPrice.Opportunity__c = objOpportunity.Id;
        objFoodPrice.Name = '식단가';
        objFoodPrice.VATIncluded__c = false;
        insert objFoodPrice;

        FoodPrice__c objUpdateFoodPrice = new FoodPrice__c();
        objUpdateFoodPrice = [SELECT    Opportunity__c, VATIncluded__c
                              FROM      FoodPrice__c
                              LIMIT 1
                             ];

        objUpdateFoodPrice.VATIncluded__c = true;
        update objUpdateFoodPrice;
        Test.stopTest();
    }
}