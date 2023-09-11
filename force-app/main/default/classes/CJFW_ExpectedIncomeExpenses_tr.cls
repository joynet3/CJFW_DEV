/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 09-08-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/

public without sharing class CJFW_ExpectedIncomeExpenses_tr extends TriggerHandler {
    public CJFW_ExpectedIncomeExpenses_tr() {
        system.debug('CJFW_ExpectedIncomeExpenses Trigger Handler START');
        listNew = (List<CJFW_ExpectedIncomeExpenses__c>) trigger.new;
        mapOld = (Map<Id, CJFW_ExpectedIncomeExpenses__c>) trigger.oldMap;
        listOld = (List<CJFW_ExpectedIncomeExpenses__c>) trigger.old;

    }

    /*** TriggerHandler ***/
    private List<CJFW_ExpectedIncomeExpenses__c> listNew { get; set; }
    private List<CJFW_ExpectedIncomeExpenses__c> listOld { get; set; }
    private Map<Id, CJFW_ExpectedIncomeExpenses__c> mapOld { get; set; }

    public override void beforeInsert() {
        doCheckOne();
    }

    public override void beforeUpdate() {
        doCheckOne();
    }

    public override void afterUpdate() {}

    /***********************************************************************************************************
    *  Trigger : Before Insert, Before Update
    *  내용    : 예상손익 품의지정 1개만 등록되게 처리
    ************************************************************************************************************/ 
    private void doCheckOne(){
        Set<Id> opportunityIds = new Set<Id>();

        for(CJFW_ExpectedIncomeExpenses__c expense : listNew) {
            opportunityIds.add(expense.Opportunity__c);
        }

        List<CJFW_ExpectedIncomeExpenses__c> existingExpenses = [
            SELECT Id, Name, Opportunity__c, IsReportCheck__c
            FROM CJFW_ExpectedIncomeExpenses__c
            WHERE Opportunity__c IN :opportunityIds
        ];

        Map<Id, CJFW_ExpectedIncomeExpenses__c> opportunityToExpenseMap = new Map<Id, CJFW_ExpectedIncomeExpenses__c>();
        for(CJFW_ExpectedIncomeExpenses__c expense : existingExpenses) {
            opportunityToExpenseMap.put(expense.Opportunity__c, expense);
        }
        
        for(CJFW_ExpectedIncomeExpenses__c newExpense : listNew){
            if (newExpense.IsReportCheck__c) {
                for (CJFW_ExpectedIncomeExpenses__c existingExpense : existingExpenses) {
                    if (existingExpense.Id != newExpense.Id  
                        && existingExpense.IsReportCheck__c) {
                        newExpense.addError('품의지정은 하나만 지정 가능합니다.');
                        break; 
                    }
                }
            }
        }
    }
}