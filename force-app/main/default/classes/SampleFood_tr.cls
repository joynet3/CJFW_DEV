/************************************************************************************
 * File Name   		: SampleFood_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.01.09
 * Tester	  		: SampleFood_tr_test.cls
 * Description 		: SampleFood_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/

public with sharing class SampleFood_tr extends TriggerHandler {
    public SampleFood_tr() {
        listNew = (List<SampleFood__c>) trigger.new;
        mapOld = (Map<Id, SampleFood__c>) trigger.oldMap;
        listOld = (List<SampleFood__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<SampleFood__c> listNew { get; set; }
    private List<SampleFood__c> listOld { get; set; }
    private Map<Id, SampleFood__c> mapOld { get; set; }

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
        DN_FieldTracking.doFieldTrackingInsert('SampleFood__c', 'SampleFoodTracking', listNew, mapOld);
    }

    /***********************************************************************************************************
    *  Trigger  : After Insert
    *  내용     : 레코드 생성시 업무(Event) 생성
    ************************************************************************************************************/    
    private void doInsertEvent() {
        List<Event> listEvent = new List<Event>();
        for(SampleFood__c objSampleFood : listNew) {
            if( objSampleFood.isMig__c == true ) continue;
            Event objEvent = new Event();
            objEvent.Subject =  '[실사(시식)] ' + objSampleFood.Name;
            objEvent.StartDateTime =  objSampleFood.StartDateTime__c;
            objEvent.EndDateTime = objSampleFood.EndDateTime__c;
            objEvent.WorkType__c = objSampleFood.WorkType__c;
            objEvent.Description = objSampleFood.ActivityInfo__c;
            objEvent.WhatId = objSampleFood.Opportunity__c;
            objEvent.LinkedRecordId__c = objSampleFood.Id;
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
        Map<String, SampleFood__c> mapTarget = new Map<String, SampleFood__c>();
        for(SampleFood__c objSampleFood : listNew) {
            SampleFood__c objOldobjSampleFood = mapOld.get(objSampleFood.Id);
            if ( 
                objSampleFood.Name != objOldobjSampleFood.Name ||
                objSampleFood.StartDateTime__c != objOldobjSampleFood.StartDateTime__c ||
                objSampleFood.EndDateTime__c != objOldobjSampleFood.EndDateTime__c ||
                objSampleFood.WorkType__c != objOldobjSampleFood.WorkType__c ||
                objSampleFood.Activityinfo__c != objOldobjSampleFood.Activityinfo__c ||
                objSampleFood.Opportunity__c != objOldobjSampleFood.Opportunity__c 
            ){
                mapTarget.put(objSampleFood.LinkedRecordId__c, objSampleFood);
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
                    SampleFood__c objSampleFood = mapTarget.get(objEvent.Id);
                    objEvent.Subject =  '[실사(시식)] ' + objSampleFood.Name;
                    objEvent.StartDateTime =  objSampleFood.StartDateTime__c;
                    objEvent.EndDateTime = objSampleFood.EndDateTime__c;
                    objEvent.WorkType__c = objSampleFood.WorkType__c;
                    objEvent.Description = objSampleFood.ActivityInfo__c;
                    objEvent.WhatId = objSampleFood.Opportunity__c;
                    objEvent.LinkedRecordId__c = objSampleFood.Id;
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
        for(SampleFood__c objSampleFood : listOld) {
            if ( objSampleFood.LinkedRecordId__c != '' && objSampleFood.LinkedRecordId__c != null){
                setEventId.add(objSampleFood.LinkedRecordId__c);
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