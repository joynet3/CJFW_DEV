/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 09-20-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_DeliveryDstMgmtBatch implements  Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Bactch START');
        List<Schema.SObjectField> fieldList = COMM_Util.getFieldList('CJFW_DeliveryDestinationMgmt__c');
        List<String> fieldNameList = new List<String>();
        for (Schema.SObjectField field : fieldList) {
            fieldNameList.add(field.getDescribe().getName());
        }
        
        String allFieldString = String.join(fieldNameList, ',');

        // Date BATCH_CONDITION = Date.today().addDays(-1);
        Datetime BATCH_CONDITION = Datetime.now().addDays(-1);
        String query = ' SELECT '
                    // +     ' Id '
                    +      allFieldString
                    +  ' FROM CJFW_DeliveryDestinationMgmt__c '
                    +  ' WHERE CreatedDate >= :BATCH_CONDITION';
        
        System.debug('BATCH_CONDITION :: ' + BATCH_CONDITION);
        System.debug('query :: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<CJFW_DeliveryDestinationMgmt__c> scope) {
        System.debug('Bactch EXECUTE, size : ' + scope.size());
        
        Set<String> mgmtIds = new Set<String>();
        for (CJFW_DeliveryDestinationMgmt__c mgmt : scope) {
            mgmtIds.add(mgmt.Id);
        }

        /*
            # GET 첨부파일 Version => Map<Id(mgmt), Set(VersionIds)>
            1. ContentDocumentLink : LinkedEntityId(mgmtId), ContentDocumentId
            2. ContentDocument : LatestPublishedVersionId
        */
        Map<Id, Set<String>> attachmentMap = new Map<Id, Set<String>>();
        List<ContentDocumentLink> linkList = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN :mgmtIds];
        for (ContentDocumentLink link : linkList) {
            if(attachmentMap.containsKey(link.LinkedEntityId)){
                attachmentMap.get(link.LinkedEntityId).add(link.ContentDocument.LatestPublishedVersionId);
            }else{
                attachmentMap.put(link.LinkedEntityId, new Set<String>{ link.ContentDocument.LatestPublishedVersionId });
            }
        }

        /*
            # 메일 수신인 => Map<String(LogisticsCenter__c),Set(emails)>
            SELECT Id, Name, MailAddress__c, LogisticsCenter__c, RecordType.Name
            FROM MailRecipientMaster__c
            WHERE RecordType.Name = '물류센터 담당자 설정'
        */
        Map<String, Set<String>> centerMailMap = new Map<String, Set<String>>();
        List<MailRecipientMaster__c>  mailRecipList = [SELECT Id, Name, MailAddress__c, LogisticsCenter__c, RecordType.Name
                                                    FROM  MailRecipientMaster__c
                                                    WHERE RecordType.Name = '물류센터 담당자 설정'];
        for (MailRecipientMaster__c mail : mailRecipList) {
            if(centerMailMap.containsKey(mail.LogisticsCenter__c)){
                centerMailMap.get(mail.LogisticsCenter__c).add(mail.MailAddress__c);
            }else{
                centerMailMap.put(mail.LogisticsCenter__c, new Set<String>{ mail.MailAddress__c });
            }
        }

        /*
            # 이메일 발송
            1. 수신자 email 기준 
            2. 알림 개인화시 RecordId 기준
        */
        Map<String,List<NotiTarget>> recipientIdListMap = new Map<String,List<NotiTarget>>();
        for(CJFW_DeliveryDestinationMgmt__c target : scope) {
            String targetId = target.Id;
            NotiTarget recipientEmail = new NotiTarget('email');
            // recipientEmail.setToAddresses(new Set<String>{'yejoo.lee@dkbmc.com'});
            recipientEmail.setToAddresses(centerMailMap.get(target.LogisticsCenter__c)); //TODO
            // recipientEmail.setAttachmentIds(new Set<String>{'0680w000002gFkfAAE'}); 
            recipientEmail.setAttachmentIds(attachmentMap.get(targetId)); 

            if(recipientIdListMap.containsKey(targetId)) {
                recipientIdListMap.get(targetId).add(recipientEmail);
            }else {
                recipientIdListMap.put(targetId, new List<NotiTarget>{recipientEmail});
            }
        }

        NotificationManager.getInstance()
                            .setTargetSObjectList(scope)
                            .setRecipientListMap(
                                recipientIdListMap
                            )
                            .execute('Delivery_Destination_Mail');
        
    }

    public void finish(Database.BatchableContext BC) {
        // ...
        System.debug('Bactch FINISH');
    }

    public void execute(SchedulableContext sc) {
        // ...
        DataBase.executeBatch( new CJFW_DeliveryDstMgmtBatch(), 50);
    }
}