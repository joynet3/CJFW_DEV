/************************************************************************************
 * File Name   		: Opportunity_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.08.24
 * Tester	  		: Opportunity_tr_test.cls
 * Description 		: Opportunity_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.08.24      Minje.Kim       Create
 * 1.1      2023.10.06      Jieun.Lee       Delete
*************************************************************************************/

public without sharing class Opportunity_tr extends TriggerHandler {
    public Opportunity_tr() {
        system.debug('Opportunity Trigger Handler START');
        listNew = (List<Opportunity>) trigger.new;
        mapOld = (Map<Id, Opportunity>) trigger.oldMap;
        listOld = (List<Opportunity>) trigger.old;

        idNaraMarketOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NaraMarketOpportunity').getRecordTypeId();
        idMilitaryOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MilitaryOpportunity').getRecordTypeId();
    }

    /*** TriggerHandler ***/
    private List<Opportunity> listNew { get; set; }
    private List<Opportunity> listOld { get; set; }
    private Map<Id, Opportunity> mapOld { get; set; }

    // 나라장터 RecordTypeId
    private Id idNaraMarketOpportunity {get;set;}
    // 군납사이트 RecordTypeId
    private Id idMilitaryOpportunity {get;set;}

    public override void beforeInsert() {
        doSetAutoRecordType();
        doSetName();
        doCheckClone();
    }   

    public override void beforeUpdate() {
        doSetAutoRecordType();
    }

    public override void afterUpdate() {
        doFieldTracking();
    }

    public override void beforeDelete(){
        doCheckStatus();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('Opportunity', 'OpportunityTracking', listNew, mapOld);
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert
    *  내용    : 레코드 생성시 Name 자동세팅
    ************************************************************************************************************/
    private void doSetName() {
        List<String> listAccountId = new List<String>();
        List<String> listOwnerId = new List<String>();

        for(Opportunity objOppty : listNew) {
            listAccountId.add(objOppty.AccountId);
            listOwnerId.add(objOppty.OwnerId);
        }
     
        Map<Id, Account> mapAccount = new Map<Id, Account>([
            SELECT Id, Name
            FROM Account
            WHERE Id IN :listAccountId
        ]);

        Map<Id, User> mapOwner = new Map<Id, User>([
            SELECT Id, Name
            FROM User
            WHERE Id IN :listOwnerId
        ]);

        for(Opportunity objOppty : listNew) {
            objOppty.Name = '['+mapAccount.get(objOppty.AccountId).Name+'] ['+mapOwner.get(objOppty.OwnerId).Name+'] '+objOppty.Name;
        }
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert
    *  내용    : 레코드 생성시 복제인경우 ContractId 빈값 처리
    ************************************************************************************************************/
    private void doCheckClone() {
        for(Opportunity obj : listNew) {
            if(obj.isClone() && obj.ContractId <> null) {
                system.debug('1> clone check');
                obj.ContractId = null;
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert, Before Update
    *  내용    : 레코드 생성, 변경시 ClosedDate 자동세팅
    ************************************************************************************************************/    
    private void doSetAutoRecordType() {
        List<Opportunity> listTarget = new List<Opportunity>();

        for(Opportunity obj : listNew) {
            if((mapOld == null && obj.BidNoticeSource__c <> null) || (mapOld <> null && obj.BidNoticeSource__c <> mapOld.get(obj.Id).BidNoticeSource__c)) {
                listTarget.add(obj);
            }
        }

        if(listTarget <> null && listTarget.size() > 0) {

            for(Opportunity obj : listTarget) {                
                if(obj.LeadSource == 'NaraMarket') {
                    obj.RecordTypeId = idNaraMarketOpportunity;

                    // Opportunity ClosedDate 세팅
                    // 나라장터일경우
                    // 입찰 참가자격 등록 마감 일시(BidQualifyRegistCloseDateTime__c) 값이 있으면 -1 Day
                    if(obj.BidQualifyRegistCloseDateTime__c <> null) {

                        Date dtClosedDate = Date.valueOf(obj.BidQualifyRegistCloseDateTime__c);
                        obj.CloseDate = dtClosedDate.addDays(-1);
                    }
                    // 입찰 마감 일시(BidCloseDateTime__c) 값이 있으면 -1 Day
                    else if(obj.BidCloseDateTime__c <> null) {
                        Date dtClosedDate = Date.valueOf(obj.BidCloseDateTime__c);
                        obj.CloseDate = dtClosedDate.addDays(-1);
                    }
                    // 개찰 일시(BidOpenDateTime__c) 값이 있으면 -1 Day
                    else if(obj.BidOpenDateTime__c <> null) {
                        Date dtClosedDate = Date.valueOf(obj.BidOpenDateTime__c);
                        obj.CloseDate = dtClosedDate.addDays(-1);
                    }
                }else if(obj.LeadSource == 'Military') {
                    obj.RecordTypeId = idMilitaryOpportunity;

                    // Opportunity ClosedDate 세팅
                    // 국방전자조달시스템일경우
                    // 입찰참가등록 마감일시(BidRegistCloseDateTime__c) 값이 있으면 -1 Day
                    if(obj.BidRegistCloseDateTime__c <> null) {
                        Date dtClosedDate = Date.valueOf(obj.BidRegistCloseDateTime__c);
                        obj.CloseDate = dtClosedDate.addDays(-1);
                    }                    
                    // 입찰서 제출 마감일시(BidLetterSubmitCloseDateTime__c) 값이 있으면 -1 Day
                    else if(obj.BidLetterSubmitCloseDateTime__c <> null) {
                        Date dtClosedDate = Date.valueOf(obj.BidLetterSubmitCloseDateTime__c);
                        obj.CloseDate = dtClosedDate.addDays(-1);
                    }
                    // 개찰 일시(BidOpenDateTime__c) 값이 있으면 -1 Day
                    else if(obj.BidOpenDateTime__c <> null) {
                        Date dtClosedDate = Date.valueOf(obj.BidOpenDateTime__c);
                        obj.CloseDate = dtClosedDate.addDays(-1);
                    }
                }
            }
        }
    }

     /***********************************************************************************************************
    *  Trigger : Before Delete
    *  내용    : 진행된 영업기회 삭제 방지, 소유자만 삭제 가능
    ************************************************************************************************************/    
    private void doCheckStatus(){

        for(Opportunity obj : listOld){
            if(obj.OwnerId <> null && UserInfo.getUserId() <> null){
                if(obj.StageName.contains('Closed')){
                    obj.addError('진행된 영업기회는 삭제할 수 없습니다.');
                }else if(obj.OwnerId <> UserInfo.getUserId()){
                    obj.addError('영업기회 소유자만 삭제 가능합니다.');
                }
            }
        }
    
    }


}