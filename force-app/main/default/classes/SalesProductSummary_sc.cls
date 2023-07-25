/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-02-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SalesProductSummary_sc implements Schedulable {
    /*
    // 매출원장정보 상품별 Summary
    String CRON_EXP1 = '0 0 2 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    SalesProductSummary_sc sc = new SalesProductSummary_sc(5);
    System.schedule('매출원장정보 상품별 Summary(SalesProductSummary__c) 02:00 batchSize 5', CRON_EXP1, sc);
    */

    global Integer batchSize;

    global SalesProductSummary_sc(Integer batchSize) {
        this.batchSize = batchSize;
    }

    global void execute(SchedulableContext sc) {
        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().addDays(-1).day());

        SalesProductSummary_ba ba = new SalesProductSummary_ba(startDate, endDate, true, this.batchSize);
        Database.executeBatch(ba, this.batchSize);
    }
}