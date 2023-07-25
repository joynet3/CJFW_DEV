/************************************************************************************
 * File Name   		: PT_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.01.09
 * Tester	  		: PT_tr_test.cls
 * Description 		: PT_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/

public without sharing class PT_tr extends TriggerHandler {
    public PT_tr() {
        listNew = (List<PT__c>) trigger.new;
        mapOld = (Map<Id, PT__c>) trigger.oldMap;
        listOld = (List<PT__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<PT__c> listNew { get; set; }
    private List<PT__c> listOld { get; set; }
    private Map<Id, PT__c> mapOld { get; set; }

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
        DN_FieldTracking.doFieldTrackingInsert('PT__c', 'PTTracking', listNew, mapOld);
    }

    /***********************************************************************************************************
    *  Trigger  : After Insert
    *  내용     : 레코드 생성시 업무(Event) 생성
    ************************************************************************************************************/
    private void doInsertEvent() {
        List<Event> listEvent = new List<Event>();
        for(PT__c objPT : listNew) {
            if( objPT.isMig__c == true ) continue;
            Event objEvent = new Event();
            objEvent.Subject =  '[PT] ' + objPT.Name;
            objEvent.StartDateTime =  objPT.StartDateTime__c;
            objEvent.EndDateTime = objPT.EndDateTime__c;
            objEvent.WorkType__c = objPT.WorkType__c;
            objEvent.Description = objPT.ActivityInfo__c;
            objEvent.WhatId = objPT.Opportunity__c;
            objEvent.LinkedRecordId__c = objPT.Id;
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
        Map<String, PT__c> mapTarget = new Map<String, PT__c>();
        for(PT__c objPT : listNew) {
            PT__c objOldobjPT = mapOld.get(objPT.Id);
            if ( 
                objPT.Name != objOldobjPT.Name ||
                objPT.StartDateTime__c != objOldobjPT.StartDateTime__c ||
                objPT.EndDateTime__c != objOldobjPT.EndDateTime__c ||
                objPT.WorkType__c != objOldobjPT.WorkType__c ||
                objPT.Activityinfo__c != objOldobjPT.Activityinfo__c ||
                objPT.Opportunity__c != objOldobjPT.Opportunity__c 
            ){
                mapTarget.put(objPT.LinkedRecordId__c, objPT);
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
                    PT__c objPT = mapTarget.get(objEvent.Id);
                    objEvent.Subject =  '[PT] ' + objPT.Name;
                    objEvent.StartDateTime =  objPT.StartDateTime__c;
                    objEvent.EndDateTime = objPT.EndDateTime__c;
                    objEvent.WorkType__c = objPT.WorkType__c;
                    objEvent.Description = objPT.ActivityInfo__c;
                    objEvent.WhatId = objPT.Opportunity__c;
                    objEvent.LinkedRecordId__c = objPT.Id;
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
        for(PT__c objPT : listOld) {
            if ( objPT.LinkedRecordId__c != '' && objPT.LinkedRecordId__c != null){
                setEventId.add(objPT.LinkedRecordId__c);
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