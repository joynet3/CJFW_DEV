/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-02-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SalesAccountSummary_sc implements Schedulable {
    /*
    // 매출원장정보 고객별 Summary
    String CRON_EXP1 = '0 0 1 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    SalesAccountSummary_sc sc = new SalesAccountSummary_sc(50);
    System.schedule('매출원장정보 고객별 Summary(SalesAccountSummary__c) 01:00 batchSize 50', CRON_EXP1, sc);
    */

    global Integer batchSize;

    global SalesAccountSummary_sc(Integer batchSize) {
        this.batchSize = batchSize;
    }

    global void execute(SchedulableContext sc) {
        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().addDays(-1).day());

        SalesAccountSummary_ba ba = new SalesAccountSummary_ba(null, null);
        Database.executeBatch(ba, this.batchSize);
    }
}