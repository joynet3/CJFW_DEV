/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 08-29-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-29-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMManagerSearchController {
    /**
    * @description 선택한 recordId를 이용해 Account정보/ Contact정보 가져와 MDM 고객 등록 요청(관리처)에 보내주기
    * 
    * @return      `String`
    */ 
    @AuraEnabled
    public static  List<Map<String, Object>> getContactInfo(String selectedId){
        system.debug('### CJFW_MDMManagerSearchController.getContactInfo(String selectedId) 모달 ### ');
        system.debug('>>> managerModal Account Id ' + selectedId);
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        // List<Account> accList = [SELECT Id,
        //                                  (SELECT Id, Lastname, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c FROM Contacts) 
        //                           FROM Account 
        //                           WHERE Id = :selectedId 
        //                           LIMIT 1];
        List<Contact> contactList = [SELECT Id, LastName, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c
                                     FROM Contact
                                     WHERE AccountId = :selectedId];

        system.debug('contactList ' + JSON.serialize(contactList));
         if(!contactList.isEmpty()){
            for(Contact con : contactList){
                Map<String, Object> contactData = new Map<String, Object>();
                integer i = 1;
                contactData.put('No', i);
                contactData.put('PV_NAME1_VK__c', con.LastName);
                contactData.put('PV_KNVKGB_lu__c', '');
                contactData.put('PV_KNVKGB__c', con.PV_KNVKGB__c);
                contactData.put('PV_TELF1_VK__c', con.MobilePhone);
                contactData.put('PV_EMAIL_VK__c', con.Email);
                contactData.put('PV_PAFKT_VK__c', con.PV_PAFKT_VK__c);
                contactData.put('PV_ABTNR_VK__c', con.Department);
                contactData.put('PV_TALKT_VK__c', con.PV_TALKT_VK__c);
                contactData.put('Contact__c', con.Id);
                result.add(contactData);
                i++;
            }
         }
        
        // if (!accList.isEmpty()) {
        //     for (Contact con : accList[0].Contacts) {
        //         Map<String, Object> contactData = new Map<String, Object>();
        //         integer i = 1;
        //         contactData.put('No', i);
        //         contactData.put('PV_NAME1_VK__c', con.LastName);
        //         contactData.put('PV_KNVKGB_lu__c', '');
        //         contactData.put('PV_KNVKGB__c', con.PV_KNVKGB__c);
        //         contactData.put('PV_TELF1_VK__c', con.MobilePhone);
        //         contactData.put('PV_EMAIL_VK__c', con.Email);
        //         contactData.put('PV_PAFKT_VK__c', con.PV_PAFKT_VK__c);
        //         contactData.put('PV_ABTNR_VK__c', con.Department);
        //         contactData.put('PV_TALKT_VK__c', con.PV_TALKT_VK__c);
        //         contactData.put('Contact__c', con.Id);
        //         result.add(contactData);
        //         i++;
        //     }
        // }
        system.debug('result ' + JSON.serialize(result));
        return result;
    }
}