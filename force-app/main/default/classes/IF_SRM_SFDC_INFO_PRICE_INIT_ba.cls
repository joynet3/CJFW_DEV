/************************************************************************************
 * File Name   		: IF_SRM_SFDC_INFO_PRICE_INIT_ba.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.12.23
 * Tester	  		: IF_SRM_SFDC_INFO_PRICE_INIT_ba_test.cls
 * Description 		: IF_SRM_SFDC_INFO_PRICE_INIT
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.12.23      Minje.Kim       Create
*************************************************************************************/

global without sharing class IF_SRM_SFDC_INFO_PRICE_INIT_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global String transactionId;
    global String MonthNow;

    global IF_SRM_SFDC_INFO_PRICE_INIT_ba(String transactionId, String MonthNow) {
        this.transactionId = transactionId;
        this.MonthNow = MonthNow;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : PriceBookEntry 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {

        Datetime now = Datetime.now();
        String nowMonth = now.format('MMM');

        String strQuery = '';
        strQuery += 'SELECT Id, ' + MonthNow +', Old' + MonthNow ;        
        strQuery += '   FROM    PriceBookEntry';

        System.debug('strQuery: ' + strQuery);
        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : PriceBookEntry 기준매입가격 Old 업데이트
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<PricebookEntry> listPriceBookEntry) {
        System.debug('execute batch');
        
        for (PricebookEntry objPriceBookEntry : listPriceBookEntry) {
            objPriceBookEntry.put('Old'+ MonthNow, objPriceBookEntry.get('' + MonthNow));
            objPriceBookEntry.put('' + MonthNow , 0);
        }
        System.debug('listPriceBookEntry : ' + listPriceBookEntry);

        if(!listPriceBookEntry.isEmpty()) {
            update listPriceBookEntry;
        }
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : IF_SRM_SFDC_INFO_PRICE_ba Batch 실행
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('finish batch');
        Integer count = Test.isRunningTest() ? 50 : 200;
        IF_SRM_SFDC_INFO_PRICE_ba ba = new IF_SRM_SFDC_INFO_PRICE_ba(transactionId);
        Database.executeBatch(ba, count);
    }
}