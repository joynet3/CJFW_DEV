/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-02-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_ContractExpirationEmailBatch implements  Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Batch START :: CJFW_ContractExpirationEmailBatch');
        
        List<Schema.SObjectField> fieldList = COMM_Util.getFieldList('Contract');
        List<String> fieldNameList = new List<String>();
        for (Schema.SObjectField field : fieldList) {
            fieldNameList.add(field.getDescribe().getName());
        }
        
        String allFieldString = String.join(fieldNameList, ',');
        Date condition = Date.today();
        
        String query = ' SELECT '
                    // +     ' Id '
                    +      allFieldString
                    +     ', Account.Name'
                    +  ' FROM Contract '
                    +  ' WHERE OwnerExpirationNotice__c != null AND EndDate >= :condition';

        Database.QueryLocator returnScope = Database.getQueryLocator(query);
        System.debug('query :: ' + returnScope);
        
        return returnScope;
    }

    public void execute(Database.BatchableContext BC, List<Contract> scope) {
        System.debug('Bactch EXECUTE, size : ' + scope.size());
        
        // CJFW_ContractExpirationEmailNotiHandler 에서 가공
        NotificationManager.getInstance()
                        .setTargetObject(scope)
                        .execute('Contact_Expiration_Noti_Mail');

    }

    public void finish(Database.BatchableContext BC) {
        // ...
        System.debug('Bactch FINISH');
    }

    public void execute(SchedulableContext sc) {
        // ...
        DataBase.executeBatch( new CJFW_ContractExpirationEmailBatch(), 50);
    }
}