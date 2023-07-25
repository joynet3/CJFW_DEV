/**
 * @description       : 매출원장정보 삭제 Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
/*
Date dtTarget = Date.newInstance(2022, 11, 1);
SalesLedgerInformationDel_ba b = new SalesLedgerInformationDel_ba(dtTarget);
Database.executeBatch(b, 1000);
*/
global with sharing class SalesLedgerInformationDel_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global Date targetDate;

    global SalesLedgerInformationDel_ba(Date targetDate) {
        this.targetDate = targetDate;
    }

    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 삭제할 매출원장정보 조회 
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('=============================:::SalesLedgerInformation__c delete batch start');
        String strQuery = '';
        Date delDate = Date.today().addMonths(-3);

        if(this.targetDate <> null)  {
            delDate = this.targetDate;
        }

        Date targetDate = Date.newInstance(delDate.year(), delDate.month(), 1);

        strQuery += 'SELECT Id';
        strQuery += '   FROM SalesLedgerInformation__c';        
        strQuery += '   WHERE     SALES_YMD__c  <: targetDate';

        return Database.getQueryLocator(strQuery);
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 매출원장정보 삭제
    ************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<SalesLedgerInformation__c> scope) {
        delete scope;
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('=============================:::SalesLedgerInformation__c delete batch finish');
    }
}