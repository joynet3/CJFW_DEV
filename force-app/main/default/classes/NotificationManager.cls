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
    @testVisible protected List<sObject> targetSObjectList;
    @testVisible protected Object targetObject;

    /* Data 형식
        {
            'recordId': [NotiTarget]
        }
    */
    @testVisible protected Map<String,List<NotiTarget>> recipientListMap;

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
                , IsNotiTest__c
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

    public NotificationManager setTargetObject(Object targetObject) {
        instance.targetObject = targetObject;
        return instance;
    }

    public NotificationManager setTargetIdSet(Set<String> targetIdSet) {
        instance.targetIdSet = targetIdSet;
        return instance;
    }

    public NotificationManager setTargetSObjectList(List<sObject> targetSObjectList) {
        instance.targetSObjectList = targetSObjectList;
        return instance;
    }

    public NotificationManager setRecipientListMap(Map<String,List<NotiTarget>> recipientListMap) {
        instance.recipientListMap = recipientListMap;
        return instance;
    }

    public Map<String,List<NotiTarget>> getRecipientListMap() {
        return instance.recipientListMap;
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
        //notiHandler.setUserListMap(recipientListMap);
        
         if(instance.targetIdSet != null) notiHandler.execute(instance.targetIdSet, null, null);
         else if(instance.targetSObjectList != null) notiHandler.execute(null, instance.targetSObjectList, null);
         else if(instance.targetObject != null ) notiHandler.execute(null, null, instance.targetObject);

        instance.resetData();

    }

    private void resetData() {
        instance.setTargetIdSet(null);
        instance.setTargetSObjectList(null);
        instance.setRecipientListMap(null);
        instance.setTargetObject(null);
    }
}