/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-19-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
trigger CjfwSurveyClone on CJFW_Survey__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CJFW_Survey_tr().run();

}