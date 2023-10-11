/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-11-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyPreviewController {
    public CJFW_SurveyPreviewController() {

    }

    public class SurveyQuestionResponse {
        @AuraEnabled
        public String question { get; set; }
        @AuraEnabled
        public String answer { get; set; }
        @AuraEnabled
        public String createdDate { get; set; }
        @AuraEnabled
        public String customerName { get; set; }

        public SurveyQuestionResponse(String question, String answer,String createdDate,String customerName) {
            this.question = question;
            this.answer = answer;
            this.createdDate = createdDate;
            this.customerName = customerName;
            
        }
    }

    @AuraEnabled
    public static List<SurveyQuestionResponse> getSurveyReulte(String recordId) {
        Set<String> responseId = new Set<String>();

        List<CJFW_SurveyResponse__c> responseList = [
            SELECT Id, OwnerId, Name, Survey__c, Lead__c,Lead__r.Name, Account__c,Account__r.Name, Opportunity__c,Opportunity__r.Name,CreatedDate
            FROM CJFW_SurveyResponse__c
            WHERE Id = :recordId
        ];

        for (CJFW_SurveyResponse__c res : responseList) {
            responseId.add(res.Id);
        }

        List<CJFW_SurveyResult__c> resultList = [
            SELECT Id, OwnerId, Owner.Name, SurveyResponse__c, SurveyQuestion__c, SurveyOption__c,
                OpenEnded__c, DateResult__c, TimeResult__c, FM_Question__c, SurveyOption__r.Name,CreatedDate,
                SurveyQuestion__r.Order__c
            FROM CJFW_SurveyResult__c
            WHERE SurveyResponse__c = :responseId
            ORDER BY SurveyQuestion__r.Order__c ASC
        ];

        List<SurveyQuestionResponse> totalList = new List<SurveyQuestionResponse>();
        Map<String, List<List<String>>> questionToAnswerMap = new Map<String, List<List<String>>>();
        
        for (CJFW_SurveyResult__c ru : resultList) {
            String question = ru.FM_Question__c;
            List<String> answers = new List<String>(); // 여러 개의 답변을 저장할 리스트를 생성
        
            if (ru.OpenEnded__c != null) {
                answers.add(ru.OpenEnded__c); // OpenEnded__c의 값을 리스트에 추가
            }
            else if (ru.SurveyOption__r.Name != null) {
                // 이미 처리한 질문인지 확인하고, 처리하지 않은 질문만 처리
                if (!questionToAnswerMap.containsKey(question)) {
                    questionToAnswerMap.put(question, new List<List<String>>());
                }
                List<List<String>> questionAnswers = questionToAnswerMap.get(question);
                questionAnswers.add(new List<String>{ru.SurveyOption__r.Name}); // SurveyOption__r.Name의 값을 리스트에 추가
                System.debug('찍혔니 : '+ questionAnswers);
            }
            else if (ru.DateResult__c != null) {
                answers.add(String.valueOf(ru.DateResult__c)); // DateResult__c의 값을 리스트에 추가
                System.debug('날짜 찍어봐 : '+ answers);
            }
            else {
                answers.add(DateTime.newInstance(2000, 1, 1, ru.TimeResult__c.hour(), ru.TimeResult__c.minute(), ru.TimeResult__c.second()).format('a hh:mm'));
                System.debug('시간 찍어봐  : '+ answers);
            }
        
           
            // 질문과 답변 리스트를 맵에 저장
            if (!questionToAnswerMap.containsKey(question)) {
                questionToAnswerMap.put(question, new List<List<String>>());
            }
            List<List<String>> questionAnswers = questionToAnswerMap.get(question);
            System.debug('1211212'+ questionAnswers);
            questionAnswers.add(answers);

        
        }
        
        // 각 질문과 답변을 SurveyQuestionResponse 객체로 변환하여 totalList에 추가
        for (String question : questionToAnswerMap.keySet()) {
            System.debug('%%%%%% :'+ question);
            List<List<String>> answersList = questionToAnswerMap.get(question);
            List<String> mergedAnswers = new List<String>();

            for (List<String> answers : answersList) {
                mergedAnswers.addAll(answers);
            }

            System.debug('이건 찍히나 : '+ mergedAnswers);
            String answerString;
            if (question.contains('날짜 From / To') || question.contains('시간 Sample')) {
                // DateResult__c 또는 TimeResult__c인 경우 물결표로 구분
                answerString = String.join(mergedAnswers,'~');
            } else {
                // 나머지 경우에는 콤마로 구분
                answerString = String.join(mergedAnswers,',' );
            }
            
            System.debug('이건 2222 : '+ answerString);
            // SurveyQuestionResponse response = new SurveyQuestionResponse(question, answerString);
            // totalList.add(response);

            String createdDate = null;
            String customerName = null;
            for (CJFW_SurveyResponse__c res : responseList) {
                createdDate = res.CreatedDate.format('yyyy년 MM월 dd일');
                if (res.Account__c != null) {
                    customerName = res.Account__r.Name;
                }else if (res.Account__c == null || res.Lead__c != null ) {
                    customerName = res.Lead__r.Name;
                }else if (res.Account__c == null || res.Lead__c == null ||res.Opportunity__c !=null ) {
                    customerName = res.Opportunity__r.Name;
                }
                 
            }
    
        SurveyQuestionResponse response = new SurveyQuestionResponse(question, answerString, createdDate,customerName);
        totalList.add(response);
        }
        

        System.debug('22222' + totalList);
        return totalList;
    }
}