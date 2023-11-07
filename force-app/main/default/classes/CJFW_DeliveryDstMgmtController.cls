/**
 * @description       : 배송처 관리 (작성 완료시 이메일 발송)
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-02-2023
 * @last modified by  : yejoo.lee@dkbmc.com
 * @since 2023-10-11  내용 작성
**/

public with sharing class CJFW_DeliveryDstMgmtController {
    @AuraEnabled
    public static Map<String,Object> sendEmail(String recordId){
        Map<String,Object> resultMap = new  Map<String,Object>();
        try {
            
            List<Schema.SObjectField> fieldList = COMM_Util.getFieldList('CJFW_DeliveryDestinationMgmt__c');
            List<String> fieldNameList = new List<String>();
            for (Schema.SObjectField field : fieldList) {
                fieldNameList.add(field.getDescribe().getName());
            }
            
            String allFieldString = String.join(fieldNameList, ',');

            String query = ' SELECT '
                        // +     ' Id '
                        +      allFieldString
                        +  '   , Account__r.Name '
                        +  '   , ManagementAccount__r.Name '
                        +  ' FROM CJFW_DeliveryDestinationMgmt__c '
                        +  ' WHERE Id =:recordId ';

            // System.debug('query :: ' + query);
            List<CJFW_DeliveryDestinationMgmt__c> scope = Database.query(query);

            // CJFW_DeliveryDstMgmtCtrlNotiHandler 에서 가공 -> Dyanamic 으로 변경 23-10-23
            Map<String,Object> emailResult = NotificationManager.getInstance()
                                                .setTargetObject(scope)
                                                .execute('Delivery_Destination_Mail');
            
            //Test
            // Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // email.setToAddresses(new List<String> {'yejoo.lee1@cj.net','hyunwook.jin@cj.net'});
            // email.setSubject('이메일 제목');
            // email.setHtmlBody('이메일 본문입니다.');
            // Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});

            // Set<String> mgmtIds = new Set<String>();
            // mgmtIds.add(recordId);

            // for (CJFW_DeliveryDestinationMgmt__c mgmt : scope) {
            //         mgmtIds.add(mgmt.Id);
            // }
    
            // /*
            //     # GET 첨부파일 Version => Map<Id(mgmt), Set(VersionIds)>
            //     1. ContentDocumentLink : LinkedEntityId(mgmtId), ContentDocumentId
            //     2. ContentDocument : LatestPublishedVersionId
            // */
            // Map<Id, Set<String>> attachmentMap = new Map<Id, Set<String>>();
            // List<ContentDocumentLink> linkList = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId 
            //                                         FROM ContentDocumentLink 
            //                                         WHERE LinkedEntityId IN :mgmtIds];
            // for (ContentDocumentLink link : linkList) {
            //     if(attachmentMap.containsKey(link.LinkedEntityId)){
            //         attachmentMap.get(link.LinkedEntityId).add(link.ContentDocument.LatestPublishedVersionId);
            //     }else{
            //         attachmentMap.put(link.LinkedEntityId, new Set<String>{ link.ContentDocument.LatestPublishedVersionId });
            //     }
            // }
    
            // /*
            //     # 메일 수신인 => Map<String(LogisticsCenter__c),Set(emails)>
            //     SELECT Id, Name, MailAddress__c, LogisticsCenter__c, RecordType.Name
            //     FROM MailRecipientMaster__c
            //     WHERE RecordType.Name = '물류센터 담당자 설정'
            // */
            // Map<String, Set<String>> centerMailMap = new Map<String, Set<String>>();
            // List<MailRecipientMaster__c>  mailRecipList = [SELECT Id, Name, MailAddress__c, LogisticsCenter__c, RecordType.Name
            //                                             FROM  MailRecipientMaster__c
            //                                             WHERE RecordType.Name = '물류센터 담당자 설정'];
            // for (MailRecipientMaster__c mail : mailRecipList) {
            //     if(centerMailMap.containsKey(mail.LogisticsCenter__c)){
            //         centerMailMap.get(mail.LogisticsCenter__c).add(mail.MailAddress__c);
            //     }else{
            //         centerMailMap.put(mail.LogisticsCenter__c, new Set<String>{ mail.MailAddress__c });
            //     }
            // }
    
            // /*
            //     # 이메일 발송
            //     1. 수신자 email 기준 
            //     2. 알림 개인화 RecordId 기준
            // */
            // Map<String,List<NotiTarget>> recipientIdListMap = new Map<String,List<NotiTarget>>();
            // // for(CJFW_DeliveryDestinationMgmt__c target : scope) {
            // String targetId = recordId;
            // List<CJFW_DeliveryDestinationMgmt__c> target = [SELECT Id, Name, LogisticsCenter__c FROM CJFW_DeliveryDestinationMgmt__c WHERE Id =:targetId];

            // NotiTarget recipientEmail = new NotiTarget('email');

            // recipientEmail.setToAddresses(centerMailMap.get(target[0].LogisticsCenter__c));// recipientEmail.setToAddresses(new Set<String>{'yejoo.lee@dkbmc.com'});
            // recipientEmail.setAttachmentIds(attachmentMap.get(targetId)); // recipientEmail.setAttachmentIds(new Set<String>{'0680w000002gFkfAAE'}); 

            // if(recipientIdListMap.containsKey(targetId)) {
            //     recipientIdListMap.get(targetId).add(recipientEmail);
            // }else {
            //     recipientIdListMap.put(targetId, new List<NotiTarget>{recipientEmail});
            // }
            // // }
            
            // Map<String,Object> emailResult = NotificationManager.getInstance()
            //                                     // .setTargetSObjectList(target)
            //                                     // .setTargetObject(target)
            //                                     .setTargetIdSet(new Set<String>{targetId})
            //                                     .setRecipientListMap(recipientIdListMap)
            //                                     .execute('Delivery_Destination_Mail');
            //                                     // .execute('Delivery_Destination_Noti_Mail');

            resultMap.put('STATUS', 'S');
            resultMap.put('emailResult', emailResult);
            System.debug('emailResult : ' + emailResult);

        } catch (Exception e) {
            resultMap.put('STATUS', 'E');
            resultMap.put('MESSAGE', e.getMessage());
            resultMap.put('TRACE', e.getStackTraceString());
            // throw new AuraHandledException(e.getMessage());
        }

        return resultMap;
    }

    /**
     * 작성완료 시 Completed__c true 변경
     */
    @AuraEnabled
    public static Map<String,Object> changeCompleted(String recordId){

        Map<String,Object> resultMap = new  Map<String,Object>();
        List<CJFW_DeliveryDestinationMgmt__c> updateDelivery = new List<CJFW_DeliveryDestinationMgmt__c>();

        try {
            List<CJFW_DeliveryDestinationMgmt__c> deliveryList = [SELECT Id, Name, Completed__c
                                                                FROM CJFW_DeliveryDestinationMgmt__c
                                                                WHERE Id =: recordId];

            for (CJFW_DeliveryDestinationMgmt__c delivery : deliveryList) {
                delivery.Completed__c = true;
                updateDelivery.add(delivery);
            }
            
            update updateDelivery;
            resultMap.put('STATUS', 'S');
            resultMap.put('resultList', updateDelivery);
            
        } catch (Exception e) {
            resultMap.put('STATUS', 'E');
            resultMap.put('MESSAGE', e.getMessage());
            resultMap.put('TRACE', e.getStackTraceString());
        }

        return resultMap;
    }
    
}