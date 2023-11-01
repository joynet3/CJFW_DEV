/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-30-2023
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
        List<CJFW_SurveyQuestion__c> newSurQues = listNew;
        System.debug('newSurQues?????????'+newSurQues);
        
        // Set<Id> surveyQueId = new Set<Id>();
        // Map<Id, CJFW_SurveyQuestion__c> surveyQueMap = new Map<Id, CJFW_SurveyQuestion__c>();
        for (CJFW_SurveyQuestion__c newSurQue : newSurQues) {
            // surveyQueId.add(newSurQue.Id); 
            // System.debug('surveyQueId >>>>> '+ surveyQueId);
            if (newSurQue.ActiveCheck__c) {
                newSurQue.addError('설문지가 활성화 되어 질문을 추가할 수 없습니다.');
            }

        }

    }
    private void doUpdateCheck() {
        System.debug('doUpdateCheck start');
        List<CJFW_SurveyQuestion__c> newSurQues = listNew;
        List<CJFW_SurveyQuestion__c> oldSurQues = listOld;
        System.debug('oldSurQues?????????'+oldSurQues);
        Set<Id> surveyQueId = new Set<Id>();
        Map<Id, CJFW_SurveyQuestion__c> surveyQueMap = new Map<Id, CJFW_SurveyQuestion__c>();
        
        for (CJFW_SurveyQuestion__c oldSurQue : oldSurQues) {
            surveyQueId.add(oldSurQue.Id);
            System.debug('surveyQueId?????????'+surveyQueId);
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
        ActiveCheck__c  FROM CJFW_SurveyQuestion__c WHERE Id IN: surveyQueId];
        System.debug('activeCheckList?????????'+activeCheckList);

        for (CJFW_SurveyQuestion__c activeCheck : activeCheckList) {
            surveyQueMap.put(activeCheck.Id,activeCheck);
            System.debug('surveyQueMap?????????'+surveyQueMap);

        }
        
        for (CJFW_SurveyQuestion__c newSurQue : newSurQues) {
            System.debug('????? start');
            if (surveyQueMap.get(newSurQue.Id).ActiveCheck__c) {
                System.debug('!!!!! end');
                newSurQue.addError('설문지가 활성화 되어 질문을 수정할 수 없습니다.');
            }
        }
    }

    private void doDeleteCheck(){
        System.debug('doDeleteCheck start');
        List<CJFW_SurveyQuestion__c> oldSurQues = listOld;
        System.debug('oldSurQues start ??????' + oldSurQues);
        Set<Id> queId = new Set<Id>();
        Map<Id, CJFW_SurveyQuestion__c> surveyQueMap = new Map<Id, CJFW_SurveyQuestion__c>();

        for (CJFW_SurveyQuestion__c oldSurQue : oldSurQues) {
            queId.add(oldSurQue.Id);
        }

        List<CJFW_SurveyQuestion__c> oldQueChecks = [SELECT Id,  
        Name,  
        Name__c, 
        Survey__c, 
        Type__c, 
        MultipleChoice__c, 
        Order__c, 
        DateType__c, 
        TextType__c, 
        ActiveCheck__c  FROM CJFW_SurveyQuestion__c WHERE Id IN: queId];

        for (CJFW_SurveyQuestion__c oldQueCheck : oldQueChecks) {
            surveyQueMap.put(oldQueCheck.Id,oldQueCheck);
        }
        
        for (CJFW_SurveyQuestion__c oldSurQue : oldSurQues) {
            if (surveyQueMap.get(oldSurQue.Id).ActiveCheck__c) {
                oldSurQue.addError('설문지가 활성화 되어 질문을 삭제할 수 없습니다.');
            }
        }

    }
}