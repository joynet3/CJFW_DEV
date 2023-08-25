/**
 * @description       : 매출원장 고객별 Summary 삭제 Batch Class
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
/*
Date dtTarget = Date.newInstance(2022, 11, 1);
String strObject = 'SalesAccountSummary__c';
SalesSummaryDel_ba b = new SalesSummaryDel_ba(strObject, dtTarget);
Database.executeBatch(b, 1000);
*/
global with sharing class SalesSummaryDel_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global Date targetDate;
    global String strObject;

    global SalesSummaryDel_ba(String strObject, Date targetDate) {
        if(targetDate == null) {
            this.targetDate = Date.today().addMonths(-12);            
        }else {
            this.targetDate = targetDate;
        }

        if(strObject == null) {
            this.strObject = 'SalesAccountSummary__c';
        }else {
            this.strObject = strObject;
        }
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 삭제할 레코드 정보 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('=============================:::SalesLedgerInformation__c delete batch start');
        String strQuery = '';

        Date delDate = Date.newInstance(this.targetDate.year(), this.targetDate.month(), 1);

        strQuery += 'SELECT Id';
        strQuery += '   FROM '+this.strObject;        
        strQuery += '   WHERE     SalesDate__c  <: delDate';

        return Database.getQueryLocator(strQuery);
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 데이터 삭제
    ************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<SalesLedgerInformation__c> scope) {
        delete scope;
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 매출원장 상품별, MA별 Summary 데이터 삭제 Batch Class 실행
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        if(this.strObject == 'SalesAccountSummary__c') {
            SalesSummaryDel_ba b = new SalesSummaryDel_ba('SalesProductSummary__c', this.targetDate);
            Database.executeBatch(b, 1000);
        }else if(this.strObject == 'SalesProductSummary__c') {
            SalesSummaryDel_ba b = new SalesSummaryDel_ba('SalesMonthOfMASummary__c', this.targetDate);
            Database.executeBatch(b, 1000);
        }
    }
}