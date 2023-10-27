/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-27-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public without sharing class CJFW_DeliveryDstMgmtCtrlNotiHandler extends NotiHandler{
    public override void manuFactureNoti(Object targetObject) {
        List<CJFW_DeliveryDestinationMgmt__c> mgmtList = (List<CJFW_DeliveryDestinationMgmt__c>) targetObject;
        List<NotiEmailTemplate> emailTemplateList = new List<NotiEmailTemplate>();

        /*
            # Rich Text Img 처리 => Map<Id(mgmt), String(url)>
            1. ContentVersion : title, PathOnClient, VersionData(Blob)
            2. ContentDistribution : ContentDownloadUrl
            3. ContentDocumentLink 업데이트
        */

        // 1. ContentVersion 생성
        List<ContentVersion> cvList = new List<ContentVersion>();
        for (CJFW_DeliveryDestinationMgmt__c mgmt : mgmtList) {
            List<String> contentList = new List<String>();
            if(mgmt.Photo__c != null){//Rich Text
                Matcher matcher = pattern.compile('<img(.+?)>').matcher(mgmt.Photo__c);
                while ( matcher.find() ) {
                    String imageTag = matcher.group();
                    // System.debug( 'imageTag=' + imageTag );
                    String imageURL = imageTag.substringBetween( ' src="', '"' );
                    // System.debug( 'imageURL=' + imageURL );
                    String decodedURL = imageURL.unescapeHtml4();
                    // System.debug( 'decodedURL=' + decodedURL );
                    PageReference page = new PageReference( decodedURL );
                    Blob b = page.getContent();
                    // System.debug( 'blob=' + b );

                    ContentVersion cv = new ContentVersion(
                        title = '배송정보 납품장소',
                        PathOnClient = '배송정보 납품장소.png',
                        VersionData = b,
                        MgmtId__c = mgmt.Id
                    );
                    cvList.add(cv);
                }
            }
        }
        insert cvList;
        
        // 2. ContentDistribution 생성 (Public Link 생성 : ContentDownloadUrl)
        Set<String> cvIdSet = new Set<String>();
        List<ContentDistribution> cdbList = new List<ContentDistribution>();
        for (ContentVersion cv : cvList) {
            cvIdSet.add(cv.Id);
            
            ContentDistribution cdb = new ContentDistribution (
                ContentVersionId = cv.Id,
                Name = cv.Title,
                PreferencesAllowViewInBrowser = true,
                PreferencesLinkLatestVersion =true
            );
            cdbList.add(cdb);
        }
        insert cdbList;

        //List 정보
        cvList = [SELECT Id, ContentDocumentId, MgmtId__c FROM ContentVersion WHERE Id IN :cvIdSet];
        cdbList = [SELECT Id, ContentVersion.MgmtId__c, ContentDownloadUrl, ContentVersionId FROM ContentDistribution WHERE ContentVersionId IN :cvIdSet];
        
        //이미지 태그 가공
        Map<String, List<String>> imgUrlMap = new Map<String, List<String>>();
        for (ContentDistribution cdb : cdbList) {
            if(imgUrlMap.containsKey(cdb.ContentVersion.MgmtId__c)){
                imgUrlMap.get(cdb.ContentVersion.MgmtId__c).add('<img src=\"' + cdb.ContentDownloadUrl + '\" style="width:100%;">');
            }else{
                imgUrlMap.put(cdb.ContentVersion.MgmtId__c, new List<String>{'<img src=\"' + cdb.ContentDownloadUrl + '\" style="width:100%;">'});
            }
        }

        // 3. Record Id 랑 Link
        Set<String> cdIdSet = new Set<String>();
        for (ContentVersion cv : cvList) {
            cdIdSet.add(cv.ContentDocumentId);
        }

        List<ContentDocumentLink> richfilelinkList = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersion.MgmtId__c, LinkedEntityId 
                                                        FROM contentdocumentLink
                                                        WHERE ContentDocumentId IN :cdIdSet];
        List<ContentDocumentLink> insertLinkList = new List<ContentDocumentLink>();
        
        for (ContentDocumentLink l : richfilelinkList) {
            ContentDocumentLink link = new ContentDocumentLink(
                LinkedEntityId = l.ContentDocument.LatestPublishedVersion.MgmtId__c,
                ContentDocumentId = l.ContentDocumentId
            );
            insertLinkList.add(link);
        }
        System.debug('updateLinkList:' +insertLinkList);
        insert insertLinkList;

        /*
            # GET 첨부파일 Version => Map<Id(mgmt), Set(VersionIds)>
            1. ContentDocumentLink : LinkedEntityId(mgmtId), ContentDocumentId
            2. ContentDocument : LatestPublishedVersionId
        */
        Set<String> mgmtIds = new Set<String>();
        for (CJFW_DeliveryDestinationMgmt__c mgmt : mgmtList) {
            mgmtIds.add(mgmt.Id);
        }

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

            String modifiedRichText = '';
            if(mgmt.Photo__c != null){            
                String richText = mgmt.Photo__c;
                
                // 새로운 <img src= 태그들의 리스트
                List<String> newImgTags = imgUrlMap.get(mgmt.Id);

                Matcher matcher = pattern.compile('<img(.+?)>').matcher(mgmt.Photo__c);
                
                Integer lastIndex = 0;
                Integer newImgTagIndex = 0;
                
                while (matcher.find()) {
                    Integer matchStartIndex = matcher.start();
                    Integer matchEndIndex = matcher.end();
                
                    // 이전 일치하지 않은 부분을 결과 문자열에 추가
                    modifiedRichText += richText.substring(lastIndex, matchStartIndex);
                
                    // 새로운 <img src= 태그 추가
                    String newImgTag = newImgTags[newImgTagIndex];
                    modifiedRichText += newImgTag;
                
                    lastIndex = matchEndIndex;
                    
                     // 다음 대체 태그 인덱스 계산
                    if (newImgTagIndex < newImgTags.size() - 1) {
                        newImgTagIndex++;
                    } else {
                        // 대체할 이미지가 더 이상 없으면 처음으로 돌아감
                        newImgTagIndex = 0;
                    }
                }
                
                // 나머지 일치하지 않은 부분을 결과 문자열에 추가
                modifiedRichText += richText.substring(lastIndex);
                
                System.debug('modifiedRichText: ' + modifiedRichText);
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
                '8-1' => mgmt.InitialRequestStartTime__c,
                '8-2' => mgmt.InitialRequestEndTime__c,
                '9-1' => mgmt.InitialRequestAfterStartTime__c,
                '9-2' => mgmt.InitialRequestAfterEndTime__c,
                '10' => mgmt.Key__c,
                '11' => mgmt.InspectionYN__c,
                '12' => mgmt.Inspector__c,
                // '13' => imgUrlMap.get(mgmt.Id),//사진파일
                '13' => modifiedRichText,//사진파일
                '14' => mgmt.DeliveryLocation__c,
                // '15' => mgmt.LoadingInfo__c, //--> *적재방법 및 장소(사진 첨부)
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
            emailTemplate.setIsUseOWE(true);//??
            emailTemplate.setTargetId(mgmt.Id);

            emailTemplate.setAttachmentIds(attachmentMap.get(mgmt.Id));//첨부파일
            emailTemplate.setToAddresses(centerMailMap.get(mgmt.LogisticsCenter__c)); //물류센터 담당자
            // emailTemplate.setToAddresses(new Set<String>{'yejoo.lee@dkbmc.com'});
            
            emailTemplateList.add(emailTemplate);
        }

        System.debug('emailTemplateList : ' + emailTemplateList);

        //발송할 채널별 Email Template List 대입
        categorySendDataListMap.put('Email', emailTemplateList);
    }

}