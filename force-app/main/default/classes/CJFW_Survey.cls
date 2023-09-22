/**
* Survey 작성용 Service 
*
*@group  Survey
*@author 진현욱
*@since 2023-07-31  최초 작성
*/
public with sharing class CJFW_Survey {
    
    @AuraEnabled public String id;                          //설문 유형 Id
    @AuraEnabled public String category;                    //설문 유형명
    @AuraEnabled public String description;                 //설문 설명
    @AuraEnabled public List<Question> questionList;        //질문 리스트
    @AuraEnabled public List<Question> resultQuestionList;  //답변 리스트

    @AuraEnabled public Id recordId;                        //Lead, Account, Opportunity 의 Id
    @AuraEnabled public String objectApiName;               //sObjectApi

    private String responseId = '';                         //설문지 응답 Id

    public CJFW_Survey(){
        questionList = new List<Question>();
    }

    /**
    * 설문지 구성하는 생성자
    *
    *@param  recordId 설문지유형Id
    */
    public CJFW_Survey(String recordId) {
        questionList = new List<Question>();

        this.initialize(recordId);
    }

    /**
    * 설문지 구성하는 생성자
    *
    *@param  recordId 설문지유형Id
    *@param responseId 설문지응답Id
    */
    public CJFW_Survey(String recordId, String responseId) {
        questionList = new List<Question>();
        this.responseId = responseId;
        List<CJFW_SurveyResponse__c> resList = [
            select 
                survey__c
            from 
                CJFW_SurveyResponse__c
            where 
                id = :responseId
        ];
        this.initialize(resList[0].survey__c);
    }

    /**
    * 설문지 초기화
    *
    *@param  변수명 파라미터 설명 (있는경우)
    */
    private void initialize(String recordId) {
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
                , Survey__r.Name        //설문 유형명
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

    /**
    * 질문 및 질문의 선택지 설정
    *
    *@param  questionDataList 설문지 sObject 리스트
    *@param  mappingKeySetMap 질문, 선택지 Mapping 정보 Map {질문Id:[옵션Id..],옵션Id:[질문Id..]}
    */
    private void setQuestions(List<CJFW_SurveyQuestion__c> questionDataList, Map<String,Set<String>> mappingKeySetMap) {
        Map<String, List<Question>> childQuestionListMap = new Map<String, List<Question>>();

        Set<String> mappingAllOptionIdSet = new Set<String>();                      //연계질문 question, option id Set
        List<QuestionOption> mappingOptionList = new List<QuestionOption>();
        Map<String, Question> mappingQuestionMap = new Map<String, Question>();
        Map<String, QuestionOption> optionMap = new Map<String, QuestionOption>();

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

                    optionMap.put(oWrapper.id, oWrapper);
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
        
        
        //설문 응답 Id 가 있을 경우 answerMap 데이터 존재
        Map<String,Object> answerMap = this.getSurveyResult(this.responseId);

        List<Question> parentQuestionList = new List<Question>();

        for(Question qWrapper : this.questionList) {
            //최상위 부모에서 자식 질문 삭제
            //if(!qWrapper.isChild) {
            parentQuestionList.add(qWrapper);
            //}
            
            //답변이 있을 경우
            if(answerMap.containsKey(qWrapper.id)) {
                List<Object> answerList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(answerMap.get(qWrapper.id)));


                switch on qWrapper.type {
                    when 'multiple' {

                        if(qWrapper.isMultipleChoice) {
                            qWrapper.selectedValue = answerList;
                            //복수선택

                            // if(answerList != null && !answerList.isEmpty()) {
                            //     List<Object> multiSelectedList = new List<Object>();
                            //     for(Object answer : answerList) {
                            //         multiSelectedList.add(optionMap.get(String.valueOf(answer)));
                            //     }
    
                            //     qWrapper.selectedValue = multiSelectedList;
                            // }

                        }else {
                            //단수선택
                            qWrapper.selectedValue = optionMap.get(String.valueOf(answerList.get(0)));
                        }
                    }
                    when 'date' {
                        if(qWrapper.isFromTo) {
                            //From To
                            qWrapper.selectedValue = answerList;
                        }else {
                            //단일 Date
                            qWrapper.selectedValue = answerList.get(0);
                        }
                    }when 'time' {
                        //From To
                        qWrapper.selectedValue = answerList;
                    }when else {
                        //나머지
                        qWrapper.selectedValue = answerList.get(0);
                    }
                }                

                if(qWrapper.selectedValue != null) {
                    qWrapper.isSelected = true;
                } 
            }
        }
        this.questionList = parentQuestionList;

        for(Question qWrapper : this.questionList) {
            qWrapper.optionList.sort();
        }
    }

    /**
    * 설문지를 응답한 결과 가져오기
    *
    *@param  reponseRecordId 파라미터 설명 (있는경우)
    *@return Map<String,Object> {질문Id,답변...}
    */
    public Map<String,Object> getSurveyResult(String reponseRecordId) {
        Map<String,Object> answerMap = new Map<String,Object>();
        List<CJFW_SurveyResponse__c> responseList = [
            select
                Id
                , Survey__c
                , ResponseDate__c
                , Lead__c
                , Account__c
                , Opportunity__c
                , ( select 
                        Id
                        , SurveyQuestion__c
                        , SurveyQuestion__r.Type__c
                        , SurveyQuestion__r.MultipleChoice__c
                        , SurveyOption__c
                        , OpenEnded__c
                        , DateResult__c
                        , TimeResult__c
                    from  Survey_Result__r
                )
            from 
                CJFW_SurveyResponse__c 
            where Id = :reponseRecordId
        ];

        for(CJFW_SurveyResponse__c response : responseList) {

            if(response.Lead__c != null)  {
                this.recordId = response.Lead__c;
            }else if(response.Account__c != null) {
                this.recordId =  response.Account__c;
            }else if(response.Opportunity__c != null) {
                this.recordId =  response.Opportunity__c;
            }

            this.objectApiName = this.recordId.getSobjectType().getDescribe().getName();

            for(CJFW_SurveyResult__c result : response.Survey_Result__r) {

                Object answer;

                if(result.SurveyOption__c != null) {
                    answer = result.SurveyOption__c;
                }else if(result.OpenEnded__c != null) {
                    answer = result.OpenEnded__c;
                }else if(result.DateResult__c != null) {
                    answer = result.DateResult__c;
                }else if(result.TimeResult__c != null) {
                    answer = result.TimeResult__c;
                }
                
                if(answerMap.containsKey(result.SurveyQuestion__c)) {
                    List<Object> tmpList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(answerMap.get(result.SurveyQuestion__c)));
                    tmpList.add(answer);
                    answerMap.put(result.SurveyQuestion__c , tmpList);
                }else {
                    answerMap.put(result.SurveyQuestion__c , new List<Object>{answer});
                }
            }

        }
        System.debug('answerMap::');
        System.debug(JSON.serializePretty(answerMap));
        return answerMap;
    }
    
    /**
    * 질문 Class
    *
    */
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
        /**
        * 질문 생성자
        *
        *@param  question 설문지 질문
        */
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

        /**
        * 정렬 규칙 정의하는 메소드
        *
        *@param  compareTo 비교 대상
        *@return  sort 순서
        */
        public Integer compareTo(Object compareTo) {
            Question compareToQ = (Question)compareTo;
            if (no == compareToQ.no) return 0;
            if (no > compareToQ.no) return 1;
            return -1;        
        }
    }


    /**
    * 객관식 질문의 선택지 Class
    *
    */
    public class QuestionOption implements Comparable {
        @AuraEnabled public String  id;                             //객관식일 경우 Id 존재
        @AuraEnabled public Integer no;                             //선택지 번호
        @AuraEnabled public String  label;                          //선택지 라벨
        @AuraEnabled public String  value;                          //선택지 내용
        @AuraEnabled public List<Question> subQuestionList;         //선택된 값에 대한 질문
        @AuraEnabled public Boolean isParent = false; 
        @AuraEnabled public Boolean isFollowUp = false;              //선택여부                  
        

        public QuestionOption(){}
        /**
        * 객관식 질문의 선택지 생성자
        *
        *@param  option 질문 선택지
        */
        public QuestionOption(CJFW_SurveyOption__c option){
            this.id = option.Id;
            this.no = Integer.valueOf(option.Order__c);
            this.label = option.Name;
            this.value = option.Id;
            this.subQuestionList = new List<Question>();        
        }

        /**
        * 정렬 규칙 정의하는 메소드
        *
        *@param  compareTo 비교 대상
        *@return  sort 순서
        */
        public Integer compareTo(Object compareTo) {
            QuestionOption compareToQo = (QuestionOption)compareTo;
            if (no == compareToQo.no) return 0;
            if (no > compareToQo.no) return 1;
            return -1;        
        }
    }


}