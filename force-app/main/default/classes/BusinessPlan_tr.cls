/************************************************************************************
 * File Name   		: BusinessPlan_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.06
 * Tester	  		: BusinessPlan_tr_test.cls
 * Description 		: BusinessPlan_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/

public without sharing class BusinessPlan_tr extends TriggerHandler {
    public BusinessPlan_tr() {
        listNew = (List<BusinessPlan__c>) trigger.new;
        mapOld = (Map<Id, BusinessPlan__c>) trigger.oldMap;
        listOld = (List<BusinessPlan__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<BusinessPlan__c> listNew { get; set; }
    private List<BusinessPlan__c> listOld { get; set; }
    private Map<Id, BusinessPlan__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('BusinessPlan__c', 'BusinessPlanTracking', listNew, mapOld);
    }
}