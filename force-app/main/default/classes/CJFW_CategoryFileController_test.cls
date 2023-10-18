/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-16-2023
 * @last modified by  : seol.kim@dkbmc.com
**/

@isTest
public class CJFW_CategoryFileController_test {
    @isTest
    static void makeData(){
        Opportunity opp = new Opportunity(); 
        opp.Name = '테스트';
        opp.StageName = 'Contract';
        insert opp;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument];

        //create ContentDocumentLink  record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = opp.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        Test.startTest();
        CJFW_CategoryFileController.getFileList('계약 참고자료', opp.Id);
        Test.stopTest();


    }
    

    

    // static void makeData(){
    //     Opportunity opp = new Opportunity();
    //     opp.Name = 'test';
    //     insert opp;

    //     ContentDocumentLink cdList = new ContentDocumentLink();
    //     cdList.LinkedEntityId = opp.Id;
    //     insert cdList;

    //     Test.startTest();
    //     CJFW_CategoryFileController.getFileList('계약 참고자료', opp.Id);
    //     Test.stopTest();

        
    // }

}