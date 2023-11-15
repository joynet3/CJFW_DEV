/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
trigger NotificationManagement on NotificationManagement__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    new NotificationMgmtTriggerHandler().run();
}