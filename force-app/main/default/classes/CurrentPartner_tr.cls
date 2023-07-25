/************************************************************************************
 * File Name   		: CurrentPartner_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.06
 * Tester	  		: CurrentPartner_tr_test.cls
 * Description 		: CurrentPartner_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/

public without sharing class CurrentPartner_tr extends TriggerHandler {
    public CurrentPartner_tr() {
        listNew = (List<CurrentPartner__c>) trigger.new;
        mapOld = (Map<Id, CurrentPartner__c>) trigger.oldMap;
        listOld = (List<CurrentPartner__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<CurrentPartner__c> listNew { get; set; }
    private List<CurrentPartner__c> listOld { get; set; }
    private Map<Id, CurrentPartner__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('CurrentPartner__c', 'CurrentPartnerTracking', listNew, mapOld);
    }
}