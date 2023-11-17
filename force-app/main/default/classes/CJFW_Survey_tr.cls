/**
 * @description       :
 * @author            : sunkyung.choi@dkbmc.com
 * @group             :
 * @last modified on  : 11-16-2023
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
    @testVisible private List<CJFW_Survey__c> listNew { get;set;}
    @testVisible private List<CJFW_Survey__c> listOld{ get;set;}
    @testVisible private Map<Id, CJFW_Survey__c> mapNew { get;set;}
    @testVisible private Map<Id, CJFW_Survey__c> mapOld { get;set;}

    public override void beforeInsert() {
        doClone();
    }
    public override void afterInsert() {
        doCloneInsert();
    }
    public override void beforeUpdate() {
        checkSuFieldChanges();
    }
    public override void beforeDelete() {
        doDeleteCheck();
    }



    @testVisible private void doClone() {
        system.debug('doClone  START');
        List<CJFW_Survey__c> newSurveyLists = listNew;
        Set<Id> surveyIdSet = new Set<Id>();
        Map<Id, CJFW_Survey__c> surveyMap = new Map<Id, CJFW_Survey__c>();
        Map<String, CJFW_Survey__c> suCheckMap = new Map<String, CJFW_Survey__c>();

        System.debug('1111111: >>' + newSurveyLists);
        for (CJFW_Survey__c newSurvey : newSurveyLists) {
            if (newSurvey.isclone()) {
                newSurvey.Active__c = false;
            }
            
            if (newSurvey.isclone()) {
                surveyIdSet.add(newSurvey.getCloneSourceId());
            }
        }

        List<CJFW_Survey__c> sourceSurveys = [SELECT Id, Active__c, Su__c, Version__c, ParentSurvey__c,CheckActiveDate__c FROM CJFW_Survey__c WHERE Id IN: surveyIdSet]; //원본

        List<CJFW_Survey__c> suChecksList = [SELECT Id,  Name,  Su__c, Active__c, ParentSurvey__c, Version__c, HeadOffice__c,CheckActiveDate__c FROM CJFW_Survey__c WHERE Su__c !=null and Active__c =true]; //su__c 필드값 있는 데이터 쿼리 

        System.debug('sourceSurveys ???>>>>' + sourceSurveys);
        for (CJFW_Survey__c sourceSurvey : sourceSurveys) {
                surveyMap.put(sourceSurvey.Id, sourceSurvey);
        }
        System.debug('맵확인 >>>> ' + surveyMap);
        for (CJFW_Survey__c suCheck : suChecksList) {
            suCheckMap.put(suCheck.su__c,suCheck);
            System.debug('suCheckMap>>>>>>>> '+ suCheckMap);
        }
        // 새로운 레코드를 반복하며 필드 업데이트
        for (CJFW_Survey__c newSurvey : newSurveyLists) {
            if (newSurvey.getCloneSourceId() != null) {
                // newSurvey.Active__c = true;
                CJFW_Survey__c sourceSurvey = surveyMap.get(newSurvey.getCloneSourceId());
                if (sourceSurvey != null) {
                    if ( sourceSurvey.Version__c >= 2 ) {
                        newSurvey.ParentSurvey__c = sourceSurvey.ParentSurvey__c;
                    }else {
                        newSurvey.ParentSurvey__c = sourceSurvey.Id;
                    }
                    // Su__c 필드가 surveyMap에 담긴 Su__c와 동일한 경우 validation 띄우기
                    // newSurvey.Version__c = sourceSurvey.Version__c + 1;


                if (sourceSurvey.ParentSurvey__c != null ) {
                    List<CJFW_Survey__c> cloneList = [SELECT Id,  Name,  Su__c, Active__c, ParentSurvey__c, Version__c, HeadOffice__c,CheckActiveDate__c FROM CJFW_Survey__c WHERE ParentSurvey__c =: sourceSurvey.ParentSurvey__c ORDER BY Version__c DESC];
                    System.debug('allList: >>' + cloneList);
                    if (cloneList.size() > 0) {
                        newSurvey.Version__c = cloneList[0].Version__c +1;
                    }else{
                        newSurvey.Version__c  =sourceSurvey.Version__c + 1;
                    }
                }else{
                    List<CJFW_Survey__c> allList = [SELECT Id,  Name,  Su__c, Active__c, ParentSurvey__c, Version__c, HeadOffice__c,CheckActiveDate__c FROM CJFW_Survey__c WHERE ParentSurvey__c =: sourceSurvey.Id ORDER BY Version__c DESC];

                    System.debug('allList: >>' + allList);
                    if (allList.size() > 0) {
                        newSurvey.Version__c = allList[0].Version__c +1;
                    }else{
                        newSurvey.Version__c  =sourceSurvey.Version__c + 1;
                    }
                }
                   
                }
            } else {
                // if (suCheckMap.containsKey(newSurvey.su__c) && suCheckMap.get(newSurvey.Su__c).Active__c ) {
                if (suCheckMap.containsKey(newSurvey.su__c)  ) {
                    newSurvey.addError('해당 사업부 형식지가 작성되어있습니다. ');
                    // if (newSurvey.Active__c) {
                    // }
                }
                System.debug('newSurvey22222: >>' + newSurveyLists);
                newSurvey.Version__c = 1;
              
            }
        }
    }

    @testVisible private void doCloneInsert() {
        system.debug('doCloneInsert  START');
        List<CJFW_Survey__c> newSurveyLists = listNew;
        system.debug('22222 : >> ' + newSurveyLists);

        List < CJFW_SurveyQuestion__c > surveyQuestionList = new List < CJFW_SurveyQuestion__c > ();
        List < CJFW_SurveyOption__c > surveyOptionList = new List < CJFW_SurveyOption__c > ();
        List < CJFW_SurveyFollowUp__c > surveyFollowList = new List < CJFW_SurveyFollowUp__c > ();

        Set<Id> originIdSet = new Set<Id>(); // 원본 ID
        Map<Id, Id> surveyIdMap = new Map<Id, Id>(); //새로 생성된 데이터 ID

        Set<Id> questionIdSet = new Set<Id>(); // 원본 questioID
        Map<Id, Id> queCloneMap = new Map<Id, Id>(); // 복제 questioID

        Set<Id> optionId = new Set<Id>(); // 원본 optionID
        Map<Id, Id> optCloneMap = new Map<Id, Id>(); // 복제 optionID

        for (CJFW_Survey__c newSurvey : newSurveyLists) {
            if (newSurvey.isclone()) {
                originIdSet.add(newSurvey.getCloneSourceId());
                surveyIdMap.put(newSurvey.getCloneSourceId(), newSurvey.Id);
            }
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
            TextType__c FROM CJFW_SurveyQuestion__c WHERE Survey__c IN: originIdSet
        ]; // 원본 Question 저장

        for (CJFW_SurveyQuestion__c originalQuestionChild : originQuestionList) {
            questionIdSet.add(originalQuestionChild.Id);
            CJFW_SurveyQuestion__c newBchild = originalQuestionChild.clone(); // Bchild 레코드 복제
            newBchild.Survey__c = surveyIdMap.get(originalQuestionChild.Survey__c);
            surveyQuestionList.add(newBchild);
            System.debug('surveyQuestionList :: ' + surveyQuestionList);

        }
        insert surveyQuestionList;

        for (CJFW_SurveyQuestion__c surq : surveyQuestionList) {
            queCloneMap.put(surq.getCloneSourceId(), surq.Id);
        }
        List < CJFW_SurveyOption__c > originOptionList = [
            SELECT Id,
            Name,
            CurrencyIsoCode,
            CreatedDate,
            CreatedById,
            Order__c,
            SurveyQuestion__c FROM CJFW_SurveyOption__c WHERE SurveyQuestion__c IN: questionIdSet
        ]; // 원본 Option 저장

        System.debug('originOptionList>>>>' + originOptionList);

        for (CJFW_SurveyOption__c originOption : originOptionList) {
            optionId.add(originOption.Id);
            CJFW_SurveyOption__c newCchild = originOption.clone();
            newCchild.SurveyQuestion__c = queCloneMap.get(originOption.SurveyQuestion__c);

            System.debug('확인 Option 11>>>>' + newCchild.SurveyQuestion__c);
            surveyOptionList.add(newCchild);
            System.debug('확인 Option 22>>>>' + surveyOptionList);
        }
        insert surveyOptionList;

        for (CJFW_SurveyOption__c suro : surveyOptionList) {
            optCloneMap.put(suro.getCloneSourceId(), suro.Id);
        }
        List<CJFW_SurveyFollowUp__c> originFollowList = [SELECT Id, Name, SurveyQuestion__c, SurveyOption__c FROM CJFW_SurveyFollowUp__c WHERE SurveyQuestion__c IN: questionIdSet AND SurveyOption__c IN: optionId];

        for (CJFW_SurveyFollowUp__c originFollow : originFollowList) {
            CJFW_SurveyFollowUp__c newDchild = originFollow.clone();
            newDchild.SurveyQuestion__c = queCloneMap.get(originFollow.SurveyQuestion__c);
            newDchild.SurveyOption__c = optCloneMap.get(originFollow.SurveyOption__c);
            System.debug('확인 Follow 11>>>>' + newDchild.SurveyQuestion__c);
            System.debug('확인 Follow 12>>>>' + newDchild.SurveyOption__c);
            surveyFollowList.add(newDchild);
            System.debug('확인 Follow 22>>>>' + surveyFollowList);
        }
        insert surveyFollowList;
    }
    @testVisible private void checkSuFieldChanges() {
        List<CJFW_Survey__c> newSurveyLists = listNew;
        List<CJFW_Survey__c> oldSurveysList = listOld;
        Map<String, CJFW_Survey__c> suCheckMap = new Map<String, CJFW_Survey__c>();
    
        List<CJFW_Survey__c> suChecksList = [SELECT Id, Name, Su__c, Active__c, ParentSurvey__c, Version__c, HeadOffice__c,CheckActiveDate__c FROM CJFW_Survey__c WHERE Su__c != null and Active__c = true];
        for (CJFW_Survey__c suCheck : suChecksList) {
            suCheckMap.put(suCheck.Su__c, suCheck);
            System.debug('suCheckMap>>>>>>>> ' + suCheckMap);
        }
        for (CJFW_Survey__c newSurvey : newSurveyLists) {
            CJFW_Survey__c oldSurvey = mapOld.get(newSurvey.Id);
            if (newSurvey.Su__c != oldSurvey.Su__c) {
                // Su__c 필드가 변경된 경우
                if (newSurvey.Su__c != null) {
                    if (suCheckMap.containsKey(newSurvey.Su__c)) {
                        if (suCheckMap.get(newSurvey.Su__c).Active__c) {
                            newSurvey.addError('해당 사업부 형식지가 작성되어있습니다.');
                        }
                    }
                }
            }
        }
    }
    @testVisible private void doDeleteCheck() {
        List<CJFW_Survey__c> oldSurveysList = listOld;
        Map<String, CJFW_Survey__c> daCheckMap = new Map<String, CJFW_Survey__c>();
    
        List<CJFW_Survey__c> dateChecksLists = [SELECT Id, Name, Su__c, Active__c, ParentSurvey__c, Version__c, HeadOffice__c,CheckActiveDate__c FROM CJFW_Survey__c WHERE CheckActiveDate__c !=null ];
       
        for (CJFW_Survey__c dateChecksList : dateChecksLists) {
            daCheckMap.put(dateChecksList.Id, dateChecksList);
            System.debug('suCheckMap>>>>>>>> ' + daCheckMap);
        }
        for (CJFW_Survey__c oldDateCheck : oldSurveysList) {
            if (daCheckMap.get(oldDateCheck.Id).CheckActiveDate__c != null) {
                oldDateCheck.addError('활성화 되었던 설문지입니다. 설문지를 삭제할 수 없습니다.');
            }
        }
    
    }
    
    
    
}