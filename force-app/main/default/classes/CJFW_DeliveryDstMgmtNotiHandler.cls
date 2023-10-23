/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_DeliveryDstMgmtNotiHandler extends NotiHandler{
    public override void manuFactureNoti(Object targetObject) {
        
        // User Id : Mgmt List (html) -> Map
        Map<Id, String> userMgmtMap = new Map<Id,String>();
        
        String orgDomainUrl = URL.getOrgDomainUrl().toExternalForm();

        List<CJFW_DeliveryDestinationMgmt__c> mgmtList = (List<CJFW_DeliveryDestinationMgmt__c>) targetObject;
        for (CJFW_DeliveryDestinationMgmt__c mgmt : mgmtList) {
            String userId = mgmt.OwnerId;
            if(userMgmtMap.containsKey(userId)) {
                String multiTr = userMgmtMap.get(userId);
                multiTr += '<tr><td><a href="'+orgDomainUrl+'/'+mgmt.Id+'">'+mgmt.Name+'</a></td></tr>';
                userMgmtMap.put(userId, multiTr);
            }else {
                userMgmtMap.put(userId, '<tr><td><a href="'+orgDomainUrl+'/'+mgmt.Id+'">'+mgmt.Name+'</a></td></tr>');
            }
        }

        List<NotiEmailTemplate> emailTemplateList = new List<NotiEmailTemplate>();

        for(Id userId : userMgmtMap.keySet()) {
            NotiEmailTemplate emailTemplate = new NotiEmailTemplate();
            emailTemplate.setTemplateId('DeliveryDstMgmtNotiEmailTemplete'); //Email 일 경우 Developer API 명
            emailTemplate.setFieldsMap(new Map<String, String>{'0'=>userMgmtMap.get(userId)});
            emailTemplate.setIsTargetObjectId(true);
            // emailTemplate.setIsSaveAsActivity(true);
            // emailTemplate.setTargetId(mgmtList[0].Id);
            emailTemplate.setToAddresses(new Set<String>{userId});
            emailTemplateList.add(emailTemplate);
        }

        //발송할 채널별 Email Template Lis 대입
        categorySendDataListMap.put('Email', emailTemplateList);
    }
}