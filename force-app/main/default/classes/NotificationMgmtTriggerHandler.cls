/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class NotificationMgmtTriggerHandler extends TriggerHandler{

    public NotificationMgmtTriggerHandler() {
        System.debug('NotificationMgmtTriggerHandler START');
        listNew = (List<NotificationManagement__c>) trigger.new;
        mapNew = (Map<Id, NotificationManagement__c>) trigger.newMap;
        listOld = (List<NotificationManagement__c>) trigger.old;
        mapOld = (Map<Id, NotificationManagement__c>) trigger.oldMap;
    }

    /*** TriggerHandler ***/
    private List<NotificationManagement__c> listNew { get; set; }
    private List<NotificationManagement__c> listOld { get; set; }
    private Map<Id, NotificationManagement__c> mapNew { get; set; }
    private Map<Id, NotificationManagement__c> mapOld { get; set; }

    public override void beforeUpdate() {
        updatedChk();
    }

    private void updatedChk(){
        for (NotificationManagement__c noti : listNew) {
            if(mapOld.get(noti.Id).IsUpdated__c){
                noti.addError('이미 자동 갱신된 알람으로 수정 불가 합니다.');
            }
        }
    }
}