/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 09-22-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyPreviewController {
    public CJFW_SurveyPreviewController() {

    }
    public class SurveyQuestionResponse {
        @AuraEnabled
        public String question { get; set; }
        @AuraEnabled
        // public String  answer { get; set; }
        public List<String> answers { get; set; }
        

        public SurveyQuestionResponse(String question, List<String> answers) {
            this.question = question;
            this.answers = answers;
        }
       
        
    }



    @AuraEnabled
    public static  List<SurveyQuestionResponse> getSurveyReulte(String recordId){
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
        
      
       
        List<SurveyQuestionResponse> totalList = new List<SurveyQuestionResponse>();
 
        for (CJFW_SurveyResult__c ru : resultList) {
            String question = ru.FM_Question__c;
            List<String> answers = new List<String>();

            if (ru.OpenEnded__c != null) {
                answers.add (ru.OpenEnded__c);
            } else if (ru.OpenEnded__c == null && ru.SurveyOption__r.Name != null) {
                answers.add (ru.SurveyOption__r.Name);
            } else if (ru.OpenEnded__c == null && ru.SurveyOption__r.Name == null && ru.DateResult__c !=null){
                answers.add(String.valueOf(ru.DateResult__c));
            } else {
                answers.add(DateTime.newInstance(2000, 1, 1, ru.TimeResult__c.hour(), ru.TimeResult__c.minute(), ru.TimeResult__c.second()).format('a hh:mm'));
            }

            SurveyQuestionResponse response = new SurveyQuestionResponse(question, answers);
            totalList.add(response);
        }

        System.debug('22222' + totalList);
        return totalList;
    }
    
    
        
}