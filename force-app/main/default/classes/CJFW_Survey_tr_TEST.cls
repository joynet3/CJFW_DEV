/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-10-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
@isTest
public with sharing class CJFW_Survey_tr_TEST {
 
    @TestSetup
    static void makeData(){

    }
   

   @isTest
   static void doClone_TEST(){ 
       Test.startTest();
       CJFW_Survey__c newSurvey = new CJFW_Survey__c(
           Name = '테스트 설문',
           Su__c = '4100',
           HeadOffice__c ='3001',
           Version__c = 1
           );
           insert newSurvey;
           
    List<CJFW_Survey__c> testLists = [SELECT Id,Name,Su__c,HeadOffice__c,Active__c,Version__c,ParentSurvey__c
     FROM CJFW_Survey__c WHERE id = :newSurvey.id];


     CJFW_Survey__c tmpSurvey = testLists[0].clone();
     if (testLists[0].isclone()) {
        testLists[0].Version__c +=1;
     }
     System.debug(tmpSurvey.isClone());
     System.debug(tmpSurvey.getCloneSourceId());

    CJFW_Survey_tr surveyTRLists = new CJFW_Survey_tr() ;
    surveyTRLists.listNew = new List<CJFW_Survey__c>{tmpSurvey};

    surveyTRLists.doClone();
           
    Test.stopTest();
    //        
    // Set<Id> testIdSet = new Set<Id>();
    // Map<Id, CJFW_Survey__c> testMap = new Map<Id, CJFW_Survey__c>();
    // for (CJFW_Survey__c testList : testLists) {
    //     testIdSet.add(testList.Id);
    // }

    // List<CJFW_Survey__c> testSurveyLists =[SELECT Id,Name,Su__c,HeadOffice__c,Active__c,Version__c
    // FROM CJFW_Survey__c WHERE Id IN: testIdSet];

    // for (CJFW_Survey__c testSurveyList : testSurveyLists) {
    //     testMap.put(testSurveyList.Id,testSurveyList);
    //     CJFW_Survey__c second = testSurveyList.clone();
    // }

   
 
   }



}