/**
 * @description       :
 * @author            : sunkyung.choi@dkbmc.com
 * @group             :
 * @last modified on  : 11-06-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyActiveController {
    public CJFW_SurveyActiveController() {}

    @AuraEnabled public static Map<Id, CJFW_Survey__c> getSurveyInfo(
        String recordId
    ) {
        List<CJFW_Survey__c> surveyList = [
            SELECT Id,
            Name,
            Su__c,
            Active__c,
            ParentSurvey__c,
            Version__c,
            HeadOffice__c,
            CheckActive__c FROM CJFW_Survey__c WHERE Id = : recordId
        ];

        Map<Id, CJFW_Survey__c> surMap = new Map<Id, CJFW_Survey__c>();
        for (CJFW_Survey__c su : surveyList) {
            surMap.put(su.Id, su);
        }
        return surMap;
    }
    @AuraEnabled public static void updateSurveyInfo(CJFW_Survey__c surveyData) {
        System.debug('시작>>>>> ');
        System.debug('surveyData' + surveyData);
        surveyData.CheckActive__c = System.now();

        Set<Id> parId = new Set<Id>();
        Set<Id> surId = new Set<Id>();

        System.debug('시작2>>>>> ');
        surId.add(surveyData.Id);
        Map<Id, CJFW_Survey__c> currentSurveyMap = new Map<Id, CJFW_Survey__c>();
        List<CJFW_Survey__c> surveyLists = [
            SELECT Id,
            Name,
            Active__c,
            CheckActive__c,
            ParentSurvey__c,
            Version__c FROM CJFW_Survey__c WHERE Id IN: surId
        ];
        for (CJFW_Survey__c surveyList : surveyLists) {
            if (surveyList.Version__c > 1) {
                parId.add(surveyList.ParentSurvey__c);
            } else if (surveyList.Version__c == 1) {
                parId.add(surveyList.Id);
            }
            currentSurveyMap.put(surveyList.Id, surveyList);
        }
        System.debug(
            '2222222222222222222>>>>> ' + currentSurveyMap.get(surveyLists[0].Id)
        );
        List<CJFW_Survey__c> realatedLists = [
            SELECT Id,
            Name,
            Active__c,
            CheckActive__c,
            ParentSurvey__c,
            Version__c FROM CJFW_Survey__c WHERE Id IN: parId or ParentSurvey__c IN: parId
        ];
        System.debug('1111111surveyLists>>>>> ' + realatedLists);

        for (CJFW_Survey__c realatedList : realatedLists) {
            if (realatedList.Id != surveyData.Id) {
                realatedList.Active__c = false;
            }
        }
        update realatedLists;
        update surveyData;

    }

}