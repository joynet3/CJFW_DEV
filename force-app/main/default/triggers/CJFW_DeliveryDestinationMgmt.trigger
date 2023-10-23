/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
trigger CJFW_DeliveryDestinationMgmt on CJFW_DeliveryDestinationMgmt__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    new CJFW_DeliveryDstMgmtTriggerHandler().run();
}