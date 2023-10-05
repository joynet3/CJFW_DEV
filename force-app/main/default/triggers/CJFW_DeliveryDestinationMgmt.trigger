/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
trigger CJFW_DeliveryDestinationMgmt on CJFW_DeliveryDestinationMgmt__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    new CJFW_DeliveryDstMgmtTriggerHandler().run();
}