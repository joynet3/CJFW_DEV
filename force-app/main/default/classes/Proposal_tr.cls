/************************************************************************************
 * File Name   		: Proposal_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.01.09
 * Tester	  		: Proposal_tr_test.cls
 * Description 		: Proposal_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/

public without sharing class Proposal_tr extends TriggerHandler {
    public Proposal_tr() {
        listNew = (List<Proposal__c>) trigger.new;
        mapOld = (Map<Id, Proposal__c>) trigger.oldMap;
        listOld = (List<Proposal__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<Proposal__c> listNew { get; set; }
    private List<Proposal__c> listOld { get; set; }
    private Map<Id, Proposal__c> mapOld { get; set; }

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
        DN_FieldTracking.doFieldTrackingInsert('Proposal__c', 'ProposalTracking', listNew, mapOld);
    }

    /***********************************************************************************************************
    *  Trigger  : After Insert
    *  내용     : 레코드 생성시 업무(Event) 생성
    ************************************************************************************************************/
    private void doInsertEvent() {
        List<Event> listEvent = new List<Event>();
        for(Proposal__c objProposal : listNew) {
            if( objProposal.isMig__c == true ) continue;
            Event objEvent = new Event();
            objEvent.Subject =  '[제안] ' + objProposal.Name;
            objEvent.StartDateTime =  objProposal.StartDateTime__c;
            objEvent.EndDateTime = objProposal.EndDateTime__c;
            objEvent.WorkType__c = objProposal.WorkType__c;
            objEvent.Description = objProposal.ActivityInfo__c;
            objEvent.WhatId = objProposal.Opportunity__c;
            objEvent.LinkedRecordId__c = objProposal.Id;
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
        Map<String, Proposal__c> mapTarget = new Map<String, Proposal__c>();
        for(Proposal__c objProposal : listNew) {
            Proposal__c objOldobjProposal = mapOld.get(objProposal.Id);
            if ( 
                objProposal.Name != objOldobjProposal.Name ||
                objProposal.StartDateTime__c != objOldobjProposal.StartDateTime__c ||
                objProposal.EndDateTime__c != objOldobjProposal.EndDateTime__c ||
                objProposal.WorkType__c != objOldobjProposal.WorkType__c ||
                objProposal.Activityinfo__c != objOldobjProposal.Activityinfo__c ||
                objProposal.Opportunity__c != objOldobjProposal.Opportunity__c 
            ){
                mapTarget.put(objProposal.LinkedRecordId__c, objProposal);
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
                    Proposal__c objProposal = mapTarget.get(objEvent.Id);
                    objEvent.Subject =  '[' + '제안' + '] ' + objProposal.Name;
                    objEvent.StartDateTime =  objProposal.StartDateTime__c;
                    objEvent.EndDateTime = objProposal.EndDateTime__c;
                    objEvent.WorkType__c = objProposal.WorkType__c;
                    objEvent.Description = objProposal.ActivityInfo__c;
                    objEvent.WhatId = objProposal.Opportunity__c;
                    objEvent.LinkedRecordId__c = objProposal.Id;
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
        for(Proposal__c objProposal : listOld) {
            if ( objProposal.LinkedRecordId__c != '' && objProposal.LinkedRecordId__c != null){
                setEventId.add(objProposal.LinkedRecordId__c);
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