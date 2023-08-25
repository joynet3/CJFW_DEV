/************************************************************************************
 * File Name   		: PreSales_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.01.09
 * Tester	  		: PreSales_tr_test.cls
 * Description 		: PreSales_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/

public without sharing class PreSales_tr extends TriggerHandler {
    public PreSales_tr() {
        listNew = (List<PreSales__c>) trigger.new;
        mapOld = (Map<Id, PreSales__c>) trigger.oldMap;
        listOld = (List<PreSales__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<PreSales__c> listNew { get; set; }
    private List<PreSales__c> listOld { get; set; }
    private Map<Id, PreSales__c> mapOld { get; set; }

    private static Boolean isRecursive { get; set; }

    public override void afterInsert() {
        // 주유비 처리상태 승인요청 또는 승인완료의 경우 금액있는 Activity 삭제방지. 
        doInsertEvent();
    }

    public override void afterUpdate() {
        // 주유비 처리상태 승인요청 또는 승인완료의 경우 금액있는 Activity 삭제방지. 
        doUpdateEvent();
        doFieldTracking();
    }

    public override void afterDelete() {
        doDeleteEvent();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('PreSales__c', 'PreSalesTracking', listNew, mapOld);
    }

    /***********************************************************************************************************
    *  Trigger  : After Insert
    *  내용     : 레코드 생성시 업무(Event) 생성
    ************************************************************************************************************/
    private void doInsertEvent() {
        List<Event> listEvent = new List<Event>();
        for(PreSales__c objPreSales : listNew) {
            if( objPreSales.isMig__c == true ) continue;
            Event objEvent = new Event();
            objEvent.Subject =  '[사전영업] ' + objPreSales.Name;
            objEvent.StartDateTime =  objPreSales.StartDateTime__c;
            objEvent.EndDateTime = objPreSales.EndDateTime__c;
            objEvent.WorkType__c = objPreSales.WorkType__c;
            objEvent.Description = objPreSales.ActivityInfo__c;
            objEvent.WhatId = objPreSales.Opportunity__c;
            objEvent.LinkedRecordId__c = objPreSales.Id;
            // 여기에 Validation 로직 필요 (adderror 사용~!)
            listEvent.add(objEvent);
        }

        if ( !listEvent.isEmpty() ){
            insert listEvent;            
        }
    }

    /***********************************************************************************************************
    *  Trigger  : After Update
    *  내용     : 레코드 업데이트시 업무(Event) 업데이트
    ************************************************************************************************************/
    private void doUpdateEvent() {
        Map<String, PreSales__c> mapTarget = new Map<String, PreSales__c>();
        for(PreSales__c objPreSales : listNew) {
            PreSales__c objOldobjPreSales = mapOld.get(objPreSales.Id);
            if ( 
                objPreSales.Name != objOldobjPreSales.Name ||
                objPreSales.StartDateTime__c != objOldobjPreSales.StartDateTime__c ||
                objPreSales.EndDateTime__c != objOldobjPreSales.EndDateTime__c ||
                objPreSales.WorkType__c != objOldobjPreSales.WorkType__c ||
                objPreSales.Activityinfo__c != objOldobjPreSales.Activityinfo__c ||
                objPreSales.Opportunity__c != objOldobjPreSales.Opportunity__c 
            ){
                mapTarget.put(objPreSales.LinkedRecordId__c, objPreSales);
            }
        }

        if ( !mapTarget.isEmpty()){
            List<Event> listEvent = new List<Event>([
                SELECT Id
                FROM Event
                WHERE Id IN :mapTarget.keyset()
            ]);

            if ( !listEvent.isEmpty() ){
                for ( Event objEvent : listEvent ){
                    PreSales__c objPreSales = mapTarget.get(objEvent.Id);
                    objEvent.Subject =  '[사전영업] ' + objPreSales.Name;
                    objEvent.StartDateTime =  objPreSales.StartDateTime__c;
                    objEvent.EndDateTime = objPreSales.EndDateTime__c;
                    objEvent.WorkType__c = objPreSales.WorkType__c;
                    objEvent.Description = objPreSales.ActivityInfo__c;
                    objEvent.WhatId = objPreSales.Opportunity__c;
                    objEvent.LinkedRecordId__c = objPreSales.Id;
                }    
                // 여기에 Validation 로직 필요
                update listEvent;      
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger  : After Delete
    *  내용     : 레코드 삭제시 업무(Event) 삭제
    ************************************************************************************************************/
    private void doDeleteEvent() {
        set<Id> setEventId = new set<Id>();
        for(PreSales__c objPreSales : listOld) {
            if ( objPreSales.LinkedRecordId__c != '' && objPreSales.LinkedRecordId__c != null){
                setEventId.add(objPreSales.LinkedRecordId__c);
            }
        }
        
        if ( !setEventId.isEmpty()){
            List<Event> listEvent = new List<Event>([
                SELECT Id
                FROM Event
                WHERE Id IN :setEventId
            ]);

            if ( !listEvent.isEmpty() ){
                // 여기에 Validation 로직 필요
                delete listEvent;            
            }
        }
    }
}