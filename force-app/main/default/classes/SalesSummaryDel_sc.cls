/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class SalesSummaryDel_sc implements Schedulable {
    /*
    String CRON_EXP = '0 45 0 1 * ? *';
    SalesSummaryDel_sc sc = new SalesSummaryDel_sc();
    System.schedule('매출합계(고객/상품/MA별) 데이터 삭제(SalesSummaryDel_ba) 매월 1일 00:45', CRON_EXP, sc);
    */
    
    global SalesSummaryDel_sc() {
    }

    global void execute(SchedulableContext sc) {          
        SalesSummaryDel_ba ba = new SalesSummaryDel_ba(null, null);
        Database.executeBatch(ba, 1000);
    }
}