/**
 * @description       : 미완료된 배송처에 관해 이메일 알림을 보냅니다. (17시 실행) TODO
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-13-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_DeliveryDstMgmtNotiEmailBatch implements  Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Batch START :: CJFW_DeliveryDstMgmtNotiEmailBatch');
        List<Schema.SObjectField> fieldList = COMM_Util.getFieldList('CJFW_DeliveryDestinationMgmt__c');
        List<String> fieldNameList = new List<String>();
        for (Schema.SObjectField field : fieldList) {
            fieldNameList.add(field.getDescribe().getName());
        }
        
        String allFieldString = String.join(fieldNameList, ',');

        String query = ' SELECT '
                    // +     ' Id '
                    +      allFieldString
                    +  ' FROM CJFW_DeliveryDestinationMgmt__c '
                    +  ' WHERE LastActivityDate = null OR Completed__c = false ';
                    // +  ' WHERE LastActivityDate = null';
                    // +  ' WHERE LogisticsCenter__c = \'장성센터\'';//Test
        
        System.debug('query :: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<CJFW_DeliveryDestinationMgmt__c> scope) {
        System.debug('Bactch EXECUTE, size : ' + scope.size());
        
        // CJFW_DeliveryDstMgmtNotiHandler 에서 가공
        NotificationManager.getInstance()
                            .setTargetObject(scope)
                            .execute('Delivery_Destination_Noti_Mail');

    }

    public void finish(Database.BatchableContext BC) {
        // ...
        System.debug('Bactch FINISH');
    }

    public void execute(SchedulableContext sc) {
        // ...
        DataBase.executeBatch( new CJFW_DeliveryDstMgmtNotiEmailBatch(), 50);
    }
}