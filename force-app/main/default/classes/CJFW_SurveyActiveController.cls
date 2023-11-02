/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-02-2023
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
    @AuraEnabled
    public static String updateSurveyInfo(CJFW_Survey__c surveyData) {
        try {
            if (surveyData != null) {
                System.debug('surveyData' + surveyData);
                surveyData.CheckActive__c = System.now();
                update surveyData;
                return 'Success'; // 업데이트가 성공했을 때 성공 메시지 반환
            } else {
                return 'Data is null'; // 데이터가 null일 때 오류 메시지 반환
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage(); // 업데이트 중 오류가 발생했을 때 오류 메시지 반환
        }
    }
    @AuraEnabled
    public static Map<Id, CJFW_SurveyOption__c> getSurveyQueInfo(String recordId){
        System.debug('recordId?????????'+recordId);
        
        List<CJFW_SurveyQuestion__c> surveyQueLists = [SELECT Id,  Name,Name__c, Survey__c, Type__c, MultipleChoice__c, Order__c, DateType__c, TextType__c, ActiveCheck__c FROM  CJFW_SurveyQuestion__c WHERE Survey__c =: recordId ];
        
        Set<Id> questionId = new Set<Id>();
        System.debug('surveyQueLists?????????'+surveyQueLists);
        Map<Id, CJFW_SurveyQuestion__c> surveyQueMap = new Map<Id, CJFW_SurveyQuestion__c>();
        Map<Id, CJFW_SurveyOption__c> surveyOptMap = new Map<Id, CJFW_SurveyOption__c>();
        
        for (CJFW_SurveyQuestion__c surveyQueList : surveyQueLists) {
            questionId.add(surveyQueList.Id);
            surveyQueMap.put(surveyQueList.Id,surveyQueList);
        }
        System.debug('surveyQueMap?????????'+surveyQueMap);
        System.debug('questionId?????????'+questionId);
        
        List<CJFW_SurveyOption__c> surveyOptions = [SELECT Id, Name, Order__c, SurveyQuestion__c, OpActiveCheck__c FROM  CJFW_SurveyOption__c WHERE  SurveyQuestion__c IN: questionId ];
        
        for (CJFW_SurveyOption__c surveyOption : surveyOptions) {
            surveyOptMap.put(surveyOption.Id,surveyOption);
        }
        System.debug('surveyOptMap?????????'+surveyOptMap);


        return surveyOptMap;

    }
    
}