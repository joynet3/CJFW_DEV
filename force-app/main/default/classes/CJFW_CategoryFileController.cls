/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 09-26-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
public with sharing class CJFW_CategoryFileController {
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getFileList(String category, Id recordId){
        try {
            //category가 "계약 참고자료"일 때 파일을 가져오기
            if (category == '계약 참고자료') {
                List<ContentVersion> cvList =  [SELECT Id, 
                                                        VersionData, 
                                                        FileType, 
                                                        Title, 
                                                        FileExtension,
                                                        ContentDocumentId, 
                                                        CreatedDate,
                                                        ContentSize, 
                                                        LastModifiedDate,
                                                        CreatedBy.Name
                                                FROM ContentVersion
                                                WHERE Category__c =: category
                                                ORDER BY LastModifiedDate ASC
                                                ];
                System.debug('조건: ' + cvList);
                return cvList;  

            } else {
                List<ContentDocumentLink> ContentDocumentLinkList = [SELECT Id, 
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

                List<ContentVersion> cvList =  [SELECT Id, 
                                                        VersionData, 
                                                        FileType, 
                                                        Title, 
                                                        FileExtension,
                                                        ContentDocumentId, 
                                                        CreatedDate,
                                                        ContentSize, 
                                                        LastModifiedDate,
                                                        CreatedBy.Name
                                                FROM ContentVersion
                                                WHERE Category__c =: category
                                                AND ContentDocumentId IN: ContentDocumentIds
                                                ORDER BY LastModifiedDate ASC
                                                ];
                System.debug('기본: ' + cvList);
    
                return cvList;           
                
            }

            
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

    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){ 
        delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];    
        System.debug('test' + [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId]);   
    }  

}