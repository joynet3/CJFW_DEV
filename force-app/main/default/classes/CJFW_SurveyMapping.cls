/**
 * @description       :
 * @author            : sunkyung.choi@dkbmc.com
 * @group             :
 * @last modified on  : 11-27-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyMapping {

    public class SurveyFieldMapping {
        @AuraEnabled public String targetObject {get;set;}
        @AuraEnabled public String QuestionName {get;set;}
        // @AuraEnabled public String targetField { get; set; }

        public SurveyFieldMapping(String obj, String field) {
            this.targetObject = obj;
            this.QuestionName = field;
            // this.targetField = field;
        }
    }

    @AuraEnabled public static void getMappingInfo(
        CJFW_SurveyResponse__c response,
        List<CJFW_SurveyResult__c> responsResultList
    ) {

        System.debug('response check' + response);

        Map<String, String> resultMap = new Map<String, String>();
        Map<String, CJFW_SurveyFieldMapping__c> sfmMap = new Map<String, CJFW_SurveyFieldMapping__c>();
        Set<Id> responseIdSet = new Set<Id>();
        Set<String> surveyQuestionSet = new Set<String>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();

        for (CJFW_SurveyResult__c resRes : responsResultList) {
            responseIdSet.add(resRes.SurveyResponse__c);
        }
        System.debug('responseIdSet ??? ' + responseIdSet);

        List<CJFW_SurveyResult__c> resultList = [
            SELECT Id,
            Name,
            SurveyResponse__r.Lead__c,
            SurveyResponse__c,
            SurveyQuestion__c,
            SurveyOption__c,
            OpenEnded__c,
            DateResult__c,
            TimeResult__c,
            FM_Question__c FROM CJFW_SurveyResult__c WHERE SurveyResponse__c = : responseIdSet
        ];
        System.debug('resultList' + resultList);

        List<CJFW_SurveyResponse__c> responseList = [
            SELECT Id,
            Name,
            Survey__c,
            ResponseDate__c,
            Lead__c,
            Lead__r.LastName,
            Lead__r.FirstName,
            Lead__r.Email,
            Lead__r.Phone,
            Lead__r.MobilePhone,
            Account__c,
            Opportunity__c FROM CJFW_SurveyResponse__c WHERE Id = : responseIdSet
        ];

        System.debug('responseList' + responseList);

        for (CJFW_SurveyResult__c suveyResult : resultList) {
            resultMap.put(suveyResult.SurveyQuestion__c, suveyResult.OpenEnded__c);
            surveyQuestionSet.add(suveyResult.SurveyQuestion__c);
        }

        for (CJFW_SurveyResponse__c suveyRespon : responseList) {
            accIdSet.add(suveyRespon.Account__c);
            leadIdSet.add(suveyRespon.Lead__c);
        }

        System.debug('resultMap ??? ' + resultMap);
        System.debug('accIdSet ??? ' + accIdSet);
        System.debug('leadIdSet ??? ' + leadIdSet);

        List<CJFW_SurveyFieldMapping__c> fieldMappings = [SELECT SurveyQuestion__c, TargetField__c, TargetObject__c, targetQuestionName__c FROM CJFW_SurveyFieldMapping__c WHERE SurveyQuestion__c IN: surveyQuestionSet];

        for (CJFW_SurveyFieldMapping__c fieldMapping : fieldMappings) {
            sfmMap.put(fieldMapping.targetQuestionName__c, fieldMapping);

        }

        List<Contact> conList = [SELECT Id, LastName, Email, Phone FROM Contact WHERE AccountId IN: accIdSet];

        List<Contact> allLists = [SELECT Id, LastName, Email, Phone FROM Contact];

        for (CJFW_SurveyFieldMapping__c mapping : fieldMappings) {
            String targetObject = mapping.TargetObject__c;
            String QuestionName = mapping.targetQuestionName__c;
            System.debug('targetObject ????' + targetObject);
            System.debug('QuestionName ????' + QuestionName);
            System.debug('시작');
            String openEndedValue = resultMap.get(mapping.SurveyQuestion__c);
            if (targetObject.equalsIgnoreCase('lead')) {
                System.debug('Lead Start');
                Lead updateLead = new Lead(Id = response.Lead__c);
                applyFieldMapping(updateLead, QuestionName, openEndedValue);
                update updateLead;
            }

        }
    }

    private static void applyFieldMapping(
        SObject record,
        String QuestionName,
        String openEndedValue
    ) {
        System.debug('일단 체크');
        if (QuestionName.contains('이름')) {
            record.put('LastName', openEndedValue);
        } else if (QuestionName.contains('이메일')) {
            record.put('Email', openEndedValue);
        } else if (QuestionName.contains('연락처')) {
            record.put('Phone', openEndedValue);
        }
    }

}