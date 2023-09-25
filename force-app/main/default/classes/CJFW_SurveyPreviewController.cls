/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 09-25-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyPreviewController {
    public CJFW_SurveyPreviewController() {

    }

    // 설문 결과를 나타내는 클래스 정의
    public class SurveyQuestionResponse {
        @AuraEnabled
        public String question { get; set; }
        @AuraEnabled
        public String answer { get; set; }

        public SurveyQuestionResponse(String question, String answer) {
            this.question = question;
            this.answer = answer;
        }
    }

    @AuraEnabled
    public static List<SurveyQuestionResponse> getSurveyReulte(String recordId) {
        Set<String> responseId = new Set<String>();

        List<CJFW_SurveyResponse__c> responseList = [
            SELECT Id, OwnerId, Name, Survey__c, Lead__c, Account__c, Opportunity__c
            FROM CJFW_SurveyResponse__c
            WHERE Id = :recordId
        ];

        for (CJFW_SurveyResponse__c res : responseList) {
            responseId.add(res.Id);
        }

        List<CJFW_SurveyResult__c> resultList = [
            SELECT Id, OwnerId, Owner.Name, SurveyResponse__c, SurveyQuestion__c, SurveyOption__c,
                OpenEnded__c, DateResult__c, TimeResult__c, FM_Question__c, SurveyOption__r.Name,
                SurveyQuestion__r.Order__c
            FROM CJFW_SurveyResult__c
            WHERE SurveyResponse__c = :responseId
            ORDER BY SurveyQuestion__r.Order__c ASC
        ];

        List<SurveyQuestionResponse> totalList = new List<SurveyQuestionResponse>();
        Map<String, List<String>> questionToOptionsMap = new Map<String, List<String>>();
        Map<String, List<String>> questionToAnswerMap = new Map<String, List<String>>();

        for (CJFW_SurveyResult__c ru : resultList) {
            String question = ru.FM_Question__c;
            List<String> answers = new List<String>(); // 여러 개의 답변을 저장할 리스트를 생성
        
            if (ru.OpenEnded__c != null) {
                answers.add(ru.OpenEnded__c); // OpenEnded__c의 값을 리스트에 추가
            }
            else if (ru.SurveyOption__r.Name != null) {
                // 이미 처리한 질문인지 확인하고, 처리하지 않은 질문만 처리
                if (questionToAnswerMap.containsKey(question)) {
                    answers = questionToAnswerMap.get(question); // 이미 있는 리스트를 가져오기
                }
                answers.add(ru.SurveyOption__r.Name); // SurveyOption__r.Name의 값을 리스트에 추가
            }
            
            else if (ru.DateResult__c != null) {
                answers.add(String.valueOf(ru.DateResult__c)); // DateResult__c의 값을 리스트에 추가
            }
            else {
                answers.add(DateTime.newInstance(2000, 1, 1, ru.TimeResult__c.hour(), ru.TimeResult__c.minute(), ru.TimeResult__c.second()).format('a hh:mm'));
            }
        
            // 질문과 답변 리스트를 맵에 저장
            questionToAnswerMap.put(question, answers);
        }

        // 각 질문과 답변을 SurveyQuestionResponse 객체로 변환하여 totalList에 추가
        for (String question : questionToAnswerMap.keySet()) {
            List<String> answers = questionToAnswerMap.get(question);
            String answerString = String.join(answers, ', '); // 여러 개의 답변을 쉼표로 구분한 문자열로 변환
            SurveyQuestionResponse response = new SurveyQuestionResponse(question, answerString);
            totalList.add(response);
        }

        System.debug('22222' + totalList);
        return totalList;
    }
}