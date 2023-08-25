/************************************************************************************
 * File Name   		    : CompetitorPrice_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.06
 * Target	  		    : CompetitorPrice_tr.cls
 * Description 		    : CompetitorPrice_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class CompetitorPrice_tr_test {
    @isTest 
    static void itShould() {

        Competitor__c objCompetitor = new Competitor__c();
        objCompetitor.Name = '경쟁사 1';
        objCompetitor.IsCJ__c = false;
        objCompetitor.IsActive__c = false;
        insert objCompetitor;

        CJOilPrice__c objCJOilPrice = new CJOilPrice__c();
        objCJOilPrice.Name = '대두유 1';
        objCJOilPrice.WholesalePrice__c = 0;
        insert objCJOilPrice;

        Test.startTest();
        CompetitorPrice__c objCompetitorPrice = new CompetitorPrice__c();
        objCompetitorPrice.Competitor__c = objCompetitor.Id;
        objCompetitorPrice.CJ__c = objCJOilPrice.Id;
        objCompetitorPrice.Name = '경쟁사 가격';
        objCompetitorPrice.WholesalePrice__c = 0;
        insert objCompetitorPrice;

        String strServiceContentsId = objCompetitorPrice.Id;
        objCompetitorPrice.WholesalePrice__c = 1000;
        update objCompetitorPrice;
        
        Test.stopTest();
    }
}