/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 09-18-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/

public with sharing class CJFW_DeliveryDstMgmtTriggerHandler extends TriggerHandler {

    public CJFW_DeliveryDstMgmtTriggerHandler() {
        system.debug('CJFW_DeliveryDstMgmtTriggerHandler START');
        listNew = (List<CJFW_DeliveryDestinationMgmt__c>) trigger.new;
    }

    private List<CJFW_DeliveryDestinationMgmt__c> listNew { get; set; }

    public override void afterInsert() {
        sendNotiEmail();
    }

    private void sendNotiEmail() {
        System.debug('CJFW_DeliveryDstMgmtTriggerHandler sendNotiEmail START : ' + listNew[0].Id);
        
        try {
            
            Set<String> mgmtIds = new Set<String>();
            for(CJFW_DeliveryDestinationMgmt__c mgmt : listNew) {
                mgmtIds.add(mgmt.Id);
            }

            /*
                # GET 첨부파일 Version
                1. ContentDocumentLink  -> LinkedEntityId, ContentDocumentId
                2. ContentDocument -> LatestPublishedVersionId
            */
            Set<String> documentIds = new Set<String>();
            List<ContentDocumentLink> linkList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :mgmtIds];
            for (ContentDocumentLink link : linkList) {
                documentIds.add(link.ContentDocumentId);
            }

            Set<String> attachmentVersionIds = new Set<String>();
            List<ContentDocument> docList = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :documentIds];
            for (ContentDocument doc : docList) {
                attachmentVersionIds.add(doc.LatestPublishedVersionId);
            }

            /*
                # 이메일 발송
                1. 수신자 email 기준 
                2. 알림 개인화시 RecordId 기준
            */
            Map<String,List<NotiTarget>> recipientIdListMap = new Map<String,List<NotiTarget>>();
            for(CJFW_DeliveryDestinationMgmt__c target : listNew) {
                String targetId = target.Id;
                NotiTarget recipientEmail = new NotiTarget('email');
                recipientEmail.setToAddresses(new Set<String>{'yejoo.lee@dkbmc.com'}); //TODO
                // recipientEmail.setAttachmentIds(new Set<String>{'0680w000002gFkfAAE'}); 
                recipientEmail.setAttachmentIds(attachmentVersionIds);

                if(recipientIdListMap.containsKey(targetId)) {
                    recipientIdListMap.get(targetId).add(recipientEmail);
                }else {
                    recipientIdListMap.put(targetId, new List<NotiTarget>{recipientEmail});
                }
            }

            NotificationManager.getInstance()
                                .setTargetSObjectList(listNew)
                                .setRecipientListMap(
                                    recipientIdListMap
                                )
                                .execute('Delivery_Destination_Mail');

            // List<NotiEmailTemplate> templateList = new List<NotiEmailTemplate>();
            // for (CJFW_DeliveryDestinationMgmt__c mgmt : listNew) {            
            //     //Email format Exception
            //     NotiEmailTemplate template = new NotiEmailTemplate();
            //     template.setTemplateId('DeliveryDestinationMgmtEmailTemplate');
            //     template.setTargetId(listNew[0].id);
            //     // template.setFieldsMap(new Map<String,String>{'ContactName__c'=>'test'});
            //     // template.setAttachmentIds(new Set<String>{'0690w000002v0cbAAA'});
            //     template.setToAddresses(new Set<String>{'yejoo.lee@dkbmc.com'});
            //     // template.setIsSystem(true);

            //     templateList.add(template);
            // }
            // // System.debug('templateList :: ' + templateList);
            
            // EmailAlert alert = new EmailAlert();
            // alert.send(templateList);
        }
        catch (Exception e) {
            System.debug('Exception :: ' + e.getStackTraceString());
            System.debug('Exception :: ' + e.getMessage());
        }

        System.debug('CJFW_DeliveryDstMgmtTriggerHandler sendNotiEmail END');
    }

}