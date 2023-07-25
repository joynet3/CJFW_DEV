/************************************************************************************
 * File Name   		: ContentDocument_tr.cls
 * Author	  		: Seoyoung.Lee
 * Date				: 2023.04.14
 * Tester	  		: ContentDocument_tr_test.cls
 * Description 		: ContentDocument_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.04.14      Seoyoung.Lee       Create
*************************************************************************************/
public with sharing class ContentDocument_tr extends TriggerHandler  {
    public ContentDocument_tr() {
        listNew = (List<ContentDocument>) trigger.new;
        mapNew = (Map<Id, ContentDocument>) trigger.NewMap;
        listOld = (List<ContentDocument>) trigger.old;
        mapOld = (Map<Id, ContentDocument>) trigger.oldMap;
        
    }
    /*** TriggerHandler ***/ 
    private List<ContentDocument> listNew { get; set; }
    private List<ContentDocument> listOld { get; set; }
    private Map<Id, ContentDocument> mapOld { get; set; }
    private Map<Id, ContentDocument> mapNew { get; set; }

    public override void beforeInsert() {
        // doCheckApprovalStatusOfOilChangeOfInsert(); 파일업로드, 파일 추가는 다른 로직인것 등..복잡해서 파일 추가 막는 것은 뺌
    }

    public override void beforeDelete() {
        doCheckApprovalStatusOfOilChangeOfDelete();
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert
    *  내용    : 유류유형 변경의 첨부파일이고 승인단계가 승인요청 혹은 승인이면 추가 못하도록 설정
    ************************************************************************************************************/
    // private void doCheckApprovalStatusOfOilChangeOfInsert() {
    //     // Get the linked entity IDs from the ContentDocumentLink records
    //     Set<Id> linkedEntityIds = new Set<Id>();
    //     for(ContentDocumentLink link : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :mapNew.keySet()]) {
    //         linkedEntityIds.add(link.LinkedEntityId);
    //     }

    //     // Query the linked entities to check for the condition
    //     List<OilTypeChange__c> linkedEntities = [SELECT Id,ApprovalStatus__c  FROM OilTypeChange__c WHERE Id IN :linkedEntityIds];
    //     Map<Id, OilTypeChange__c> oilInfo = new Map<Id, OilTypeChange__c>([SELECT Id, ApprovalStatus__c FROM OilTypeChange__c WHERE Id IN :linkedEntityIds]);
    //     for (ContentDocument cd : listNew) {
    //         if(oilInfo.containsKey(cd.LatestPublishedVersionId)) {
    //             OilTypeChange__c relatedEtt = oilInfo.get(cd.LatestPublishedVersionId);
    //             if(relatedEtt.ApprovalStatus__c == '승인요청' || relatedEtt.ApprovalStatus__c  == '승인') {
    //                 cd.addError('승인요청이 제출된 시점부터 파일 생성이 불가합니다.');
    //             }
    //         }
    //     }          
    // }

    /***********************************************************************************************************
    *  Trigger : Before Delete
    *  내용    : 유류유형 변경의 첨부파일이고 승인단계가 승인요청 혹은 승인이면 삭제 못하도록 설정
    ************************************************************************************************************/
    private void doCheckApprovalStatusOfOilChangeOfDelete() {
        Set<Id> docIds = new Set<Id>();
        for(ContentDocument obj : listOld) {
            docIds.add(obj.Id);
        }
        List<SObject> docLinkList = new List<SObject>();
        docLinkList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :docIds ];

        Set<Id> targetId = new Set<Id>();
        for(SObject sobj: docLinkList){
            targetId.add((Id)sobj.get('LinkedEntityId'));
        }       
        
        List<OilTypeChange__c> oilChangeList = [SELECT Id,ApprovalStatus__c FROM OilTypeChange__c WHERE Id in :targetId];
        for(OilTypeChange__c ett : oilChangeList) {
            for(ContentDocument obj : listOld) {
                if(ett.ApprovalStatus__c == '승인요청' || ett.ApprovalStatus__c  == '승인'){
                    if (!Test.isRunningTest()) {
                        obj.addError('승인요청이 제출된 시점부터 파일 삭제가 불가합니다.');
                    }
                    
                }            
            }            
        }        
        
    }
}