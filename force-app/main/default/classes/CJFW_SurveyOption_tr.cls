/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-16-2023
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
        List<CJFW_SurveyOption__c> newSurOptsList = listNew;
        System.debug('newSurOptsList?????????'+newSurOptsList);
        Set<Id> queIdSet = new Set<Id>();
        Map<Id, CJFW_SurveyQuestion__c> queMap = new Map<Id, CJFW_SurveyQuestion__c>();

       for (CJFW_SurveyOption__c newSurOpt : newSurOptsList) {
             queIdSet.add(newSurOpt.SurveyQuestion__c);
       }

       List<CJFW_SurveyQuestion__c> surQueLists =[SELECT Id,  Name,  Name__c, Survey__c, Type__c, MultipleChoice__c, Order__c, DateType__c, TextType__c, ActiveCheck__c,Survey__r.CheckActiveDate__c FROM CJFW_SurveyQuestion__c  WHERE Id IN: queIdSet];

       for (CJFW_SurveyQuestion__c surQueList : surQueLists) {
        queMap.put(surQueList.Id,surQueList);
       }

       for (CJFW_SurveyOption__c  newSurOpt : newSurOptsList) {
        CJFW_SurveyQuestion__c queList = queMap.get(newSurOpt.SurveyQuestion__c);
        if (queList.ActiveCheck__c   ) {
            newSurOpt.addError('설문지가 활성화 되어 질문을 추가할 수 없습니다.');
        }else if (queList.Survey__r.CheckActiveDate__c != null) {
            newSurOpt.addError('활성화 되었던 설문지입니다. 질문을 추가할 수 없습니다.');
        }
       }

    }
    private void doUpdateCheck() {
        System.debug('doUpdateCheck start');
        List<CJFW_SurveyOption__c> newSurOptsList = listNew;
        List<CJFW_SurveyOption__c> oldSurOptsList = listOld;
        System.debug('oldSurOptsList?????????'+oldSurOptsList);
        Set<Id> surveyOptIdSet = new Set<Id>();
        Map<Id, CJFW_SurveyOption__c> surveyOptMap = new Map<Id, CJFW_SurveyOption__c>();
        
        for (CJFW_SurveyOption__c oldSurOpt : oldSurOptsList) {
            surveyOptIdSet.add(oldSurOpt.Id);
            System.debug('surveyOptIdSet?????????'+surveyOptIdSet);
        }

        List<CJFW_SurveyOption__c> OpActiveChecksList = [ SELECT Id,  Name,  Order__c, SurveyQuestion__c, OpActiveCheck__c,SurveyQuestion__r.Survey__r.CheckActiveDate__c  FROM CJFW_SurveyOption__c WHERE Id IN: surveyOptIdSet];
        System.debug('activeCheckList?????????'+OpActiveChecksList);

        for (CJFW_SurveyOption__c OpActiveCheck : OpActiveChecksList) {
            surveyOptMap.put(OpActiveCheck.Id,OpActiveCheck);
            System.debug('surveyOptMap?????????'+surveyOptMap);

        }
        
        for (CJFW_SurveyOption__c newSurOpt : newSurOptsList) {
            System.debug('????? start');
            System.debug('!!!!! ' +surveyOptMap.get(newSurOpt.Id).SurveyQuestion__r.Survey__r.CheckActiveDate__c );
            if (surveyOptMap.get(newSurOpt.Id).OpActiveCheck__c ) {
                System.debug('!!!!! end');
                newSurOpt.addError('설문지가 활성화 되어 선택지를 수정할 수 없습니다.');
            }else if (surveyOptMap.get(newSurOpt.Id).SurveyQuestion__r.Survey__r.CheckActiveDate__c !=null) {
                newSurOpt.addError('활성화 되었던 설문지입니다. 선택지를 수정할 수 없습니다.');
            }
        }
    }

    private void doDeleteCheck(){
        System.debug('doDeleteCheck start');
        List<CJFW_SurveyOption__c> oldSurOptsList = listOld;
        System.debug('oldSurOptsList start ??????' + oldSurOptsList);
        Set<Id> optIdSet = new Set<Id>();
        Map<Id, CJFW_SurveyOption__c> surveyOptMap = new Map<Id, CJFW_SurveyOption__c>();

        for (CJFW_SurveyOption__c oldSurOpt : oldSurOptsList) {
            optIdSet.add(oldSurOpt.Id);
        }

        List<CJFW_SurveyOption__c> oldOptChecks = [SELECT Id,  Name,  Order__c, SurveyQuestion__c, OpActiveCheck__c,SurveyQuestion__r.Survey__r.CheckActiveDate__c  FROM CJFW_SurveyOption__c WHERE Id IN: optIdSet];

        for (CJFW_SurveyOption__c oldOptCheck : oldOptChecks) {
            surveyOptMap.put(oldOptCheck.Id,oldOptCheck);
        }
        
        for (CJFW_SurveyOption__c oldSurOpt : oldSurOptsList) {
            if (surveyOptMap.get(oldSurOpt.Id).OpActiveCheck__c ) {
                oldSurOpt.addError('설문지가 활성화 되어 선택지를 삭제할 수 없습니다.');
            }else if( surveyOptMap.get(oldSurOpt.Id).SurveyQuestion__r.Survey__r.CheckActiveDate__c !=null){
                oldSurOpt.addError('활성화 되었던 설문지입니다. 선택지를 삭제할 수 없습니다.');
            }
        }

    }



}