/************************************************************************************
 * File Name   		    : OilTypeChange_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.06
 * Target	  		    : OilTypeChange_tr.cls
 * Description 		    : OilTypeChange_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.06      Minje.kim       Create
 * 1.1      2023.04.07      sy.lee          update
 *************************************************************************************/

@IsTest
public with sharing class OilTypeChange_tr_test {
    @isTest 
    static void itShould() {
        Test.startTest();
        
        OilTypeChange__c objOilTypeChange = new OilTypeChange__c();
        objOilTypeChange.oil_type_cd__c = '1';
        insert objOilTypeChange;

        String strOilTypeChangeId = objOilTypeChange.Id;
        objOilTypeChange = new OilTypeChange__c();
        objOilTypeChange.Id = strOilTypeChangeId;
        objOilTypeChange.oil_type_cd__c = '2';
        update objOilTypeChange;
        Test.stopTest();
    }
    @isTest 
    static void itShould2() {
        Test.startTest();
        Id ownerIdInfo = UserInfo.getUserId();      
        
        OilTypeChange__c obj0 = new OilTypeChange__c();
        obj0.oil_type_cd__c = '1';
        obj0.ApprovalStatus__c = '작성중';    
        obj0.OwnerId = ownerIdInfo;
        insert obj0;

        obj0.OwnerId = ownerIdInfo;
        obj0.ApprovalStatus__c = '승인요청';

        update obj0; //파일없이 업로드 하기 때문에 실패하게됨
        
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

        obj1.OwnerId = ownerIdInfo;      
        obj1.StartDate__c = Date.today();
        obj1.ApprovalStatus__c = '승인';

        update obj1;

        OilTypeChange__c obj2 = new OilTypeChange__c();
        obj2.oil_type_cd__c = '2';
        obj2.ApprovalStatus__c = '작성중';  
        obj2.OwnerId = ownerIdInfo;      
        insert obj2;

        ContentDocumentLink conDcLink2 = new ContentDocumentLink();
        conDcLink2.LinkedEntityId = obj2.Id;
        conDcLink2.ContentDocumentId = objConDocId;

        insert conDcLink2;

        obj2.OwnerId = ownerIdInfo;
        obj2.ApprovalStatus__c = '승인요청';

        update obj2;    

        obj2.OwnerId = ownerIdInfo;      
        obj2.StartDate__c = Date.today();
        obj2.ApprovalStatus__c = '승인';
        update obj2;
        ContentDocument delTarget = [SELECT Id FROM ContentDocument WHERE Id =:objConDocId];

        delete delTarget;
        
        Test.stopTest();
    }
}