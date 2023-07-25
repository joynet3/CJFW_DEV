/************************************************************************************
 * File Name   		    : Event_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : Event_tr.cls
 * Description 		    : Event_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

 @IsTest
 public with sharing class Event_tr_test {
 
     @isTest 
     static void itShould() {
         Test.startTest();
         Account objExAccount = TestObjectCreator.objExAccount;
         insert objExAccount;
         Opportunity objOpportunity = new Opportunity();
         objOpportunity.AccountId = objExAccount.Id;
         objOpportunity.Name = '영업활동';
         objOpportunity.CloseDate = date.valueOf('2022-01-01');
         objOpportunity.StageName = 'Proposal';
         insert objOpportunity;
 
         FieldBriefing__c objFieldBriefing = new FieldBriefing__c();
         objFieldBriefing.Opportunity__c = objOpportunity.Id;
         objFieldBriefing.name = 'test';
         objFieldBriefing.SalesStage__c = '현장실사 및 시설파악';
         objFieldBriefing.WorkType__c = '외근';
         objFieldBriefing.StartDateTime__c = datetime.valueOf('2022-01-01 15:00:00.000Z');
         objFieldBriefing.EndDateTime__c = datetime.valueOf('2022-01-02 15:00:00.000Z');
         insert objFieldBriefing;
 
         Event objEvent1 = new Event();
         objEvent1.StartDateTime = Datetime.valueOf('2022-01-01 09:00:00');
         objEvent1.DurationInMinutes = 2;
         objEvent1.VehicleRefuelingCosts__c = 2000;
         objEvent1.Opportunity__c = objOpportunity.Id;
         objEvent1.isMig__c = false;
         insert objEvent1;
 
         Event objEvent2 = new Event();
         objEvent2.StartDateTime = Datetime.valueOf('2022-01-01 09:00:00');
         objEvent2.WhatId = objExAccount.Id;
         objEvent2.DurationInMinutes = 2;
         objEvent2.VehicleRefuelingCosts__c = 2000;
         insert objEvent2;
 
         Event objEvent4 = new Event();
         objEvent4.StartDateTime = Datetime.valueOf('2022-01-01 09:00:00');
         objEvent4.WhatId = objOpportunity.Id;
         objEvent4.DurationInMinutes = 2;
         objEvent4.VehicleRefuelingCosts__c = 2000;
         insert objEvent4;
 
         //linkedRecordId 있음
         Event objEvent5 = new Event();
         objEvent5.StartDateTime = Datetime.valueOf('2022-01-01 09:00:00');
         objEvent5.WhatId = objOpportunity.Id;
         objEvent5.DurationInMinutes = 2;
         objEvent5.VehicleRefuelingCosts__c = 2000;
         objEvent5.LinkedRecordId__c = objFieldBriefing.Id;
         insert objEvent5;
         delete objEvent5;       
 
         Event objEvent = new Event();
         objEvent.Id = objEvent1.Id;
         objEvent.VehicleRefuelingCosts__c = 3000;
         objEvent.WhatId = objOpportunity.Id;
         update objEvent;
 
         // objEvent = new Event();
         // objEvent.Id = objEvent2.Id;
         // objEvent.WhatId = objOpportunity.Id;
         // delete objEvent;
 
 
         Test.stopTest();
     }
     
     @isTest 
     static void itShould2() {
         Test.startTest();
 
         Account objExAccount = TestObjectCreator.objExAccount;
         insert objExAccount;
         Opportunity objOpportunity = new Opportunity();
         objOpportunity.AccountId = objExAccount.Id;
         objOpportunity.Name = '영업활동';
         objOpportunity.CloseDate = date.valueOf('2022-01-01');
         objOpportunity.StageName = 'Proposal';
         insert objOpportunity;
         
         ActivityReport__c objActivityReport = new ActivityReport__c();
         objActivityReport.OilTotalAmount__c = 1000;
         objActivityReport.ApprovalStatus__c = 'Writing';
         insert objActivityReport;
 
         Event objEvent6 = new Event();
         objEvent6.StartDateTime = Datetime.valueOf('2022-01-01 09:00:00');
         objEvent6.EndDateTime = Datetime.valueOf('2022-01-01 18:00:00');
         objEvent6.WhatId = objOpportunity.Id;
         objEvent6.DurationInMinutes = 540;
         objEvent6.VehicleRefuelingCosts__c = 2000;
         objEvent6.WorkType__c ='외근';
         objEvent6.isMig__c = false;
         insert objEvent6;
 
         objEvent6.StartDateTime = Datetime.valueOf('2022-01-02 09:00:00');
         objEvent6.EndDateTime = Datetime.valueOf('2022-01-02 18:00:00');
         objEvent6.DurationInMinutes = 540;
         objEvent6.WhatId = objOpportunity.Id;
         objEvent6.WorkType__c ='내근';
         update objEvent6;
 
         objEvent6.ActivityReport__c = objActivityReport.Id;
         objEvent6.WorkType__c ='외근';
         update objEvent6;
 
         // objEvent6.StartDateTime = Datetime.valueOf('2021-12-31 09:00:00');
         // objEvent6.EndDateTime = Datetime.valueOf('2021-12-31 10:00:00');
         // objEvent6.DurationInMinutes = 60;
         // update objEvent6;
         
         // objActivityReport.ApprovalStatus__c = 'Approved';
         // update objActivityReport;
 
         // objEvent6.StartDateTime = Datetime.valueOf('2021-12-30 09:00:00');
         // objEvent6.EndDateTime = Datetime.valueOf('2021-12-30 10:00:00');
         // objEvent6.DurationInMinutes = 60;
         // update objEvent6;
 
         // delete objEvent6;
 
         Test.stopTest();
     }
 
     @isTest 
     static void itShould3() {
         Test.startTest();
         Account objExAccount = TestObjectCreator.objExAccount;
         insert objExAccount;
         Opportunity objOpportunity = new Opportunity();
         objOpportunity.AccountId = objExAccount.Id;
         objOpportunity.Name = '영업활동ofLSY';
         objOpportunity.CloseDate = date.valueOf('2023-03-01');
         objOpportunity.StageName = 'Proposal';
         insert objOpportunity;
 
         Event objEvt1 = new Event();
         objEvt1.StartDateTime = Datetime.valueOf('2023-04-06 09:00:00');
         objEvt1.EndDateTime = Datetime.valueOf('2023-04-06 18:00:00');
         objEvt1.WhatId = objOpportunity.Id;
         objEvt1.DurationInMinutes = 540;
         objEvt1.VehicleRefuelingCosts__c = 2000;
         objEvt1.WorkType__c ='외근';
         objEvt1.isMig__c = false;
         insert objEvt1;
 
         ActivityReport__c actRept1 = new ActivityReport__c();
         actRept1.Id = objEvt1.ActivityReport__r.Id;
 
         delete objEvt1;
 
         Event objEvt2 = new Event();
         objEvt2.StartDateTime = Datetime.valueOf('2023-04-06 09:00:00');
         objEvt2.EndDateTime = Datetime.valueOf('2023-04-06 18:00:00');
         objEvt2.WhatId = objOpportunity.Id;
         objEvt2.DurationInMinutes = 540;
         objEvt2.VehicleRefuelingCosts__c = 2000;
         objEvt2.WorkType__c ='내근';
         objEvt2.isMig__c = false;
         insert objEvt2;
 
         ActivityReport__c actRept2 = new ActivityReport__c();
         actRept2.Id = objEvt2.ActivityReport__r.Id;
 
         objEvt2.StartDateTime = Datetime.valueOf('2023-04-07 09:00:00');
         objEvt2.EndDateTime = Datetime.valueOf('2023-04-07 18:00:00');
         update objEvt2;
         Test.stopTest();
     }
 
     @isTest 
     static void itShould4() {
         Test.startTest();
         Account objExAccount = TestObjectCreator.objExAccount;
         insert objExAccount;
         Opportunity objOpportunity = new Opportunity();
         objOpportunity.AccountId = objExAccount.Id;
         objOpportunity.Name = '영업활동';
         objOpportunity.CloseDate = date.valueOf('2022-01-01');
         objOpportunity.StageName = 'Proposal';
         insert objOpportunity;
 
         Event objEvent6 = new Event();
         objEvent6.StartDateTime = Datetime.valueOf('2022-01-01 09:00:00');
         objEvent6.EndDateTime = Datetime.valueOf('2022-01-01 18:00:00');
         objEvent6.WhatId = objOpportunity.Id;
         objEvent6.DurationInMinutes = 540;
         objEvent6.VehicleRefuelingCosts__c = 2000;
         objEvent6.WorkType__c ='외근';
         objEvent6.isMig__c = false;
         insert objEvent6;
 
         objEvent6.StartDateTime = Datetime.valueOf('2022-01-02 09:00:00');
         objEvent6.EndDateTime = Datetime.valueOf('2022-01-02 18:00:00');
         objEvent6.DurationInMinutes = 540;
         objEvent6.WhatId = objOpportunity.Id;
         objEvent6.WorkType__c ='내근';
         update objEvent6;
         Test.stopTest();
     }
 }