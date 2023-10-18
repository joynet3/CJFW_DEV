/**
 * @description       :
 * @author            : sunkyung.choi@dkbmc.com
 * @group             :
 * @last modified on  : 10-18-2023
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

    public override void afterInsert() {
        doCloneInsert();
    }

    private void doCloneInsert() {
        system.debug('doCloneInsert  START');
        List<CJFW_Survey__c> newSurveys = listNew;
        system.debug('11111 : >> ' + newSurveys);

        List < CJFW_SurveyQuestion__c > surveyQuestion = new List < CJFW_SurveyQuestion__c > ();
        // List < CJFW_SurveyOption__c > surveyOption = new List < CJFW_SurveyOption__c > ();
        Map<Id, String> optionMap = new Map<Id, String>();
        Set<Id> questionId = new Set<Id>();

        for (CJFW_Survey__c newSurvey : newSurveys) {
            System.debug('isClone:: ' + newSurvey.isClone());
            System.debug('getCloneSourceId:: ' + newSurvey.getCloneSourceId());

            string cloneId = newSurvey.getCloneSourceId(); // 원본 ID 저장

            List<CJFW_SurveyQuestion__c> originQuestionList = [
                SELECT Id,
                Name,
                Name__c,
                Survey__c,
                Type__c,
                MultipleChoice__c,
                Order__c,
                DateType__c,
                TextType__c FROM CJFW_SurveyQuestion__c WHERE Survey__c = : cloneId
            ]; // 원본 Question 저장
            System.debug('originQuestionList :: ' + originQuestionList);
            for (CJFW_SurveyQuestion__c originalQuestionChild : originQuestionList) {
                CJFW_SurveyQuestion__c newBchild = originalQuestionChild.clone(); // Bchild 레코드 복제
                newBchild.Survey__c = newSurvey.Id;
              
                surveyQuestion.add(newBchild);
                
                // questionId.add(originalQuestionChild.Id);
                // System.debug('questionId :: ' + questionId);
                List < CJFW_SurveyOption__c > originOptionList = [
                    SELECT Id, Name, Order__c, SurveyQuestion__c FROM CJFW_SurveyOption__c WHERE SurveyQuestion__c = : originalQuestionChild.Id 
                ]; // 원본 Option 저장
                

                System.debug('originOptionList :: ' + originOptionList);

                for (CJFW_SurveyOption__c originalOptionChild : originOptionList) {

                    CJFW_SurveyOption__c newCchild = originalOptionChild.clone();
                    newCchild.SurveyQuestion__c = originalQuestionChild.Id;
                    optionMap.put(originalQuestionChild.Id, originalOptionChild.Name);
                    System.debug('optionMap :: ' + optionMap);
                }
                
                
                
                // for (CJFW_SurveyOption__c originalOptionChild : originOptionList) {
                //     CJFW_SurveyOption__c newCchild = originalOptionChild.clone();
                //     newCchild.SurveyQuestion__c = originalQuestionChild.Id;
                //     newCchild.Order__c = originalQuestionChild.Order__c;
                //     newCchild.Name = originalQuestionChild.Name;
                //     surveyOption.add(newCchild);
                // }
            }
            System.debug('surveyQuestion :: ' + surveyQuestion);
            // System.debug('surveyOption :: ' + surveyOption);
        }
        insert surveyQuestion;
        // insert optionMap;
    }
}