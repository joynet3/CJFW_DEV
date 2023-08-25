/************************************************************************************
 * File Name   		: ServiceContents_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.10.12
 * Tester	  		: ServiceContents_tr_test.cls
 * Description 		: ServiceContents_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.10.12      Minje.Kim       Create
*************************************************************************************/

public without sharing class ServiceContents_tr extends TriggerHandler {
    public ServiceContents_tr() {
        listNew = (List<ServiceContents__c>) trigger.new;
        mapOld = (Map<Id, ServiceContents__c>) trigger.oldMap;
        listOld = (List<ServiceContents__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<ServiceContents__c> listNew { get; set; }
    private List<ServiceContents__c> listOld { get; set; }
    private Map<Id, ServiceContents__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('ServiceContents__c', 'ServiceContentsTracking', listNew, mapOld);
    }
}