/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
@isTest
public with sharing class CJFW_SurveyPreviewController_test {
    
    
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
         Name = '테스트 설문'
     );
     surveyList.add(newSurvey);
     insert surveyList; 
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

    //  주관식
     CJFW_SurveyResult__c  result1 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = oneQuest.Id,
        OpenEnded__c = '테스트'
    );
    surveyResultList.add(result1); 

    // 객관식 단수
    CJFW_SurveyResult__c  result2 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = twoQuest.Id,
        SurveyOption__c = oneOption_TWQ.Id
    );
    surveyResultList.add(result2); 
    
    // 객관식 복수 
    CJFW_SurveyResult__c  result3_1 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = threeQuest.Id,
        SurveyOption__c = oneOption_THQ.Id
    );
    surveyResultList.add(result3_1); 
   
    CJFW_SurveyResult__c  result3_2 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = threeQuest.Id,
        SurveyOption__c = twoOption_THQ.Id
    );
    surveyResultList.add(result3_2); 
   
    CJFW_SurveyResult__c  result3_3 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = threeQuest.Id,
        SurveyOption__c = thrOption_THQ.Id
    );
    surveyResultList.add(result3_3); 
   
    CJFW_SurveyResult__c  result3_4 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = threeQuest.Id,
        SurveyOption__c = forOption_THQ.Id
    );
    surveyResultList.add(result3_4); 

    CJFW_SurveyResult__c  result4_1 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = fourQuest.Id,
        DateResult__c = Date.valueOf('2023-10-23')
    );
    surveyResultList.add(result4_1); 

    CJFW_SurveyResult__c  result4_2 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = fourQuest.Id,
        DateResult__c = Date.valueOf('2023-10-24')
    );
    surveyResultList.add(result4_2); 

    CJFW_SurveyResult__c  result5_1 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = fiveQuest.Id,
        TimeResult__c = Time.newInstance(23, 0, 0, 0)
    );
    surveyResultList.add(result5_1); 
    
    CJFW_SurveyResult__c  result5_2 = new CJFW_SurveyResult__c (
        SurveyResponse__c =respon.Id,
        SurveyQuestion__c = fiveQuest.Id,
        TimeResult__c = Time.newInstance(1, 0, 0, 0) 
    );
    surveyResultList.add(result5_2); 
     
    insert surveyResultList;
 
    }

    @isTest
   static void getSurveyReulteTest(){
    
    Test.startTest();
    // SurveyId를 사용하여 CJFW_SurveyPreviewController 인스턴스를 생성
    CJFW_Survey__c testSurvey = [SELECT Id,Name
    FROM CJFW_Survey__c WHERE Name ='테스트 설문' LIMIT 1];
    System.assertNotEquals(null, testSurvey, 'Survey 레코드를 찾을 수 없습니다.');
    
    // SurveyResponseId와 SurveyId를 가져오기
    CJFW_SurveyResponse__c testRespon = [SELECT Id,Survey__c
    FROM CJFW_SurveyResponse__c WHERE Survey__c =: testSurvey.Id];
    System.assertNotEquals(null, testRespon, 'SurveyResponse 레코드를 찾을 수 없습니다.');

    // CJFW_SurveyResult__c testResult = [SELECT Id, Name,SurveyResponse__c, SurveyQuestion__c, SurveyOption__c, OpenEnded__c, DateResult__c,	SurveyOption__r.name, TimeResult__c
    // FROM CJFW_SurveyResult__c WHERE SurveyResponse__c =: testRespon.Id];
  
    List<CJFW_SurveyPreviewController.SurveyQuestionResponse> result = CJFW_SurveyPreviewController.getSurveyReulte(testRespon.Id);


    Test.stopTest();
   }
}