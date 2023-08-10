/**
* Survey 작성용 Service 
*
*@group  Survey
*@author 진현욱
*@since 2023-07-31  최초 작성
*/
public with sharing class CJFW_Survey {
    
    @AuraEnabled public String id;                          //id
    @AuraEnabled public String category;                    //설문유형
    @AuraEnabled public String description;                 //설문설명
    @AuraEnabled public List<Question> questionList;        //질문 리스트
    @AuraEnabled public List<Question> resultQuestionList; //답변 리스트

    public CJFW_Survey(){
        questionList = new List<Question>();
    }

    public CJFW_Survey(String recordId) {
        questionList = new List<Question>();

        Set<String> questionIdSet = new Set<String>();
        Set<String> optionIdSet = new Set<String>();
        //Map<String, CJFW_SurveyQuestion__c> questionMap = new Map<String, CJFW_SurveyQuestion__c>(); //questionId 로 put
        Map<String,Set<String>> mappingKeySetMap  = new Map<String,Set<String>>(); //key: questionId, optionIdSet
        
        List<CJFW_SurveyQuestion__c> questionList = [
            select                              
                Id
                , Name                  //Auto Num
                , Name__c               //질문명
                , Survey__c             
                , Survey__r.Name     //설문 유형명
                , Survey__r.Description__c
                , Type__c               
                , MultipleChoice__c     
                , Order__c
                , DateType__c
                , (
                    select  
                        Id
                        , Order__c
                        , Name
                        , SurveyQuestion__c
                    from Survey_Option__r
                )
            from CJFW_SurveyQuestion__c       
            where Survey__c = :recordId
        ];

        for(CJFW_SurveyQuestion__c question : questionList) {
            
            if(String.isEmpty(this.id))             this.id = question.Survey__c;
            if(String.isEmpty(this.category))       this.category = question.Survey__r.Name;
            if(String.isEmpty(this.description))    this.description = question.Survey__r.Description__c;

            //questionMap.put(question.Id,question);

            questionIdSet.add(question.Id);
            for(CJFW_SurveyOption__c option : question.Survey_Option__r) {
                optionIdSet.add(option.Id);
            }
        }

        List<CJFW_SurveyFollowUp__c> followUpList = [
            select
                Id
                , SurveyQuestion__c
                , SurveyOption__c
            from CJFW_SurveyFollowUp__c
            where 
                SurveyQuestion__c IN :questionIdSet
            and
                SurveyOption__c IN :optionIdSet
        ];

        for(CJFW_SurveyFollowUp__c sfu : followUpList) {
            //String mappingKey = sfu.SurveyOption__c+'_'+sfu.SurveyQuestion__c;
            if(mappingKeySetMap.containsKey(sfu.SurveyQuestion__c)) {
                mappingKeySetMap.get(sfu.SurveyQuestion__c).add(sfu.SurveyOption__c);
            }else {
                mappingKeySetMap.put(sfu.SurveyQuestion__c, new Set<String>{sfu.SurveyOption__c});
            }

            if(mappingKeySetMap.containsKey(sfu.SurveyOption__c)) {
                mappingKeySetMap.get(sfu.SurveyOption__c).add(sfu.SurveyQuestion__c);
            }else {
                mappingKeySetMap.put(sfu.SurveyOption__c, new Set<String>{sfu.SurveyQuestion__c});
            }
            
        }

        this.setQuestions(questionList, mappingKeySetMap);
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

            mappingOption.subQuestionList.sort();
        }
        
        this.questionList.sort();
        List<Question> parentQuestionList = new List<Question>();

        for(Question qWrapper : this.questionList) {
            //최상위 부모에서 자식 질문 삭제
            if(!qWrapper.isChild) {
                parentQuestionList.add(qWrapper);
            }
        }
        this.questionList = parentQuestionList;

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
        @AuraEnabled public Boolean isTime = false;                  //시간 여부
        @AuraEnabled public Boolean isFromTo = false;                //날짜 From/To 여부
        @AuraEnabled public Boolean isSelected = false;              //선택여부
        @AuraEnabled public Boolean isShowDetail = true;             //설문지 디테일 보이기 여부


        public Question() {}
        public Question(CJFW_SurveyQuestion__c question) {
            this.id = question.Id;
            this.no = Integer.valueOf(question.Order__c);
            this.content = question.Name__c;
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
                }when 'time' {
                    this.isTime = true;
                    this.isFromTo = true;
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