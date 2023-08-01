public with sharing class NotiTriggerHandler extends TriggerHandler{
    
    private List<Notification__c> newList; 
    private List<Notification__c> oldList; 
    private Map<Id, Notification__c> oldMap; 
    private Map<Id, Notification__c> newMap;
    private Map<String, Schema.RecordTypeInfo> recordTypeMap;
    private static Map<String,CustomNotificationType> customNotiTypeMap;
    
    public NotiTriggerHandler() {
        newList = (List<Notification__c>) Trigger.new;
        oldList = (List<Notification__c>) Trigger.old;
        newMap  = (Map<Id,Notification__c>) Trigger.newMap;
        oldMap  = (Map<Id,Notification__c>) Trigger.oldMap;
        if(recordTypeMap == null)recordTypeMap = Schema.SObjectType.Notification__c.getRecordTypeInfosByDeveloperName();

        if(customNotiTypeMap == null) customNotiTypeMap = new Map<String,CustomNotificationType>();
        if(customNotiTypeMap.isEmpty()) {

            for(CustomNotificationType customNoti :[
                select
                    Id
                    ,DeveloperName    
                from CustomNotificationType 
            ]) {
                customNotiTypeMap.put(customNoti.DeveloperName, customNoti);
            }
        }

    }

    public override void beforeInsert() {        
        validationCheck(newList);
    }

    public override void beforeUpdate() {
        validationCheck(newList);
    }

    private void validationCheck(List<Notification__c> notiList) {
      

        Id appRecordTypeId = recordTypeMap.get('App').getRecordTypeId();

        for(Notification__c noti : notiList) {
            if(noti.RecordTypeId == appRecordTypeId) {
                
                //App Notification 일떄 CustomNotificationTypeId 생성 체크 
                if(!customNotiTypeMap.containsKey(noti.CustomNotificationTypeId__c)) noti.addError('CustomNotificationTypeId__c', 'Custom Notification Type 을 먼저 생성후 등록해 주세요.');
            }

            //개발자가 동적으로 개인화시에 ClassName 필수값 체크
            if(noti.IsDynamic__c && String.isBlank(noti.ClassName__c)) noti.addError('ClassName__c', '알림 생성 로직 커스텀시에 ClassName 은 필수값 입니다.');
        }

    }
}