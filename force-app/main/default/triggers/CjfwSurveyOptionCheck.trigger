/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
trigger CjfwSurveyOptionCheck on CJFW_SurveyOption__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CJFW_SurveyOption_tr().run();
}