/**
 * @description       : IFLog 삭제 Batch Class
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global without sharing class IFLogDel_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    global Integer targetDays;

    global IFLogDel_ba(Integer targetDays) {
        this.targetDays = targetDays;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : IFLog__c Object 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date targetDate = Date.today();

        if(this.targetDays == null) {
            this.targetDays = -14;
        }

        targetDate = targetDate.addDays(this.targetDays);

        String strQuery = '';
        strQuery += 'SELECT Id';                
        strQuery += '   FROM    IFLog__c';        
        strQuery += '   WHERE   CreatedDate <:targetDate';

        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : IFLog__c 삭제
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        delete scope;
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('finish batch');
    }
}