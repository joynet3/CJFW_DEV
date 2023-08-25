/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-05-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class MIG_SalesSchool_ba implements Database.Batchable<SObject>, Database.Stateful {
    global MIG_SalesSchool_ba() {
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';

        Date inqDate = Date.newInstance(2022, 1, 1);

        strQuery += 'SELECT  Id, SALES_YMD__c, SCHL_CD__c, SCHL__c';        
        strQuery += '   FROM    SalesLedgerInformation__c';
        strQuery += '   WHERE   SCHL_CD__c != null';
        strQuery += '   AND     SALES_YMD__c >=:inqDate';
        //strQuery += '   AND     SCHL__c = null';
        
        return  Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<SalesLedgerInformation__c> scope) {

        Set<String> setSchlCd = new Set<String>();

        for(SalesLedgerInformation__c obj : scope) {
            if(obj.SCHL_CD__c <> null) {
                setSchlCd.add(obj.SCHL_CD__c);
            }
        }

        Map<String, String> mapSchool = new Map<String, String>();

        for(Account objAccount : [
            SELECT  Id, Name, custID__c
            FROM    Account
            WHERE   RecordType.DeveloperName = 'SchoolDepartment'
            AND     custID__c In:setSchlCd
        ]) {
            mapSchool.put(objAccount.custID__c, objAccount.Id);
        }

        List<SalesLedgerInformation__c> listUpdate = new List<SalesLedgerInformation__c>();

        for(SalesLedgerInformation__c obj : scope) {
            if(mapSchool <> null && mapSchool.get(obj.SCHL_CD__c) <> null) {
                obj.SCHL__c = mapSchool.get(obj.SCHL_CD__c);

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