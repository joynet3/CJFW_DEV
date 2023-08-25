/************************************************************************************
 * File Name   		    : PreSales_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : PreSales_tr.cls
 * Description 		    : PreSales_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@isTest
public with sharing class PreSales_tr_test {
    @isTest
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;

        insert objAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = Date.valueOf('2022-01-01');
        objOpportunity.StageName = 'PreSales';
        insert objOpportunity;


        Test.startTest();
        PreSales__c objPreSales = new PreSales__c();
        objPreSales.Opportunity__c = objOpportunity.Id;
        objPreSales.StartDateTime__c = Datetime.valueOf('2022-01-01 15:00:00.000Z');
        objPreSales.EndDateTime__c = Datetime.valueOf('2022-01-02 15:00:00.000Z');
        objPreSales.Name = '사전영업';
        
        insert objPreSales;

        String strPreSalesId = objPreSales.Id;
        objPreSales = new PreSales__c();
        objPreSales.Id = strPreSalesId;
        objPreSales.StartDateTime__c = Datetime.valueOf('2022-01-01 15:00:00.000Z');
        objPreSales.EndDateTime__c = Datetime.valueOf('2022-01-02 15:00:00.000Z');
        objPreSales.Name = '사전영업 EDIT';
        update objPreSales;

        Test.stopTest();
    }
}