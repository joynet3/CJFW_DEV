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
        public String answer { get; set; }
        

        public SurveyQuestionResponse(String question, String answer) {
            this.question = question;
            this.answer =answer;
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
        // FM_Question__c와 SurveyOption__r.Name을 관리하기 위한 맵 생성
        Map<String, List<String>> questionToOptionsMap = new Map<String, List<String>>();

        for (CJFW_SurveyResult__c ru : resultList) {
            String question = ru.FM_Question__c;

            String answer;

            if (ru.OpenEnded__c != null) {
                answer = ru.OpenEnded__c;
            }  else if (ru.OpenEnded__c == null && ru.SurveyOption__r.Name != null) {
                // SurveyOption__r.Name을 가져올 리스트를 생성
                List<String> optionNames = new List<String>();
                
                // 같은 질문에 대한 SurveyOption__r.Name 값을 가져와서 저장
                if (questionToOptionsMap.containsKey(question)) {
                    optionNames = questionToOptionsMap.get(question);
                }
                
                optionNames.add(ru.SurveyOption__r.Name);
                
                // SurveyOption__r.Name 값이 있는 경우 콤마로 연결하여 저장
                if (!optionNames.isEmpty()) {
                    answer = String.join(optionNames, ', ');
                }
                
                // 다음에 이 질문에 대한 다른 답변이 올 경우를 대비해 맵에 저장
                questionToOptionsMap.put(question, optionNames);
            } else if (ru.OpenEnded__c == null && ru.SurveyOption__r.Name == null && ru.DateResult__c !=null){
                answer =String.valueOf(ru.DateResult__c);
            } else {
                answer = DateTime.newInstance(2000, 1, 1, ru.TimeResult__c.hour(), ru.TimeResult__c.minute(), ru.TimeResult__c.second()).format('a hh:mm');
            }

            SurveyQuestionResponse response = new SurveyQuestionResponse(question, answer);
            totalList.add(response);
        }

        System.debug('22222' + totalList);
        return totalList;
    }
    
    
        
}