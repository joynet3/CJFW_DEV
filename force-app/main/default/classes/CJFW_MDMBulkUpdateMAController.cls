/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkUpdateMAController {
    
    /**
    * Save 버튼을 클릭 했을 때 호출
    * 
    * @params mdmContacts : 화면 mdmContact 데이터
    * 
    */
    @AuraEnabled
    public static SaveResult doSave(List<MDMRegRequestContact__c> mdmContacts, String recordId) {

        system.debug('# CJFW_MDMBulkCreateMAController >>> doSave ');

        SaveResult saveResult = new SaveResult();
        system.debug('>>>doSave # mdmContacts ' + JSON.serialize(mdmContacts));
        system.debug('>>>doSave # recordId ' + recordId);

        List<MDMRegRequestContact__c> contactList = new List<MDMRegRequestContact__c>();

        // 각종 ID 필요한 MDMReferenceCode__c 조회해서 Id값 가지고 오기
        Set<String> codeSet = new Set<String>();
        for(MDMRegRequestContact__c con : mdmContacts){
            String upperCode = con.PV_KNVKGB__c;
            codeSet.add(upperCode.toUpperCase());
            System.debug('# upperCode => ' + upperCode);
            codeSet.remove(null);
        }

        System.debug('# codeSet => ' + codeSet);
        
        List<MDMReferenceCode__c> referenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c = :codeSet AND GROUPID__c = 'KNVKGB'];

        System.debug('# referenceCodeList => ' + referenceCodeList);

        // Key : code , value : Id
        Map<String, String> codeToIdMap = new Map<String, String>();
        for(MDMReferenceCode__c mdmCode :referenceCodeList){
            codeToIdMap.put(mdmCode.Code__c, mdmCode.Id);
        }

        System.debug('# codeToIdMap => ' + codeToIdMap);

        // 받아 온 CustomerId로 MDM 혹은 Account로부터 Id 가지고 오기
        Set<String> idSet = new Set<String>();
        for(MDMRegRequestContact__c con : mdmContacts){
            idSet.add(con.MDMRegRequestCustomer__c);
            idSet.remove(null);
        }

        // Key : code , value : Id
        Map<String, String> kunnrToIdMap = new Map<String, String>();

        // Key : code , value : Id
        Map<String, String> newMDMToIdMap = new Map<String, String>();

        if(recordId != null) {
            
            List<MDMRegRequestCustomer__c> customerList = [SELECT Id, PV_KUNNR__c FROM MDMRegRequestCustomer__c WHERE PV_KUNNR__c = :idSet AND MDMRegRequestBulkCustomer__c = :recordId];

            System.debug('# <MDM> customerList => ' + customerList);
    
            for(MDMRegRequestCustomer__c cus : customerList){
                kunnrToIdMap.put(cus.PV_KUNNR__c, cus.Id);
            }
    
            System.debug('# kunnrToIdMap => ' + kunnrToIdMap);

        } else {

            List<Account> customerList = [SELECT Id, Name, CustomerId__c, CustomerType__c, SalesForm__c, CustomerStatus__c, PV_BLCKYN__c, IsHeadShopUseYN__c, IsAffiliatedcompanyYN__c, IsPrintVirtualAccount__c, IsFaceToFaceInspectionStatus__c, IsInitialDeliveryFTFInspection__c, IsBusinessPlaceKey__c, InitialDeliveryShare__c, KXOTD__c FROM Account WHERE CustomerId__c = :idSet];

            System.debug('# <Acc> customerList => ' + customerList);

            // MDM 요청 insert할 객체들 담기
            List<MDMRegRequestCustomer__c> mdmList = new List<MDMRegRequestCustomer__c>();

            MDMRegRequestBulkCustomer__c mdmRequestbulk = new MDMRegRequestBulkCustomer__c();

            String bulkName = customerList[0].Name;
            mdmRequestbulk.RequestType__c = 'Edit';
            
            mdmRequestbulk.Name = bulkName + ' 외 ' + (customerList.size() -1) + '건';

            insert mdmRequestbulk;
            
            for(Account acc : customerList) {

                MDMRegRequestCustomer__c customer = new MDMRegRequestCustomer__c();

                String recordIdEx = null;
                List<String> managementList = new List<String>{'C03', 'C04', 'C11'};

                if(acc.CustomerType__c == 'C01') {
                    recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMParent').getRecordTypeId();
                } else if(acc.CustomerType__c == 'C02') {
                    recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMChild').getRecordTypeId();
                } else if(managementList.contains(acc.CustomerType__c)) {
                    recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMManagement').getRecordTypeId();
                }

                customer.MDMRegRequestBulkCustomer__c    =       mdmRequestbulk.id;
                customer.RecordTypeId                    =       String.isBlank(acc.CustomerType__c) ? null : recordIdEx;
                customer.PV_KUNNR__c                     =       acc.CustomerId__c;
                customer.PV_NAME1__c                     =       acc.Name;
                customer.PV_BLCKYN__c                    =       acc.PV_BLCKYN__c;
                customer.PV_HDOFFICEYN__c                =       acc.IsHeadShopUseYN__c;
                
                Boolean isKxOtd = false;
                if(acc.KXOTD__c == 'Y') {
                    isKxOtd = true;
                } else if(acc.KXOTD__c == 'N') {
                    isKxOtd = false;
                }

                Boolean isFdInfo = false;
                if(acc.InitialDeliveryShare__c == 'Y') {
                    isFdInfo = true;
                } else if(acc.InitialDeliveryShare__c == 'N') {
                    isFdInfo = false;
                }
                
                customer.PV_SUBSIDIARYYN__c              =       acc.IsAffiliatedcompanyYN__c;
                customer.PV_VACCPRTEXCYN__c              =       acc.IsPrintVirtualAccount__c;
                customer.PV_EXAMYN__c                    =       acc.IsFaceToFaceInspectionStatus__c;
                customer.PV_KEYYN__c                     =       acc.IsBusinessPlaceKey__c;
                customer.PV_KXOTD__c                     =       isKxOtd;
                customer.PV_FDINFO__c                    =       isFdInfo;
                customer.PV_ISFDFTF__c                   =       acc.IsInitialDeliveryFTFInspection__c;
                customer.PV_BUSAB__c                     =       acc.SalesForm__c;
                customer.PV_CESSION_KZ__c                =       acc.CustomerStatus__c;
                customer.RequestType__c                  =       'Edit';

                mdmList.add(customer);

            }

            System.debug('# <Acc> mdmList => ' + mdmList);

            insert mdmList;

            // 커스텀ID : ID
            for(MDMRegRequestCustomer__c mdm : mdmList) {
                newMDMToIdMap.put(mdm.PV_KUNNR__c, mdm.Id);
            }

            System.debug('# <Acc> newMDMToIdMap => ' + newMDMToIdMap);

            saveResult.bulkId = mdmRequestbulk.id;

        }

        try {
            
            if(mdmContacts != null){

                for (MDMRegRequestContact__c con : mdmContacts) {
                    MDMRegRequestContact__c mdmContact = new MDMRegRequestContact__c();

                    mdmContact.PV_NAME1_VK__c           =      String.isBlank(con.PV_NAME1_VK__c) ? null : con.PV_NAME1_VK__c;
                    mdmContact.PV_KNVKGB__c             =      String.isBlank(con.PV_KNVKGB__c) ? null : con.PV_KNVKGB__c.toUpperCase();
                    mdmContact.PV_KNVKGB_lu__c          =      codeToIdMap.get(con.PV_KNVKGB__c.toUpperCase());
                    mdmContact.PV_TELF1_VK__c           =      String.isBlank(con.PV_TELF1_VK__c) ? null : con.PV_TELF1_VK__c;
                    mdmContact.PV_ABTNR_VK__c           =      String.isBlank(con.PV_ABTNR_VK__c) ? null : con.PV_ABTNR_VK__c;
                    mdmContact.PV_PAFKT_VK__c           =      String.isBlank(con.PV_PAFKT_VK__c) ? null : con.PV_PAFKT_VK__c;
                    mdmContact.PV_TALKT_VK__c           =      String.isBlank(con.PV_TALKT_VK__c) ? null : con.PV_TALKT_VK__c;
                    mdmContact.PV_EMAIL_VK__c           =      String.isBlank(con.PV_EMAIL_VK__c) ? null : con.PV_EMAIL_VK__c;
                    mdmContact.Contact__c               =      String.isBlank(con.Contact__c) ? null : con.Contact__c;
                    if(recordId != null) {
                        mdmContact.MDMRegRequestCustomer__c     =      kunnrToIdMap.get(con.MDMRegRequestCustomer__c);
                        mdmContact.MDMRegRequestBulkCustomer__c =      recordId;
                    } else {
                        mdmContact.MDMRegRequestCustomer__c     =      newMDMToIdMap.get(con.MDMRegRequestCustomer__c);
                        mdmContact.MDMRegRequestBulkCustomer__c =      saveResult.bulkId;
                    }
                    
                    contactList.add(mdmContact);
                }

                System.debug('contactList => ' + contactList);

                insert contactList;

            }
            
        } catch (Exception e) {
            saveResult = new SaveResult('F', e.getMessage() + e.getLineNumber());
        }

        return saveResult;

    }

    public class SaveResult{

        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String massage {get;set;}
        @AuraEnabled public String bulkId {get;set;}

        // 생성자의 역할은 기본적으로
        // 전역변수(인스턴스변수) 초기화 해주는 역할을함
        public SaveResult() {
            this.status = 'S';
            this.massage = '성공 하였습니다.';
        }
        
        public SaveResult(String status, String massage) {
            this.status  = status;
            this.massage = massage;
        }

        public SaveResult(String status, String massage, String bulkId) {
            this.status  = status;
            this.massage = massage;
            this.bulkId = bulkId;
        }

    }

}