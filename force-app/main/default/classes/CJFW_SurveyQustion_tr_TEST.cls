/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
@isTest
public with sharing class CJFW_SurveyQustion_tr_TEST {


 @TestSetup
 static void makeData(){
  
  List<CJFW_Survey__c> surveyList = new List<CJFW_Survey__c>(); // CJFW_Survey__c 담는 리스트 
  List<CJFW_SurveyQuestion__c> surveyQueList = new List<CJFW_SurveyQuestion__c>(); // Qustion 담는 리스트 
  

  CJFW_Survey__c newSurvey = new CJFW_Survey__c(
    Name = '테스트 설문',
    Su__c = '4100',
    HeadOffice__c ='3001',
    Version__c = 1
    );
    insert newSurvey;
    surveyList.add(newSurvey);
  
  CJFW_SurveyQuestion__c oneQuest =new CJFW_SurveyQuestion__c(
      Name__c = '1번 질문',
      Order__c = 1,
      Type__c = 'openended',// 주관식
      Survey__c = newSurvey.Id
  );
  surveyQueList.add(oneQuest);
  

  insert surveyQueList;

 }

 @isTest
 static void insertCheck_TEST(){ 
    Test.startTest();
    Set<Id> surveyIdSet = new Set<Id>();
    Map<String, CJFW_Survey__c> surveyQuMap = new Map<String, CJFW_Survey__c>();
    Map<Id, CJFW_SurveyQuestion__c> surveyQueMap = new Map<Id, CJFW_SurveyQuestion__c>();
    Boolean exceptionThrown = false;

    
    List<CJFW_Survey__c> testLists = [SELECT Id,Name,Su__c,HeadOffice__c,Active__c,CheckActive__c,Version__c,ParentSurvey__c
    FROM CJFW_Survey__c WHERE Name = :'테스트 설문'];
    testLists[0].Active__c = true; 
    update testLists;
    for (CJFW_Survey__c testList : testLists) {
        surveyIdSet.add(testList.Id);
        surveyQuMap.put(testList.Id ,testList);
        
    }

 
    List<CJFW_SurveyQuestion__c> testQueLists = [SELECT Id,  
    Name,  
    Name__c, 
    Survey__c, 
    Type__c, 
    MultipleChoice__c, 
    Order__c, 
    DateType__c, 
    TextType__c, 
    Survey__r.CheckActive__c,
    ActiveCheck__c
    FROM CJFW_SurveyQuestion__c WHERE Survey__c = :surveyIdSet];
    
    for (CJFW_SurveyQuestion__c testQueList : testQueLists) {
        surveyQueMap.put(testQueList.Id,testQueList);

        System.debug('testQueLists check >>> '+testQueList.ActiveCheck__c);
    }
    try {
    
        CJFW_SurveyQuestion__c addQuest =new CJFW_SurveyQuestion__c(
            Name__c = '새로운 질문',
            Order__c = 11,
            Type__c = 'multiple',
            MultipleChoice__c = 'plural',//복수
            Survey__c = testLists[0].Id
            );
        insert addQuest;
    
        List<CJFW_SurveyQuestion__c> updateQueLists = [SELECT Id,  
        Name,  
        Name__c, 
        Survey__c, 
        Type__c, 
        MultipleChoice__c, 
        Order__c, 
        DateType__c, 
        TextType__c, 
        Survey__r.CheckActive__c,
        ActiveCheck__c
        FROM CJFW_SurveyQuestion__c WHERE Survey__c = :surveyIdSet and Name__c =: '1번 질문'];
        
        updateQueLists[0].Name__c = '11';
        
        update updateQueLists;
        delete updateQueLists;
    
   }
   catch (Exception e) {
    exceptionThrown = true;
    
    Boolean expectedExceptionThrown =  (e.getMessage().contains('error msg')) ? true : false; 
    System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
   }
    
     Test.stopTest();
 }
}