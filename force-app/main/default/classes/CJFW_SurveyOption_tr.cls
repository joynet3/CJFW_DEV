/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyOption_tr extends TriggerHandler {
    public CJFW_SurveyOption_tr() {
        system.debug('SurveyOption Trigger Handler START');
        listNew = (List<CJFW_SurveyOption__c>) Trigger.new;
        listOld = (List<CJFW_SurveyOption__c>) Trigger.old;
        mapNew = (Map<Id, CJFW_SurveyOption__c>) Trigger.newMap;
        mapOld = (Map<Id, CJFW_SurveyOption__c>) Trigger.oldMap;
    }
    private List<CJFW_SurveyOption__c> listNew { get;set;}
    private List<CJFW_SurveyOption__c> listOld{ get;set;}
    private Map<Id, CJFW_SurveyOption__c> mapNew { get;set;}
    private Map<Id, CJFW_SurveyOption__c> mapOld { get;set;}

    public override void beforeInsert() {
        insertCheck();
     }
     public override void beforeUpdate() {
         doUpdateCheck(); // 수정 불가처리 
     }
     public override void beforeDelete() {
         doDeleteCheck(); // 삭제 불가 처리
     }

     private void insertCheck() {
        System.debug('insertCheck start');
        List<CJFW_SurveyOption__c> newSurOpts = listNew;
        System.debug('newSurOpts?????????'+newSurOpts);
        
        // Set<Id> surveyOptId = new Set<Id>();
        // Map<Id, CJFW_SurveyOptstion__c> surveyOptMap = new Map<Id, CJFW_SurveyOptstion__c>();
        for (CJFW_SurveyOption__c newSurOpt : newSurOpts) {
            // surveyOptId.add(newSurOpt.Id); 
            // System.debug('surveyOptId >>>>> '+ surveyOptId);
            if (newSurOpt.OpActiveCheck__c) {
                newSurOpt.addError('설문지가 활성화 되어 선택지를 추가할 수 없습니다.');
            }

        }

    }
    private void doUpdateCheck() {
        System.debug('doUpdateCheck start');
        List<CJFW_SurveyOption__c> newSurOpts = listNew;
        List<CJFW_SurveyOption__c> oldSurOpts = listOld;
        System.debug('oldSurOpts?????????'+oldSurOpts);
        Set<Id> surveyOptId = new Set<Id>();
        Map<Id, CJFW_SurveyOption__c> surveyOptMap = new Map<Id, CJFW_SurveyOption__c>();
        
        for (CJFW_SurveyOption__c oldSurOpt : oldSurOpts) {
            surveyOptId.add(oldSurOpt.Id);
            System.debug('surveyOptId?????????'+surveyOptId);
        }

        List<CJFW_SurveyOption__c> OpActiveChecks = [ SELECT Id,  Name,  Order__c, SurveyQuestion__c, OpActiveCheck__c  FROM CJFW_SurveyOption__c WHERE Id IN: surveyOptId];
        System.debug('activeCheckList?????????'+OpActiveChecks);

        for (CJFW_SurveyOption__c OpActiveCheck : OpActiveChecks) {
            surveyOptMap.put(OpActiveCheck.Id,OpActiveCheck);
            System.debug('surveyOptMap?????????'+surveyOptMap);

        }
        
        for (CJFW_SurveyOption__c newSurOpt : newSurOpts) {
            System.debug('????? start');
            if (surveyOptMap.get(newSurOpt.Id).OpActiveCheck__c) {
                System.debug('!!!!! end');
                newSurOpt.addError('설문지가 활성화 되어 선택지를 수정할 수 없습니다.');
            }
        }
    }

    private void doDeleteCheck(){
        System.debug('doDeleteCheck start');
        List<CJFW_SurveyOption__c> oldSurOpts = listOld;
        System.debug('oldSurOpts start ??????' + oldSurOpts);
        Set<Id> optId = new Set<Id>();
        Map<Id, CJFW_SurveyOption__c> surveyOptMap = new Map<Id, CJFW_SurveyOption__c>();

        for (CJFW_SurveyOption__c oldSurOpt : oldSurOpts) {
            optId.add(oldSurOpt.Id);
        }

        List<CJFW_SurveyOption__c> oldOptChecks = [SELECT Id,  Name,  Order__c, SurveyQuestion__c, OpActiveCheck__c  FROM CJFW_SurveyOption__c WHERE Id IN: optId];

        for (CJFW_SurveyOption__c oldOptCheck : oldOptChecks) {
            surveyOptMap.put(oldOptCheck.Id,oldOptCheck);
        }
        
        for (CJFW_SurveyOption__c oldSurOpt : oldSurOpts) {
            if (surveyOptMap.get(oldSurOpt.Id).OpActiveCheck__c) {
                oldSurOpt.addError('설문지가 활성화 되어 선택지를 삭제할 수 없습니다.');
            }
        }

    }



}