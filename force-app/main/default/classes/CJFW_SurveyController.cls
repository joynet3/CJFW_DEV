/**
* 설문지 정보 가져오기
*
*@group  Survey
*@author 진현욱
*@since 2023-08-01  최초작성
*
*@author 최선경
*@since 2023-09-06  샘플 코드 삭제
*
*@author 진현욱
*@since 2023-09-20  설문지 Edit 버전 추가
*@since 2023-10-26  설문지를 Opportunity 에서 작성할 경우 Oppty 의 AccountId 도 Survey Response 에 등록
*@since 2023-11-01  Lead, Opportunity, Account Owenr 의 SU__c 필드 기준으로 설문지 노출
*/



public with sharing class CJFW_SurveyController {
    public CJFW_SurveyController() {

    }
    /**
    * 부모 Object 의 정보
    *
    *@param  recordId parentRecordId
    *@return  Map<String,Object>
    */
    @AuraEnabled
    public static Map<String,Object> getParentInfo(String recordId){
        try {
            Map<String,Object> result = new Map<String,Object>();

            String query = ' select '
                         + '         Id '
                         + '        ,Name '
                         + '        ,Owner.SU__c '
                         + ' from ' + Id.valueOf(recordId).getSobjectType()
                         + ' where Id = :recordId';

            result.put('data', database.query(query));

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getCurrentUserInfo(){
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        String profileName = currentUser.Profile.Name;
        //System.debug('현재 프로필: ' + profileName);
        return profileName;

    }
    /**
    * surveyType 정보 가져오기
    *
    *@return  result Map<String,Object>
    */
   @AuraEnabled
    public static Map<String,Object> getSurveyType(Boolean isNotAdmin, String suCode){
        try {
            Map<String,Object> result = new Map<String,Object>();
            List<selectOption> optionList = new List<selectOption>();

            
            String query = ' select '
            + '        Id '
            + '        ,Name '
            + '        ,Description__c'
            + ' from CJFW_Survey__c '
            + ' where Id != null ';
            
            if(isNotAdmin) {
                query += ' and Active__c = true '
                +  ' and SU__c = :suCode ';
            }
            
            List<CJFW_Survey__c> surveyList = database.query(query);

            for(CJFW_Survey__c survey : surveyList) {
                optionList.add(new selectOption(survey.Name , survey.Id));
            }
            result.put('surveyList', surveyList);
            result.put('optionList', optionList);

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }


    /**
    * survey 정보 가져오기
    *
    *@param  params Map<String,Object>
    *@return  result Map<String,Object>
    */
    @AuraEnabled
    public static Map<String,Object> getSurvey(Map<String,Object> params){
        try {
            Map<String,Object> result = new Map<String,Object>();
            result.put('params', params);                           //params 확인용
            
            String recordId = (String) params.get('recordId');
            String mode     = (String) params.get('mode');
            String responseId;
            if(params.get('surveyResponseId') != null) responseId = (String) params.get('surveyResponseId');

            CJFW_Survey survey;

            switch on mode {
                when  'create'{
                    survey = new CJFW_Survey(recordId);
                }
                when 'edit' {
                    survey = new CJFW_Survey(recordId,responseId);
                }
            }

            if(survey != null) {
                
                System.debug(
                    JSON.serializePretty(survey)
                );

                result.put('survey' , survey);
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * 설문 응답 저장
    *
    *@return  result Map<String,Object>
    */
   @AuraEnabled
    public static Map<String,Object> saveSurveyResponse(Map<String,Object> params){
        try {
            
            Map<String,Object> result = new Map<String,Object>();
            result.put('params', params);

            String mode = (String) params.get('mode');
            String objectApiName;
            Id recordId;
            if(params.get('recordId') != null) recordId = Id.valueOf((String)params.get('recordId'));
            if(params.get('objectApiName') != null) objectApiName = (String) params.get('objectApiName');

            Id surveyTypeId  = Id.valueOf((String)params.get('surveyTypeId'));
            Id surveyResponseId;
            if(params.get('surveyResponseId') != null) surveyResponseId = Id.valueOf((String) params.get('surveyResponseId'));
            
            List<Object> objList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(params.get('selectedValueList')));
            System.debug(objList);
            CJFW_SurveyResponse__c response;
            switch on mode {
                when 'create' {
                    /** */
                    response = new CJFW_SurveyResponse__c();

                    switch on objectApiName {
                        when 'Lead' {
                            response.Lead__c = recordId;
                        }when 'Account' {
                            response.Account__c = recordId;
                        }when 'Opportunity' {
                            response.Opportunity__c = recordId;

                            List<Opportunity> optyList = [
                                select 
                                    id,
                                    AccountId
                                from Opportunity
                                where 
                                    Id = :recordId
                            ];

                            response.Account__c = optyList[0].AccountId;
                        }
                    }

                    response.ResponseDate__c = Date.today();
                    response.Survey__c = surveyTypeId;

                    insert response;
                }when 'edit' {
                    //edit 일 때는 이전 설문지 결과 데이터 삭제 후 신규 생성 : 복수개의 객관식 때문에 수정하기 어려움..        
                    
                    List<CJFW_SurveyResult__c> existSurveyResultList = [
                        select id
                        from CJFW_SurveyResult__c
                        where SurveyResponse__c = :surveyResponseId
                    ];

                    delete existSurveyResultList;

                    response = [ 
                        select 
                            id
                         from 
                            CJFW_SurveyResponse__c 
                        where 
                            id = :surveyResponseId
                    ];
                }
            }

            List<CJFW_SurveyResult__c> responsResultList = new List<CJFW_SurveyResult__c>();

            for(Object obj : objList) {
                Map<String,Object> question = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                CJFW_SurveyResult__c surveyResult = new CJFW_SurveyResult__c();
                surveyResult.SurveyResponse__c = response.Id;
                surveyResult.SurveyQuestion__c = Id.valueOf(String.valueOf(question.get('id')));
                String type = String.valueOf(question.get('type'));

                switch on type {
                    when 'multiple' {
                        //객관식
                        //SurveyOption__c
                        if(Boolean.valueOf(question.get('isMultipleChoice'))) {
                            //복수선택
                            List<String> selectedValueList = (List<String>) JSON.deserialize(JSON.serialize(question.get('selectedValue')), List<String>.class);
                            Integer idx = 0;
                            for(String selectedValue : selectedValueList) {
                                CJFW_SurveyResult__c fromData = surveyResult.clone(false, true, false, false);
                                fromData.SurveyOption__c = selectedValue;
                                //마지막 데이터 제외하고 Add 마지막 데이터는 마지막에 공통 Add
                                if(idx < selectedValueList.size()-1) responsResultList.add(fromData);
                                idx++;
                            }
                            
                            surveyResult.SurveyOption__c = selectedValueList[selectedValueList.size()-1];

                        }else {
                            //단수선택
                            Map<String,Object> selectedValue = (Map<String,Object>)question.get('selectedValue');
                            surveyResult.SurveyOption__c = Id.valueOf(String.valueOf(selectedValue.get('id')));

                            //surveyResult.SurveyOption__c = ((CJFW_Survey.QuestionOption) JSON.deserialize(JSON.serialize(question.get('selectedValue')), CJFW_Survey.QuestionOption.class)).id;
                            
                        }
                    }
                    when 'date' {
                        //날짜
                        
                        if(Boolean.valueOf(question.get('isFromTo'))) {
                            List<Date> dateList = (List<Date>)JSON.deserialize(JSON.serialize(question.get('selectedValue')), List<Date>.class);
                            CJFW_SurveyResult__c fromData = surveyResult.clone(false, true, false, false);
                            fromData.DateResult__c = dateList[0];
                            responsResultList.add(fromData);
                            
                            surveyResult.DateResult__c = dateList[1];
                        }else{
                            surveyResult.DateResult__c = Date.valueOf(String.valueOf(question.get('selectedValue')));
                        }
                    }when 'time' {
                        //시간
                        if(Boolean.valueOf(question.get('isFromTo'))) {
                            List<Time> timeList = (List<Time>)JSON.deserialize(JSON.serialize(question.get('selectedValue')), List<Time>.class);
                            CJFW_SurveyResult__c fromData = surveyResult.clone(false, true, false, false);
                            fromData.TimeResult__c = timeList[0];
                            responsResultList.add(fromData);

                            surveyResult.TimeResult__c = timeList[1];
                        }
                    }when else {
                        //주관식
                        surveyResult.OpenEnded__c = (String) question.get('selectedValue');
                    }
                }
                responsResultList.add(surveyResult);
            }
            insert responsResultList;
            
            result.put('insertData', response);

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    public class selectOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public selectOption(){}
        public selectOption(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}