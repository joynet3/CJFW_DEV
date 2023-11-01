/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-31-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyActiveController {
    public CJFW_SurveyActiveController() {

    }
    @AuraEnabled
    public static Map<String, CJFW_Survey__c> getSurveyInfo(String recordId){
        System.debug('recordId?????????'+recordId);
        List<CJFW_Survey__c> surveyLists = [SELECT Id,Active__c,CheckActive__c FROM  CJFW_Survey__c WHERE Id =: recordId ];
        System.debug('surveyLists?????????'+surveyLists);
        Map<String, CJFW_Survey__c> surveyMap = new Map<String, CJFW_Survey__c>();
        
        for (CJFW_Survey__c surveyList : surveyLists) {
            surveyMap.put(surveyList.Id,surveyList);
        }
        System.debug('surveyMap?????????'+surveyMap);
        return surveyMap;

    }
}