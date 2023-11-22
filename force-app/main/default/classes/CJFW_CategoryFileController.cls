/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-17-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
public with sharing class CJFW_CategoryFileController {
    @AuraEnabled
    public static List<ContentVersion> getFileList(String category, Id recordId, String searchTerm){
        try {
            System.debug('category ==> ' + category);     
            System.debug('recordId ==> ' + recordId);     

            String categoryName = Label.CJFW_ETC_CategoryName;
            System.debug('categoryName ==> ' + categoryName); 

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
                System.debug('검색어 있을때 : ' + searchTerm);

                if (category == categoryName) {
                    contentDocumentLinkQuery += ' WHERE LinkedEntityId IN (SELECT CollaborationGroupId FROM CollaborationGroupMember) ';
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
                                            ' ORDER BY Title  ASC';
    
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
                                            ' ORDER BY Title  ASC';
                    List<ContentVersion> ContentVersionList = Database.query(contentVersionQuery);
                    System.debug('ContentVersionList ==> ' + ContentVersionList);       
                    System.debug('ContentVersionList size ==> ' + ContentVersionList.size());       
                    return ContentVersionList;
                }

            } else {
                // 검색어가 없을 때의 처리
                if (category == categoryName) {
                    contentDocumentLinkQuery += ' WHERE LinkedEntityId IN ( SELECT CollaborationGroupId FROM CollaborationGroupMember) ';

                    List<ContentDocumentLink> ContentDocumentLinkList = Database.query(contentDocumentLinkQuery);
                    System.debug('쿼리실행 ==> ' + ContentDocumentLinkList);    
    
                    Set<Id> ContentDocumentIds = new Set<Id>();
                    for (ContentDocumentLink link : ContentDocumentLinkList) {
                        ContentDocumentIds.add(link.ContentDocumentId);
                        System.debug('계약참고자료 아이디 ==> ' + ContentDocumentIds);         
                    }
    
                    contentVersionQuery += ' WHERE Category__c = :category ' +
                                            ' AND ContentDocumentId IN :ContentDocumentIds ' +
                                            ' ORDER BY Title  ASC';
    
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
                                            ' ORDER BY Title  ASC';
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

            System.debug('에러 메시지: ' + e.getMessage());
           System.debug('에러 라인: ' + e.getStackTraceString());
        }
    }

    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){ 
        delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];    
        System.debug('test' + [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId]);   
    }  

    @AuraEnabled(cacheable=true)
    public static Boolean isUserMemberOfCollaborationGroup(String groupId, String category, String objectName) {
        String categoryName = Label.CJFW_ETC_CategoryName;
        System.debug('categoryName ==> ' + categoryName); 
        
        String userId = UserInfo.getUserId();
        System.debug('userId ==>' + userId);
        System.debug('category ==>' + category);
        System.debug('groupId ==>' + groupId);
        System.debug('objectName ==>' + objectName);

      
  
        if (category == categoryName && objectName == 'CollaborationGroup') {
            CollaborationGroupMember[] members = [SELECT Id FROM CollaborationGroupMember
                                                    WHERE CollaborationGroupId = :groupId
                                                    AND MemberId  =: userId
                                                    AND (CollaborationRole = 'Admin'
                                                    OR CollaborationRole = 'Standard')];
            return !members.isEmpty();
        } else if (category != categoryName) {
            return true; // category와 categoryName이 같지 않을 때 true 반환
        } else {
            return false; // 기본 조건에 맞지 않으면 false 반환
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getObjectLabel(String objectApiName) {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        return describeResult.getLabel();
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordName(String recordId, String objectApiName) {
        String recordName;
        try {
            SObject obj = Database.query('SELECT Name FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1');
            if (obj != null) {
                recordName = (String)obj.get('Name');
            }
        } catch (Exception e) {

        }
        return recordName;
    }


}