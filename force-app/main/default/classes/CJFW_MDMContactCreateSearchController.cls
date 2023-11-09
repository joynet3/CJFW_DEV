/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMContactCreateSearchController {
    
    @AuraEnabled
    public static saveResult doSave(List<MDMRegRequestContact__c> contactList, String recordId) {

        system.debug('>>>doSave # contactList ' + JSON.serialize(contactList));

        SaveResult saveResult = new SaveResult();

        List<String> ids = new List<String>();
        
        System.debug('recordId => ' + recordId);

        if(recordId != null) {
            List<MDMRegRequestCustomer__c> customerList = [SELECT Id, Name
                                                           FROM MDMRegRequestCustomer__c
                                                           WHERE MDMRegRequestBulkCustomer__c = :recordId];
            System.debug('customerList => ' + customerList);

            for(MDMRegRequestCustomer__c cus : customerList) {
                ids.add(cus.Id);
            }
            System.debug('ids => ' + ids);
        }

        // 담당자 유형 Code 가지고 오기
        List<MDMReferenceCode__c> referenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE GROUPID__c = 'KNVKGB'];

        System.debug('# referenceCodeList => ' + referenceCodeList);

        // Key : code , value : Id
        Map<String, String> codeToIdMap = new Map<String, String>();
        for(MDMReferenceCode__c mdmCode :referenceCodeList){
            codeToIdMap.put(mdmCode.Code__c, mdmCode.Id);
        }

        System.debug('# codeToIdMap => ' + codeToIdMap);

        try {
            
            // id가 없으면 Insert
            List<Contact> insertConList = new List<Contact>();
            // id가 있으면 Update
            List<Contact> updateConList = new List<Contact>();
            // Insert해 줄 MDMContact
            List<MDMRegRequestContact__c> mdmContact = new List<MDMRegRequestContact__c>();

            for(MDMRegRequestContact__c con : contactList) {

                System.debug('contact => ' + con);

                if(String.isNotBlank(con.Contact__c)) { // ID 있을 때

                    Contact updateCon = new Contact();
                    updateCon.LastName         = String.isBlank(con.PV_NAME1_VK__c)   ? '' : con.PV_NAME1_VK__c;
                    updateCon.PV_KNVKGB__c     = String.isBlank(con.PV_KNVKGB__c)     ? '' : con.PV_KNVKGB__c;
                    updateCon.MobilePhone      = String.isBlank(con.PV_TELF1_VK__c)   ? '' : con.PV_TELF1_VK__c;
                    updateCon.Email            = String.isBlank(con.PV_EMAIL_VK__c)   ? '' : con.PV_EMAIL_VK__c;
                    updateCon.PV_PAFKT_VK__c   = String.isBlank(con.PV_PAFKT_VK__c)   ? '' : con.PV_PAFKT_VK__c;
                    updateCon.Department       = String.isBlank(con.PV_ABTNR_VK__c)   ? '' : con.PV_ABTNR_VK__c;
                    updateCon.PV_TALKT_VK__c   = String.isBlank(con.PV_TALKT_VK__c)   ? '' : con.PV_TALKT_VK__c;
                    updateCon.Id               = con.Contact__c;
                    updateConList.add(updateCon);

                } else { // ID 없을 때

                    Contact insertCon = new Contact();
                    insertCon.LastName         = String.isBlank(con.PV_NAME1_VK__c)   ? '' : con.PV_NAME1_VK__c;
                    insertCon.PV_KNVKGB__c     = String.isBlank(con.PV_KNVKGB__c)     ? '' : con.PV_KNVKGB__c;
                    insertCon.MobilePhone      = String.isBlank(con.PV_TELF1_VK__c)   ? '' : con.PV_TELF1_VK__c;
                    insertCon.Email            = String.isBlank(con.PV_EMAIL_VK__c)   ? '' : con.PV_EMAIL_VK__c;
                    insertCon.PV_PAFKT_VK__c   = String.isBlank(con.PV_PAFKT_VK__c)   ? '' : con.PV_PAFKT_VK__c;
                    insertCon.Department       = String.isBlank(con.PV_ABTNR_VK__c)   ? '' : con.PV_ABTNR_VK__c;
                    insertCon.PV_TALKT_VK__c   = String.isBlank(con.PV_TALKT_VK__c)   ? '' : con.PV_TALKT_VK__c;
                    insertConList.add(insertCon);

                }
                
            }
            
            System.debug('updateConList => ' + updateConList);
            System.debug('insertConList => ' + insertConList);
            
            if(!updateConList.isEmpty()) { update updateConList; }
            if(!insertConList.isEmpty()) { insert insertConList; }

            for(Contact con : insertConList) {
                for(String mdmId : ids) {
                    MDMRegRequestContact__c mdm = new MDMRegRequestContact__c();
                    mdm.PV_NAME1_VK__c               = String.isBlank(con.LastName)   ? '' : con.LastName;
                    mdm.PV_KNVKGB__c                 = String.isBlank(con.PV_KNVKGB__c) ? '' : con.PV_KNVKGB__c;
                    mdm.PV_KNVKGB_lu__c              = codeToIdMap.get(con.PV_KNVKGB__c);
                    mdm.PV_TELF1_VK__c               = String.isBlank(con.MobilePhone)   ? '' : con.MobilePhone;
                    mdm.PV_EMAIL_VK__c               = String.isBlank(con.Email)   ? '' : con.Email;
                    mdm.PV_PAFKT_VK__c               = String.isBlank(con.PV_PAFKT_VK__c)   ? '' : con.PV_PAFKT_VK__c;
                    mdm.PV_ABTNR_VK__c               = String.isBlank(con.Department)   ? '' : con.Department;
                    mdm.PV_TALKT_VK__c               = String.isBlank(con.PV_TALKT_VK__c)   ? '' : con.PV_TALKT_VK__c;
                    mdm.Contact__c                   = String.isBlank(con.Id)       ? null : con.Id;
                    mdm.MDMRegRequestCustomer__c     = mdmId;
                    mdm.MDMRegRequestBulkCustomer__c = recordId;
                    mdmContact.add(mdm);
                }
            }

            for(Contact con : updateConList) {
                for(String mdmId : ids) {
                    MDMRegRequestContact__c mdm = new MDMRegRequestContact__c();
                    mdm.PV_NAME1_VK__c               = String.isBlank(con.LastName)   ? '' : con.LastName;
                    mdm.PV_KNVKGB__c                 = String.isBlank(con.PV_KNVKGB__c) ? '' : con.PV_KNVKGB__c;
                    mdm.PV_KNVKGB_lu__c              = codeToIdMap.get(con.PV_KNVKGB__c);
                    mdm.PV_TELF1_VK__c               = String.isBlank(con.MobilePhone)   ? '' : con.MobilePhone;
                    mdm.PV_EMAIL_VK__c               = String.isBlank(con.Email)   ? '' : con.Email;
                    mdm.PV_PAFKT_VK__c               = String.isBlank(con.PV_PAFKT_VK__c)   ? '' : con.PV_PAFKT_VK__c;
                    mdm.PV_ABTNR_VK__c               = String.isBlank(con.Department)   ? '' : con.Department;
                    mdm.PV_TALKT_VK__c               = String.isBlank(con.PV_TALKT_VK__c)   ? '' : con.PV_TALKT_VK__c;
                    mdm.Contact__c                   = String.isBlank(con.Id)       ? null : con.Id;
                    mdm.MDMRegRequestCustomer__c     = mdmId;
                    mdm.MDMRegRequestBulkCustomer__c = recordId;
                    mdmContact.add(mdm);
                }
            }

            System.debug('mdmContact => ' + mdmContact);

            if(!mdmContact.isEmpty()) { insert mdmContact; }
            
            saveResult.bulkId = recordId;

        } catch (Exception e) {
            saveResult = new SaveResult('F', e.getMessage() + e.getLineNumber());
        }

        return saveResult;

    }

    public class SaveResult{

        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String massage{get;set;}
        @AuraEnabled public String bulkId{get;set;}

        public SaveResult() {
            this.status = 'S';
            this.massage = '성공 하였습니다.';
        }
        
        public SaveResult(String status, String massage) {
            this.status  = status;
            this.massage = massage;
        }
        
        // location.href에 사용할 id
        public SaveResult(String status, String massage, String bulkId) {
            this.status  = status;
            this.massage = massage;
            this.bulkId = bulkId;
        }
    }

}