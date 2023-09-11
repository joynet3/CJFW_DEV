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
    public static List<Map<Decimal, String>>  getSurveyReulte(String recordId){
        System.debug('start>>>>>>>>>>>>>>>>>>>' );
        System.debug('getSurveyReulte' + recordId);
        
        Set<String> responseId = new Set<String>();// CJFW_SurveyResponse__c ID저장 set
         

        List<CJFW_SurveyResponse__c> responseList = [
            SELECT Id,
            OwnerId,
            Name,
            Survey__c,
            Lead__c,
            Account__c,
            Opportunity__c FROM CJFW_SurveyResponse__c WHERE Id = : recordId
        ];
       
        for (CJFW_SurveyResponse__c res : responseList) {
            responseId.add(res.Id);
        }
        

        List<CJFW_SurveyResult__c> resultList = [SELECT 
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
        SurveyOption__r.Name,
        SurveyQuestion__r.Order__c  FROM CJFW_SurveyResult__c 
        WHERE SurveyResponse__c =: responseId ORDER BY SurveyQuestion__r.Order__c ASC ];
        
        System.debug('11111' + resultList);
        
       
        List<Map<Decimal, String>> totalList = new List<Map<Decimal, String>>();
       
        for (CJFW_SurveyResult__c ru : resultList) {
        
        Map<Decimal, String> questionMap = new Map<Decimal, String>(); // CJFW_SurveyResult__c에 질문을 담기위한 map 
         Map<Decimal, String> answernMap = new Map<Decimal, String>(); // CJFW_SurveyResult__c에 답변을 담기위한 map 
        
            questionMap.put(ru.SurveyQuestion__r.Order__c, ru.FM_Question__c);
            if (ru.OpenEnded__c != null) {
                answernMap.put(ru.SurveyQuestion__r.Order__c, ru.OpenEnded__c);
            }
            else {
                answernMap.put(ru.SurveyQuestion__r.Order__c, ru.SurveyOption__r.Name);
            }
            totalList.add(questionMap); 
            totalList.add(answernMap); 
        }
        
      

        System.debug('22222' + totalList);
        return totalList;
    }
}