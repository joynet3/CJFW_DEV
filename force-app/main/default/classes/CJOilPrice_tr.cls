/************************************************************************************
 * File Name   		: CjOilPrice_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.06
 * Tester	  		: CjOilPrice_tr_test.cls
 * Description 		: CjOilPrice_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/

public without sharing class CJOilPrice_tr extends TriggerHandler {
    public CjOilPrice_tr() {
        listNew = (List<CJOilPrice__c>) trigger.new;
        mapOld = (Map<Id, CJOilPrice__c>) trigger.oldMap;
        listOld = (List<CJOilPrice__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<CJOilPrice__c> listNew { get; set; }
    private List<CJOilPrice__c> listOld { get; set; }
    private Map<Id, CJOilPrice__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('CJOilPrice__c', 'CJOilPriceTracking', listNew, mapOld);
    }
}