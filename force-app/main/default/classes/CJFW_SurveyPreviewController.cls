/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 09-08-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyPreviewController {
    public CJFW_SurveyPreviewController() {

    }
    @AuraEnabled
    public static void getSurveyReulte(String recordId){
        
        Set<String> responseId = new Set<String>();
        List<CJFW_SurveyResponse__c> responseList = [SELECT Id, OwnerId,  Name, Survey__c, Lead__c, Account__c, Opportunity__c  FROM CJFW_SurveyResponse__c WHERE Id =: recordId];
       
        for (CJFW_SurveyResponse__c res : responseList) {
            responseId.add(res.Id);
        }
        

        List<CJFW_SurveyResult__c> rusultList = [SELECT 
        Id, 
        OwnerId,
        Owner.Name, 
        SurveyResponse__c, 
        SurveyQuestion__c, 
        SurveyOption__c, 
        OpenEnded__c, 
        DateResult__c, 
        TimeResult__c, 
        FM_Question__c,
        SurveyOption__r.name,
        SurveyQuestion__r.Order__c  FROM CJFW_SurveyResult__c 
        WHERE SurveyResponse__c =: responseId ORDER BY SurveyQuestion__r.Order__c ASC ];
        
        System.debug('11111' + rusultList);
        
        Map<String, String> surveyMap = new Map<String, String>();
        
        for (CJFW_SurveyResult__c ru : rusultList) {
           if (ru.OpenEnded__c != null) {
            surveyMap.put(ru.FM_Question__c, ru.OpenEnded__c);
           }else{
            surveyMap.put(ru.FM_Question__c, ru.SurveyOption__c);
           }
        }
        System.debug('22222' + surveyMap);
        
    }
}