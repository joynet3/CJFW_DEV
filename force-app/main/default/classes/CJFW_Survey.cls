/**
* Survey 작성용 Service 
*
*@group  Survey
*@author 진현욱
*@since 2023-07-31  최초 작성
*/
public with sharing class CJFW_Survey {
    
    @AuraEnabled public String category;             //설문유형
    @AuraEnabled public String description;          //설문설명
    @AuraEnabled public List<Question> questionList; //문항 리스트


    public CJFW_Survey() {

    }
    

    public class Question {
        @AuraEnabled public String  id;                             //질문Id
        @AuraEnabled public Integer no;                             //질문번호
        @AuraEnabled public String  content;                        //질문내용
        @AuraEnabled public String  type;                           //질문유형
        @AuraEnabled public String  multipleChoice;                 //객관식유형 singular, plural
        @AuraEnabled public String  dateType;                       //날짜유형 
        @AuraEnabled public List<QuestionOption> optionList;        //선택지 리스트
        @AuraEnabled public Object  selectedValue;                  //선택된 값: Date, Date From/To, 주관식, QuestionOption
    }


    public class QuestionOption {
        @AuraEnabled public String  id;                     //객관식일 경우 Id 존재
        @AuraEnabled public Integer no;                     //선택지 번호
        @AuraEnabled public String  label;                  //선택지 라벨
        @AuraEnabled public String  value;                  //선택지 내용
        @AuraEnabled public List<Question> subQuestionList; //선택된 값에 대한 질문
    }

}