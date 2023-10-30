/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-27-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
trigger CjfwSurveyQuestionCheck on CJFW_SurveyQuestion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CJFW_SurveyQustion_tr().run();

}