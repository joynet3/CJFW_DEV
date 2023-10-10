/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
@isTest
public with sharing class CJFW_SurveyController_TEST {
    
    @TestSetup
    static void makeData(){
        List<User> userList = new List<User>();
        
        String profileName4100 = 'CJFW_아이누리사업부';
        Map<String,Profile> profieMap = COMM_TestDataFactory.getProfileMap(new List<String>{
            profileName4100
        });

        User ibUser = COMM_TestDataFactory.createUser(profieMap.get(profileName4100).Id);
        ibUser.LastName = '테스트Staff';
        userList.add(ibUser);


        insert userList;

        //231005기준 4개 설문지를 생성
        CJFW_Survey_TEST.makeData();

    }
    @isTest
    static void getCurrentUserInfoTest(){

        // 먼저 테스트에 사용할 사용자 레코드를 쿼리
        User testUser = [SELECT Id FROM User WHERE LastName = '테스트Staff' LIMIT 1];

         // System.runAs 블록 내에서 코드를 지정된 사용자 컨텍스트에서 실행합니다.
         System.runAs(testUser) {
            Test.startTest();
            
            // getCurrentUserInfo 메서드를 호출하여 결과를 가져옵니다.
            String result = CJFW_SurveyController.getCurrentUserInfo();
            
            // 여기에서 결과에 대한 검증 논리를 추가합니다.
            
            Test.stopTest();
        }
    }

    @isTest
    static void getSurveyType_Test(){
        Test.startTest();

        Map<String,Object> result = CJFW_SurveyController.getSurveyType();

        List<CJFW_Survey__c> surveyList =  (List<CJFW_Survey__c>) JSON.deserialize(JSON.serialize(result.get('surveyList')), List<CJFW_Survey__c>.class);

        System.assert(surveyList.size() == 4);

        Test.stopTest();
    }

    @isTest
    static void getSurvey_Test() {
        Test.startTest();

        List<CJFW_Survey__c> surveyList = [select id from CJFW_Survey__c where SU__c = '4600'];

        //1. 생성
        Map<String, Object> params = new Map<String, Object>();
        params.put('recordId', surveyList.get(0).id);
        params.put('mode', 'create');
        CJFW_SurveyController.getSurvey(params);

        //2. 수정
        params.put('mode', 'edit');
        CJFW_SurveyResponse__c response = CJFW_Survey_TEST.saveSurveyResponse(surveyList.get(0).id);
        params.put('surveyResponseId', response.id);
        CJFW_SurveyController.getSurvey(params);
        
        Test.stopTest();
    }


    @isTest
    static void saveSurveyResponse_TEST() {
        Test.startTest();

        List<CJFW_Survey__c> surveyList = [select id from CJFW_Survey__c where SU__c = '4600'];
        Map<String, List<CJFW_SurveyOption__c>> questionOptionListMap = new Map<String, List<CJFW_SurveyOption__c>>();
        String surveyId = surveyList.get(0).id;
        for(CJFW_SurveyQuestion__c quest : [
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
                    order by Order__c, Name
                )
            from CJFW_SurveyQuestion__c       
            where Survey__c = :surveyId
            order by Order__c, Name
        ]) {
            List<CJFW_SurveyOption__c> optionList = new List<CJFW_SurveyOption__c>();

            for(CJFW_SurveyOption__c option : quest.Survey_Option__r) {
                optionList.add(option);
            }
            
            questionOptionListMap.put(quest.id, optionList);
        }
        System.debug(questionOptionListMap);
        Map<String, Object> params = new Map<String, Object>();
        params.put('recordId', surveyId);
        params.put('mode', 'create');
        Map<String,Object> result = CJFW_SurveyController.getSurvey(params);

        Map<String,Object> surveyObj = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(result.get('survey')));
        
        List<Object> selectedObjList = new List<Object>();
        
        List<Object> questionObjList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(surveyObj.get('questionList')));
        for(Object obj : questionObjList) {
            Map<String,Object> question = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            String questionId = String.valueOf(question.get('id'));
            String type = String.valueOf(question.get('type'));

            switch on type {
                when 'multiple' {
                    //객관식
                    if(Boolean.valueOf(question.get('isMultipleChoice'))) {
                        //복수선택
                        
                        List<String> selectedList = new List<String>();
                        for(CJFW_SurveyOption__c surveyOption : questionOptionListMap.get(questionId)) {
                            selectedList.add(surveyOption.id);
                        }

                        question.put('selectedValue', selectedList);

                    }else {
                        //단수선택
                        CJFW_Survey.QuestionOption selectedOption;
                        for(CJFW_SurveyOption__c surveyOption : questionOptionListMap.get(questionId)) {
                            selectedOption = new CJFW_Survey.QuestionOption(surveyOption);
                            break;
                        }

                        question.put('selectedValue', selectedOption);
                    }
                }
                when 'date' {
                    //날짜
                    
                    if(Boolean.valueOf(question.get('isFromTo'))) {
                        question.put('selectedValue', new List<Date>{
                            Date.today()
                            ,Date.today().addDays(1)
                        });
                        
                    }else{
                        question.put('selectedValue', Date.today());
                    }
                }when 'time' {
                    //시간
                    if(Boolean.valueOf(question.get('isFromTo'))) {
                        question.put('selectedValue', new List<Time>{
                            Time.newInstance(9, 0, 0, 0)
                            ,Time.newInstance(10, 0, 0, 0)
                        });
                    }
                }when else {
                    //주관식
                    question.put('selectedValue', '주관식 테스트');
                }
            }
            selectedObjList.add(question);
        }

        params.remove('recordId');

        params.put('surveyTypeId', surveyList.get(0).id);
        //System.debug(JSON.serializePretty(selectedObjList));
        params.put('selectedValueList', selectedObjList);
        //1. 생성
        CJFW_SurveyController.saveSurveyResponse(params);


        //2. 수정
        params.put('mode', 'edit');
        CJFW_SurveyController.saveSurveyResponse(params);
        Test.stopTest();
    }
}