/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class MIG_SalesOwnerChange_ba implements Database.Batchable<SObject>, Database.Stateful {            
    global Date targetDate;    

    global MIG_SalesOwnerChange_ba(Date targetDate) {        
        this.targetDate = targetDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';

        strQuery += 'SELECT  OwnerId, CRG_MA_ID__c, CRG_MA__c';        
        strQuery += '   FROM    SalesLedgerInformation__c';
        strQuery += '   WHERE   CRG_MA__c = null';

        Date inqDate = Date.today();

        if(this.targetDate <> null) {
            inqDate = this.targetDate;
        }

        Date dtStart = Date.newInstance(inqDate.year(), inqDate.month(), 1);
        Date dtEnd = Date.newInstance(inqDate.year(), inqDate.month(), Date.daysInMonth(inqDate.year(), inqDate.month()));
        
        strQuery += '   AND     SALES_YMD__c >=: dtStart';
        strQuery += '   AND     SALES_YMD__c <=: dtEnd';
        
        return  Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<SalesLedgerInformation__c> scope) {

        Set<String> setUserId = new Set<String>();
        Set<String> setUserEmployeeNumber = new Set<String>();

        Map<String, String> mapUserId = new Map<String, String>();

        for(SalesLedgerInformation__c obj : scope) {
            if(obj.CRG_MA_ID__c <> null) {
                setUserEmployeeNumber.add(obj.CRG_MA_ID__c);
            }
        }

        for(User objUser : [
            SELECT Id, EmployeeNumber FROM User WHERE EmployeeNumber In:setUserEmployeeNumber
        ]) {
            mapUserId.put(objUser.EmployeeNumber, objUser.Id);
        }

        List<SalesLedgerInformation__c> listUpdate = new List<SalesLedgerInformation__c>();

        for(SalesLedgerInformation__c obj : scope) {
            if(mapUserId <> null && mapUserId.get(obj.CRG_MA_ID__c) <> null) {
                obj.OwnerId = mapUserId.get(obj.CRG_MA_ID__c);
                obj.CRG_MA__c = mapUserId.get(obj.CRG_MA_ID__c);

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