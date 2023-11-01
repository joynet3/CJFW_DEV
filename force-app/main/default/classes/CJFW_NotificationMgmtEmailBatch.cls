/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-31-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_NotificationMgmtEmailBatch implements  Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{
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
                    +  ' FROM NotificationManagement__c '
                    +  ' WHERE Cycle__c != null AND EndDate__c >= :condition';
                    // +  ' WHERE Name =\'Test\' ';

        Database.QueryLocator returnScope = Database.getQueryLocator(query);
        System.debug('query :: ' + returnScope);
        
        return returnScope;
    }

    public void execute(Database.BatchableContext BC, List<NotificationManagement__c> scope) {
        System.debug('Bactch EXECUTE, size : ' + scope.size());
        
        // CJFW_NotificationMgmtEmailNotiHandler 에서 가공
        NotificationManager.getInstance()
                        .setTargetObject(scope)
                        .execute('Notification_Mgmt_Noti_Mail');

    }

    public void finish(Database.BatchableContext BC) {
        // ...
        System.debug('Bactch FINISH');
    }

    public void execute(SchedulableContext sc) {
        // ...
        DataBase.executeBatch( new CJFW_NotificationMgmtEmailBatch(), 50);
    }
}