/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SalesProductSummaryBefore_sc implements Schedulable {
    /*
    // 매출원장정보 상품별 재 Summary(-2M ~ -1M)
    String CRON_EXP1 = '0 10 4 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    SalesProductSummaryBefore_sc sc = new SalesProductSummaryBefore_sc(5);
    System.schedule('매출원장정보 상품별 재 Summary(-2M ~ -1M)(SalesProductSummary__c) 04:10 batchSize 5', CRON_EXP1, sc);
    */

    global Integer batchSize;

    global SalesProductSummaryBefore_sc(Integer batchSize) {
        this.batchSize = batchSize;
    }

    global void execute(SchedulableContext sc) {
        Date dtStartTarget = Date.today().addMonths(-3);
        Date dtEndTarget = Date.today().addMonths(-1);
        Date startDate = Date.newInstance(dtStartTarget.year(), dtStartTarget.month(), 1);
        Date endDate = Date.newInstance(dtEndTarget.year(), dtEndTarget.month(), Date.daysInMonth(dtEndTarget.year(), dtEndTarget.month()));        

        SalesProductSummary_ba ba = new SalesProductSummary_ba(startDate, endDate, true, this.batchSize);
        Database.executeBatch(ba, this.batchSize);
    }
}