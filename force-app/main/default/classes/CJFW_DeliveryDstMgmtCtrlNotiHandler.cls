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
            2. 알림 개인화 RecordId 기준
        */
        Map<String,Set<String>> recipientIdListMap = new Map<String,Set<String>>();
        for(CJFW_DeliveryDestinationMgmt__c target : mgmtList) {
            if(centerMailMap.get(target.LogisticsCenter__c) != null){
                recipientIdListMap.put(target.Id, centerMailMap.get(target.LogisticsCenter__c));
            }
        }


        //Email Templete Setting
        for (CJFW_DeliveryDestinationMgmt__c mgmt : mgmtList) {
            NotiEmailTemplate emailTemplate = new NotiEmailTemplate();
            emailTemplate.setTemplateId('DeliveryDstMgmtEmailTemplate'); //Email 일 경우 Developer API 명
            
            String richTextFieldContent = mgmt.Photo__c;

            String convertRichTextContent = blobToImg(mgmt.Photo__c, mgmt.Photo__c);

            emailTemplate.setFieldsMap(new Map<String, String>{ //Field Mapping
                '0' => mgmt.Account__c,
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

            emailTemplate.setIsTargetObjectId(true);
            emailTemplate.setIsSaveAsActivity(true);//Acticity 기록
            emailTemplate.setTargetId(mgmt.Id);

            emailTemplate.setAttachmentIds(attachmentMap.get(mgmt.Id));//첨부파일
            emailTemplate.setToAddresses(recipientIdListMap.get(mgmt.Id)); //물류센터 담당자
            
            emailTemplateList.add(emailTemplate);
        }


        //발송할 채널별 Email Template List 대입
        categorySendDataListMap.put('Email', emailTemplateList);

    }

    private static String blobToImg(String txtStr, String richStr){
        System.debug('txtStr => ' + txtStr);
        String res = txtStr;
        Integer i = 1;

        Matcher imgMatcher = Pattern.compile('<img(.+?)>').matcher(res);
        Matcher richImgMatcher = Pattern.compile('<img(.+?)>').matcher(richStr);
        List<String> richImgList = new List<String>();
        while(richImgMatcher.find()){
            richImgList.add(richImgMatcher.group());
        }

        System.debug('richImgList => ' + richImgList);

        Integer groupIndex = 0;
        System.debug('res : ' + res);
        while(imgMatcher.find()){
            System.debug('groupIndex => ' + groupIndex);
            String matchTag = imgMatcher.group();

            if((matchTag).indexOf('unselectable=\"on\"') > 0 && (matchTag).indexOf('data-cui-image=\"true\"') > 0){
                res = (res).replaceFirst(matchTag, richImgList.get(groupIndex) + '</img>');
                groupIndex++;
            } else if((matchTag).indexOf('unselectable=\"on\" data-cui-image=\"true\"') < 0){
                i = matchTag.indexOf('unselectable=\"on\" data-cui-image=\"true\"');
                break;
            }

            System.debug('res => ' + res);
        }

        System.debug('FINAL => ' + res);

        return res;
    }
}