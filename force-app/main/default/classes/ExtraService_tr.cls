/************************************************************************************
 * File Name   		: ExtraService_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.10.12
 * Tester	  		: ExtraService_tr_test.cls
 * Description 		: ExtraService_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.10.12      Minje.Kim       Create
*************************************************************************************/

public without sharing class ExtraService_tr extends TriggerHandler {
    public ExtraService_tr() {
        listNew = (List<ExtraService__c>) trigger.new;
        mapOld = (Map<Id, ExtraService__c>) trigger.oldMap;
        listOld = (List<ExtraService__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<ExtraService__c> listNew { get; set; }
    private List<ExtraService__c> listOld { get; set; }
    private Map<Id, ExtraService__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('ExtraService__c', 'ExtraServiceTracking', listNew, mapOld);
    }

}