/************************************************************************************
 * File Name   		: Negotiation_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.02
 * Tester	  		: Negotiation_tr_test.cls
 * Description 		: Negotiation_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.02      Minje.Kim       Create
*************************************************************************************/

public without sharing class Negotiation_tr extends TriggerHandler {
    public Negotiation_tr() {
        listNew = (List<Negotiation__c>) trigger.new;
        mapOld = (Map<Id, Negotiation__c>) trigger.oldMap;
        listOld = (List<Negotiation__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<Negotiation__c> listNew { get; set; }
    private List<Negotiation__c> listOld { get; set; }
    private Map<Id, Negotiation__c> mapOld { get; set; }

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
        DN_FieldTracking.doFieldTrackingInsert('Negotiation__c', 'NegotiationTracking', listNew, mapOld);
    }

    /***********************************************************************************************************
    *  Trigger  : After Insert
    *  내용     : 레코드 생성시 업무(Event) 생성
    ************************************************************************************************************/    
    private void doInsertEvent() {
        List<Event> listEvent = new List<Event>();
        for(Negotiation__c objNegotiation : listNew) {
            if( objNegotiation.isMig__c == true ) continue;
            Event objEvent = new Event();
            objEvent.Subject =  '[협상] ' + objNegotiation.Name;
            objEvent.StartDateTime =  objNegotiation.StartDateTime__c;
            objEvent.EndDateTime = objNegotiation.EndDateTime__c;
            objEvent.WorkType__c = objNegotiation.WorkType__c;
            objEvent.Description = objNegotiation.ActivityInfo__c;
            objEvent.WhatId = objNegotiation.Opportunity__c;
            objEvent.LinkedRecordId__c = objNegotiation.Id;
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
        Map<String, Negotiation__c> mapTarget = new Map<String, Negotiation__c>();
        for(Negotiation__c objNegotiation : listNew) {
            Negotiation__c objOldobjNegotiation = mapOld.get(objNegotiation.Id);
            if ( 
                objNegotiation.Name != objOldobjNegotiation.Name ||
                objNegotiation.StartDateTime__c != objOldobjNegotiation.StartDateTime__c ||
                objNegotiation.EndDateTime__c != objOldobjNegotiation.EndDateTime__c ||
                objNegotiation.WorkType__c != objOldobjNegotiation.WorkType__c ||
                objNegotiation.Activityinfo__c != objOldobjNegotiation.Activityinfo__c ||
                objNegotiation.Opportunity__c != objOldobjNegotiation.Opportunity__c 
            ){
                mapTarget.put(objNegotiation.LinkedRecordId__c, objNegotiation);
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
                    Negotiation__c objNegotiation = mapTarget.get(objEvent.Id);
                    objEvent.Subject =  '[사전영업] ' + objNegotiation.Name;
                    objEvent.StartDateTime =  objNegotiation.StartDateTime__c;
                    objEvent.EndDateTime = objNegotiation.EndDateTime__c;
                    objEvent.WorkType__c = objNegotiation.WorkType__c;
                    objEvent.Description = objNegotiation.ActivityInfo__c;
                    objEvent.WhatId = objNegotiation.Opportunity__c;
                    objEvent.LinkedRecordId__c = objNegotiation.Id;
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
        for(Negotiation__c objNegotiation : listOld) {
            if ( objNegotiation.LinkedRecordId__c != '' && objNegotiation.LinkedRecordId__c != null){
                setEventId.add(objNegotiation.LinkedRecordId__c);
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