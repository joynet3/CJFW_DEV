/************************************************************************************
 * File Name   		: ActivityReport_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.11.01
 * Tester	  		: ActivityReport_tr_test.cls
 * Description 		: ActivityReport_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.01      Minje.Kim       Create
*************************************************************************************/

public with sharing class ActivityReport_tr extends TriggerHandler {
    public ActivityReport_tr() {
        listNew = (List<ActivityReport__c>) trigger.new;
        mapOld = (Map<Id, ActivityReport__c>) trigger.oldMap;
        listOld = (List<ActivityReport__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<ActivityReport__c> listNew { get; set; }
    private List<ActivityReport__c> listOld { get; set; }
    private Map<Id, ActivityReport__c> mapOld { get; set; }

    public override void beforeUpdate() {
        doCheckSummaryAmount();
    }

    public override void afterUpdate() {
        // DN_FieldTracking.doFieldTrackingInsert('ActivityReport__c', 'ActivityReportTracking', listNew, mapOld);
    }
    
    /***********************************************************************************************************
    *  Trigger  : Before Update
    *  내용     : 활동보고 제출완료로 변경될 경우 주유비 총금액(OilTotalAmount__c)이 값이 없으면 Summary 진행을 한다
    ************************************************************************************************************/
    private void doCheckSummaryAmount() {
        List<ActivityReport__c> listTarget = new List<ActivityReport__c>();
        Set<String> setActivityReportId = new Set<String>();

        for(ActivityReport__c obj : listNew) {
            if((obj.ApprovalStatus__c == 'Request' && obj.OilTotalAmount__c == null) && (mapOld <> null && obj.ApprovalStatus__c <> mapOld.get(obj.Id).ApprovalStatus__c)) {
                setActivityReportId.add(obj.Id);
                listTarget.add(obj);
            }            
        }

        System.debug('===========> listTarget : '+listTarget.size());

        if(listTarget <> null && listTarget.size() > 0) {
            Map<String, List<Event>> mapEvent = new Map<String, List<Event>>();

            for(Event objEvent : [
                SELECT  Id, ActivityReport__c, VehicleRefuelingCosts__c
                FROM    Event
                WHERE   ActivityReport__c In:setActivityReportId
            ]) {
                List<Event> listBefore = new List<Event>();

                if(mapEvent <> null && mapEvent.get(objEvent.ActivityReport__c) <> null) {
                    listBefore = mapEvent.get(objEvent.ActivityReport__c);
                }

                listBefore.add(objEvent);

                mapEvent.put(objEvent.ActivityReport__c, listBefore);
            }

            for(ActivityReport__c obj : listTarget) {
                if(mapEvent <> null && mapEvent.get(obj.Id) <> null) {
                    Decimal decOilTotalAmount = 0;

                    for(Event objEvent : mapEvent.get(obj.Id)) {
                        if(objEvent.VehicleRefuelingCosts__c <> null) {                            
                            decOilTotalAmount += objEvent.VehicleRefuelingCosts__c;
                        }
                    }

                    System.debug('============> decOilTotalAmount : '+decOilTotalAmount);

                    obj.OilTotalAmount__c = decOilTotalAmount;
                }
            }
        }
    }
}