/************************************************************************************
 * File Name   		: FoodPrice_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.10.12
 * Tester	  		: FoodPrice_tr_test.cls
 * Description 		: FoodPrice_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.10.12      Minje.Kim       Create
*************************************************************************************/

public with sharing class FoodPrice_tr extends TriggerHandler {
    public FoodPrice_tr() {
        listNew = (List<FoodPrice__c>) trigger.new;
        mapOld = (Map<Id, FoodPrice__c>) trigger.oldMap;
        listOld = (List<FoodPrice__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<FoodPrice__c> listNew { get; set; }
    private List<FoodPrice__c> listOld { get; set; }
    private Map<Id, FoodPrice__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('FoodPrice__c', 'FoodPriceTracking', listNew, mapOld);
    }
}