/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_DeliveryDstMgmtTriggerHandler extends TriggerHandler{
    public CJFW_DeliveryDstMgmtTriggerHandler() {
        system.debug('CJFW_DeliveryDstMgmt Trigger Handler START');
        listNew = (List<CJFW_DeliveryDestinationMgmt__c>) trigger.new;
        mapOld = (Map<Id, CJFW_DeliveryDestinationMgmt__c>) trigger.oldMap;
        listOld = (List<CJFW_DeliveryDestinationMgmt__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<CJFW_DeliveryDestinationMgmt__c> listNew { get; set; }
    private List<CJFW_DeliveryDestinationMgmt__c> listOld { get; set; }
    private Map<Id, CJFW_DeliveryDestinationMgmt__c> mapOld { get; set; }

    public override void beforeUpdate() {
        //doCheckCompleted();
    }
    
    public override void beforeDelete() {
        doCheckCompleted();
    }

    /***********************************************************************************************************
    *  Trigger : Before Update
    *  내용    : 배송처 관리 작성완료 처리 후 수정/삭제 불가 처리
    ************************************************************************************************************/ 
    private void doCheckCompleted(){
        System.debug('listOld : ' + listOld[0].Completed__c);

        for (CJFW_DeliveryDestinationMgmt__c oldDelivery : listOld) {
            if (oldDelivery.Completed__c == true) {
                oldDelivery.addError('배송처 작성완료 처리 후 삭제는 불가합니다.');
            }
            
        }
    }
}