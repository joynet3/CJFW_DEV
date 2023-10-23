/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_DeliveryDstMgmtCtrlNotiHandler extends NotiHandler{
    public override void manuFactureNoti(Object targetObject) {
        List<CJFW_DeliveryDestinationMgmt__c> mgmtList = (List<CJFW_DeliveryDestinationMgmt__c>) targetObject;
        List<NotiEmailTemplate> emailTemplateList = new List<NotiEmailTemplate>();

        Set<String> mgmtIds = new Set<String>();
        for (CJFW_DeliveryDestinationMgmt__c mgmt : mgmtList) {
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
        System.debug('attachmentMap : ' + attachmentMap);

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
        System.debug('centerMailMap : ' + centerMailMap);

        /*
            # 이메일 발송
            1. 수신자 email 기준 
            2. 알림 개인화 RecordId 기준
        */
        // Map<String,Set<String>> recipientIdListMap = new Map<String,Set<String>>();
        // for(CJFW_DeliveryDestinationMgmt__c target : mgmtList) {
        //     if(centerMailMap.get(target.LogisticsCenter__c) != null){
        //         recipientIdListMap.put(target.Id, centerMailMap.get(target.LogisticsCenter__c));
        //     }
        // }
        // System.debug('recipientIdListMap : ' + recipientIdListMap);

        //Email Templete Setting
        for (CJFW_DeliveryDestinationMgmt__c mgmt : mgmtList) {
            NotiEmailTemplate emailTemplate = new NotiEmailTemplate();
            emailTemplate.setTemplateId('DeliveryDstMgmtEmailTemplate'); //Email 일 경우 Developer API 명
            
            String richTextFieldContent = mgmt.Photo__c;
            String convertRichTextContent ='';
            if(richTextFieldContent != null){
                Matcher matcher = pattern.compile('<img(.+?)>').matcher(mgmt.Photo__c);

                while ( matcher.find() ) {
                    // get the image tag html
                    String imageTag = matcher.group();
                    System.debug( 'imageTag=' + imageTag );

                    String imageURL = imageTag.substringBetween( ' src="', '"' );
                    System.debug( 'imageURL=' + imageURL );

                    String decodedURL = imageURL.unescapeHtml4();
                    System.debug( 'decodedURL=' + decodedURL );

                    PageReference page = new PageReference( decodedURL );
                    Blob b = page.getContent();
                    System.debug( 'blob=' + b );
                    
                    string strImageBase64 = EncodingUtil.base64Encode(b);
                    System.debug('data:image/png;Base64,' + strImageBase64);
                    
                    convertRichTextContent += '<img src="data:image/png;base64,' + strImageBase64 + '">';
                    System.debug('test:' + convertRichTextContent);
                    
                }
            }

            emailTemplate.setFieldsMap(new Map<String, String>{ //Field Mapping
                '0' => mgmt.Account__r.Name,
                '1' => mgmt.FM_CustomerID__c,
                '2' => mgmt.ContactName__c,
                '3' => mgmt.Phone__c,
                '4' => mgmt.FM_Address__c,
                '5' => mgmt.FM_MA__c,
                '6' => mgmt.TotalSize__c,
                '7' => String.valueOf(mgmt.InitialDate__c),
                '8' => mgmt.InitialRequestTime__c,
                '9' => mgmt.InitialRequestAfterTime__c,
                '10' => mgmt.Key__c,
                '11' => mgmt.InspectionYN__c,
                '12' => mgmt.Inspector__c,
                '13' => convertRichTextContent,//사진파일
                '14' => mgmt.DeliveryLocation__c,
                '15' => mgmt.LoadingInfo__c,
                '16' => mgmt.Condition__c,
                '17' => mgmt.ReturnLocation__c,
                '18' => mgmt.AllowedVehicle__c,
                '19' => mgmt.LogisticRemark__c,
                '20' => mgmt.OrderForm__c,
                '21' => mgmt.FM_HeadOfficeCode__c,
                '22' => mgmt.CenterRemark__c
            });

            // emailTemplate.setIsTargetObjectId(true);
            emailTemplate.setIsSaveAsActivity(true);//Acticity 기록
            emailTemplate.setTargetId(mgmt.Id);

            emailTemplate.setAttachmentIds(attachmentMap.get(mgmt.Id));//첨부파일
            emailTemplate.setToAddresses(centerMailMap.get(mgmt.LogisticsCenter__c)); //물류센터 담당자
            // emailTemplate.setToAddresses(new Set<String>{'yejoo1.lee@cj.net'});
            
            emailTemplateList.add(emailTemplate);
        }

        System.debug('emailTemplateList : ' + emailTemplateList);

        //발송할 채널별 Email Template List 대입
        categorySendDataListMap.put('Email', emailTemplateList);
    }

}