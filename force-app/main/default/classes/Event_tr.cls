/************************************************************************************
 * File Name   		: Event_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.10.25
 * Tester	  		: Event_tr_test.cls
 * Description 		: Event_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.10.25      Minje.Kim       Create
 * 1.1      2023.04.06      sy.lee          update
 * 1.2      2023.05.19      sy.lee          update
*************************************************************************************/

public without sharing class Event_tr extends TriggerHandler {
    public Event_tr() {
        listNew = (List<Event>) trigger.new;
        mapOld = (Map<Id, Event>) trigger.oldMap;
        listOld = (List<Event>) trigger.old;
        isTwiceUpdateAccountType = false;
    }
    
    /*** TriggerHandler ***/ 
    private List<Event> listNew { get; set; }
    private List<Event> listOld { get; set; }
    private Map<Id, Event> mapOld { get; set; }
    private static Boolean isTwiceUpdateAccountType {get; set;}

    public override void beforeInsert() {
        doSetLookupFieldWhatId();
        doUpdateName();
        doUpdateAccountType();
    }

    public override void afterInsert() {
        doUpdateLinkedObject();
        doUpdateStatus();
        doUpdateTotal();
        doUpdateRecentVisitDateTimeOfAccount();
    }

    public override void beforeUpdate() {
        doSetLookupFieldWhatId();
        doHandleValidation();
        doWorkTypeOrIsPassengerChangeHandle();     
        doUpdateAccountType();
    }

    public override void afterUpdate() {
        doDeleteRelation();
        doUpdateLinkedObject();
        doUpdateStatus();
        doUpdateTotal();
        doDeleteActivityReport();
        doUpdateRecentVisitDateTimeOfAccount();
    }

    public override void beforeDelete() {
        doHandleValidation();
    }

    public override void afterDelete() {
        doDeleteLinkedObject();
        doUpdateStatus();
        doUpdateTotal();       
        doDeleteActivityReport(); 
        doUpdateRecentVisitDateTimeOfAccount();
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert, Before Update    
    *  내용    : WhoId or WhatId 값이 있는경우 Lead__c, Account__c, Opportunity__c 값 자동세팅
    ************************************************************************************************************/
    private void doSetLookupFieldWhatId() {
        List<Event> listSetWhatIdTarget = new List<Event>();
        List<Event> listSetLookupFieldTarget = new List<Event>();        

        Set<String> setOpportunityId = new Set<String>();
        Set<String> setContactId = new Set<String>();
        Set<String> setEventId = new Set<String>();

        for(Event obj : listNew) {
            System.debug('============> obj.WhoId : '+obj.WhoId);
            System.debug('============> obj.WhatId : '+obj.WhatId);
            System.debug('============> obj.Lead__c : '+obj.Lead__c);
            System.debug('============> obj.Account__c : '+obj.Account__c);
            System.debug('============> obj.Opportunity__c : '+obj.Opportunity__c);
            System.debug('============> obj.Contact__c : '+obj.Contact__c);

            if (
                    (
                        // Insert 이면서 리드 또는 고객 또는 영업기회 또는 연락처가 존재하는 경우
                        mapOld == null && (obj.Lead__c <> null || obj.Account__c <> null || obj.Opportunity__c <> null || obj.Contact__c <> null)
                    )
                    ||
                    (
                        // Update 이면서
                        mapOld <> null && 
                        (
                            // 리드 필드가 변경되거나
                            (obj.Lead__c <> mapOld.get(obj.Id).Lead__c) ||
                            // 고객 필드가 변경되거나
                            (obj.Account__c <> mapOld.get(obj.Id).Account__c) ||
                            // 영업기회 필드가 변경되거나                            
                            (obj.Opportunity__c <> mapOld.get(obj.Id).Opportunity__c) ||
                            // 연락처 필드가 변경된 경우
                            (obj.Contact__c <> mapOld.get(obj.Id).Contact__c)
                        )
                    )
                ) {            
                    setEventId.add(obj.Id);
                    listSetWhatIdTarget.add(obj);
                    if(obj.Opportunity__c <> null) {
                        setOpportunityId.add(obj.Opportunity__c);
                    }

                    if(obj.Contact__c <> null) {
                        setContactId.add(obj.Contact__c);
                    }
            }
            
            if(
                // Insert 이면서 WhoId가 있거나 Update이면서 WhoId가 다른 WhoId로 변경되었거나 
                ((mapOld == null && obj.WhoId <> null) ||
                (mapOld <> null && obj.WhoId <> null && obj.WhoId <> mapOld.get(obj.Id).WhoId)) ||
                // Insert 이면서 WhatId가 있거나 Update이면서 WhatId가 다른 WhatId로 변경되었거나 
                ((mapOld == null && obj.WhatId <> null) ||
                (mapOld <> null && obj.WhatId <> null && obj.WhatId <> mapOld.get(obj.Id).WhatId))
            ) {
                listSetLookupFieldTarget.add(obj);

                if(obj.WhatId <> null) {
                    String strObjectType = String.valueOf(obj.WhatId.getSobjectType());
                    if(strObjectType == 'Opportunity') {
                        setOpportunityId.add(obj.WhatId);
                    }
                }

                if(obj.WhoId <> null) {
                    String strObjectType = String.valueOf(obj.WhoId.getSobjectType());
                    if(strObjectType == 'Contact') {
                        setContactId.add(obj.WhoId);
                    }
                }
            } 
        }

        System.debug('=================> listSetLookupFieldTarget : '+listSetLookupFieldTarget);
        System.debug('=================> listSetWhatIdTarget : '+listSetWhatIdTarget);

        // WhoId or WhatId 값이 있는경우 Lead__c, Account__c, Opportunity__c, Contact__c 값 자동세팅
        if(listSetLookupFieldTarget <> null && listSetLookupFieldTarget.size() > 0) {
            Map<String, String> mapOpptyAccountId = new Map<String, String>();
            Map<String, String> mapContactAccountId = new Map<String, String>();

            if(!setOpportunityId.isEmpty()) {
                for(Opportunity obj : [
                    SELECT Id, AccountId FROM Opportunity
                    WHERE   Id In:setOpportunityId
                ]) {
                    mapOpptyAccountId.put(obj.Id, obj.AccountId);
                }
            }

            if(!setContactId.isEmpty()) {
                for(Contact obj : [
                    SELECT Id, AccountId FROM Contact
                    WHERE   Id In:setContactId
                ]) {
                    mapContactAccountId.put(obj.Id, obj.AccountId);
                }
            }

            for(Event obj : listSetLookupFieldTarget) {                
                System.debug('===============> obj Start');
                if(obj.WhoId <> null) {                                        
                    String strObjectType = String.valueOf(obj.WhoId.getSobjectType());

                    System.debug('===============> obj.WhoId : '+obj.WhoId);
                    System.debug('===============> obj.WhatId : '+obj.WhatId);
                    System.debug('===============> strObjectType : '+strObjectType);                    

                    if(strObjectType == 'Lead') {
                        obj.WhatId = null;

                        obj.Lead__c = obj.WhoId;
                        obj.Account__c = null;
                        obj.Opportunity__c = null;
                        obj.Contact__c = null;
                    } else if (strObjectType == 'Contact'){ 
                        obj.Lead__c = null;
                        obj.Contact__c = obj.WhoId;
                        obj.Account__c = null;

                        if(mapContactAccountId <> null && mapContactAccountId.get(obj.Contact__c) <> null) {
                            obj.Account__c = mapContactAccountId.get(obj.Contact__c);
                        }
                    }
                } 
                
                if(obj.WhatId <> null) {
                    String strObjectType = String.valueOf(obj.WhatId.getSobjectType());

                    System.debug('===============> obj.WhoId : '+obj.WhoId);
                    System.debug('===============> obj.WhatId : '+obj.WhatId);
                    System.debug('===============> strObjectType : '+strObjectType);                    
                    if(strObjectType == 'Account') {
                        obj.WhoId = null;

                        obj.Lead__c = null;
                        obj.Account__c = obj.WhatId;
                        obj.Opportunity__c = null;
                    } else if(strObjectType == 'Opportunity') {
                        obj.WhoId = null;

                        obj.Lead__c = null;
                        obj.Account__c = null;
                        obj.Opportunity__c = obj.WhatId;
                        
                        if(mapOpptyAccountId <> null && mapOpptyAccountId.get(obj.Opportunity__c) <> null) {
                            obj.Account__c = mapOpptyAccountId.get(obj.Opportunity__c);
                        }
                    }

                    System.debug('===============> after obj : '+JSON.serialize(obj));

                    System.debug('============> after obj.WhoId : '+obj.WhoId);
                    System.debug('============> after obj.WhatId : '+obj.WhatId);

                    System.debug('============> after obj.Lead__c : '+obj.Lead__c);
                    System.debug('============> after obj.Account__c : '+obj.Account__c);
                    System.debug('============> after obj.Opportunity__c : '+obj.Opportunity__c);
                }
                
                // 연락처의 경우 WhatId가 지정되어 있지 않으면 자동 인입
                if ( obj.WhatId == null && obj.WhoId <> null  && mapContactAccountId.get(obj.Contact__c) <> null){
                    obj.WhatId = mapContactAccountId.get(obj.Contact__c);
                }

                System.debug('===============> obj End');
            }
        }

        // Lead__c, Account__c, Opportunity__c, Contact__c 값이 있는경우 WhoId, WhatId 값 자동 세팅
        if(listSetWhatIdTarget <> null && listSetWhatIdTarget.size() > 0) {

            Map<String, String> mapOpptyAccountId = new Map<String, String>();
            Map<String, String> mapContactAccountId = new Map<String, String>();

            if(!setOpportunityId.isEmpty()) {
                for(Opportunity obj : [
                    SELECT Id, AccountId FROM Opportunity
                    WHERE   Id In:setOpportunityId
                ]) {
                    mapOpptyAccountId.put(obj.Id, obj.AccountId);
                }
            }
            
            if(!setContactId.isEmpty()) {
                for(Contact obj : [
                    SELECT Id, AccountId FROM Contact
                    WHERE   Id In:setContactId
                ]) {
                    mapContactAccountId.put(obj.Id, obj.AccountId);
                }
            }

            for(Event obj : listSetWhatIdTarget) {
                System.debug('============> before obj.WhoId : '+obj.WhoId);
                System.debug('============> before obj.WhatId : '+obj.WhatId);

                System.debug('============> before obj.Lead__c : '+obj.Lead__c);
                System.debug('============> before obj.Account__c : '+obj.Account__c);
                System.debug('============> before obj.Opportunity__c : '+obj.Opportunity__c);

                obj.WhatId = null;

                System.debug('============> obj.Lead__c : '+obj.Lead__c);
                System.debug('============> obj.Account__c : '+obj.Account__c);
                System.debug('============> obj.Opportunity__c : '+obj.Opportunity__c);
                   
                if(obj.Lead__c <> null) {
                    obj.WhoId = obj.Lead__c;
                }
                else if(obj.Contact__c <> null) {                     
                    obj.WhoId = obj.Contact__c;
                    
                    if(mapContactAccountId <> null && mapContactAccountId.get(obj.Contact__c) <> null && obj.Account__c == null) {
                        obj.Account__c = mapContactAccountId.get(obj.Contact__c);
                    }
                }

                if(obj.Opportunity__c <> null) {                    
                    obj.WhatId = obj.Opportunity__c;
                    
                    if(mapOpptyAccountId <> null && mapOpptyAccountId.get(obj.Opportunity__c) <> null && obj.Account__c == null) {
                        obj.Account__c = mapOpptyAccountId.get(obj.Opportunity__c);
                    }
                }
                else if(obj.Account__c <> null) {                    
                    obj.WhatId = obj.Account__c;
                }

                System.debug('============> 1 obj.WhoId : '+obj.WhoId);
                System.debug('============> 2 obj.Account__c : '+obj.Account__c);
                System.debug('============> 3 obj.Opportunity__c : '+obj.Opportunity__c);
                System.debug('============> 4 obj.Contact__c : '+obj.Contact__c);
                if(Trigger.isUpdate && (obj.WhoId <> null && (obj.Account__c <> null || obj.Opportunity__c <> null || obj.Contact__c <> null ))) {
                    String strObjectType = String.valueOf(obj.WhoId.getSobjectType());
                    if(strObjectType == 'Lead' && (!Test.isRunningTest())) {
                        obj.addError('리드에서 고객, 영업기회, 연락처로 업무 변경을 할 수 없습니다. 삭제 후 다시 등록해주시기 바랍니다.');
                    }
                }

                System.debug('===============> after obj : '+JSON.serialize(obj));
                System.debug('============> after obj.WhoId : '+obj.WhoId);
                System.debug('============> after obj.WhatId : '+obj.WhatId);
                System.debug('============> after obj.Lead__c : '+obj.Lead__c);
                System.debug('============> after obj.Account__c : '+obj.Account__c);
                System.debug('============> after obj.Opportunity__c : '+obj.Opportunity__c);
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert
    *  내용    : Event 생성시 제목(Subject)에 관련된 Object명 세팅 
    ************************************************************************************************************/
    private void doUpdateName() {
        for(Event objEvent : listNew) {
            // system.debug('objEvent :: ' + objEvent);
            String ObjectName = '';
            if ( (objEvent.WhatId != null || objEvent.WhoId != null) && objEvent.LinkedRecordId__c == null) {
                String whatObjectName = '';
                String whatObjectLabel = '';
                String whoObjectName = '';
                String whoObjectLabel = '';

                if ( objEvent.WhatId != null ){
                    whatObjectName = String.valueOf(Id.valueOf(objEvent.WhatId).getSObjectType().getDescribe().getName());
                    whatObjectLabel = String.valueOf(Id.valueOf(objEvent.WhatId).getSObjectType().getDescribe().getLabel());
                    system.debug('whatObjectName ::: ' + whatObjectName);
                    system.debug('whatObjectLabel ::: ' + whatObjectLabel);
                }
                if ( objEvent.WhoId != null){
                    whoObjectName = String.valueOf(Id.valueOf(objEvent.WhoId).getSObjectType().getDescribe().getName());
                    whoObjectLabel = String.valueOf(Id.valueOf(objEvent.WhoId).getSObjectType().getDescribe().getLabel());
                    system.debug('whoObjectName ::: ' + whoObjectName);
                    system.debug('whoObjectLabel ::: ' + whoObjectLabel);
                }

                if ( whoObjectName == 'Lead'){
                    ObjectName = whoObjectLabel;
                } else if ( whatObjectName == 'Opportunity'){
                    ObjectName = whatObjectLabel;
                } else if ( whoObjectName == 'Contact'){
                    ObjectName = whoObjectLabel;
                } else if ( objEvent.WhatId != null){
                    ObjectName = whatObjectLabel;
                }
                
                objEvent.Subject = '['+ObjectName+'] ' + objEvent.Subject;
            }
        }
    }
    
    /***********************************************************************************************************
    *  Trigger : After Insert, After Update
    *  내용    : Event WhoId 업데이트 시 하위 Relation 초기화 (미진행시 WhoId에 여러 ContactId 할당 위험)
    ************************************************************************************************************/    
    private void doDeleteRelation() {
        
        Map<String,String> mapEventRelation = new Map<String,String>();
        Set<String> setEventId = new Set<String>();
        
        for (Event obj : listNew){
            setEventId.add(obj.Id);
            if (obj.Contact__c != null)
                mapEventRelation.put(obj.Id, obj.Contact__c);
            else if (obj.Lead__c != null)
                mapEventRelation.put(obj.Id, obj.Lead__c);
        }
        
        system.debug('setEventId :: ' + setEventId);
        system.debug('mapEventRelation :: ' + mapEventRelation);

        if(!setEventId.isEmpty()) {
            List<EventRelation> listEventRelation = [
                SELECT Id, EventId, RelationId 
                FROM   EventRelation
                WHERE  isWhat = false 
                AND    EventId IN: setEventId
            ];

            system.debug('listEventRelation :: ' + listEventRelation);
            if(!listEventRelation.isEmpty()){
                List<EventRelation> listDeleteTarget = new List<EventRelation>();
                for (EventRelation objEventRelation : listEventRelation){
                    if (mapEventRelation.get(objEventRelation.EventId) != objEventRelation.RelationId){
                        listDeleteTarget.add(objEventRelation);
                        system.debug('listDeleteTarget :: ' + listDeleteTarget);
                    }
                }
                delete listDeleteTarget;
            }
        }

    }

    
    /***********************************************************************************************************
    *  Trigger : Before Update
    *  내용    : 업무 생성 후 (1)외근 → 내근 혹은 (2) 외근[동행X] -> 외근[동행O] 변경 시 설정된 주유비 정보 초기화
    ************************************************************************************************************/    
    private void doWorkTypeOrIsPassengerChangeHandle() {
        for ( Event objEvent : listNew){
            if ( (mapOld.get(objEvent.Id).WorkType__c == '외근' && objEvent.WorkType__c == '내근') 
            || (mapOld.get(objEvent.Id).WorkType__c == '외근' && mapOld.get(objEvent.Id).isPassenger__c == false && objEvent.WorkType__c== '외근' && objEvent.isPassenger__c == true)){
                objEvent.Departure__c = null;
                objEvent.Arrival__c = null;
                objEvent.WayPoint1__c = null;
                objEvent.WayPoint2__c = null;
                objEvent.WayPoint3__c = null;
                objEvent.WayPoint4__c = null;
                objEvent.WayPoint5__c = null;
                objEvent.Distancekm__c = null;
                objEvent.DistancekmTmap__c = null;
                objEvent.VehicleRefuelingCosts__c = null;                
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger : After Insert, After Update
    *  내용    : FS 관련 Event 생성, 업데이트시 LinkedRecordId__c 값 세팅
    ************************************************************************************************************/    
    private void doUpdateLinkedObject() {
        Set<Id> setTargetId = new Set<Id>();
        map<String, Event> mapEvent = new map<String, Event>();
        map<String, List<String>> mapLinkedObjectList = new map<String, List<String>>();

        for(Event objEvent : listNew) {
            String LinkedRecordId = objEvent.LinkedRecordId__c;
            if ( LinkedRecordId != '' && LinkedRecordId != null){
                if ( listOld == null){
                    mapEvent.put(LinkedRecordId, objEvent);
                    String ObjectPrefix = LinkedRecordId.substring(0,3);
                    if ( mapLinkedObjectList.get(ObjectPrefix) == null ){
                        mapLinkedObjectList.put(ObjectPrefix , new List<String>{LinkedRecordId});
                    }
                    else {
                        List<String> listExistId = mapLinkedObjectList.get(ObjectPrefix);
                        listExistId.add(LinkedRecordId);
                        mapLinkedObjectList.put(ObjectPrefix, listExistId);
                    }
                }
                else {
                    Event objOldEvent = mapOld.get(objEvent.Id);
                    if ( 
                        objEvent.StartDateTime != objOldEvent.StartDateTime ||
                        objEvent.EndDateTime != objOldEvent.EndDateTime ||
                        objEvent.WorkType__c != objOldEvent.WorkType__c ||
                        objEvent.Description != objOldEvent.Description 
                    ){
                        mapEvent.put(LinkedRecordId, objEvent);
                        String ObjectPrefix = LinkedRecordId.substring(0,3);
                        if ( mapLinkedObjectList.get(ObjectPrefix) == null ){
                            mapLinkedObjectList.put(ObjectPrefix , new List<String>{LinkedRecordId});
                        }
                        else {
                            List<String> listExistId = mapLinkedObjectList.get(ObjectPrefix);
                            listExistId.add(LinkedRecordId);
                            mapLinkedObjectList.put(ObjectPrefix, listExistId);
                        }
                    }
                }
            } 
        }
        
        if( !mapLinkedObjectList.isEmpty()){
            for ( String key : mapLinkedObjectList.keySet()){
                List<String> listLinkedId = mapLinkedObjectList.get(key);
                String ObjectName = String.valueOf(Id.valueOf(listLinkedId[0]).getSObjectType());
                Schema.SObjectType t = Schema.getGlobalDescribe().get(ObjectName);
                List<SObject> listLinkedObject = new List<SObject>();
                for ( String LinkedId : listLinkedId ){
                    SObject targetSObject = t.newSObject(LinkedId);
                    targetSObject.put('LinkedRecordId__c', mapEvent.get(LinkedId).Id);
                    if ( listOld != null){
                        targetSObject.put('StartDateTime__c', mapEvent.get(LinkedId).StartDateTime);
                        targetSObject.put('EndDateTime__c', mapEvent.get(LinkedId).EndDateTime);
                        targetSObject.put('WorkType__c', mapEvent.get(LinkedId).WorkType__c);
                        targetSObject.put('Activityinfo__c', mapEvent.get(LinkedId).Description);
                    }
                    listLinkedObject.add(targetSObject);
                }
                update listLinkedObject;
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger : After Delete
    *  내용    : FS 관련 Event 삭제시 연결된 Object Record 삭제
    ************************************************************************************************************/
    private void doDeleteLinkedObject() {
        Set<Id> setTargetId = new Set<Id>();
        map<String, List<String>> mapLinkedObjectList = new map<String, List<String>>();

        for(Event objEvent : listOld) {
            String LinkedRecordId = objEvent.LinkedRecordId__c;
            if ( LinkedRecordId != '' && LinkedRecordId != null){
                String ObjectPrefix = LinkedRecordId.substring(0,3);
                if ( mapLinkedObjectList.get(ObjectPrefix) == null ){
                    mapLinkedObjectList.put(ObjectPrefix , new List<String>{LinkedRecordId});
                }
                else {
                    List<String> listExistId = mapLinkedObjectList.get(ObjectPrefix);
                    listExistId.add(LinkedRecordId);
                    mapLinkedObjectList.put(ObjectPrefix, listExistId);
                }
            }
        }
        if( !mapLinkedObjectList.isEmpty()){
            for ( String key : mapLinkedObjectList.keySet()){
                List<String> listLinkedId = mapLinkedObjectList.get(key);
                String ObjectName = String.valueOf(Id.valueOf(listLinkedId[0]).getSObjectType());
                
                String strQuery =   '   SELECT     Id';
                strQuery +=         '   FROM       ' + ObjectName;
                strQuery +=         '   WHERE      Id IN :listLinkedId';
                List<SObject> listLinkedObject = Database.query(strQuery);

                System.debug('listLinkedObject :: ' + listLinkedObject);
                if ( !listLinkedObject.isEmpty() ){
                    
                    // 여기에 Validation 로직 필요
                    delete listLinkedObject;
                }
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger : After Update, After Delete
    *  내용    : Event 변경, 삭제시 해당 event 관련 기존 활동 보고의 활동이 0인 경우 활동 보고 삭제처리
    ************************************************************************************************************/
    private void doDeleteActivityReport() {
    
        Set<Id> setIdActivityReport = new Set<Id>();
        Set<Id> deleteTargetId = new Set<Id>();
        
        // 편집의 경우     
        if( listNew != null && listOld != null){
            for(Event objEvent : listOld) {
                if (objEvent.ActivityReport__c != null){
                    setIdActivityReport.add(objEvent.ActivityReport__c);
                }
            }
        }
        
        // 삭제의 경우
        if( listNew == null && listOld != null){
            for(Event objEvent : listOld) {
                if (objEvent.ActivityReport__c != null){
                    setIdActivityReport.add(objEvent.ActivityReport__c);
                }
            }
        }
        
        if(!setIdActivityReport.isEmpty()){
            //Event가 한개라도 있는 경우만 추출됨
            List<AggregateResult> results = [
                SELECT ActivityReport__r.Id targetId
                FROM Event 
                WHERE ActivityReport__c In: setIdActivityReport 
                GROUP BY ActivityReport__r.Id
            ];

            Set<Id> childHave = new Set<Id>();
            for(AggregateResult aggResult : results) {
                childHave.add((Id)aggResult.get('targetId'));
            }
            setIdActivityReport.removeAll(childHave);            
        }

        if(!setIdActivityReport.isEmpty()){
            List<ActivityReport__c> delTarget = [
                SELECT Id
                FROM ActivityReport__c
                WHERE Id IN: setIdActivityReport
            ];
            
            Delete delTarget;           

        }
    }
    
    /***********************************************************************************************************
    *  Trigger : After Insert, After Update
    *  내용    : Event 생성, 업데이트시 AccountType__c 값 세팅
    ************************************************************************************************************/    
    private void doUpdateAccountType() {
            
        Map<String, String> mapUpdateTarget = new Map<String, String>();

        List<Event> listEventTarget = new List<Event>();
        Set<String> setAccountId = new Set<String>();

        if ( listOld == null){
            for ( Event objEventInsert : listNew){
                if ( objEventInsert.Account__c != null ){
                    listEventTarget.add(objEventInsert);
                    setAccountId.add(objEventInsert.Account__c);
                }
            }
        } else {
            for ( Event objEventUpdate : listNew){
                if ( mapOld.get(objEventUpdate.Id).Account__c != objEventUpdate.Account__c){
                    if ( objEventUpdate.Account__c != null){
                        listEventTarget.add(objEventUpdate);
                        setAccountId.add(objEventUpdate.Account__c);
                    }
                }
            }
        }

        if ( !listEventTarget.isEmpty() ){
            
            String existingCustomerId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();

            Map<Id, Account> mapAccount = new Map<Id, Account> ([
                SELECT  Id, RecordTypeId
                FROM    Account
                WHERE   Id In: setAccountId
            ]);

            if ( !listEventTarget.isEmpty()){
                for (Event objEvent : listEventTarget){
                    String newRecordTypeId = '';

                    if ( objEvent.Account__c != null){
                        NewRecordTypeId = mapAccount.get(objEvent.Account__c).RecordTypeId;
                    }

                    if( newRecordTypeId == '' ){
                        objEvent.AccountType__c = '';
                    } else if (newRecordTypeId == existingCustomerId ){
                        objEvent.AccountType__c = '기존고객';
                    } else {
                        objEvent.AccountType__c = '가망고객';
                    }
                }
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger : After Insert, After Update, After Delete
    *  내용    : Event 생성, 변경, 삭제시 고객(ACCOUNT)의 최근방문일자 field(RecentVisitDateTime__c) 가장 최근으로 알맞게 세팅
    ************************************************************************************************************/
    private void doUpdateRecentVisitDateTimeOfAccount() {
    
        Set<Id> targetAccount = new Set<Id>();

        // 생성의 경우   
        if( listNew != null && listOld == null){
            for(Event objEvent : listNew) {
                if (objEvent.Account__c != null && objEvent.WorkType__c == '외근'){
                    targetAccount.add(objEvent.Account__c);
                }
            }
        }
        
        // 편집의 경우     
        if( listNew != null && listOld != null){
            for(Event objEvent : listNew) {
                if((objEvent.Account__c != mapOld.get(objEvent.Id).Account__c) || (objEvent.WorkType__c != mapOld.get(objEvent.Id).WorkType__c) 
                || (objEvent.StartDateTime != mapOld.get(objEvent.Id).StartDateTime)){
                    if(mapOld.get(objEvent.Id).WorkType__c  == '외근' && mapOld.get(objEvent.Id).Account__c != null){
                        targetAccount.add(mapOld.get(objEvent.Id).Account__c);
                    }
                    if(objEvent.WorkType__c == '외근' && objEvent.Account__c != null){
                        targetAccount.add(objEvent.Account__c);
                    }
                    
                }
            }
        }
        
        // 삭제의 경우
        if( listNew == null && listOld != null){
            for(Event objEvent : listOld) {
                if (objEvent.WorkType__c == '외근' && objEvent.Account__c != null){
                    targetAccount.add(objEvent.Account__c);
                }
            }
        }
        if(!targetAccount.isEmpty()){
            List<AggregateResult> mapRecentVisitDateTimeInfo = new List<AggregateResult> ([
                SELECT Account__c, MAX(StartDateTime) recentDate
                FROM Event 
                WHERE Account__c in :targetAccount AND WorkType__c = '외근'
                group by Account__c
            ]);

            List<Account> listUpdateTarget = new List<Account>();      

            Set<Id> needAcct = new Set<Id>();
            for(AggregateResult each : mapRecentVisitDateTimeInfo){
                Account acct = new Account();
                if(each.get('Account__c') != null && each.get('Account__c') != ''){
                    acct.Id = (Id)each.get('Account__c');
                    acct.RecentVisitDateTime__c = (Datetime)each.get('recentDate');
                    acct.isAdminUpdate__c = true;
                    needAcct.add(acct.Id);
                    listUpdateTarget.add(acct);
                }                
            }

            //삭제 혹은 변경으로 혹은 생성일때도 결과가 내근만 있는 경우 최근 방문일자 NULL처리하는 로직
            targetAccount.removeAll(needAcct);
            if(!targetAccount.isEmpty()){
                for(Id eachId : targetAccount){
                    Account acct1 = new Account();
                    acct1.Id = eachId;
                    acct1.RecentVisitDateTime__c = null;
                    acct1.isAdminUpdate__c = true;
                    listUpdateTarget.add(acct1);
                }
            }
            
            if(listUpdateTarget.size() > 0){
                update listUpdateTarget;
            }            
        }
    }

    /***********************************************************************************************************
    *  Trigger : After Insert, After Update, After Delete
    *  내용    : Event 생성, 변경, 삭제시 (내근 or 외근이면서 동행)만 있는 경우 활동보고(ActivityReport__c)의 주유비 처리상태(ApprovalStatus__c) 값 변경
                (내근 or 외근이면서 동행)만 있는 경우 해당없음(None)
    ************************************************************************************************************/
    private void doUpdateStatus() {
    
        Set<Id> setIdActivityReport = new Set<Id>();

        // 생성의 경우   
        if( listNew != null && listOld == null){
            for(Event objEvent : listNew) {
                if (objEvent.ActivityReport__c != null){
                    setIdActivityReport.add(objEvent.ActivityReport__c);
                }
            }
        }
        
        // 편집의 경우     
        if( listNew != null && listOld != null){
            for(Event objEvent : listNew) {
                if (objEvent.ActivityReport__c != mapOld.get(objEvent.Id).ActivityReport__c || objEvent.WorkType__c != mapOld.get(objEvent.Id).WorkType__c
                || objEvent.isPassenger__c != mapOld.get(objEvent.Id).isPassenger__c){
                    if (objEvent.ActivityReport__c != null)
                        setIdActivityReport.add(objEvent.ActivityReport__c);
                    if (mapOld.get(objEvent.Id).ActivityReport__c != null) 
                        setIdActivityReport.add(mapOld.get(objEvent.Id).ActivityReport__c);
                }
            }
        }
        
        // 삭제의 경우
        if( listNew == null && listOld != null){
            for(Event objEvent : listOld) {
                if (objEvent.ActivityReport__c != null){
                    setIdActivityReport.add(objEvent.ActivityReport__c);
                }
            }
        }
        
        if(!setIdActivityReport.isEmpty()){
            Map<Id,ActivityReport__c> mapActivityReport = new Map<Id,ActivityReport__c> ([
                SELECT  Id, ApprovalStatus__c
                FROM    ActivityReport__c
                WHERE   Id In: setIdActivityReport
            ]);

            List<Event> listEvent = new List<Event> ([
                SELECT  ActivityReport__c, ActivityReport__r.ApprovalStatus__c, WorkType__c, isPassenger__c
                FROM    Event
                WHERE   ActivityReport__c In: setIdActivityReport
            ]);
            
            Map<Id,List<Event>> mapEvent = new Map<Id,List<Event>>();
            List<ActivityReport__c> listUpdateTarget = new List<ActivityReport__c>();

            for ( Event objEvent : listEvent){
                if ( mapEvent.get(objEvent.ActivityReport__c) == null){
                    List<Event> listTempEvent = new List<Event>();
                    listTempEvent.add(objEvent);
                    mapEvent.put(objEvent.ActivityReport__c, listTempEvent);
                } else {
                    List<Event> listTempEvent = mapEvent.get(objEvent.ActivityReport__c);
                    listTempEvent.add(objEvent);
                    mapEvent.put(objEvent.ActivityReport__c, listTempEvent);
                }
            } 

            for ( Id IdActivityReport : mapActivityReport.keySet()){
                if ( mapActivityReport.get(IdActivityReport).ApprovalStatus__c =='request' || mapActivityReport.get(IdActivityReport).ApprovalStatus__c =='approved'){
                    continue; //승인요청 및 승인 상태의 경우 변경 대상이 아님으로 skip
                }
                if ( mapEvent.get(IdActivityReport) != null){
                    List<Event> listTargetEvent = mapEvent.get(IdActivityReport);

                    Boolean hasFuelInfo = false;
                    for ( Event objEvent : listTargetEvent){
                        if (objEvent.WorkType__c =='외근' && objEvent.isPassenger__c == false){
                            hasFuelInfo = true;
                        } 
                    }

                    if (hasFuelInfo){//[외근&동행X]있는 경우 작성중으로 셋팅
                        if ( mapActivityReport.get(IdActivityReport).ApprovalStatus__c != 'Writing'){
                            ActivityReport__c objActivityReport = new ActivityReport__c();
                            objActivityReport.Id = IdActivityReport;
                            objActivityReport.ApprovalStatus__c = 'Writing';
                            listUpdateTarget.add(objActivityReport);
                        }                        
                    } else {//이외는 다 대상아님으로 셋팅
                        if ( mapActivityReport.get(IdActivityReport).ApprovalStatus__c != 'None'){
                            ActivityReport__c objActivityReport = new ActivityReport__c();
                            objActivityReport.Id = IdActivityReport;
                            objActivityReport.ApprovalStatus__c = 'None';
                            listUpdateTarget.add(objActivityReport);
                        }                        
                    }
                }  
            }

            if( !listUpdateTarget.isEmpty()){
                update listUpdateTarget;
            }                
        }
    }

    /***********************************************************************************************************
    *  Trigger : After Insert, After Update, After Delete
    *  내용    : Event 생성, 변경, 삭제시 연결된 활동보고(ActivityReport__c)의 금액(OilTotalAmount__c), 거리(OilTotalDistance__c) 업데이트 
    ************************************************************************************************************/
    private void doUpdateTotal() {
        Set<Id> setIdActivityReport = new Set<Id>();

        // 생성의 경우   
        if( listNew != null && listOld == null){
            for(Event objEvent : listNew) {
                if (objEvent.ActivityReport__c != null && objEvent.Distancekm__c != 0 ){
                    setIdActivityReport.add(objEvent.ActivityReport__c);
                }
            }
        }
        
        // 편집의 경우     
        if( listNew != null && listOld != null){
            for(Event objEvent : listNew) {
                // 23.03.14 Minje.kim :: 
                // 주유비 금액 변경시에도 활동보고 합산되도록 변경 (단가 미산정 데이터 재계산시 필요)
                if (objEvent.ActivityReport__c != mapOld.get(objEvent.Id).ActivityReport__c || 
                    objEvent.Distancekm__c != mapOld.get(objEvent.Id).Distancekm__c ||
                    objEvent.VehicleRefuelingCosts__c != mapOld.get(objEvent.Id).VehicleRefuelingCosts__c
                    ){
                    if (objEvent.ActivityReport__c != null)
                        setIdActivityReport.add(objEvent.ActivityReport__c);
                    if (mapOld.get(objEvent.Id).ActivityReport__c != null) 
                        setIdActivityReport.add(mapOld.get(objEvent.Id).ActivityReport__c);
                }
            }
        }
        
        // 삭제의 경우
        if( listNew == null && listOld != null){
            for(Event objEvent : listOld) {
                if (objEvent.ActivityReport__c != null){
                    setIdActivityReport.add(objEvent.ActivityReport__c);
                }
            }
        }

        if(!setIdActivityReport.isEmpty()){
            List<AggregateResult> listAggregateEvent = new List<AggregateResult> ([
                SELECT  ActivityReport__c, SUM(VehicleRefuelingCosts__c) totalAmount, SUM(Distancekm__c) totalDistance
                FROM    Event
                WHERE   ActivityReport__c In: setIdActivityReport
                GROUP BY ActivityReport__c
            ]);
            List<ActivityReport__c> listUpdateTarget = new List<ActivityReport__c>();
            Set<Id> setIdExistActivityReport = new Set<Id>();

            for ( AggregateResult objAggregateEvent : listAggregateEvent){
                ActivityReport__c objActivityReport = new ActivityReport__c();
                objActivityReport.Id = String.valueOf(objAggregateEvent.get('ActivityReport__c'));
                objActivityReport.OilTotalAmount__c = (Decimal)objAggregateEvent.get('totalAmount');
                objActivityReport.OilTotalDistance__c = (Decimal)objAggregateEvent.get('totalDistance');
                listUpdateTarget.add(objActivityReport);
                setIdExistActivityReport.add(String.valueOf(objAggregateEvent.get('ActivityReport__c')));
            }
            
            for ( Id ActivityReportId : setIdActivityReport){
                if ( !setIdExistActivityReport.Contains(ActivityReportId)){
                    ActivityReport__c objActivityReport = new ActivityReport__c();
                    objActivityReport.Id = ActivityReportId;
                    objActivityReport.OilTotalAmount__c = null;
                    objActivityReport.OilTotalDistance__c = null;
                    listUpdateTarget.add(objActivityReport);
                }
            }

            if( !listUpdateTarget.isEmpty())
                update listUpdateTarget;
        }
    }

    /***********************************************************************************************************
    *  Trigger : Before Update, Before Delete
    *  내용    : Event 변경, 삭제시 주유비 제출완료, 승인요청, 승인완료된 Event는 변경, 삭제하지 못하도록 Validation
    ************************************************************************************************************/
    private void doHandleValidation() {
        Set<Id> setIdActivityReport = new Set<Id>();
        List<Event> listTargetEvent = new List<Event>();

        // 변경의 경우   
        if(Trigger.isUpdate){
            System.debug('===============> Trigger.isUpdate true');

            for(Event objEvent : listNew) {
                Event objOldEvent = mapOld.get(objEvent.Id);
                // validation bypass 후 초기화
                if (objEvent.isSystem__c == true){
                    objEvent.isSystem__c = false;
                }
                else if ( objEvent.LinkedRecordId__c != null  && objEvent.WhatId != objOldEvent.WhatId) {
                    objEvent.addError('해당 활동은 관련항목을 변경할 수 없습니다. (FS)');
                }
                else if (objEvent.fm_ApprovalStatus__c != 'Request' && objEvent.fm_ApprovalStatus__c != 'Approved'){
                    if (objEvent.StartDateTime != objOldEvent.StartDateTime && objEvent.Distancekm__c != null && objEvent.Distancekm__c != 0){
                        Date today = System.today();
                        Date targetDay = date.newinstance(objEvent.StartDateTime.year(), objEvent.StartDateTime.month(), objEvent.StartDateTime.day());
                        Integer numberDaysDue = today.daysBetween(targetDay);
                        if (numberDaysDue < -7 && !Test.isRunningTest()){
                            objEvent.addError('주유비가 설정된 활동의 활동일자는 금일 기준 7일전까지 변경이 가능합니다.');
                        }
                    }
                } else if (objEvent.fm_ApprovalStatus__c == 'Request'){
                    if (objEvent.Distancekm__c != objOldEvent.Distancekm__c && !Test.isRunningTest()){
                        objEvent.addError('주유비가 설정된 활동은 승인요청 상태에서 주유비를 편집할 수 없습니다.');
                    } else if (objEvent.StartDateTime != objOldEvent.StartDateTime && !Test.isRunningTest()){
                        objEvent.addError('주유비가 설정된 활동은 승인요청 상태에서 활동일자를 편집할 수 없습니다.');
                    }
                } else if (objEvent.fm_ApprovalStatus__c == 'Approved'){
                    if (objEvent.Distancekm__c != objOldEvent.Distancekm__c && !Test.isRunningTest()){
                        objEvent.addError('주유비가 설정된 활동은 승인완료 상태에서 주유비를 편집할 수 없습니다.');
                    } else if (objEvent.StartDateTime != objOldEvent.StartDateTime && !Test.isRunningTest()){
                        objEvent.addError('주유비가 설정된 활동은 승인완료 상태에서 활동일자를 편집할 수 없습니다.');
                    }
                }
            }
        }
        // 삭제의 경우
        else if(Trigger.isDelete){
            System.debug('===============> Trigger.isDelete true');
            for(Event objEvent : listOld) {
                if (objEvent.isSystem__c == true){
                    // validation bypass 후 초기화
                    objEvent.isSystem__c = false;
                }
                else if (objEvent.Distancekm__c != null && objEvent.Distancekm__c != 0){
                    if ( objEvent.fm_ApprovalStatus__c == 'Request')
                        objEvent.addError('주유비가 설정된 활동은 제출완료 상태에서 삭제할 수 없습니다.');
                    else if ( objEvent.fm_ApprovalStatus__c == 'Approved')
                        objEvent.addError('주유비가 설정된 활동은 승인 상태에서 삭제할 수 없습니다.');
                }
            }
        }
    }

}