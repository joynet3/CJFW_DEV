/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SalesMonthOfMASummaryBefore_sc implements Schedulable {
    /*
    // 매출원장정보 MA별 재 Summary(-2M ~ -1M)
    String CRON_EXP1 = '0 30 3 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    SalesMonthOfMASummaryBefore_sc sc = new SalesMonthOfMASummaryBefore_sc(20);
    System.schedule('매출원장정보 MA별 재 Summary(-2M ~ -1M)(SalesMonthOfMASummary__c) 03:30 batchSize 20', CRON_EXP1, sc);
    */

    global Integer batchSize;

    global SalesMonthOfMASummaryBefore_sc(Integer batchSize) {
        this.batchSize = batchSize;
    }

    global void execute(SchedulableContext sc) {
        Date dtStartTarget = Date.today().addMonths(-3);
        Date dtEndTarget = Date.today().addMonths(-1);
        Date startDate = Date.newInstance(dtStartTarget.year(), dtStartTarget.month(), 1);
        Date endDate = Date.newInstance(dtEndTarget.year(), dtEndTarget.month(), Date.daysInMonth(dtEndTarget.year(), dtEndTarget.month()));

        String strUserId = null;

        // 2023-02-02 테스트클래스 진행시 Batch Target Record가 200이상일 경우 에러가 발생하여 처리
        if(Test.isRunningTest()) {
            strUserId = UserInfo.getUserId();
        }

        SalesMonthOfMASummary_ba ba = new SalesMonthOfMASummary_ba(startDate, endDate, strUserId, true, this.batchSize);
        Database.executeBatch(ba, this.batchSize);
    }
}