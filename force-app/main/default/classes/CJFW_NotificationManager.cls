/**
* 알림 전송 관리 Object
*
*@group  Notification
*@author 진현욱
*@since 2023-07-24  최초 작성
*/
public with sharing class CJFW_NotificationManager {
    
    private static CJFW_NotificationManager instance;

    @testVisible private Map<String, CJFW_Notification__c> notiMap;
    @testVisible private Set<String> targetIdSet;
    @testVisible private List<sObject> targetObjectList;

    /* Data 형식
        {
            'Id': [User]
            ,'Email':[User]
        }
    */
    @testVisible private Map<String,List<User>> recipientListMap;

    private CJFW_NotificationManager() {
        notiMap = new Map<String, CJFW_Notification__c>();

        for(CJFW_Notification__c noti : [
            select 
                ClassName__c
                , IsDynamic__c
                , Key__c
                , Description__c
                , CustomNotificationTypeId__c
                , PageReference__c
                , sObject__c
                , TargetFields__c
                , IsSendToSender__c
                ,(   select 
                        Title__c
                        , Message__c
                        , Language__c
                        , EmailDeveloperName__c
                        , RecordType.DeveloperName 
                    from Notification_Template__r
                )
                ,(   select 
                        GroupId__c
                        , GroupName__c
                        , RoleId__c
                        , RoleName__c
                        , User__c
                        , RecordType.DeveloperName 
                    from Notification_Target__r
                )
            from CJFW_Notification__c
            where IsActive__c = true
        ]) {
            notiMap.put(noti.Key__c, noti);
        }
    }

    public CJFW_NotificationManager setTargetIdSet(Set<String> targetIdSet) {
        this.targetIdSet = targetIdSet;
        return instance;
    }

    public CJFW_NotificationManager setTargetObjectList(List<sObject> targetObjectList) {
        this.targetObjectList = targetObjectList;
        return instance;
    }

    public CJFW_NotificationManager setRecipientListMap(Map<String,List<User>> recipientListMap) {
        this.recipientListMap = recipientListMap;
        return instance;
    }

    public CJFW_NotificationManager getInstance() {
        if(instance == null) instance = new CJFW_NotificationManager();
        return instance;
    }

    public void execute(String key) {
        CJFW_Notification__c noti = notiMap.get(key);

        if(noti == null) return;
        if(this.targetIdSet == null) return;
        if(this.targetObjectList == null) return;


        instance.resetData();

    }

    private void resetData() {
        instance.setTargetIdSet(null);
        instance.setTargetObjectList(null);
        instance.setRecipientListMap(null);
    }
}