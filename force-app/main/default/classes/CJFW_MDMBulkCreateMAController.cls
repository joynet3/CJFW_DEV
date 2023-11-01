/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkCreateMAController {

    /**
    * Save 버튼을 클릭 했을 때 호출
    * 
    * @params mdmContacts : 화면 mdmContact 데이터
    * 
    */
    @AuraEnabled
    public static SaveResult doSave(List<MDMRegRequestContact__c> mdmContacts) {

        system.debug('# CJFW_MDMBulkCreateMAController >>> doSave ');

        SaveResult saveResult = new SaveResult();
        system.debug('>>>doSave # mdmContacts ' + JSON.serialize(mdmContacts));

        List<MDMRegRequestContact__c> contactList = new List<MDMRegRequestContact__c>();

        // 각종 ID 필요한 MDMReferenceCode__c 조회해서 Id값 가지고 오기
        Set<String> codeSet = new Set<String>();
        for(MDMRegRequestContact__c con : mdmContacts){
            codeSet.add(con.PV_KNVKGB__c);
            codeSet.remove(null);
        }
        
        List<MDMReferenceCode__c> referenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c = :codeSet];

        System.debug('# referenceCodeList => ' + referenceCodeList);

        // Key : code , value : Id
        Map<String, String> codeToIdMap = new Map<String, String>();
        for(MDMReferenceCode__c mdmCode :referenceCodeList){
            codeToIdMap.put(mdmCode.Code__c, mdmCode.Id);
        }

        System.debug('# codeToIdMap => ' + codeToIdMap);

        // 받아 온 이름으로 MDM으로부터 Id 가지고 오기
        Set<String> idSet = new Set<String>();
        for(MDMRegRequestContact__c con : mdmContacts){
            idSet.add(con.MDMRegRequestCustomer__c);
            idSet.remove(null);
        }

        List<MDMRegRequestCustomer__c> customerList = [SELECT Id, PV_NAME1__c FROM MDMRegRequestCustomer__c WHERE PV_NAME1__c = :idSet];

        System.debug('# customerList => ' + customerList);

        // Key : code , value : Id
        Map<String, String> nameToIdMap = new Map<String, String>();
        for(MDMRegRequestCustomer__c cus : customerList){
            nameToIdMap.put(cus.PV_NAME1__c, cus.Id);
        }

        System.debug('# nameToIdMap => ' + nameToIdMap);

        try {
            
            if(mdmContacts != null){

                for (MDMRegRequestContact__c con : mdmContacts) {
                    MDMRegRequestContact__c mdmContact = new MDMRegRequestContact__c();

                    mdmContact.PV_NAME1_VK__c           =      String.isBlank(con.PV_NAME1_VK__c) ? null : con.PV_NAME1_VK__c;
                    mdmContact.PV_KNVKGB__c             =      String.isBlank(con.PV_KNVKGB__c) ? null : con.PV_KNVKGB__c;
                    mdmContact.PV_KNVKGB_lu__c          =      codeToIdMap.get(con.PV_KNVKGB__c);
                    mdmContact.PV_TELF1_VK__c           =      String.isBlank(con.PV_TELF1_VK__c) ? null : con.PV_TELF1_VK__c;
                    mdmContact.PV_ABTNR_VK__c           =      String.isBlank(con.PV_ABTNR_VK__c) ? null : con.PV_ABTNR_VK__c;
                    mdmContact.PV_PAFKT_VK__c           =      String.isBlank(con.PV_PAFKT_VK__c) ? null : con.PV_PAFKT_VK__c;
                    mdmContact.PV_TALKT_VK__c           =      String.isBlank(con.PV_TALKT_VK__c) ? null : con.PV_TALKT_VK__c;
                    mdmContact.PV_EMAIL_VK__c           =      String.isBlank(con.PV_EMAIL_VK__c) ? null : con.PV_EMAIL_VK__c;
                    mdmContact.MDMRegRequestCustomer__c =      nameToIdMap.get(con.MDMRegRequestCustomer__c);
                    
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

    }
    
}