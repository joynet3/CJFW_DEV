/************************************************************************************
 * File Name   		: CRMIssue_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.06
 * Tester	  		: CRMIssue_tr_test.cls
 * Description 		: CRMIssue_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/

public without sharing class CRMIssue_tr extends TriggerHandler {
    public CRMIssue_tr() {
        listNew = (List<CRM_Issue__c>) trigger.new;
        mapOld = (Map<Id, CRM_Issue__c>) trigger.oldMap;
        listOld = (List<CRM_Issue__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<CRM_Issue__c> listNew { get; set; }
    private List<CRM_Issue__c> listOld { get; set; }
    private Map<Id, CRM_Issue__c> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('CRM_Issue__c', 'CRMIssueTracking', listNew, mapOld);
    }
}