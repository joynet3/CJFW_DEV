/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class SalesMonthOfMASummary_sc implements Schedulable {
    /*
    // 매출원장정보 MA별 Summary
    String CRON_EXP1 = '0 0 3 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    SalesMonthOfMASummary_sc sc = new SalesMonthOfMASummary_sc(20);
    System.schedule('매출원장정보 MA별 Summary(SalesMonthOfMASummary__c) 03:00 batchSize 20', CRON_EXP1, sc);
    */

    global Integer batchSize;

    global SalesMonthOfMASummary_sc(Integer batchSize) {
        this.batchSize = batchSize;
    }

    global void execute(SchedulableContext sc) {
        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().addDays(-1).day());

        String strUserId = null;

        // 2023-02-02 테스트클래스 진행시 Batch Target Record가 200이상일 경우 에러가 발생하여 처리
        if(Test.isRunningTest()) {
            strUserId = UserInfo.getUserId();
        }

        SalesMonthOfMASummary_ba ba = new SalesMonthOfMASummary_ba(null, null, strUserId, true, this.batchSize);
        Database.executeBatch(ba, this.batchSize);
    }
}