/************************************************************************************
 * File Name   		    : ContentDocument_tr_test.cls
 * Author	  		    : sy.lee
 * Date				    : 2023.04.18
 * Target	  		    : ContentDocument_tr.cls
 * Description 		    : ContentDocument_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.04.18      sy.lee          Create
 *************************************************************************************/

 @IsTest
 public with sharing class ContentDocument_tr_test {
     @isTest 
     static void itShould() {
        Test.startTest();
        Id ownerIdInfo = UserInfo.getUserId();  

        OilTypeChange__c obj1 = new OilTypeChange__c();
        obj1.oil_type_cd__c = '1';
        obj1.OwnerId = ownerIdInfo;
        obj1.ApprovalStatus__c = '작성중';        
        insert obj1;
 
        ContentVersion objContentVersion = new Contentversion();
        objContentVersion.Title = 'test';
        objContentVersion.PathOnClient = 'test.txt';
        objContentVersion.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert objContentVersion;

        objContentVersion = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:objContentVersion.Id
        ];
        Id objConDocId = objContentVersion.ContentDocumentId;

        ContentDocumentLink conDcLink = new ContentDocumentLink();
        conDcLink.LinkedEntityId = obj1.Id;
        conDcLink.ContentDocumentId = objConDocId;

        insert conDcLink;
        obj1.OwnerId = ownerIdInfo;
        obj1.ApprovalStatus__c = '승인요청';

        update obj1;

        ContentDocument delTarget = [SELECT Id FROM ContentDocument WHERE Id =:objConDocId];

        delete delTarget;
         
        Test.stopTest();
     }
 }