/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SalesAccountSummaryBefore_sc implements Schedulable {
    /*
    // 매출원장정보 고객별 재 Summary(-2 Month ~ -1 Month)
    String CRON_EXP1 = '0 0 1 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    SalesAccountSummary_sc sc = new SalesAccountSummary_sc(50);
    System.schedule('매출원장정보 고객별 재 Summary(-2M ~ -1M) (SalesAccountSummary__c) 01:00 batchSize 50', CRON_EXP1, sc);
    */

    global Integer batchSize;

    global SalesAccountSummaryBefore_sc(Integer batchSize) {
        this.batchSize = batchSize;
    }

    global void execute(SchedulableContext sc) {
        Date dtStartTarget = Date.today().addMonths(-3);
        Date dtEndTarget = Date.today().addMonths(-1);
        Date startDate = Date.newInstance(dtStartTarget.year(), dtStartTarget.month(), 1);
        Date endDate = Date.newInstance(dtEndTarget.year(), dtEndTarget.month(), Date.daysInMonth(dtEndTarget.year(), dtEndTarget.month()));

        SalesAccountSummary_ba ba = new SalesAccountSummary_ba(startDate, endDate);
        Database.executeBatch(ba, this.batchSize);
    }
}