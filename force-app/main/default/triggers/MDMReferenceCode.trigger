/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger MDMReferenceCode on MDMReferenceCode__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new MDMReferenceCode_tr().run();
}