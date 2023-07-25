/*************************************************************************************
 * File Name   		: DecisionProcess_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.05.26
 * Tester	  		: DecisionProcess_tr_test.cls
 * Description 		: DecisionProcess_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.05.26      Minje.Kim       Create
*************************************************************************************/

public without sharing class DecisionProcess_tr extends TriggerHandler {
    public DecisionProcess_tr() {
        listNew = (List<DecisionProcess__c>) trigger.new;
        mapOld = (Map<Id, DecisionProcess__c>) trigger.oldMap;
        listOld = (List<DecisionProcess__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<DecisionProcess__c> listNew { get; set; }
    private List<DecisionProcess__c> listOld { get; set; }
    private Map<Id, DecisionProcess__c> mapOld { get; set; }

    public override void afterDelete() {
        delExtDoc();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void delExtDoc() {
        Set<String> setDocId = new Set<String>();
        for (DecisionProcess__c obj : listOld) {
            if ( obj.DocStatus__c <> '임시저장'){
                obj.addError('임시저장 상태의 품의이력만 삭제가능합니다.');
            } else if (obj.DocId__c != null && obj.DocId__c != ''){
                DecisionProcess_tr.doDelete(obj.DocId__c);
                // 동기 setTimeout 0.5초
                Long startTimerTime = DateTime.now().getTime();
                Long finishTimerTime = DateTime.now().getTime();
                while ((finishTimerTime - startTimerTime ) < 500) {
                    finishTimerTime = DateTime.now().getTime();
                } 
            }
        }
    }
    
    
    @Future(Callout=true)
    public static void doDelete(String docId) {

        try {
            User objUser = [
                SELECT  Id, EmployeeNumber
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
            ];

            // I/F 파라미터 셋팅
            Map<String, Object> mapInput = new Map<String, Object>();
                            
            mapInput.put('doc_Id', docId);
            mapInput.put('sabun', objUser.EmployeeNumber);

            IFUtil ifutilWrapper = new IFUtil('IF_SFDC_IFRESH_DEL_APPROVAL');

            // I/F 진행
            System.debug(' check Input ::: ' + mapInput);
            String strJsonRequestBody = JSON.serialize(mapInput);
            HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);
            system.debug( 'check Output ::: ' + response.getBody() );

            // I/F 성공시
            if(response.getStatusCode() == 200){
                Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
                System.debug('성공');
            } else {
                system.debug( '[I/F Error] ::: [' + response.getStatusCode() + '] 서버접속 실패');
            }

        } catch(Exception e) {
            System.debug('error getMessage : ' + e.getMessage());
            System.debug('error getLineNumber : ' + e.getLineNumber());
            System.debug('error getCause : ' + e.getCause());
        }
    }
}