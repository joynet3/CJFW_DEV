/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-22-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_SuretyEmailActionController {
    @AuraEnabled
    public static Map<String,Object> getAttachments(String recordId){
        Map<String,Object> resultMap = new Map<String,Object>();

        String categoryName = System.Label.CJFW_ETC_CategoryName_002;
        List<ContentDocumentLink> cdlinkList = [SELECT 
                                                    Id
                                                    , ContentDocumentId
                                                    , ContentDocument.LatestPublishedVersion.Category__c
                                                    , ContentDocument.LatestPublishedVersion.Title
                                                    , ContentDocument.LatestPublishedVersionId
                                                    , LinkedEntityId
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:recordId 
                                                    AND ContentDocument.LatestPublishedVersion.Category__c = :categoryName
        ];

        Set<String> cvIdSet = new Set<String>();
        List<ContentDistribution> cdbList = new List<ContentDistribution>();
        for (ContentDocumentLink link : cdlinkList) {   
            cvIdSet.add(link.ContentDocument.LatestPublishedVersionId);

            ContentDistribution cdb = new ContentDistribution (
                ContentVersionId = link.ContentDocument.LatestPublishedVersionId,
                Name = link.ContentDocument.LatestPublishedVersion.Title,
                PreferencesAllowViewInBrowser = true,
                PreferencesLinkLatestVersion =true
            );
            cdbList.add(cdb);
        }

        insert cdbList;
        Set<String> cdbIdSet = new Set<String>();
        for (ContentDistribution cdb : cdbList) {
            cdbIdSet.add(cdb.Id);
        }
        cdbList = [SELECT Id, ContentVersionId , ContentVersion.Title, ContentVersion.FileExtension, ContentVersion.PathOnClient, ContentDownloadUrl FROM ContentDistribution WHERE Id IN :cdbIdSet];
        resultMap.put('cdbList', cdbList);
        return resultMap;
    }
}