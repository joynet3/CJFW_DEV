/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 10-04-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
trigger CJFW_ExpectedIncomeExpenses on CJFW_ExpectedIncomeExpenses__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    new CJFW_ExpectedIncomeExpenses_tr().run();
}