/**
 * @description       : 카테고리별로 파일 등록이 가능한 controller
 * @author            : seol.kim@dkbmc.com
 * @since 08-25-2023  내용 작성
 * @group             : 
 * @last modified on  : 08-25-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
public with sharing class CategoryFileUploadContorller {

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getFileList(String ContentDocumentId, String category, Id recordId){
        try {
            List<ContentDocumentLink> ContentDocumentLinkList = [
                SELECT Id, 
                        LinkedEntityId, 
                        ContentDocumentId                    
                FROM ContentDocumentLink                  
                WHERE LinkedEntityId =: recordId
            ];
            
            // ContentDocumentLink와 ContentDocument를 연결해줄 ID값 찾기
            Set<Id> ContentDocumentIds = new Set<Id>();
            for(ContentDocumentLink cdl : ContentDocumentLinkList){
                ContentDocumentIds.add(cdl.ContentDocumentId); 
            }
    
            List<ContentDocument> ContentDocumentList = [
                SELECT Id
                FROM ContentDocument 
                WHERE id =: ContentDocumentIds
            ];
            // ContentDocument와 ContentVersion를 연결해줄 ID값 찾기
            Set<Id> documentId = new Set<Id>();
            for(ContentDocument cd : ContentDocumentList){
                documentId.add(cd.Id);
            }
    
            return  [SELECT Id, 
                            Title, 
                            Category__c,
                            FileType,
                            CreatedDate,
                            ContentDocumentId 
                    FROM ContentVersion
                    WHERE Category__c =: category 
                    AND ContentDocumentId IN: documentId
                    ];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void updateContentVersion(String uploadedFiles , String category){
        try {
            Map<String, Object> valuesMap = new Map<String, Object>();
            
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
}