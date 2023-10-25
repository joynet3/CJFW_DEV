/**
 * @description       :
 * @author            : sunkyung.choi@dkbmc.com
 * @group             :
 * @last modified on  : 10-25-2023
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
        System.debug('doClone START');
        List<CJFW_Survey__c> newSurveys = listNew;  
    
        for (CJFW_Survey__c newSurvey : newSurveys) {
            // 기존 레코드의 Active__c 값을 false로 설정
            CJFW_Survey__c sourceSurvey = [SELECT Id, Active__c FROM CJFW_Survey__c WHERE Id = :newSurvey.getCloneSourceId()];
            if (sourceSurvey != null) {
                sourceSurvey.Active__c = false;
                update sourceSurvey; // 기존 레코드 업데이트
            }
    
            // 복제된 레코드의 Active__c 값을 true로 설정
            newSurvey.Active__c = true;
    
            // 나머지 로직을 처리 (Version__c 업데이트 등)
            Id check = newSurvey.getCloneSourceId();
            System.debug('확인중 >>>>' + check);
            if (newSurvey.isClone()) {
                if (newSurvey.ParentSurvey__c == null) {
                    newSurvey.ParentSurvey__c = newSurvey.getCloneSourceId();    
                }
                newSurvey.Version__c = newSurvey.Version__c + 1;
            } else {
                newSurvey.Version__c = 1;
            }
        }
    
        // 복제된 레코드 업데이트
        update newSurveys;
    }
    

    

    private void doCloneInsert() {
        system.debug('doCloneInsert  START');
        List<CJFW_Survey__c> newSurveys = listNew;
        system.debug('22222 : >> ' + newSurveys);

        List < CJFW_SurveyQuestion__c > surveyQuestion = new List < CJFW_SurveyQuestion__c > ();
        List < CJFW_SurveyOption__c > surveyOption = new List < CJFW_SurveyOption__c > ();
        List < CJFW_SurveyFollowUp__c > surveyFollow = new List < CJFW_SurveyFollowUp__c > ();

        Set<Id> originId = new Set<Id>(); // 원본 ID
        Map<Id, Id> surveyIdMap = new Map<Id, Id>(); //새로 생성된 데이터 ID

        Set<Id> questionId = new Set<Id>(); // 원본 questioID
        Map<Id, Id> queCloneMap = new Map<Id, Id>(); // 복제 questioID
        
        Set<Id> optionId = new Set<Id>(); // 원본 optionID
        Map<Id, Id> optCloneMap = new Map<Id, Id>(); // 복제 optionID

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
            questionId.add(originalQuestionChild.Id);
            CJFW_SurveyQuestion__c newBchild = originalQuestionChild.clone(); // Bchild 레코드 복제
            newBchild.Survey__c = surveyIdMap.get(originalQuestionChild.Survey__c);
            surveyQuestion.add(newBchild);
            System.debug('surveyQuestion :: ' + surveyQuestion);

        }
        insert surveyQuestion;

        for (CJFW_SurveyQuestion__c surq : surveyQuestion) {
            queCloneMap.put(surq.getCloneSourceId(), surq.Id);
        }
        List < CJFW_SurveyOption__c > originOptionList = [
            SELECT Id,
            Name,
            CurrencyIsoCode,
            CreatedDate,
            CreatedById,
            Order__c,
            SurveyQuestion__c FROM CJFW_SurveyOption__c WHERE SurveyQuestion__c IN: questionId
        ]; // 원본 Option 저장

        System.debug('originOptionList>>>>' + originOptionList);

        for (CJFW_SurveyOption__c originOption : originOptionList) {
            optionId.add(originOption.Id);
            CJFW_SurveyOption__c newCchild = originOption.clone();
            newCchild.SurveyQuestion__c = queCloneMap.get(originOption.SurveyQuestion__c);
             
            System.debug('확인 Option 11>>>>' + newCchild.SurveyQuestion__c);
            surveyOption.add(newCchild);
            System.debug('확인 Option 22>>>>' + surveyOption);
        }
        insert surveyOption;
        
        for (CJFW_SurveyOption__c suro : surveyOption) {
            optCloneMap.put(suro.getCloneSourceId(), suro.Id);
        }
        List<CJFW_SurveyFollowUp__c> originFollowList = [
            SELECT Id,
            Name,
            SurveyQuestion__c,
            SurveyOption__c
            FROM CJFW_SurveyFollowUp__c WHERE SurveyQuestion__c IN: questionId AND SurveyOption__c IN: optionId
        ];

        for (CJFW_SurveyFollowUp__c originFollow : originFollowList) {
            CJFW_SurveyFollowUp__c newDchild = originFollow.clone();
            newDchild.SurveyQuestion__c = queCloneMap.get(originFollow.SurveyQuestion__c);
            newDchild.SurveyOption__c = optCloneMap.get(originFollow.SurveyOption__c);
            System.debug('확인 Follow 11>>>>' + newDchild.SurveyQuestion__c);
            System.debug('확인 Follow 12>>>>' + newDchild.SurveyOption__c);
            surveyFollow.add(newDchild);
            System.debug('확인 Follow 22>>>>' + surveyFollow);
        }
        insert surveyFollow;
    }


}