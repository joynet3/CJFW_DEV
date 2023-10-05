@isTest
public with sharing class CJFW_Survey_TEST {
    
    @testSetup
    static void makeData() {
        //원료솔루션사업부: 4600
        //급식솔루션사업부: 4700
        //아이누리사업부: 4100
        //헬씨누리사업부: 4705

        List<User> userList = new List<User>();
        String adminProfileName = 'System Administrator';

        if('ko'.equals(UserInfo.getLanguage())) {
            adminProfileName = '시스템 관리자';
        }

        Profile adminProfile = getProfile(adminProfileName);
        UserRole adminRole = getUserRole('SFDC_HQ_GM');
        User u = createUser(adminProfile.Id);
        u.LastName = '어드민 사용자';
        u.UserRoleId = adminRole.Id;
        userList.add(u);

        
        Profile pf4600 = getProfile('CJFW_원료솔루션사업부');
        UserRole role4600 = getUserRole('SFDC_6001_4600_Div_BM');
        User u4600 = createUser(pf4600.Id);
        u4600.UserRoleId = role4600.Id;
        u4600.LastName = '원료솔루션사업부 사용자';
        u4600.HeadOffice__c = '6001';
        u4600.SU__c = '4600';
        userList.add(u4600);

        insert userList;
       

        System.runAs(u) {
            List<CJFW_Survey__c> surveyList = new List<CJFW_Survey__c>();
            List<CJFW_SurveyQuestion__c> questionList = new List<CJFW_SurveyQuestion__c>();
            List<CJFW_SurveyOption__c> optionList = new List<CJFW_SurveyOption__c>();
            List<CJFW_SurveyFollowUp__c> followUpList = new List<CJFW_SurveyFollowUp__c>();

            CJFW_Survey__c survey4600 = new CJFW_Survey__c(
                Name = '원료 솔루션 설문지'
                ,Description__c = '원료 솔루션 설문지 설명'
                ,SU__c = '4600'
            );
            surveyList.add(survey4600);

            
            CJFW_Survey__c survey4700 = new CJFW_Survey__c(
                Name = '급식 솔루션 설문지'
                ,Description__c = '급식 솔루션 설문지 설명'
                ,SU__c = '4700'
            );
            surveyList.add(survey4700);

            
            CJFW_Survey__c survey4100 = new CJFW_Survey__c(
                Name = '아이누리 설문지'
                ,Description__c = '아이누리 설문지 설명'
                ,SU__c = '4100'
            );
            surveyList.add(survey4100);

            
            CJFW_Survey__c survey4705 = new CJFW_Survey__c(
                Name = '헬씨누리 설문지'
                ,Description__c = '헬씨누리 설문지 설명'
                ,SU__c = '4705'
            );
            surveyList.add(survey4705);

            insert surveyList;

            
            /*              Label(api)
                Type__c : 
                        주관식(openended)
                        객관식(multiple)
                        날짜(date)
                        시간(time)

                Type__c Dependency Picklist
                    -multiple
                        > MultipleChoice__c :
                                                단수(singular)
                                                복수(plural)
                    -date
                        > DateType__c : 
                                        시작/끝(From/To)
                                        일(Date)
            */
        
            //원료 솔루션 설문지는 연계 질문 x
            CJFW_SurveyQuestion__c question4600_opended = new CJFW_SurveyQuestion__c(
                    Name__c = '1. 첫번째 질문 - 주관식'
                    ,Order__c = 1
                    ,Survey__c = survey4600.Id
                    ,Type__c = 'openended'
            );
            questionList.add(question4600_opended);

            CJFW_SurveyQuestion__c question4600_multiple = new CJFW_SurveyQuestion__c(
                    Name__c = '2. 첫번째 질문 - 객관식 단수'
                    ,Order__c = 2
                    ,Survey__c = survey4600.Id
                    ,Type__c = 'multiple'
                    ,MultipleChoice__c = 'singular'
            );
            questionList.add(question4600_multiple);

            CJFW_SurveyQuestion__c question4600_multiple_plural = new CJFW_SurveyQuestion__c(
                    Name__c = '3. 첫번째 질문 - 객관식 복수'
                    ,Order__c = 3
                    ,Survey__c = survey4600.Id
                    ,Type__c = 'multiple'
                    ,MultipleChoice__c = 'plural'
            );
            questionList.add(question4600_multiple_plural);

            CJFW_SurveyQuestion__c question4600_date = new CJFW_SurveyQuestion__c(
                    Name__c = '4. 첫번째 질문 - 날짜'
                    ,Order__c = 4
                    ,Survey__c = survey4600.Id
                    ,Type__c = 'date'
                    ,DateType__c = 'Date'
            );
            questionList.add(question4600_date);

            CJFW_SurveyQuestion__c question4600_date_FromTo = new CJFW_SurveyQuestion__c(
                    Name__c = '5. 첫번째 질문 - 날짜 From/To'
                    ,Order__c = 5
                    ,Survey__c = survey4600.Id
                    ,Type__c = 'date'
                    ,DateType__c = 'From/To'
            );
            questionList.add(question4600_date_FromTo);

            CJFW_SurveyQuestion__c question4600_time = new CJFW_SurveyQuestion__c(
                    Name__c = '6. 첫번째 질문 - 시간 From/To'
                    ,Order__c = 6
                    ,Survey__c = survey4600.Id
                    ,Type__c = 'time'
            );
            questionList.add(question4600_time);

            /*급식솔루션 사업부 연계 질문  [s]*/
            CJFW_SurveyQuestion__c question4700_multiple = new CJFW_SurveyQuestion__c(
                    Name__c = '1. 첫번째 질문 - 객관식 단수'
                    ,Order__c = 1
                    ,Survey__c = survey4700.Id
                    ,Type__c = 'multiple'
                    ,MultipleChoice__c = 'singular'
            );
            questionList.add(question4700_multiple);

            CJFW_SurveyQuestion__c question4700_multiple_1 = new CJFW_SurveyQuestion__c(
                    Name__c = '1.1 첫번째 질문 - 첫번째 Option 의 Sub 질문'
                    ,Order__c = 1
                    ,Survey__c = survey4700.Id
                    ,Type__c = 'openended'
            );
            questionList.add(question4700_multiple_1);

            CJFW_SurveyQuestion__c question4700_multiple_2 = new CJFW_SurveyQuestion__c(
                    Name__c = '1.2 첫번째 질문 - 첫번째 Option 의 Sub 질문'
                    ,Order__c = 1
                    ,Survey__c = survey4700.Id
                    ,Type__c = 'openended'
            );
            questionList.add(question4700_multiple_2);
            /*급식솔루션 사업부 연계 질문  [e]*/

            insert questionList;

            
            CJFW_SurveyOption__c option_question4600_multiple = new CJFW_SurveyOption__c(
                Name = '첫번째 단수 옵션'
                ,Order__c = 1
                ,SurveyQuestion__c = question4600_multiple.Id
            );
            optionList.add(option_question4600_multiple);

            CJFW_SurveyOption__c option_question4600_multiple_two = new CJFW_SurveyOption__c(
                Name = '두번째 단수 옵션'
                ,Order__c = 2
                ,SurveyQuestion__c = question4600_multiple.Id
            );
            optionList.add(option_question4600_multiple_two);

            CJFW_SurveyOption__c option_question4600_multiple_three = new CJFW_SurveyOption__c(
                Name = '세번쨰 단수 옵션'
                ,Order__c = 3
                ,SurveyQuestion__c = question4600_multiple.Id
            );
            optionList.add(option_question4600_multiple_three);

            CJFW_SurveyOption__c option_question4600_multiple_four = new CJFW_SurveyOption__c(
                Name = '네번쨰 단수 옵션'
                ,Order__c = 4
                ,SurveyQuestion__c = question4600_multiple.Id
            );
            optionList.add(option_question4600_multiple_four);


            CJFW_SurveyOption__c option_question4600_multiple_plural = new CJFW_SurveyOption__c(
                Name = '첫번째 복수 옵션'
                ,Order__c = 1
                ,SurveyQuestion__c = question4600_multiple_plural.Id
            );
            optionList.add(option_question4600_multiple_plural);

            CJFW_SurveyOption__c option_question4600_multiple_plural_two = new CJFW_SurveyOption__c(
                Name = '두번째 복수 옵션'
                ,Order__c = 2
                ,SurveyQuestion__c = question4600_multiple_plural.Id
            );
            optionList.add(option_question4600_multiple_plural_two);

            CJFW_SurveyOption__c option_question4600_multiple_plural_three = new CJFW_SurveyOption__c(
                Name = '세번쨰 복수 옵션'
                ,Order__c = 3
                ,SurveyQuestion__c = question4600_multiple_plural.Id
            );
            optionList.add(option_question4600_multiple_plural_three);

            CJFW_SurveyOption__c option_question4600_multiple_plural_four = new CJFW_SurveyOption__c(
                Name = '네번쨰 복수 옵션'
                ,Order__c = 4
                ,SurveyQuestion__c = question4600_multiple_plural.Id
            );
            optionList.add(option_question4600_multiple_plural_four);

            /*급식솔루션 사업부 연계 질문 - 옵션  [s]*/
            CJFW_SurveyOption__c option_question4700_multiple = new CJFW_SurveyOption__c(
                Name = '첫번째 단수 옵션'
                ,Order__c = 1
                ,SurveyQuestion__c = question4700_multiple.Id
            );
            optionList.add(option_question4700_multiple);

            CJFW_SurveyOption__c option_question4700_multiple_two = new CJFW_SurveyOption__c(
                Name = '두번째 단수 옵션'
                ,Order__c = 2
                ,SurveyQuestion__c = question4700_multiple.Id
            );
            optionList.add(option_question4700_multiple_two);

            CJFW_SurveyOption__c option_question4700_multiple_three = new CJFW_SurveyOption__c(
                Name = '세번쨰 단수 옵션'
                ,Order__c = 3
                ,SurveyQuestion__c = question4700_multiple.Id
            );
            optionList.add(option_question4700_multiple_three);

            CJFW_SurveyOption__c option_question4700_multiple_four = new CJFW_SurveyOption__c(
                Name = '네번쨰 단수 옵션'
                ,Order__c = 4
                ,SurveyQuestion__c = question4700_multiple.Id
            );
            optionList.add(option_question4700_multiple_four);
            /*급식솔루션 사업부 연계 질문 - 옵션  [e]*/
            insert optionList;


            /*급식솔루션 사업부 연계 질문 - 연계  [s]*/
            CJFW_SurveyFollowUp__c followup4700 = new CJFW_SurveyFollowUp__c(
                SurveyQuestion__c = question4700_multiple_1.id,
                SurveyOption__c = option_question4700_multiple.id
            );
            followUpList.add(followup4700);

            CJFW_SurveyFollowUp__c followup4700_two = new CJFW_SurveyFollowUp__c(
                SurveyQuestion__c = question4700_multiple_2.id,
                SurveyOption__c = option_question4700_multiple.id
            );
            followUpList.add(followup4700_two);
            insert followUpList;
            /*급식솔루션 사업부 연계 질문 - 연계  [e]*/

            CJFW_Survey__Share u4600Share = new CJFW_Survey__Share(
                AccessLevel = 'Read'
                ,UserOrGroupId = u4600.Id
                ,ParentID = survey4600.Id
            );

            insert u4600Share;
        }

    }

    @isTest
    static void constructor_Test() {
        test.startTest();
        Map<String, CJFW_Survey__c> surveyMap = new Map<String, CJFW_Survey__c>();

        for(CJFW_Survey__c survey :[
                select id, SU__c from CJFW_Survey__c 
        ]) {
            surveyMap.put(survey.SU__c,  survey);
        }

        //1. 기본
        new CJFW_Survey();

        //2. 원료솔루션사업부: 4600 - 연계질문x
        CJFW_Survey__c survey4600 = surveyMap.get('4600');
        CJFW_Survey survey4600Wrapper = new CJFW_Survey(survey4600.id);

        //3. 급식솔루션 4700 - 연계질문
        CJFW_Survey__c survey4700 = surveyMap.get('4700');
        CJFW_Survey survey4700Wrapper = new CJFW_Survey(survey4700.id);

        for(CJFW_Survey.Question question : survey4700Wrapper.questionList) {
            System.debug(question.content);
        }


        test.stopTest();
    }

    @isTest
    public static void user4600_Execute() {
        test.startTest();
        

        User u4600 =  [select id, LastName from User where LastName = '원료솔루션사업부 사용자' limit 1];

        System.runAs(u4600) {

            List<CJFW_SurveyResponse__c> responseList = new List<CJFW_SurveyResponse__c>();
            List<CJFW_SurveyResult__c> responsResultList = new List<CJFW_SurveyResult__c>();
            System.debug('surveyList :: ');
            System.debug([select id, SU__c, Name from CJFW_Survey__c ]);

            CJFW_Survey__c survey = [select id from CJFW_Survey__c where SU__c = '4600' limit 1];
            
            CJFW_SurveyResponse__c response = new CJFW_SurveyResponse__c();
            response.Survey__c = survey.id;
            response.ResponseDate__c = Date.today();
            responseList.add(response);

            insert responseList;

            for(CJFW_SurveyQuestion__c question :[
                select 
                    id
                    , survey__c
                    , name
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
                where 
                    Survey__c = :survey.id
                order by Order__c, Name
            ]) {
                CJFW_SurveyResult__c result = new CJFW_SurveyResult__c(
                    SurveyResponse__c = response.id
                    ,SurveyQuestion__c = question.id
                );

                if('openended'.equals(question.Type__c)) {
                    //주관식
                    result.OpenEnded__c = '주관식 답변';
                    responsResultList.add(result);
                }else if('multiple'.equals(question.Type__c)) {
                    //객관식
                    for(CJFW_SurveyOption__c option : question.Survey_Option__r) {

                        if('singular'.equals(question.MultipleChoice__c)) {
                            result.SurveyOption__c = option.id;
                            responsResultList.add(result);
                            break;
                        }else if('plural'.equals(question.MultipleChoice__c)) {
                            CJFW_SurveyResult__c cloneResult = result.clone(false);
                            cloneResult.SurveyOption__c = option.id;
                            responsResultList.add(cloneResult);
                        }
                    }
                }else if('date'.equals(question.Type__c)) {
                    //날짜
                    if('Date'.equals(question.DateType__c)) {
                        result.DateResult__c = Date.today().addDays(1);
                        responsResultList.add(result);
                    }
                    
                    if('From/To'.equals(question.DateType__c)) {
                        CJFW_SurveyResult__c cloneResult = result.clone(false);
                        cloneResult.DateResult__c = Date.today().addDays(2);
                        responsResultList.add(cloneResult);
                    }

                }else if('time'.equals(question.Type__c)) { 
                    //시간

                    result.TimeResult__c = Time.newInstance(9, 0, 0, 0);
                    responsResultList.add(result);

                    CJFW_SurveyResult__c cloneResult = result.clone(false);
                    cloneResult.TimeResult__c = Time.newInstance(10, 0, 0, 0);
                    responsResultList.add(cloneResult);
                }
            }

            insert responsResultList;

            CJFW_Survey resultSurvey = new CJFW_Survey(survey.id , response.id);
            CJFW_Survey.Question resultSurveyQuestion = resultSurvey.questionList.get(0);

            System.assert('주관식 답변'.equals(String.valueOf(resultSurveyQuestion.selectedValue)) , true);
        }

        test.stopTest();
    }

    public static Profile getProfile(String profileName) { 
        Profile pf = [SELECT Id, Name FROM Profile WHERE Name = :profileName LIMIT 1];
        
        return pf;
    }

    public static User createUser(String profileId){
        User user = new User(
            ProfileId = profileId
            , Alias = 'Alias'
            , Username = 'Test@test.com' + System.currentTimeMillis()
            , EmployeeNumber = '998877'
            , Email = 'Test@test.com'
            , FirstName = 'Test'
            , LastName = 'Test'
            , LocaleSidKey = 'en_US'
            , LanguageLocaleKey = 'en_US'
            , EmailEncodingKey = 'UTF-8'
            , TimeZoneSidKey = 'America/Los_Angeles'
            , IsActive = true
            , FederationIdentifier = 'Test' + System.currentTimeMillis()
        );

        return user;
    }

    public static UserRole getUserRole(String roleName) { 
        UserRole role = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = :roleName];
        
        return role;
    }
}