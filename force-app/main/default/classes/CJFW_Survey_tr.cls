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
    private List<CJFW_Survey__c> listNew {
        get;
        set;
    }
    private List<CJFW_Survey__c> listOld {
        get;
        set;
    }
    private Map<Id, CJFW_Survey__c> mapNew {
        get;
        set;
    }
    private Map<Id, CJFW_Survey__c> mapOld {
        get;
        set;
    }

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

        Map<Id, String> optionMap = new Map<Id, String>();

        for (CJFW_Survey__c newSurvey : newSurveys) {
            System.debug('isClone:: ' + newSurvey.isClone());
            System.debug('getCloneSourceId:: ' + newSurvey.getCloneSourceId());

            string originId = newSurvey.getCloneSourceId(); // 원본 ID 저장
            string cloneId = newSurvey.Id; // 복제된 ID 저장

            List<CJFW_SurveyQuestion__c> originQuestionList = [
                SELECT Id,
                Name,
                Name__c,
                Survey__c,
                Type__c,
                MultipleChoice__c,
                Order__c,
                DateType__c,
                TextType__c FROM CJFW_SurveyQuestion__c WHERE Survey__c = : originId
            ]; // 원본 Question 저장

            System.debug('originQuestionList :: ' + originQuestionList);

            for (CJFW_SurveyQuestion__c originalQuestionChild : originQuestionList) {
                CJFW_SurveyQuestion__c newBchild = originalQuestionChild.clone(); // Bchild 레코드 복제
                newBchild.Survey__c = newSurvey.Id;
                surveyQuestion.add(newBchild);

                System.debug('surveyQuestion :: ' + surveyQuestion);

            }
            // System.debug('surveyOption :: ' + surveyOption);
            insert surveyQuestion;

            System.debug('surveyQuestion :: ' + surveyQuestion);
            for (Integer i = 0; i < surveyQuestion.size(); i++) {
                List < CJFW_SurveyOption__c > originOptionList = [
                    SELECT Id,
                    Name,
                    CurrencyIsoCode,
                    CreatedDate,
                    CreatedById,
                    Order__c,
                    SurveyQuestion__c FROM CJFW_SurveyOption__c WHERE SurveyQuestion__c = : originQuestionList[i].Id
                ]; // 원본 Option 저장

                System.debug('originOptionList 확인 >>>>' + originOptionList);
                for (CJFW_SurveyOption__c originOption : originOptionList) {
                    CJFW_SurveyOption__c newCchild = originOption.clone();
                    newCchild.SurveyQuestion__c = surveyQuestion[i].Id;
                    System.debug('확인 Option 11>>>>' + newCchild.SurveyQuestion__c);
                    surveyOption.add(newCchild);
                }
            }
            insert surveyOption;
            System.debug('확인 Option 22>>>>' + surveyOption);

            for (Integer i = 0; i < surveyQuestion.size(); i++) {
                for (Integer j = 0; j < surveyOption.size(); j++) {

                    List < CJFW_SurveyFollowUp__c > originFollowList = [
                        SELECT Id, Name, SurveyQuestion__c, SurveyOption__c FROM CJFW_SurveyFollowUp__c WHERE SurveyQuestion__c = : surveyQuestion[i].Id and SurveyOption__c =: surveyOption[j].Id
                    ];

                    System.debug('originFollowList 확인 >>>>' + originFollowList);

                    for (CJFW_SurveyFollowUp__c originFollow : originFollowList) {
                        CJFW_SurveyFollowUp__c newDchild = originFollow.clone();
                        newDchild.SurveyQuestion__c = surveyQuestion[i].Id;
                        newDchild.SurveyOption__c = surveyOption[j].Id;
                        System.debug('확인 Follow 11>>>>' + newDchild.SurveyQuestion__c);
                        System.debug('확인 Follow 12>>>>' + newDchild.SurveyOption__c);
                        surveyFollow.add(newDchild);
                        System.debug('확인 Follow 22>>>>' + surveyFollow);
                    }
                }
            }
            insert surveyFollow;

        }
    }

}