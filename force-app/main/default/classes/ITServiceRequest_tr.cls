/************************************************************************************
 * File Name   		: ITServiceRequest_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.06
 * Tester	  		: ITServiceRequest_tr_test.cls
 * Description 		: ITServiceRequest_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/

public without sharing class ITServiceRequest_tr extends TriggerHandler {
    public ITServiceRequest_tr() {
        listNew = (List<ITServiceRequest__c>) trigger.new;
        mapOld = (Map<Id, ITServiceRequest__c>) trigger.oldMap;
        listOld = (List<ITServiceRequest__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<ITServiceRequest__c> listNew { get; set; }
    private List<ITServiceRequest__c> listOld { get; set; }
    private Map<Id, ITServiceRequest__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('ITServiceRequest__c', 'ITServiceRequestTracking', listNew, mapOld);
    }
}