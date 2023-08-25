/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-23-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class MIG_ORDER_DEL_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    global Date strDate;
    global Date endDate;

    global MIG_ORDER_DEL_ba(Date strDate, Date endDate) {
        this.strDate = strDate;
        this.endDate = endDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id';                
        strQuery += '   FROM    SalesLedgerInformation__c';
        strQuery += '   WHERE   Id <> null';

        if(strDate <> null) {
            strQuery += '   AND SALES_YMD__c >=:strDate';
        }

        if(endDate <> null) {
            strQuery += '   AND SALES_YMD__c <:endDate';
        }

        return  Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<SalesLedgerInformation__c> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish batch');
    }
}