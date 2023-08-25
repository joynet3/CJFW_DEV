/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class IFLogDel_sc implements Schedulable {
    /*

    // IFLog__c 삭제
    String CRON_EXP = '0 40 0 * * ? *';  // 초 분 시 일 월 ? ?
    IFLogDel_sc sc = new IFLogDel_sc();
    System.schedule('IFLog 삭제(IFLog__c) 00:40', CRON_EXP, sc);
    */
    
    global IFLogDel_sc() {
    }

    global void execute(SchedulableContext sc) {        
        IFLogDel_ba ba = new IFLogDel_ba(null);
        Database.executeBatch(ba, 1000);
    }
}