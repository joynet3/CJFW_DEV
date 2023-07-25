/************************************************************************************
 * File Name   		: AfterOperation_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.01.09
 * Tester	  		: AfterOperation_tr_test.cls
 * Description 		: AfterOperation_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/

public without sharing class AfterOperation_tr extends TriggerHandler {
    public AfterOperation_tr() {
        listNew = (List<AfterOperation__c>) trigger.new;
        mapOld = (Map<Id, AfterOperation__c>) trigger.oldMap;
        listOld = (List<AfterOperation__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<AfterOperation__c> listNew { get; set; }
    private List<AfterOperation__c> listOld { get; set; }
    private Map<Id, AfterOperation__c> mapOld { get; set; }

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
    *  Trigger  : After Update
    *  내용     : FieldTracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('AfterOperation__c', 'AfterOperationTracking', listNew, mapOld);
    }

    /***********************************************************************************************************
    *  Trigger  : After Insert
    *  내용     : 레코드 생성시 업무(Event) 생성
    ************************************************************************************************************/
    private void doInsertEvent() {
        List<Event> listEvent = new List<Event>();
        for(AfterOperation__c objAfterOperation : listNew) {
            if( objAfterOperation.isMig__c == true ) continue;
            Event objEvent = new Event();
            objEvent.Subject =  '[사후영업] ' + objAfterOperation.Name;
            objEvent.StartDateTime =  objAfterOperation.StartDateTime__c;
            objEvent.EndDateTime = objAfterOperation.EndDateTime__c;
            objEvent.WorkType__c = objAfterOperation.WorkType__c;
            objEvent.Description = objAfterOperation.ActivityInfo__c;
            objEvent.WhatId = objAfterOperation.Opportunity__c;
            objEvent.LinkedRecordId__c = objAfterOperation.Id;
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
        Map<String, AfterOperation__c> mapTarget = new Map<String, AfterOperation__c>();
        for(AfterOperation__c objAfterOperation : listNew) {
            AfterOperation__c objOldobjAfterOperation = mapOld.get(objAfterOperation.Id);
            if ( 
                objAfterOperation.Name != objOldobjAfterOperation.Name ||
                objAfterOperation.StartDateTime__c != objOldobjAfterOperation.StartDateTime__c ||
                objAfterOperation.EndDateTime__c != objOldobjAfterOperation.EndDateTime__c ||
                objAfterOperation.WorkType__c != objOldobjAfterOperation.WorkType__c ||
                objAfterOperation.Activityinfo__c != objOldobjAfterOperation.Activityinfo__c ||
                objAfterOperation.Opportunity__c != objOldobjAfterOperation.Opportunity__c 
            ){
                mapTarget.put(objAfterOperation.LinkedRecordId__c, objAfterOperation);
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
                    AfterOperation__c objAfterOperation = mapTarget.get(objEvent.Id);
                    objEvent.Subject =  '[사후영업] ' + objAfterOperation.Name;
                    objEvent.StartDateTime =  objAfterOperation.StartDateTime__c;
                    objEvent.EndDateTime = objAfterOperation.EndDateTime__c;
                    objEvent.WorkType__c = objAfterOperation.WorkType__c;
                    objEvent.Description = objAfterOperation.ActivityInfo__c;
                    objEvent.WhatId = objAfterOperation.Opportunity__c;
                    objEvent.LinkedRecordId__c = objAfterOperation.Id;
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
        for(AfterOperation__c objAfterOperation : listOld) {
            if ( objAfterOperation.LinkedRecordId__c != '' && objAfterOperation.LinkedRecordId__c != null){
                setEventId.add(objAfterOperation.LinkedRecordId__c);
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