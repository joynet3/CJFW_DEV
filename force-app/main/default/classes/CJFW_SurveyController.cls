/**
* 설문지 정보 가져오기
*
*@group  Survey
*@author 진현욱
*@since 2023-08-01  최초작성
*/
public with sharing class CJFW_SurveyController {
    public CJFW_SurveyController() {

    }

    /**
    * surveyType 정보 가져오기
    *
    *@return  result Map<String,Object>
    */
   @AuraEnabled
    public static Map<String,Object> getSurveyType(){
        try {
            Map<String,Object> result = new Map<String,Object>();
            List<selectOption> optionList = new List<selectOption>();

            //Sample 용
            Set<String> recordIdSet = new Set<String>{
                'a1U0w000001cJd4EAE',  'a1U0w000001cJd9EAE'
            };

            if(UserInfo.getUserId() == Id.valueOf('0050w000005XKvNAAW')) {
                // recordIdSet.add('a1U0w000001cA9AEAU');
                // recordIdSet.add('a1U0w000001cHsbEAE');
            }
            //'a1U0w000001cA9AEAU' Sample 스무고개 설문 - 개발
            //'a1U0w000001cHsbEAE' 주문목적 유형(TEST) - 개발
            //'a1U0w000001cJd4EAE' //주문정보
            //'a1U0w000001cJd9EAE' //확인사항
            List<CJFW_Survey__c> surveyList =[
                select
                    Id
                    , Name
                    , Description__c
                from CJFW_Survey__c 
                where Id IN :recordIdSet //테스트시..
            ];

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
            result.put('params', params);
            String recordId = (String) params.get('recordId');
            CJFW_Survey survey = new CJFW_Survey(recordId);
            
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

            Id recordId =  Id.valueOf((String)params.get('recordId'));
            String objectApiName = (String) params.get('objectApiName');
            Id surveyTypeId  = Id.valueOf((String)params.get('surveyTypeId'));
            
            List<Object> objList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(params.get('selectedValueList')));
            System.debug(objList);
            
            /** */
            CJFW_SurveyResponse__c response = new CJFW_SurveyResponse__c();
            
            switch on objectApiName {
                when 'Lead' {
                    response.Lead__c = recordId;
                }when 'Account' {
                    response.Account__c = recordId;
                }when 'Opportunity' {
                    response.Opportunity__c = recordId;
                }
            }

            response.ResponseDate__c = Date.today();
            response.Survey__c = surveyTypeId;

            insert response;

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
                            for(String selectedValue : selectedValueList) {
                                CJFW_SurveyResult__c fromData = surveyResult.clone(false, true, false, false);
                                fromData.SurveyOption__c = selectedValue;
                                //마지막 데이터 제외하고 Add 마지막 데이터는 마지막에 공통 Add
                                responsResultList.add(fromData);
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
            /* */
            //result.put('')

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