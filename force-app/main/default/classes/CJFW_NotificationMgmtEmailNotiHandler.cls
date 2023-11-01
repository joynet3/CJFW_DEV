/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_NotificationMgmtEmailNotiHandler extends NotiHandler{
    public override void manuFactureNoti(Object targetObject) {

        List<NotificationManagement__c> mgmtList = (List<NotificationManagement__c>) targetObject;
        
        System.debug('mgmtList ::' + mgmtList);

        //15, 30, 45, 60, 90 알림
        Map<Integer,List<NotificationManagement__c>> notiDayMap = new Map<Integer,List<NotificationManagement__c>>();// key Day
        for (NotificationManagement__c mgmt : mgmtList) {            
            // String cyc = mgmt.Cycle__c;
            Integer cycn = Integer.valueOf(mgmt.Cycle__c);
            Integer daysDifference = -mgmt.EndDate__c.daysBetween(System.today());

            System.debug('daysDifference ::' + daysDifference + '/' + cycn + '/' + mgmt.Id);

            if (daysDifference == 15 || daysDifference == 30 || daysDifference == 45 || daysDifference == 60 || daysDifference == 90) {
                if(daysDifference <= cycn){ //90일로 설정, 30일 전이라면 O / 30일로 설졍 90일전이라면 X
                    if(notiDayMap.containsKey(daysDifference)){
                        notiDayMap.get(daysDifference).add(mgmt);
                    }else{
                        notiDayMap.put(daysDifference, new List<NotificationManagement__c>{mgmt});
                    }
                }
            }
        }

        System.debug('mgmtList ::' + notiDayMap);

        String orgDomainUrl = URL.getOrgDomainUrl().toExternalForm();

        List<NotiEmailTemplate> emailTemplateList = new List<NotiEmailTemplate>();
        for(Integer day : notiDayMap.keySet()) {
            List<NotificationManagement__c> dayMgmtList = notiDayMap.get(day);
            for (NotificationManagement__c mgmt : dayMgmtList) {
                NotiEmailTemplate emailTemplate = new NotiEmailTemplate();
                emailTemplate.setTemplateId('NotificationMgmtEmailTemplete'); //Email 일 경우 Developer API 명
                emailTemplate.setFieldsMap(new Map<String, String>{
                        'FM_CustomerID__c'=>mgmt.FM_CustomerID__c,
                        'Account__c'=>mgmt.Account__r.Name,
                        'Name'=>mgmt.Name,
                        'Day'=>String.valueOf(day),
                        'StartDate__c'=>String.valueOf(mgmt.StartDate__c),
                        'EndDate__c'=>String.valueOf(mgmt.EndDate__c),
                        'Description__c'=>mgmt.Description__c,
                        'Link'=>orgDomainUrl+'/'+mgmt.Id,
                        'accLink'=>orgDomainUrl+'/'+mgmt.Account__c
                    });
                // emailTemplate.setIsTargetObjectId(true);
                emailTemplate.setIsSaveAsActivity(true);
                emailTemplate.setTargetId(mgmt.Id);
                emailTemplate.setToAddresses(new Set<String>{mgmt.CreatedById});
                emailTemplateList.add(emailTemplate);
            }
        }
        
        //발송할 채널별 Email Template List 대입
        categorySendDataListMap.put('Email', emailTemplateList);
    }
}