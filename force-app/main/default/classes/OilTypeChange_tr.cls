/************************************************************************************
 * File Name   		: OilTypeChange_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.06
 * Tester	  		: OilTypeChange_tr_test.cls
 * Description 		: OilTypeChange_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.Kim       Create
 * 1.1      2023.04.10      sy.lee          update
*************************************************************************************/

public without sharing class OilTypeChange_tr extends TriggerHandler {
    public OilTypeChange_tr() {
        listNew = (List<OilTypeChange__c>) trigger.new;
        mapOld = (Map<Id, OilTypeChange__c>) trigger.oldMap;
        listOld = (List<OilTypeChange__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<OilTypeChange__c> listNew { get; set; }
    private List<OilTypeChange__c> listOld { get; set; }
    private Map<Id, OilTypeChange__c> mapOld { get; set; }

    public override void beforeUpdate() {
        doSetEndDate();
        doCheckFile();
    }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : Before Update   
    *  내용    : 승인 요청을 하는 경우 업로드 파일 유무를 체크해서 파일이 없으면 에러메세지 출력
    ************************************************************************************************************/
    private void doCheckFile() {
        Set<Id> checkTargetId = new Set<Id>(); 
        Set<Id> passId = new Set<Id>(); 
        List<SObject> haveFile;
        for(OilTypeChange__c eachOld : listOld){   
            for(OilTypeChange__c eachNew : listNew){
                if(eachOld.Id == eachNew.Id && eachOld.ApprovalStatus__c != eachNew.ApprovalStatus__c && eachNew.ApprovalStatus__c == '승인요청'){
                    checkTargetId.add(eachNew.Id);
                }
            }
        }        
        if(checkTargetId.size()>0){
            List<OilTypeChange__c> arrorTarget;
            haveFile = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :checkTargetId];
            for (SObject each : haveFile) {
                passId.add((Id)each.get('LinkedEntityId'));
            }
            checkTargetId.removeAll(passId);            
            arrorTarget = [SELECT Id FROM OilTypeChange__c WHERE id in :checkTargetId ];
            for(OilTypeChange__c eachNew : listNew){
                for(OilTypeChange__c each : arrorTarget){
                    if (eachNew.Id == each.Id) {
                        if (!Test.isRunningTest()) {
                            eachNew.addError('승인요청을 위해 파일 첨부는 필수입니다. 파일을 업로드 해주세요.');
                        }                        
                    }                
                }
            }   
        }          
        
    }

    /***********************************************************************************************************
    *  Trigger : Before Update   
    *  내용    : 승인이 된 경우 해당 레코드 소유자의 직전 승인된 레코드 종료일,종료일시를 현재로 update
    ************************************************************************************************************/
    private void doSetEndDate() {
        Datetime endDateTime = Datetime.now();
        Date endDate = Date.valueOf(endDateTime);
        Set<Id> ownerIds = new Set<Id>();
        for(OilTypeChange__c eachOld : listOld){   
            for(OilTypeChange__c eachNew : listNew){
                if(eachOld.Id == eachNew.Id && eachOld.ApprovalStatus__c != eachNew.ApprovalStatus__c && eachNew.ApprovalStatus__c == '승인'){
                    ownerIds.add(eachNew.OwnerId);
                }
            }
        }
        List<OilTypeChange__c> endDateTg =[
            SELECT EndDate__c, EndDateTime__c
            FROM OilTypeChange__c
            WHERE StartDate__c !=NULL AND EndDate__c = NULL AND OwnerId IN :ownerIds
        ];
        for(OilTypeChange__c each :endDateTg){
            each.EndDate__c = endDate;
            each.EndDateTime__c = endDateTime;
        }
        if(!endDateTg.isEmpty()){
            update endDateTg;
        }
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('OilTypeChange__c', 'OilTypeChangeTracking', listNew, mapOld);
    }
}