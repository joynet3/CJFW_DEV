/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-16-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
@isTest
public with sharing class CJFW_SurveyOption_tr_TEST {
  // 옵션을 담기 위한 map 
  static Map<String, Id> optionIdMap = new Map<String, Id>();
    
  // 응답을 담기 위한 map 
  static Map<String, Id> responMap = new Map<String, Id>(); 

  @TestSetup
  static void makeData(){
   List<CJFW_Survey__c> surveyList = new List<CJFW_Survey__c>(); // CJFW_Survey__c 담는 리스트 
   List<CJFW_SurveyQuestion__c> surveyQueList = new List<CJFW_SurveyQuestion__c>(); // Qustion 담는 리스트 
   List<CJFW_SurveyOption__c> surveyOptList = new List<CJFW_SurveyOption__c>(); // Qustion 담는 리스트 



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
   
   CJFW_SurveyQuestion__c twoQuest =new CJFW_SurveyQuestion__c(
       Name__c = '2번 질문',
       Order__c = 2,
       Type__c = 'multiple',// 객관식
       MultipleChoice__c = 'singular', //단수
       Survey__c = newSurvey.Id
   );
   surveyQueList.add(twoQuest);
   
   CJFW_SurveyQuestion__c threeQuest =new CJFW_SurveyQuestion__c(
      Name__c = '3번 질문',
      Order__c = 3,
      Type__c = 'multiple',
      MultipleChoice__c = 'plural',//복수
      Survey__c = newSurvey.Id
  );
  surveyQueList.add(threeQuest);

  CJFW_SurveyQuestion__c fourQuest =new CJFW_SurveyQuestion__c(
       Name__c = '4번 질문',
       Order__c = 4,
       Type__c = 'date', 
       DateType__c = 'From/To',
       Survey__c = newSurvey.Id
   );
   surveyQueList.add(fourQuest);

   CJFW_SurveyQuestion__c fiveQuest =new CJFW_SurveyQuestion__c(
       Name__c = '5번 질문',
       Order__c = 5,
       Type__c = 'time',
       Survey__c = newSurvey.Id
   );
   surveyQueList.add(fiveQuest);
   insert surveyQueList;






   // twoQuest에 대한 옵션들 
   CJFW_SurveyOption__c oneOption_TWQ = new CJFW_SurveyOption__c(
       Order__c = 1,
       Name = '2-1번 옵션', //Content
       SurveyQuestion__c = twoQuest.Id
   );
   surveyOptList.add(oneOption_TWQ);

   CJFW_SurveyOption__c twoOption_TWQ = new CJFW_SurveyOption__c(
       Order__c = 2,
       Name = '2-2번 옵션', //Content
       SurveyQuestion__c = twoQuest.Id
   );
   surveyOptList.add(twoOption_TWQ);

  

   // threeQuest에 대한 옵션들 
   CJFW_SurveyOption__c oneOption_THQ = new CJFW_SurveyOption__c(
       Order__c = 1,
       Name = '3-1번 옵션', //Content
       SurveyQuestion__c = threeQuest.Id
   );
   surveyOptList.add(oneOption_THQ);
    
   CJFW_SurveyOption__c twoOption_THQ = new CJFW_SurveyOption__c(
       Order__c = 2,
       Name = '3-2번 옵션', //Content
       SurveyQuestion__c = threeQuest.Id
   );
   surveyOptList.add(twoOption_THQ);

   CJFW_SurveyOption__c thrOption_THQ = new CJFW_SurveyOption__c(
       Order__c = 3,
       Name = '3-3번 옵션', //Content
       SurveyQuestion__c = threeQuest.Id
   );
   surveyOptList.add(thrOption_THQ);

   CJFW_SurveyOption__c forOption_THQ = new CJFW_SurveyOption__c(
       Order__c = 4,
       Name = '3-4번 옵션', //Content
       SurveyQuestion__c = threeQuest.Id
   );
   surveyOptList.add(forOption_THQ);

   insert surveyOptList;



 
  }

   @isTest
   static void insertCheck_TEST(){ 
    TEST.startTest();
    
    Set<Id> surveyIdSet = new Set<Id>();
    Set<Id> surveyQueIdSet = new Set<Id>();
    Map<Id, CJFW_SurveyQuestion__c> surveyQueMap = new Map<Id, CJFW_SurveyQuestion__c>();
    Map<Id, CJFW_SurveyOption__c> surveyOptMap = new Map<Id, CJFW_SurveyOption__c>();
     
    List<CJFW_Survey__c> testLists = [SELECT Id,Name,Su__c,HeadOffice__c,Active__c,CheckActiveDate__c,Version__c,ParentSurvey__c
    FROM CJFW_Survey__c WHERE Name = :'테스트 설문'];
    testLists[0].Active__c = true; 
    update testLists;
    for (CJFW_Survey__c testList : testLists) {
        surveyIdSet.add(testList.Id);
        
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
    Survey__r.CheckActiveDate__c,
    ActiveCheck__c
    FROM CJFW_SurveyQuestion__c WHERE Survey__c = :surveyIdSet];

    for (CJFW_SurveyQuestion__c testQueList : testQueLists) {
        surveyQueMap.put(testQueList.Id,testQueList);
        surveyQueIdSet.add(testQueList.Id);
    }
    List<CJFW_SurveyOption__c> testOptLists = [SELECT  Id, IsDeleted, Name, CurrencyIsoCode,  Order__c, SurveyQuestion__c, OpActiveCheck__c
    FROM CJFW_SurveyOption__c WHERE SurveyQuestion__c = :surveyQueIdSet];

    for (CJFW_SurveyOption__c testOptList : testOptLists) {
        surveyOptMap.put(testOptList.Id,testOptList);
    }
  try {
    
    List<CJFW_SurveyQuestion__c> testQueOrgLists = [SELECT Id,  
    Name,  
    Name__c, 
    Survey__c, 
    Type__c, 
    MultipleChoice__c, 
    Order__c, 
    DateType__c, 
    TextType__c, 
    Survey__r.CheckActiveDate__c,
    ActiveCheck__c
    FROM CJFW_SurveyQuestion__c WHERE name__c = :'2번 질문'];

    CJFW_SurveyOption__c newOption_TWQ = new CJFW_SurveyOption__c(
        Order__c = 7,
        Name = '2-1번 옵션', //Content
        SurveyQuestion__c = testQueOrgLists[0].Id
    );
    insert newOption_TWQ;

    
  }
  catch (Exception e) {
    System.debug('error message'+ e.getMessage());
  }

  try {
    List<CJFW_SurveyOption__c> testNewOptLists = [SELECT  Id, IsDeleted, Name, CurrencyIsoCode,  Order__c, SurveyQuestion__c, OpActiveCheck__c
    FROM CJFW_SurveyOption__c WHERE Name = :'2-2번 옵션'];
    testNewOptLists[0].Order__c = 12;
    update testNewOptLists;
  }
  catch (Exception e) {
    System.debug('error message'+ e.getMessage());
  }

  try {
    List<CJFW_SurveyOption__c> testNewOptLists = [SELECT  Id, IsDeleted, Name, CurrencyIsoCode,  Order__c, SurveyQuestion__c, OpActiveCheck__c
    FROM CJFW_SurveyOption__c WHERE Name = :'2-2번 옵션'];
  
    delete testNewOptLists;
  }
  catch (Exception e) {
    System.debug('error message'+ e.getMessage());
  }
    TEST.stopTest();
   }
}