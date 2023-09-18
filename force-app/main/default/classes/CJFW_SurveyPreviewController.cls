/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 09-16-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyPreviewController {
    public CJFW_SurveyPreviewController() {

    }
    public class SurveyQuestionResponse {
        @AuraEnabled
        public String question { get; set; }
        @AuraEnabled
        public String  answer { get; set; }
        // @AuraEnabled
        // public Boolean  isClicked { get; set; }

        public SurveyQuestionResponse(String question, String answer) {
            this.question = question;
            this.answer = answer;
            // this.isClicked = false;
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
            String answer;
        
           


            if (ru.OpenEnded__c != null) {
                answer = ru.OpenEnded__c;
            } else if (ru.OpenEnded__c == null && ru.SurveyOption__r.Name != null) {
                answer = ru.SurveyOption__r.Name;
            } else{
                answer =String.valueOf(ru.DateResult__c);
            }

            SurveyQuestionResponse response = new SurveyQuestionResponse(question, answer);
            totalList.add(response);
        }

        System.debug('22222' + totalList);
        return totalList;
    }
    
    
        
}