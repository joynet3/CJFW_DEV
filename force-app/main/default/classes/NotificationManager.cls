/**
* 알림 전송 관리 
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

    //임시
    public static List<IFMaster__c> logMasters;

    /* Data 형식
        {
            '${sObjectId}': [NotiTarget]
        }
    */
    @testVisible protected Map<String,List<NotiTarget>> recipientListMap;

    @testVisible private NotificationManager() {
        /* 임시 LogMaster  [s]  */
        if(logMasters == null) logMasters = new List<IFMaster__c>();
        if(logMasters.isEmpty())
        logMasters  = [
            SELECT Id
            FROM IFMaster__c
            WHERE Name = 'NotiAlert'
        ];
        /* 임시 LogMaster  [e]  */
        
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
                , IsSystemEmail__c
                , IsUseOWE__c
                , IsSaveAsActivity__c
                , IsTargetObjectId__c
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

    /**
    * sObject Type 이 아닌 Object Type 정보 저장
    * 이 메소드 사용시 Notification 이 IsDynamic : true 이면서 
    * 알림 보낼 로직을 구현할 ClassName__c 필수적으로 있어야함
    * ClassName__c 개발자가 직접 구현필요
    * 알림 개인화 시에 필요 
    *
    *@param  targetObject 
    *@return  NotificationManager Static instance 
    */
    public NotificationManager setTargetObject(Object targetObject) {
        instance.targetObject = targetObject;
        instance.targetIdSet = null;
        instance.targetSObjectList = null;
        return instance;
    }

    /**
    * sObject의 Id Set 저장
    * 알림 보내기 위한 데이터 정보
    * 공통 로직에서 알림 템플릿 개인화
    *
    *@param  targetIdSet 
    *@return  NotificationManager Static instance 
    */
    public NotificationManager setTargetIdSet(Set<String> targetIdSet) {
        instance.targetIdSet = targetIdSet;
        instance.targetSObjectList = null;
        instance.targetObject = null;
        return instance;
    }

    /**
    * sObject List 저장
    * 알림 보내기 위한 데이터 정보
    * 공통 로직에서 알림 템플릿 개인화
    *
    *@param  targetSObjectList 
    *@return  NotificationManager Static instance 
    */
    public NotificationManager setTargetSObjectList(List<sObject> targetSObjectList) {
        instance.targetSObjectList = targetSObjectList;
        instance.targetIdSet = null;
        instance.targetObject = null;
        return instance;
    }

    /**
    * 알림 수신자 저장
    * ${sObjectId} 값은 setTargetIdSet, setTargetSObjectList에 
    * 저장한 recordId 에 있어야 함
    * 데이터 형식
    * {
    *   '${sObjectId}': [NotiTarget]
    * }
    *
    *@param  recipientListMap 
    *@return  NotificationManager Static instance 
    */
    public NotificationManager setRecipientListMap(Map<String,List<NotiTarget>> recipientListMap) {
        instance.recipientListMap = recipientListMap;
        return instance;
    }

    /**
    * 알림 수신자 가져오기
    *
    *@return  Map<String,List<NotiTarget>>
    */
    public Map<String,List<NotiTarget>> getRecipientListMap() {
        return instance.recipientListMap;
    }

    /**
    * Static Instance 생성자 생성
    *
    */
    public static NotificationManager getInstance() {
        if(instance == null) instance = new NotificationManager();
        return instance;
    }

    /**
    * 알림 모듈 실행
    *
    *@param  key 알림 마스터 데이터 가져올 Unique Key
    */
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

    /**
    * 전체 데이터 초기화 (싱글톤 패턴 사용하여 데이터가 공유 될 수 있음)
    *
    */
    private void resetData() {
        instance.setTargetIdSet(null);
        instance.setTargetSObjectList(null);
        instance.setRecipientListMap(null);
        instance.setTargetObject(null);
    }

    /**
    * 임시 IF Log 저장
    *
    *@param  logList 
    */
    public static void saveHistory(List<IFLog__c> logList) {
        if(!logList.isEmpty() && logMasters != null && !logMasters.isEmpty() && logMasters[0]?.Id != null ) {
            //System.debug('logMasters :: '+JSON.serializePretty(logMasters));
            for(IFLog__c objLog : logList) {
                objLog.IFMaster__c = logMasters[0]?.Id;
            }
            insert logList;
        }
    }
}