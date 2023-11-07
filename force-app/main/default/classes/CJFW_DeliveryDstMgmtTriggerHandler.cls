/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_DeliveryDstMgmtTriggerHandler extends TriggerHandler{
    
    static Id userId =UserInfo.getUserId(); 
    static String profileName = [SELECT Profile.Name FROM User WHERE Id =: userId].Profile.Name;

    public CJFW_DeliveryDstMgmtTriggerHandler() {
        system.debug('CJFW_DeliveryDstMgmt Trigger Handler START');
        listNew = (List<CJFW_DeliveryDestinationMgmt__c>) trigger.new;
        mapNew = (Map<Id, CJFW_DeliveryDestinationMgmt__c>) trigger.newMap;
        listOld = (List<CJFW_DeliveryDestinationMgmt__c>) trigger.old;
        mapOld = (Map<Id, CJFW_DeliveryDestinationMgmt__c>) trigger.oldMap;
    }

    /*** TriggerHandler ***/
    private List<CJFW_DeliveryDestinationMgmt__c> listNew { get; set; }
    private List<CJFW_DeliveryDestinationMgmt__c> listOld { get; set; }
    private Map<Id, CJFW_DeliveryDestinationMgmt__c> mapNew { get; set; }
    private Map<Id, CJFW_DeliveryDestinationMgmt__c> mapOld { get; set; }

    public override void beforeUpdate() {
        if(profileName != 'System Administrator') doCheckCompletedWhenEdit();
    }
    
    public override void beforeDelete() {
        if(profileName != 'System Administrator') doCheckCompleted();
    }

    /***********************************************************************************************************
    *  Trigger : Before Update
    *  내용    : 배송처 관리 작성완료 처리 후 수정/삭제 불가 처리
    ************************************************************************************************************/ 
    private void doCheckCompleted(){
        for (CJFW_DeliveryDestinationMgmt__c oldDelivery : listOld) {
            // if (oldDelivery.LastActivityDate != null && oldDelivery.Completed__c == true) {
            if (oldDelivery.Completed__c == true) {
                oldDelivery.addError('배송처 작성완료 처리 후 삭제는 불가합니다.');
            }
        }
    }

    private void doCheckCompletedWhenEdit(){
        for (CJFW_DeliveryDestinationMgmt__c oldDelivery : listOld) {
            // if (oldDelivery.LastActivityDate != null && oldDelivery.Completed__c == true) {
            if (oldDelivery.Completed__c == true) {
                mapNew.get(oldDelivery.Id).addError('배송처 작성완료 처리 후 수정 및 삭제가 불가합니다.');
            }
        }
    }
}