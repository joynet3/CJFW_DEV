/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class OrderServiceRequest_tr extends TriggerHandler {
    public OrderServiceRequest_tr() {
        listNew = (List<OrderServiceRequest__c>) trigger.new;
        mapOld = (Map<Id, OrderServiceRequest__c>) trigger.oldMap;
        listOld = (List<OrderServiceRequest__c>) trigger.old;

    }
    /*** TriggerHandler ***/
    private List<OrderServiceRequest__c> listNew { get; set; }
    private List<OrderServiceRequest__c> listOld { get; set; }
    private Map<Id, OrderServiceRequest__c> mapOld { get; set; }

    public override void beforeUpdate(){
        
    }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('OrderServiceRequest__c', 'OrderServiceRequestTracking', listNew, mapOld);
    }

}