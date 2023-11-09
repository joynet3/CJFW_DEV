/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : seol.kim@dkbmc.com
**/

@isTest
public class CJFW_CategoryFileController_test {
    @TestSetup
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
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            Category__c = '표준계약서',
            IsMajorVersion = true
        );
        insert cv;
            
        }
    @isTest
    public static void test() {
     
        // 테스트 데이터 생성
        String category = '표준계약서';
        String otherCategory = '파일';
        Id recordId = [SELECT Id FROM Opportunity Limit 1].Id; 
        String searchTerm = 'SearchTerm1';
        String searchNull = null;
        String cdId = [SELECT Id FROM ContentDocument LIMIT 1].Id;    

        // 업데이트할 ContentVersion 레코드 데이터 설정
        List<Map<String, Object>> uploadedFiles = new List<Map<String, Object>>();
        Map<String, Object> data = new Map<String, Object>();
        
        // @TestSetup 메서드에서 생성한 데이터를 가져옴
        ContentVersion cv = [SELECT Id, Category__c FROM ContentVersion LIMIT 1];
        
        data.put('contentVersionId', cv.Id);
        // data.put('category', cv.Category__c);
        
        uploadedFiles.add(data);
        String uploadedFilesJson = JSON.serialize(uploadedFiles);

        Test.startTest();     

        CJFW_CategoryFileController.getFileList(category, recordId, searchTerm);
        CJFW_CategoryFileController.getFileList(category, recordId, searchNull);
        CJFW_CategoryFileController.getFileList(otherCategory, recordId, searchTerm);
        CJFW_CategoryFileController.getFileList(otherCategory, recordId, searchNull);

        CJFW_CategoryFileController.deleteFile(cdId);

        CJFW_CategoryFileController.updateContentVersion(uploadedFilesJson, category);



        Test.stopTest();

    
    }
}