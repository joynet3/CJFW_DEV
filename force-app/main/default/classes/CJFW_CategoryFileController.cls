/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
public with sharing class CJFW_CategoryFileController {
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getFileList(String category, Id recordId, String searchTerm){
        try {
            System.debug('category ==> ' + category);     
            System.debug('recordId ==> ' + recordId);     


            if(category == '파일'){
                category = null;
            }


            String contentDocumentLinkQuery = 'SELECT Id, ' +
                                                    'LinkedEntityId, ' +
                                                    'ContentDocumentId ' +
                                                'FROM ContentDocumentLink';


            String contentVersionQuery = 'SELECT Id, ' +
                                                'VersionData, ' +
                                                'FileType, ' +
                                                'Title, ' +
                                                'FileExtension, ' +
                                                'ContentDocumentId, ' +
                                                'CreatedDate, ' +
                                                'ContentSize, ' +
                                                'LastModifiedDate, ' +
                                                'CreatedBy.Name ' +
                                            'FROM ContentVersion';

            if (searchTerm != null) {
                // 검색어가 있을 때의 처리
                searchTerm = '%' + searchTerm + '%'; // 검색어 형식을 처리
                System.debug('searchTerm: ' + searchTerm);

                if (category == '계약 참고자료') {
                    contentDocumentLinkQuery += ' WHERE LinkedEntityId IN (SELECT Id FROM Opportunity) ';
                    List<ContentDocumentLink> ContentDocumentLinkList = Database.query(contentDocumentLinkQuery);
                    System.debug('쿼리실행 ==> ' + ContentDocumentLinkList);    
    
                    Set<Id> ContentDocumentIds = new Set<Id>();
                    for (ContentDocumentLink link : ContentDocumentLinkList) {
                        ContentDocumentIds.add(link.ContentDocumentId);
                        System.debug('계약참고자료 아이디 ==> ' + ContentDocumentIds);         
                    }
    
                    contentVersionQuery += ' WHERE Category__c = :category ' +
                                            ' AND ContentDocumentId IN :ContentDocumentIds ' +
                                            ' AND Title LIKE :searchTerm ' +
                                            ' ORDER BY LastModifiedDate ASC';
    
                    List<ContentVersion> ContentVersionList = Database.query(contentVersionQuery);   
                    System.debug('쿼리실행 2 ==> ' + ContentVersionList);                 
                    return ContentVersionList;
    
                }else {
                    contentDocumentLinkQuery += ' WHERE LinkedEntityId = :recordId';
                    List<ContentDocumentLink> ContentDocumentLinkList = Database.query(contentDocumentLinkQuery);
                    // ContentDocumentLink와 ContentDocument를 연결해줄 ID값 찾기
                    Set<Id> ContentDocumentIds = new Set<Id>();
                    for(ContentDocumentLink cdl : ContentDocumentLinkList){
                        ContentDocumentIds.add(cdl.ContentDocumentId); 
                    }
                    contentVersionQuery += ' WHERE Category__c = :category ' +
                                            ' AND ContentDocumentId IN :ContentDocumentIds ' +
                                            ' AND Title LIKE :searchTerm ' +
                                            ' ORDER BY LastModifiedDate ASC';
                    List<ContentVersion> ContentVersionList = Database.query(contentVersionQuery);
                    System.debug('기본 ==> ' + ContentVersionList);       
                    return ContentVersionList;
                }

            } else {
                // 검색어가 없을 때의 처리
                if (category == '계약 참고자료') {
                    contentDocumentLinkQuery += ' WHERE LinkedEntityId IN (SELECT Id FROM Opportunity) ';
                    List<ContentDocumentLink> ContentDocumentLinkList = Database.query(contentDocumentLinkQuery);
                    System.debug('쿼리실행 ==> ' + ContentDocumentLinkList);    
    
                    Set<Id> ContentDocumentIds = new Set<Id>();
                    for (ContentDocumentLink link : ContentDocumentLinkList) {
                        ContentDocumentIds.add(link.ContentDocumentId);
                        System.debug('계약참고자료 아이디 ==> ' + ContentDocumentIds);         
                    }
    
                    contentVersionQuery += ' WHERE Category__c = :category ' +
                                            ' AND ContentDocumentId IN :ContentDocumentIds ' +
                                            ' ORDER BY LastModifiedDate ASC';
    
                    List<ContentVersion> ContentVersionList = Database.query(contentVersionQuery);   
                    System.debug('쿼리실행 2 ==> ' + ContentVersionList);                 
                    return ContentVersionList;
    
                }else {
                    contentDocumentLinkQuery += ' WHERE LinkedEntityId = :recordId';
                    List<ContentDocumentLink> ContentDocumentLinkList = Database.query(contentDocumentLinkQuery);
                    // ContentDocumentLink와 ContentDocument를 연결해줄 ID값 찾기
                    Set<Id> ContentDocumentIds = new Set<Id>();
                    for(ContentDocumentLink cdl : ContentDocumentLinkList){
                        ContentDocumentIds.add(cdl.ContentDocumentId); 
                    }
                    contentVersionQuery += ' WHERE Category__c = :category ' +
                                            ' AND ContentDocumentId IN :ContentDocumentIds ' +
                                            ' ORDER BY LastModifiedDate ASC';
                    List<ContentVersion> ContentVersionList = Database.query(contentVersionQuery);
                    System.debug('기본 ==> ' + ContentVersionList);       
                    return ContentVersionList;

                
            }

            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void updateContentVersion(String uploadedFiles , String category){
        try {
            Map<String, Object> valuesMap = new Map<String, Object>();

            if(category == '파일'){
                category = null;
            }
            
            List<ContentVersion> contentVersionsToUpdate = new List<ContentVersion>();
            for(Object obj : (List<Object>)JSON.deserializeUntyped(uploadedFiles)){

                // 값을 Map으로 변환
                Map<String, Object> data = (Map<String, Object>)obj;
                String cvId = (String) data.get('contentVersionId');
                System.debug(cvId);
    
                // 등록한 파일 카테고리별로 업데이트 하기
                ContentVersion cvRecord = new ContentVersion();
                cvRecord.Category__c = category; 
                cvRecord.Id = cvId;
                contentVersionsToUpdate.add(cvRecord);
                System.debug(cvRecord);
            }
            update contentVersionsToUpdate;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){ 
        delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];    
        System.debug('test' + [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId]);   
    }  


}