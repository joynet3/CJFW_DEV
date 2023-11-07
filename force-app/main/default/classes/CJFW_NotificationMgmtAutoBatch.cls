/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_NotificationMgmtAutoBatch implements  Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Batch START :: CJFW_NotificationMgmtEmailBatch');
        List<Schema.SObjectField> fieldList = COMM_Util.getFieldList('NotificationManagement__c');
        List<String> fieldNameList = new List<String>();
        for (Schema.SObjectField field : fieldList) {
            fieldNameList.add(field.getDescribe().getName());
        }
        
        String allFieldString = String.join(fieldNameList, ',');
        Date condition = Date.today();
        
        String query = ' SELECT '
                    // +     ' Id '
                    +      allFieldString
                    +     ', Account__r.Name'
                    +     ', Account__r.OwnerId'
                    +  ' FROM NotificationManagement__c '
                    +  ' WHERE AutoUpdate__c = true AND IsUpdated__c != true AND EndDate__c < :condition';
                    // +  ' WHERE Name =\'Test\' ';

        Database.QueryLocator returnScope = Database.getQueryLocator(query);
        System.debug('query :: ' + returnScope);
        
        return returnScope;
    }

    public void execute(Database.BatchableContext BC, List<NotificationManagement__c> scope) {
        System.debug('Bactch EXECUTE, size : ' + scope.size());
        
        List<NotificationManagement__c> cloneList = new List<NotificationManagement__c>();
        List<NotificationManagement__c> updateList = new List<NotificationManagement__c>();
        for (NotificationManagement__c noti : scope) {
            NotificationManagement__c cl = noti.clone(false);
            cl.StartDate__c = Date.today();
            cloneList.add(cl);
            noti.IsUpdated__c = true;
            updateList.add(noti);
        }

        insert cloneList;
        update updateList;
        // System.debug('Bactch EXECUTE, cloneList : ' + cloneList.size() + '/' + cloneList);
        // System.debug('Bactch EXECUTE, updateList : ' + updateList.size() + '/' + updateList);
    }

    public void finish(Database.BatchableContext BC) {
        // ...
        System.debug('Bactch FINISH');
    }

    public void execute(SchedulableContext sc) {
        // ...
        DataBase.executeBatch( new CJFW_NotificationMgmtAutoBatch(), 50);
    }
}