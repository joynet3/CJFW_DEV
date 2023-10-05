/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : seol.kim@dkbmc.com
**/

@isTest
public class CJFW_CategoryFileController_test {
    @isTest
    static void testGetFileListForCategory() {
        // 테스트에 필요한 데이터 생성
        ContentVersion cv1 = new ContentVersion(
            VersionData = Blob.valueOf('Test File 1'),
            // FileType = 'PNG',
            Title = 'Test File 1',
            // FileExtension = 'png',
            ContentDocumentId = '0690w000002v7lFAAQ', // ContentDocumentId를 적절한 값으로 설정
            Category__c = '계약 참고자료'
        );
        insert cv1;
        
        ContentVersion cv2 = new ContentVersion(
            VersionData = Blob.valueOf('Test File 2'),
            // FileType = 'jpg',
            Title = 'Test File 2',
            // FileExtension = 'jpg',
            ContentDocumentId = '0690w000002v7hXAAQ', // ContentDocumentId를 적절한 값으로 설정
            Category__c = '파일' // 테스트를 위해 다른 카테고리로 설정
        );
        insert cv2;

        Id recordId = '0680w000002gMjTAAU'; // LinkedEntityId를 적절한 값으로 설정

        // 테스트 메서드 호출
        Test.startTest();
        List<ContentVersion> result = CJFW_CategoryFileController.getFileList('계약 참고자료', recordId);
        Test.stopTest();

        // 결과 검증
        System.assertEquals(1, result.size());
        System.assertEquals('Test File 1', result[0].Title);
        // System.assertEquals('pdf', result[0].FileType);
        // 필요한 다른 필드도 검증할 수 있습니다.
    }

}