/**
* Survey 작성용 Service 
*
*@group  Survey
*@author 진현욱
*@since 2023-07-31  최초 작성
*/
public with sharing class CJFW_Survey {
    
    @AuraEnabled public String id;                   //id
    @AuraEnabled public String category;             //설문유형
    @AuraEnabled public String description;          //설문설명
    @AuraEnabled public List<Question> questionList; //문항 리스트


    public CJFW_Survey() {
        questionList = new List<Question>();
    }

    //, Map<String, CJFW_SurveyQuestion__c> questionMap
    public void setQuestions(List<CJFW_SurveyQuestion__c> questionDataList, Map<String,Set<String>> mappingKeySetMap) {
        Map<String, List<Question>> childQuestionListMap = new Map<String, List<Question>>();

        Set<String> mappingAllOptionIdSet = new Set<String>();
        List<QuestionOption> mappingOptionList = new List<QuestionOption>();
        Map<String, Question> mappingQuestionMap = new Map<String, Question>();

        if(!mappingKeySetMap.isEmpty()) {
            for(Set<String> keySet : mappingKeySetMap.values()) {
                mappingAllOptionIdSet.addAll(keySet);
            }
        }

        for(CJFW_SurveyQuestion__c question : questionDataList) {
            Question qWrapper = new Question(question);
            this.questionList.add(qWrapper);

            //연계질문이 있을경우
            if(mappingKeySetMap.containsKey(qWrapper.id)) {
                qWrapper.isChild = true;
                mappingQuestionMap.put(qWrapper.id, qWrapper);
            }

            //객관식일경우
            if(qWrapper.isMultiple) {
                for(CJFW_SurveyOption__c option : question.Survey_Option__r) {
                    QuestionOption oWrapper = new QuestionOption(option);
                    oWrapper.id = option.Id;
                    qWrapper.optionList.add(oWrapper);
                    if(mappingAllOptionIdSet.contains(oWrapper.id)) {
                        oWrapper.isParent = true;
                        mappingOptionList.add(oWrapper);
                    }
                }
            }

        }


        for(QuestionOption mappingOption : mappingOptionList) {
            for(String surveyId : mappingKeySetMap.get(mappingOption.id)) {
                mappingOption.subQuestionList.add(mappingQuestionMap.get(surveyId));
            }
        }
        
        this.questionList.sort();
        for(Question qWrapper : this.questionList) {
            qWrapper.optionList.sort();
        }
    }
    
    public class Question implements Comparable {
        @AuraEnabled public String  id;                             //질문Id
        @AuraEnabled public Integer no;                             //질문번호
        @AuraEnabled public String  content;                        //질문내용
        @AuraEnabled public String  type;                           //질문유형
        @AuraEnabled public String  multipleChoice;                 //객관식유형 singular, plural
        @AuraEnabled public String  dateType;                       //날짜유형 
        @AuraEnabled public List<QuestionOption> optionList;        //선택지 리스트
        @AuraEnabled public Object  selectedValue;                  //선택된 값: Date, Date From/To, 주관식, QuestionOption
        @AuraEnabled public Boolean isChild = false;                //자식 여부 
        @AuraEnabled public Boolean isMultipleChoice = false;        //복수선택 여부
        @AuraEnabled public Boolean isMultiple = false;              //객관식 여부
        @AuraEnabled public Boolean isDate = false;                  //날짜 여부
        @AuraEnabled public Boolean isFromTo = false;                //날짜 From/To 여부
        @AuraEnabled public Boolean isSelected = false;              //선택여부
        @AuraEnabled public Boolean isShowDetail = true;             //설문지 디테일 보이기 여부

        public Question() {}
        public Question(CJFW_SurveyQuestion__c question) {
            this.id = question.Id;
            this.no = Integer.valueOf(question.Order__c);
            this.content = String.valueOf(no)+'. '+ question.Name__c;
            this.type = question.Type__c;
            this.multipleChoice = question.MultipleChoice__c;
            this.dateType = question.DateType__c;
            this.optionList = new List<QuestionOption>();

            switch on this.type {
                when 'multiple' {
                    this.isMultiple = true;

                    //복수선택여부
                    if('plural'.equals(this.multipleChoice)) this.isMultipleChoice = true;
                }
                when 'date' {
                    this.isDate = true;

                    if('From/To'.equals(this.dateType)) this.isFromTo = true;
                }
            }

        }

        public Integer compareTo(Object compareTo) {
            Question compareToQ = (Question)compareTo;
            if (no == compareToQ.no) return 0;
            if (no > compareToQ.no) return 1;
            return -1;        
        }
    }


    public class QuestionOption implements Comparable {
        @AuraEnabled public String  id;                             //객관식일 경우 Id 존재
        @AuraEnabled public Integer no;                             //선택지 번호
        @AuraEnabled public String  label;                          //선택지 라벨
        @AuraEnabled public String  value;                          //선택지 내용
        @AuraEnabled public List<Question> subQuestionList;         //선택된 값에 대한 질문
        @AuraEnabled public Boolean isParent = false; 
        @AuraEnabled public Boolean isFollowUp = false;              //선택여부                  
        

        public QuestionOption(){}
        public QuestionOption(CJFW_SurveyOption__c option){
            this.id = option.Id;
            this.no = Integer.valueOf(option.Order__c);
            this.label = option.Name;
            this.value = option.Name;
            this.subQuestionList = new List<Question>();        
        }

        public Integer compareTo(Object compareTo) {
            QuestionOption compareToQo = (QuestionOption)compareTo;
            if (no == compareToQo.no) return 0;
            if (no > compareToQo.no) return 1;
            return -1;        
        }
    }


}