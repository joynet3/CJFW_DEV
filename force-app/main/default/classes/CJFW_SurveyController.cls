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

            Set<String> questionIdSet = new Set<String>();
            Set<String> optionIdSet = new Set<String>();
            //Map<String, CJFW_SurveyQuestion__c> questionMap = new Map<String, CJFW_SurveyQuestion__c>(); //questionId 로 put
            Map<String,Set<String>> mappingKeySetMap  = new Map<String,Set<String>>(); //key: questionId, optionIdSet
            CJFW_Survey survey;
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
                where Survey__c = 'a1U0w000001cA9AEAU'
            ];

            for(CJFW_SurveyQuestion__c question : questionList) {
                if(survey == null)  {
                    survey = new CJFW_Survey();
                    survey.id = question.Survey__c;
                    survey.category = question.Survey__r.Name;
                    survey.description = question.Survey__r.Description__c;
                }
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

            if(survey != null) {
                survey.setQuestions(questionList, mappingKeySetMap);
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
}