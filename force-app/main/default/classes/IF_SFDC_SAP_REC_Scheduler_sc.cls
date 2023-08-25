/*
* ==================================================================================
*   File Name   : IF_SFDC_SAP_REC_Scheduler_sc.cls
*   Author      : Minje.Kim
*   Date        : 2022.06.23
*   Tester      : IF_SFDC_SAP_REC_Scheduler_sc_test.cls
*   Description : 국내아동 종결/파기 이메일 알림
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.06.23    Minje.Kim      Create
* ==================================================================================
*/

// 입고, 출고, 재고 동기화 (매일 오후 10시)
// String CRON_EXP = '0 0 22 * * ?';
// System.schedule('입고 동기화', CRON_EXP, new IF_SFDC_SAP_REC_Scheduler_sc('입고'));
// CRON_EXP = '0 1 22 * * ?';
// System.schedule('출고 동기화', CRON_EXP, new IF_SFDC_SAP_REC_Scheduler_sc('출고'));
// CRON_EXP = '0 00 * * * ?';
// System.schedule('재고 동기화', CRON_EXP, new IF_SFDC_SAP_REC_Scheduler_sc('재고'));


global class IF_SFDC_SAP_REC_Scheduler_sc implements Schedulable, Database.AllowsCallouts {

    public String BatchType;

    public IF_SFDC_SAP_REC_Scheduler_sc ( String aBatchType ) {
        if ( BatchType == null ) BatchType = aBatchType; 
    }
    global void execute(SchedulableContext sc) {

        Datetime calcDate = system.today().addDays(1);
        String targetDate = calcDate.format('yyyyMMdd');

        if ( BatchType == '입고'){
            callORDER(targetDate);
        }
        else if ( BatchType == '출고'){
            callRELEASE(targetDate);

        }
        else if ( BatchType == '재고'){
            callSTOCK();
        }

    }

    @future(callout=true)
    public static void callORDER(String targetDate){
        IF_SFDC_SAP_REC_ORDER.Output outputObj = new IF_SFDC_SAP_REC_ORDER.Output();
        IF_SFDC_SAP_REC_ORDER ifORDER = new IF_SFDC_SAP_REC_ORDER();    
        if(!Test.isRunningTest()) {
            outputObj = ifORDER.callOut(targetDate);
        }
        system.debug('outputObj ::' + outputObj);
    }

    @future(callout=true)
    public static void callRELEASE(String targetDate){
        IF_SFDC_SAP_REC_RELEASE.Output outputObj = new IF_SFDC_SAP_REC_RELEASE.Output();
        IF_SFDC_SAP_REC_RELEASE ifRELEASE = new IF_SFDC_SAP_REC_RELEASE();
        if(!Test.isRunningTest()) {
            outputObj = ifRELEASE.callOut(targetDate);
        }
        system.debug('outputObj ::' + outputObj);
    }
    
    @future(callout=true)
    public static void callSTOCK(){
        IF_SFDC_SAP_REC_STOCK.Output outputObj = new IF_SFDC_SAP_REC_STOCK.Output();
        IF_SFDC_SAP_REC_STOCK ifSTOCK = new IF_SFDC_SAP_REC_STOCK();
        if(!Test.isRunningTest()) {
            outputObj = ifSTOCK.callOut();
        }
        system.debug('outputObj ::' + outputObj);
    }
}