/**
* 알림 전송 관리 Object
*
*@group  Notification
*@author 진현욱
*@since 2023-07-24  최초 작성
*/
public with sharing class NotificationManager {
    
    private static NotificationManager instance;

    @testVisible private Map<String, Notification__c> notiMap;
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
    @testVisible protected Map<String,List<User>> recipientListMap;

    private NotificationManager() {
        notiMap = new Map<String, Notification__c>();

        for(Notification__c noti : [
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
                , RecordType.DeveloperName
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
            from Notification__c
            where IsActive__c = true
        ]) {
            notiMap.put(noti.Key__c, noti);
        }
    }



    public NotificationManager setTargetIdSet(Set<String> targetIdSet) {
        instance.targetIdSet = targetIdSet;
        return instance;
    }

    public NotificationManager setTargetObjectList(List<sObject> targetObjectList) {
        instance.targetObjectList = targetObjectList;
        return instance;
    }

    public NotificationManager setRecipientListMap(Map<String,List<User>> recipientListMap) {
        instance.recipientListMap = recipientListMap;
        return instance;
    }

    public static NotificationManager getInstance() {
        if(instance == null) instance = new NotificationManager();
        return instance;
    }

    public void execute(String key) {
        Notification__c noti = notiMap.get(key);

        if(noti == null) return;

        String className = 'NotiHandler';
        if(noti.IsDynamic__c) {
            className = noti.ClassName__c;
        }
        NotiHandler notiHandler = (NotiHandler)Type.forName(className).newInstance();
        notiHandler.setNotiData(noti);
        notiHandler.setUserListMap(recipientListMap);
        
         if(instance.targetIdSet != null) notiHandler.execute(instance.targetIdSet, null);
         else if(instance.targetObjectList != null) notiHandler.execute(null, instance.targetObjectList);

        instance.resetData();

    }

    private void resetData() {
        instance.setTargetIdSet(null);
        instance.setTargetObjectList(null);
        instance.setRecipientListMap(null);
    }
}