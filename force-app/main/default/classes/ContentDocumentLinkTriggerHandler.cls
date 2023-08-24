/**
* ContentDocumentLinkTriggerHandler
*
*@group  Notificatoin
*@author 조형준
*@since 2023-08-14  최초작성
*/
public without sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler{
    @testVisible private List<ContentDocumentLink> news; 
    @testVisible private List<ContentDocumentLink> olds; 
    @testVisible private Map<Id, ContentDocumentLink> oldMap; 
    @testVisible private Map<Id, ContentDocumentLink> newMap;
    @testVisible private static Map<String, Schema.RecordTypeInfo> recordTypeMap;

    
    public ContentDocumentLinkTriggerHandler() {
        news = (List<ContentDocumentLink>) Trigger.new;
        olds = (List<ContentDocumentLink>) Trigger.old;
        newMap  = (Map<Id,ContentDocumentLink>) Trigger.newMap;
        oldMap  = (Map<Id,ContentDocumentLink>) Trigger.oldMap;
    }

    public override void beforeInsert() {        
    }

    public override void afterInsert() {        
        createContentDistribution(news);
    }

    /**
    * 솔루션, 파트너사 등 커뮤니티 관련 오브젝트에 파일 업로드 시 ContentDistribution 레코드 생성
    *
    *@param  news 신규 생성 레코드
    *@return  
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    private void createContentDistribution(List<ContentDocumentLink> news){
        Set<String> setCommunityObjects = new Set<String>{'Solution__c', 'PartnerCompany__c', 'Brochure__c', 'CommunityBoard__c'};
        Set<String> setContentDocumentId = new Set<String>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        Map<String, ContentVersion> contentVersionMap = new Map<String, ContentVersion>();

        for(ContentDocumentLink obj : news){
            setContentDocumentId.add(obj.ContentDocumentId);
        }

        contentVersions = [SELECT Id
                                    ,ContentDocumentId
                                    ,PathOnClient
                            FROM ContentVersion
                            WHERE ContentDocumentId IN :setContentDocumentId
                            ];

        for(ContentVersion obj : contentVersions){
            contentVersionMap.put(obj.ContentDocumentId, obj);
        }

        for(ContentDocumentLink obj : news){

            if(setCommunityObjects.contains(obj.LinkedEntityId.getSObjectType().getDescribe().getName())){

                ContentDistribution cd = new ContentDistribution();
                cd.Name = contentVersionMap.get(obj.ContentDocumentId).PathOnClient;
                cd.ContentVersionId = contentVersionMap.get(obj.ContentDocumentId).Id;
                cd.RelatedRecordId = obj.LinkedEntityId;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;

                contentDistributions.add(cd);
            }
        }

        Insert contentDistributions;
    }
}