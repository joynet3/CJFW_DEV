/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class IF_IFRESH_SFDC_INFO_ORDER_0001_DEL_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global String transactionId;

    global IF_IFRESH_SFDC_INFO_ORDER_0001_DEL_ba(String transactionId) {
        this.transactionId = transactionId;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT     Id, transactionId__c';
        strQuery += '   FROM    IF_IFRESH_SFDC_INFO_ORDER_0001__c';        
        strQuery += '   WHERE   transactionId__c =\'' + transactionId + '\'';
        strQuery += '   AND     IsUpdate__c = true' ;

        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<IF_IFRESH_SFDC_INFO_ORDER_0001__c> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {

    }
}