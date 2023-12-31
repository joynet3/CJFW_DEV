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
    @testVisible protected Set<String> targetIdSet;
    @testVisible protected List<sObject> targetObjectList;

    /* Data 형식
        {
            'Id': [
                User : {
                    Id:''
                    Email:''
                }
            ]
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
        instance.targetIdSet = targetIdSet;
        return instance;
    }

    public CJFW_NotificationManager setTargetObjectList(List<sObject> targetObjectList) {
        instance.targetObjectList = targetObjectList;
        return instance;
    }

    public CJFW_NotificationManager setRecipientListMap(Map<String,List<User>> recipientListMap) {
        instance.recipientListMap = recipientListMap;
        return instance;
    }

    public static CJFW_NotificationManager getInstance() {
        if(instance == null) instance = new CJFW_NotificationManager();
        return instance;
    }

    public void execute(String key) {
        CJFW_Notification__c noti = notiMap.get(key);

        if(noti == null) return;

        String className = 'CJFW_NotiHandler';
        if(noti.IsDynamic__c) {
            className = noti.ClassName__c;
        }
        CJFW_NotiHandler notiHandler = (CJFW_NotiHandler)Type.forName(className).newInstance();
        notiHandler.setNotiData(noti);
        
        if(instance.targetIdSet != null) notiHandler.manuFactureNoti(instance.targetIdSet, null);
        else if(instance.targetObjectList != null) notiHandler.manuFactureNoti(instance.targetObjectList, null);

        instance.resetData();

    }

    private void resetData() {
        instance.setTargetIdSet(null);
        instance.setTargetObjectList(null);
        instance.setRecipientListMap(null);
    }
}