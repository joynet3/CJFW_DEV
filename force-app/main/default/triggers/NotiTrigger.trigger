trigger NotiTrigger on Notification__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new NotiTriggerHandler().run();
}