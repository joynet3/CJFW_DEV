/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-03-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_ContractExpirationEmailNotiHandler extends NotiHandler{
    public override void manuFactureNoti(Object targetObject) {

        List<Contract> contractList = (List<Contract>) targetObject;
        
        System.debug('contractList ::' + contractList);
        // try {
        
        //15, 30, 45, 60, 90, 120 알림
        Map<Integer,List<Contract>> notiDayMap = new Map<Integer,List<Contract>>();// key Day
        for (Contract con : contractList) {            
            // String cyc = con.OwnerExpirationNotice__c;
            Integer cycn = Integer.valueOf(con.OwnerExpirationNotice__c);
            Integer daysDifference = -con.EndDate.daysBetween(System.today());

            System.debug('daysDifference ::' + daysDifference + '/' + cycn + '/' + con.Id);

            if (daysDifference == 15 || daysDifference == 30 || daysDifference == 45 || daysDifference == 60 || daysDifference == 90 || daysDifference == 120) {
                if(daysDifference <= cycn){ //90일로 설정, 30일 전이라면 O / 30일로 설졍 90일전이라면 X
                    if(notiDayMap.containsKey(daysDifference)){
                        notiDayMap.get(daysDifference).add(con);
                    }else{
                        notiDayMap.put(daysDifference, new List<Contract>{con});
                    }
                }
            }
        }

        System.debug('mgmtList ::' + notiDayMap);
        
        String orgDomainUrl = URL.getOrgDomainUrl().toExternalForm();

        List<NotiEmailTemplate> emailTemplateList = new List<NotiEmailTemplate>();
        for(Integer day : notiDayMap.keySet()) {
            List<Contract> dayConList = notiDayMap.get(day);
            for (Contract con : dayConList) {
                NotiEmailTemplate emailTemplate = new NotiEmailTemplate();
                emailTemplate.setTemplateId('ContractExpirationDateNotiEmailTemplete'); //Email 일 경우 Developer API 명
                emailTemplate.setFieldsMap(new Map<String, String>{
                    'FM_CustomerID__c'=>con.FM_CustomerID__c,
                    'AccountId'=>con.Account.Name,
                    'Name'=>con.Name,
                    'Day'=>String.valueOf(day),
                    'StartDate'=>String.valueOf(con.StartDate),
                    'EndDate'=>String.valueOf(con.EndDate),
                    'Link'=>orgDomainUrl+'/'+con.Id,
                    'accLink'=>orgDomainUrl+'/'+con.AccountId
                });
                // emailTemplate.setIsTargetObjectId(true);
                emailTemplate.setIsSaveAsActivity(true);
                emailTemplate.setTargetId(con.Id);
                emailTemplate.setToAddresses(new Set<String>{con.OwnerId});
                emailTemplateList.add(emailTemplate);
            }
        }
        
        //발송할 채널별 Email Template List 대입
        categorySendDataListMap.put('Email', emailTemplateList);


        // }
        // catch (Exception e) {
        //     System.debug('error ::' + e);
        //     System.debug('error ::' + e.getMessage());
        // }
    }
}