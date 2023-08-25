/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SalesLedgerInformationDel_sc implements Schedulable {
    /*
    String CRON_EXP1 = '0 0 0 1 * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.
    SalesLedgerInformationDel_sc sc = new SalesLedgerInformationDel_sc();
    System.schedule('SalesLedgerInformationDel_sc 매출원장정보삭제(-3Month) 00시30분', CRON_EXP1, sc);
    */
    
    global SalesLedgerInformationDel_sc() {

    }

    global void execute(SchedulableContext sc) {        
        SalesLedgerInformationDel_ba ba = new SalesLedgerInformationDel_ba(null);
        Database.executeBatch(ba, 1000);
    }
}