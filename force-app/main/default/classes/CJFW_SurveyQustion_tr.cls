/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyQustion_tr extends TriggerHandler {
    public CJFW_SurveyQustion_tr() {
        system.debug('SurveyQustion Trigger Handler START');
        listNew = (List<CJFW_SurveyQuestion__c>) Trigger.new;
        listOld = (List<CJFW_SurveyQuestion__c>) Trigger.old;
        mapNew = (Map<Id, CJFW_SurveyQuestion__c>) Trigger.newMap;
        mapOld = (Map<Id, CJFW_SurveyQuestion__c>) Trigger.oldMap;
        // recordIdEx =  ApexPages.CurrentPage().getparameters().get('id');
    }
    private List<CJFW_SurveyQuestion__c> listNew { get;set;}
    private List<CJFW_SurveyQuestion__c> listOld{ get;set;}
    // private Id recordIdEx { get; set; }
    private Map<Id, CJFW_SurveyQuestion__c> mapNew { get;set;}
    private Map<Id, CJFW_SurveyQuestion__c> mapOld { get;set;}

    
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
        List<CJFW_SurveyQuestion__c> newSurQuesList = listNew;
        System.debug('newSurQuesList?????????'+newSurQuesList);
        
        Set<Id> surveyQueIdSet = new Set<Id>();
        Map<Id, CJFW_Survey__c> surveyMap = new Map<Id, CJFW_Survey__c>();
        for (CJFW_SurveyQuestion__c newSurQue : newSurQuesList) {
            surveyQueIdSet.add(newSurQue.Survey__c); 
            
        }
        List<CJFW_Survey__c> newQueLists = [SELECT Id, OwnerId,  Name,  Description__c, Su__c, Active__c, ParentSurvey__c, Version__c, HeadOffice__c, CheckActive__c FROM CJFW_Survey__c WHERE Id IN: surveyQueIdSet];

        for (CJFW_Survey__c newQueList : newQueLists) {
            surveyMap.put(newQueList.Id,newQueList);
        }

        for (CJFW_SurveyQuestion__c newSurQue : newSurQuesList) {
            CJFW_Survey__c surList = surveyMap.get(newSurQue.Survey__c);
            if  (surList.Active__c  ) {
                newSurQue.addError('설문지가 활성화 되어 질문을 추가할 수 없습니다.');
            }else if (surList.CheckActive__c != null) {
                newSurQue.addError(' 활성화 되었던 설문지입니다. 질문을 추가할 수 없습니다.');
            }
        }

    }
    private void doUpdateCheck() {
        System.debug('doUpdateCheck start');
        List<CJFW_SurveyQuestion__c> newSurQuesList = listNew;
        List<CJFW_SurveyQuestion__c> oldSurQuesList = listOld;
        System.debug('oldSurQuesList?????????'+oldSurQuesList);
        Set<Id> surveyQueIdSet = new Set<Id>();
        Map<Id, CJFW_SurveyQuestion__c> surveyQueMap = new Map<Id, CJFW_SurveyQuestion__c>();
        
        for (CJFW_SurveyQuestion__c oldSurQue : oldSurQuesList) {
            surveyQueIdSet.add(oldSurQue.Id);
            System.debug('surveyQueIdSet?????????'+surveyQueIdSet);
        }

        List<CJFW_SurveyQuestion__c> activeCheckList = [ SELECT Id,  
        Name,  
        Name__c, 
        Survey__c, 
        Type__c, 
        MultipleChoice__c, 
        Order__c, 
        DateType__c, 
        TextType__c, 
        Survey__r.CheckActive__c,
        ActiveCheck__c  FROM CJFW_SurveyQuestion__c WHERE Id IN: surveyQueIdSet];
        System.debug('activeCheckList?????????'+activeCheckList);

        for (CJFW_SurveyQuestion__c activeCheck : activeCheckList) {
            surveyQueMap.put(activeCheck.Id,activeCheck);
            System.debug('surveyQueMap?????????'+surveyQueMap);

        }
        
        for (CJFW_SurveyQuestion__c newSurQue : newSurQuesList) {
            System.debug('????? start');
            System.debug('222222?????????????'+ surveyQueMap.get(newSurQue.Id).Survey__r.CheckActive__c);
            if (surveyQueMap.get(newSurQue.Id).ActiveCheck__c ) {
                System.debug('!!!!! end');
                newSurQue.addError('설문지가 활성화 되어 질문을 수정할 수 없습니다.');
            }else if ( surveyQueMap.get(newSurQue.Id).Survey__r.CheckActive__c != null) {
                newSurQue.addError('활성화 되었던 설문지입니다. 질문을 수정할 수 없습니다.');
            }
        }
    }

    private void doDeleteCheck(){
        System.debug('doDeleteCheck start');
        List<CJFW_SurveyQuestion__c> oldSurQuesList = listOld;
        System.debug('oldSurQuesList start ??????' + oldSurQuesList);
        Set<Id> queIdSet = new Set<Id>();
        Map<Id, CJFW_SurveyQuestion__c> surveyQueMap = new Map<Id, CJFW_SurveyQuestion__c>();

        for (CJFW_SurveyQuestion__c oldSurQue : oldSurQuesList) {
            queIdSet.add(oldSurQue.Id);
        }

        List<CJFW_SurveyQuestion__c> oldQueChecksList = [SELECT Id,  
        Name,  
        Name__c, 
        Survey__c, 
        Type__c, 
        MultipleChoice__c, 
        Order__c, 
        DateType__c, 
        TextType__c, 
        Survey__r.CheckActive__c,
        ActiveCheck__c  FROM CJFW_SurveyQuestion__c WHERE Id IN: queIdSet];

        for (CJFW_SurveyQuestion__c oldQueCheck : oldQueChecksList) {
            surveyQueMap.put(oldQueCheck.Id,oldQueCheck);
        }
        
        for (CJFW_SurveyQuestion__c oldSurQue : oldSurQuesList) {
            if (surveyQueMap.get(oldSurQue.Id).ActiveCheck__c ) {
                oldSurQue.addError('설문지가 활성화 되어 질문을 삭제할 수 없습니다.');
            }else if ( surveyQueMap.get(oldSurQue.Id).Survey__r.CheckActive__c != null) {
                oldSurQue.addError('활성화 되었던 설문지입니다. 질문을 삭제할 수 없습니다.');
            }
        }

    }
}