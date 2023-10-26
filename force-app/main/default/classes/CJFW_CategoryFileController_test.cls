/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-26-2023
 * @last modified by  : seol.kim@dkbmc.com
**/

@isTest
public class CJFW_CategoryFileController_test {
    @isTest
    static void makeData(){

        Account acc = new Account(
            Name = 'acc'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'opp',
            AccountId = acc.Id, 
            CloseDate = date.valueOf('2022-01-01'),
            StageName = 'Contract',
            Type = 'New Business'
        );
        insert opp;

    
        ContentVersion cv = new ContentVersion(
            Title = 'test',
            Category__c = '계약 참고자료',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv;


        // List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        // System.assertEquals(cvList.size(), 1);
        // system.debug('ContentVersionID : ' + cvList[0].Id);

        // ContentDocumentLink cdl = New ContentDocumentLink();
        // cdl.LinkedEntityId = opp.id;
        // cdl.ContentDocumentId = cvList[0].ContentDocumentId;
        // insert cdl;  
        // System.assertEquals(cdl.ContentDocumentId,cvList[0].ContentDocumentId);

        // test.startTest();
        // Map<ID, String>  mapContentVersion = CJFW_CategoryFileController.getFileList('계약 참고자료', opp.Id, 'Test');
        // test.stopTest();
        // system.debug('mapContentVersion : ' +mapContentVersion.values());
        // string mapTitle = mapContentVersion.values()[0];
        //  System.assertEquals(mapTitle ,'Test Document');

    }
}