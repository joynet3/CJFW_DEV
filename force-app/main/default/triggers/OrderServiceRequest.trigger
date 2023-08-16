/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger OrderServiceRequest on OrderServiceRequest__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new OrderServiceRequest_tr().run();
}