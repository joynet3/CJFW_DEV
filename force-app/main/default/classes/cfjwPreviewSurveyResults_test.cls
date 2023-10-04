/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 09-26-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
@isTest
public with sharing class cfjwPreviewSurveyResults_test {
   @TestSetup
   static void makeData(){
    CJFW_Survey__c newSurvey = new CJFW_Survey__c(
        Name = '테스트 설문'
    );
    insert newSurvey;
    CJFW_SurveyQuestion__c oneQuest =new CJFW_SurveyQuestion__c(
        Name__c = '1번 질문',
        Order__c = 1,
        Type__c = 'openended',// 주관식
        Survey__c = newSurvey.Id
    );
    insert oneQuest;
    
    CJFW_SurveyQuestion__c twoQuest =new CJFW_SurveyQuestion__c(
        Name__c = '2번 질문',
        Order__c = 2,
        Type__c = 'multiple',// 객관식
        MultipleChoice__c = 'singular', //단수
        Survey__c = newSurvey.Id
    );
    insert twoQuest;

    // twoQuest에 대한 옵션들 
    CJFW_SurveyOption__c oneOption_TWQ = new CJFW_SurveyOption__c(
        Order__c = 1,
        Name = '1번 옵션', //Content
        SurveyQuestion__c = twoQuest.Id
    );
    insert oneOption_TWQ;

    CJFW_SurveyOption__c twoOption_TWQ = new CJFW_SurveyOption__c(
        Order__c = 2,
        Name = '2번 옵션', //Content
        SurveyQuestion__c = twoQuest.Id
    );
    insert oneOption_TWQ;


    CJFW_SurveyQuestion__c threeQuest =new CJFW_SurveyQuestion__c(
        Name__c = '3번 질문',
        Order__c = 3,
        Type__c = 'multiple',
        MultipleChoice__c = 'plural',//복수
        Survey__c = newSurvey.Id
    );
    insert threeQuest;

    // threeQuest에 대한 옵션들 
    CJFW_SurveyOption__c oneOption_THQ = new CJFW_SurveyOption__c(
        Order__c = 1,
        Name = '1번 옵션', //Content
        SurveyQuestion__c = threeQuest.Id
    );
    insert oneOption_THQ;

    CJFW_SurveyOption__c twoOption_THQ = new CJFW_SurveyOption__c(
        Order__c = 2,
        Name = '2번 옵션', //Content
        SurveyQuestion__c = threeQuest.Id
    );
    insert oneOption_THQ;

    CJFW_SurveyOption__c thrOption_THQ = new CJFW_SurveyOption__c(
        Order__c = 3,
        Name = '3번 옵션', //Content
        SurveyQuestion__c = threeQuest.Id
    );
    insert thrOption_THQ;

    CJFW_SurveyOption__c foOption_THQ = new CJFW_SurveyOption__c(
        Order__c = 4,
        Name = '4번 옵션', //Content
        SurveyQuestion__c = threeQuest.Id
    );
    insert foOption_THQ;


    CJFW_SurveyQuestion__c fourQuest =new CJFW_SurveyQuestion__c(
        Name__c = '4번 질문',
        Order__c = 4,
        Type__c = 'date', 
        DateType__c = 'From/To',
        Survey__c = newSurvey.Id
    );
    insert fourQuest;

    CJFW_SurveyQuestion__c fiveQuest =new CJFW_SurveyQuestion__c(
        Name__c = '5번 질문',
        Order__c = 5,
        Type__c = 'time',
        Survey__c = newSurvey.Id
    );
    insert fourQuest;
   }
   

}