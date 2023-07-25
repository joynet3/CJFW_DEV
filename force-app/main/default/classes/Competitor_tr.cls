/************************************************************************************
 * File Name   		: Competitor_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.06
 * Tester	  		: Competitor_tr_test.cls
 * Description 		: Competitor_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/

public without sharing class Competitor_tr extends TriggerHandler {
    public Competitor_tr() {
        listNew = (List<Competitor__c>) trigger.new;
        mapOld = (Map<Id, Competitor__c>) trigger.oldMap;
        listOld = (List<Competitor__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<Competitor__c> listNew { get; set; }
    private List<Competitor__c> listOld { get; set; }
    private Map<Id, Competitor__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('Competitor__c', 'CompetitorTracking', listNew, mapOld);
    }
}