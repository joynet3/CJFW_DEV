/************************************************************************************
 * File Name   		: CompetitorPrice_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.06
 * Tester	  		: CompetitorPrice_tr_test.cls
 * Description 		: CompetitorPrice_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/

public without sharing class CompetitorPrice_tr extends TriggerHandler {
    public CompetitorPrice_tr() {
        listNew = (List<CompetitorPrice__c>) trigger.new;
        mapOld = (Map<Id, CompetitorPrice__c>) trigger.oldMap;
        listOld = (List<CompetitorPrice__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<CompetitorPrice__c> listNew { get; set; }
    private List<CompetitorPrice__c> listOld { get; set; }
    private Map<Id, CompetitorPrice__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('CompetitorPrice__c', 'CompetitorPriceTracking', listNew, mapOld);
    }
}