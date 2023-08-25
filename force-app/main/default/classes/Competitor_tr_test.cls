/************************************************************************************
 * File Name   		    : Competitor_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.06
 * Target	  		    : Competitor_tr.cls
 * Description 		    : Competitor_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class Competitor_tr_test {
    @isTest 
    static void itShould() {

        Test.startTest();
        
        Competitor__c objCompetitor = new Competitor__c();
        objCompetitor.Name = '경쟁사 1';
        objCompetitor.IsCJ__c = false;
        objCompetitor.IsActive__c = false;
        insert objCompetitor;

        String strServiceContentsId = objCompetitor.Id;
        objCompetitor.Name = '경쟁사 2';
        objCompetitor.IsCJ__c = false;
        update objCompetitor;
        Test.stopTest();
    }
}