trigger CJFW_ExpectedIncomeExpenses on CJFW_ExpectedIncomeExpenses__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    new CJFW_ExpectedIncomeExpenses_tr().run();
}