/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-30-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class MIG_Account_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
    global MIG_Account_ba() {
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, ';
        strQuery += '   PaymentAccountName__c, PaymentAccountCode__c,';
        strQuery += '   ShippingAccountName__c, ShippingAccountCode__c';
        strQuery += '   FROM Account';        
        //strQuery += '   WHERE     (PaymentAccountName__c = null OR ShippingAccountName__c = null)' ;        
        
        return  Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<String> setCustomerId = new Set<String>();

        for(Account obj : scope) {
            if(obj.PaymentAccountCode__c <> null) {
                setCustomerId.add(obj.PaymentAccountCode__c);
            }

            if(obj.ShippingAccountCode__c <> null) {
                setCustomerId.add(obj.ShippingAccountCode__c);
            }
        }

        Map<String, Account> mapAccount = new Map<String, Account>();

        for(Account objAccount : [
            SELECT  Id, CustomerID__c, Name
            FROM    Account
            WHERE   CustomerID__c In:setCustomerId
        ]) {
            mapAccount.put(objAccount.CustomerID__c, objAccount);
        }

        List<Account> listUpdate = new List<Account>();

        for(Account obj : scope) {
            Boolean isUpdate = false;

            if(mapAccount <> null && mapAccount.get(obj.PaymentAccountCode__c) <> null) {
                obj.PaymentAccountName__c = mapAccount.get(obj.PaymentAccountCode__c).Name;
                isUpdate = true;
            }

            if(mapAccount <> null && mapAccount.get(obj.ShippingAccountCode__c) <> null) {
                obj.ShippingAccountName__c = mapAccount.get(obj.ShippingAccountCode__c).Name;
                isUpdate = true;
            }

            if(isUpdate) {
                listUpdate.add(obj);
            }
        }

        if(listUpdate <> null && listUpdate.size() > 0) {
            update listUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}