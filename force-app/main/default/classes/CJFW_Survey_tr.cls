/**
 * @description       :
 * @author            : sunkyung.choi@dkbmc.com
 * @group             :
 * @last modified on  : 10-23-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_Survey_tr extends TriggerHandler {
    public CJFW_Survey_tr() {
        system.debug('Suvey Trigger Handler START');
        listNew = (List<CJFW_Survey__c>)Trigger.new;
        listOld = (List<CJFW_Survey__c>)Trigger.old;
        mapNew = (Map<Id, CJFW_Survey__c>)Trigger.newMap;
        mapOld = (Map<Id, CJFW_Survey__c>)Trigger.oldMap;
    }

    /*** TriggerHandler ***/
    private List<CJFW_Survey__c> listNew {get;set;}
    private List<CJFW_Survey__c> listOld {get;set;}
    private Map<Id, CJFW_Survey__c> mapNew {get;set;}
    private Map<Id, CJFW_Survey__c> mapOld {get;set;}

    public override void beforeInsert() {
        doClone();
    }
    public override void afterInsert() {
        doCloneInsert();
    }
    private void doClone() {
        system.debug('doClone  START');
        List<CJFW_Survey__c> newSurveys = listNew;
        System.debug('1111111: >>' + newSurveys);
        for (CJFW_Survey__c newSurvey : newSurveys) {
            newSurvey.Version__c = newSurvey.Version__c + 1;
            newSurvey.ParentSurvey__c = newSurvey.getCloneSourceId();

        }

    }
    private void doCloneInsert() {
        system.debug('doCloneInsert  START');
        List<CJFW_Survey__c> newSurveys = listNew;
        system.debug('22222 : >> ' + newSurveys);

        List < CJFW_SurveyQuestion__c > surveyQuestion = new List < CJFW_SurveyQuestion__c > ();
        List < CJFW_SurveyOption__c > surveyOption = new List < CJFW_SurveyOption__c > ();
        List < CJFW_SurveyFollowUp__c > surveyFollow = new List < CJFW_SurveyFollowUp__c > ();

   

        Set<Id> originId = new Set<Id>();
        Map<Id, Id> surveyIdMap = new Map<Id, Id>();
        for (CJFW_Survey__c newSurvey : newSurveys) {
            originId.add(newSurvey.getCloneSourceId());
            surveyIdMap.put(newSurvey.getCloneSourceId(), newSurvey.Id);
        }
        List<CJFW_SurveyQuestion__c> originQuestionList = [
            SELECT Id,
            Name,
            Name__c,
            Survey__c,
            Type__c,
            MultipleChoice__c,
            Order__c,
            DateType__c,
            TextType__c FROM CJFW_SurveyQuestion__c WHERE Survey__c IN: originId
        ]; // 원본 Question 저장

        for (CJFW_SurveyQuestion__c originalQuestionChild : originQuestionList) {
            CJFW_SurveyQuestion__c newBchild = originalQuestionChild.clone(); // Bchild 레코드 복제
            newBchild.Survey__c = surveyIdMap.get(originalQuestionChild.Survey__c);
            surveyQuestion.add(newBchild);

            System.debug('surveyQuestion :: ' + surveyQuestion);

        }
        insert surveyQuestion;
    }

}