/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-16-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
@isTest
public with sharing class CJFW_Survey_tr_TEST {
  // 옵션을 담기 위한 map 
  static Map<String, Id> optionIdMap = new Map<String, Id>();
    
  // 응답을 담기 위한 map 
  static Map<String, Id> responMap = new Map<String, Id>(); 

  @TestSetup
  static void makeData(){
   List<CJFW_Survey__c> surveyList = new List<CJFW_Survey__c>(); // CJFW_Survey__c 담는 리스트 
   List<CJFW_SurveyQuestion__c> surveyQueList = new List<CJFW_SurveyQuestion__c>(); // Qustion 담는 리스트 
   List<CJFW_SurveyOption__c> surveyOptList = new List<CJFW_SurveyOption__c>(); // Option 담는 리스트 
   List<CJFW_SurveyResponse__c> surveyResList = new List<CJFW_SurveyResponse__c>(); // Response담는 리스트 

   List<CJFW_SurveyResult__c> surveyResultList = new List<CJFW_SurveyResult__c>(); // Response담는 리스트 


   CJFW_Survey__c newSurvey = new CJFW_Survey__c(
    Name = '테스트 설문',
    Su__c = '4100',
    HeadOffice__c ='3001',
    Version__c = 1
    );
    insert newSurvey;
    

   CJFW_Survey__c secSurvey = new CJFW_Survey__c(
    Name = '설문 테스트',
    Su__c = '4700',
    HeadOffice__c ='3001',
    Version__c = 1
    );
    insert secSurvey;
    CJFW_Survey__c nullSurvey = new CJFW_Survey__c(
        Name = '비어있는 설문지',
        Version__c = 1
        );
        insert nullSurvey;
   surveyList.add(newSurvey);
   surveyList.add(secSurvey);
   surveyList.add(nullSurvey);
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

   CJFW_SurveyResponse__c respon = new CJFW_SurveyResponse__c(
      
      Survey__c = newSurvey.Id
   );
   surveyResList.add(respon);
   insert surveyResList;

 
  }
  

   @isTest
   static void doClone_TEST(){ 
    Test.startTest();
    Set<Id> surveyIdSet = new Set<Id>();
    Set<Id> surveyQueIdSet = new Set<Id>();
    Map<String, CJFW_Survey__c> surveyMap = new Map<String, CJFW_Survey__c>();
        
    List<CJFW_Survey__c> testLists = [SELECT Id,Name,Su__c,HeadOffice__c,Active__c,Version__c,ParentSurvey__c
    FROM CJFW_Survey__c WHERE Name = :'테스트 설문'];
    
    List<CJFW_Survey__c> tesAlltLists = [SELECT Id,Name,Su__c,HeadOffice__c,Active__c,Version__c,ParentSurvey__c
    FROM CJFW_Survey__c ];
    
    for (CJFW_Survey__c testList : testLists) {
        surveyIdSet.add(testList.Id);
    }
    System.debug('tesAlltLists'+ tesAlltLists);
    List<CJFW_SurveyQuestion__c> testQueLists = [SELECT Id,
    Name,
    Name__c,
    Survey__c,
    Type__c,
    MultipleChoice__c,
    Order__c,
    DateType__c,
    TextType__c
     FROM CJFW_SurveyQuestion__c WHERE Survey__c = :surveyIdSet];
     for (CJFW_SurveyQuestion__c testQueList : testQueLists) {
        surveyQueIdSet.add(testQueList.Id);
     }
     List<CJFW_SurveyOption__c> testOptLists = [SELECT  Id,
     Name,
     CurrencyIsoCode,
     CreatedDate,
     CreatedById,
     Order__c,
     SurveyQuestion__c
      FROM CJFW_SurveyOption__c WHERE SurveyQuestion__c = :surveyQueIdSet];
  
     CJFW_Survey__c tmpSurveys = testLists[0].clone();
     CJFW_SurveyQuestion__c tmpQueSurveys = testQueLists[0].clone();
     CJFW_SurveyOption__c tmpOptSurveys = testOptLists[0].clone();
     CJFW_Survey__c tmpOldSurveys = testLists[0];
     
     if (tmpSurveys.isclone()) {
        tmpSurveys.Active__c = true;
        tmpSurveys.Version__c +=1;
     }
     insert tmpSurveys;

     List<CJFW_Survey__c> testSuLists = [SELECT Id,Name,Su__c,HeadOffice__c,Active__c,Version__c,ParentSurvey__c
     FROM CJFW_Survey__c WHERE Su__c !=null and Active__c =true ];

     for (CJFW_Survey__c testSuList : testSuLists) {
        surveyMap.put(testSuList.su__c,testSuList); 
     }

  
     try {
        List<CJFW_Survey__c> nullLists = [SELECT Id,Name,Su__c,HeadOffice__c,Active__c,Version__c,ParentSurvey__c
        FROM CJFW_Survey__c WHERE Name = :'비어있는 설문지'];
        nullLists[0].Active__c = true;
        CJFW_Survey__c nullSurveys = nullLists[0].clone();
   
        insert nullSurveys;
        if (nullSurveys.isClone()) {
            nullSurveys.Active__c = true;
            nullSurveys.HeadOffice__c = '3001';
            nullSurveys.su__c = '4700';
         }
         update nullSurveys;
     }
     catch (Exception e) {
        System.debug('error Message ?? '+ e.getMessage());
     }
   

 

    CJFW_Survey_tr surveyTRLists = new CJFW_Survey_tr() ;
    surveyTRLists.listNew = new List<CJFW_Survey__c>{tmpSurveys};
    surveyTRLists.listOld = new List<CJFW_Survey__c>{tmpOldSurveys};

    surveyTRLists.doClone();
    // surveyTRLists.doCloneInsert();

 
    Test.stopTest();
  

   
 
   }



}