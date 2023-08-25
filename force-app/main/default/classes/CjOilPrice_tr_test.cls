/************************************************************************************
 * File Name   		    : CjOilPrice_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.06
 * Target	  		    : CjOilPrice_tr.cls
 * Description 		    : CjOilPrice_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class CjOilPrice_tr_test {
    @isTest 
    static void itShould() {

        Test.startTest();
        CJOilPrice__c objCJOilPrice = new CJOilPrice__c();
        objCJOilPrice.Name = '대두유 1';
        objCJOilPrice.WholesalePrice__c = 0;
        insert objCJOilPrice;

        String strServiceContentsId = objCJOilPrice.Id;
        objCJOilPrice.WholesalePrice__c = 1000;
        update objCJOilPrice;
        Test.stopTest();
    }
}