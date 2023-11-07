/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
**/
public with sharing class CJFW_MDMBulkCreateMAController {

    /**
    * 담당자 생성 Btn 클릭 했을 때 호출하여 MDMbulkId를 물고 있는 하위 MDM Id/MDM Name을 미리 뿌려줌
    * 
    * @params bulkId : MDM 대량 고객 등록 및 수정 요청의 recordId 값
    * 
    */
    @AuraEnabled
    public static DataWrapper getMDMContactInfo(String recordId) {
        system.debug('### CJFW_MDMBulkCreateMAController getMDMContactInfo ');
        system.debug('Params : recordId ' + recordId);
        String strStatus = 'S';
        String strMessage = '';
        DataWrapper objWrapper = new DataWrapper();
        try{
            
            List<MDMRegRequestBulkCustomer__c> listSearchResult = new List<MDMRegRequestBulkCustomer__c>(); // 모두 담은

            List<MDMRegRequestCustomer__c> mdmRegRequestList = [SELECT Id, PV_NAME1__c, MDMRegRequestBulkCustomer__c FROM MDMRegRequestCustomer__c WHERE MDMRegRequestBulkCustomer__c =: recordId];            
            
            system.debug('mdmRegRequestList ' + mdmRegRequestList);

            Integer listSearchResultSize = mdmRegRequestList.size();
            objWrapper.listSearchResult = mdmRegRequestList;
        }catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;
        return objWrapper;
    }
    /**
    * =======================================================================================================================
    * @description : code만 알고있는 필드를 이용해 Name을 가져오기 (PV_KNVKGB__c) 에 넣어줘야 함 
    * 
    * @params      : List<String> codes
    * @return      : `List<MDMReferenceCode__c>`
    * =======================================================================================================================
    */
    @AuraEnabled 
    public static MDMReferenceCode__c getManagerNameByCodes(String code){
        return [SELECT Id, Name, CODE__c  FROM MDMReferenceCode__c WHERE CODE__c =:code AND GROUPID__c = 'KNVKGB'];
    }

    /**
    * Save 버튼을 클릭 했을 때 호출
    * 
    * @params mdmContacts : 화면 mdmContact 데이터
    * 
    */
    @AuraEnabled
    public static SaveResult doSave(List<MDMRegRequestContact__c> mdmContacts, String recordId) {

        system.debug('# CJFW_MDMBulkCreateMAController >>> doSave ');
        system.debug('Params 1 # mdmContacts ' + JSON.serialize(mdmContacts));
        system.debug('Params 2 # bulkId ' + recordId);

        SaveResult saveResult = new SaveResult();

        List<MDMRegRequestContact__c> contactList = new List<MDMRegRequestContact__c>();
        try {

            Set<String> conCodeSet = new Set<String>();
            for(MDMRegRequestContact__c con :mdmContacts){
                conCodeSet.add(con.PV_KNVKGB__c);
            }
            
            List<MDMReferenceCode__c> conReferenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c =: conCodeSet AND GROUPID__c = 'KNVKGB'];
            
            // Key :code , value :Id
            Map<String, String> codeToConIdMap = new Map<String, String>();
            for(MDMReferenceCode__c conCode :conReferenceCodeList){ 
                codeToConIdMap.put(conCode.Code__c, conCode.id);
            }

            if(mdmContacts != null){

                for (MDMRegRequestContact__c con : mdmContacts) {
                    MDMRegRequestContact__c mdmContact = new MDMRegRequestContact__c();
                    mdmContact.MDMRegRequestBulkCustomer__c   =   recordId;
                    mdmContact.MDMRegRequestCustomer__c       =   String.isBlank(con.Id) ? null : con.Id;
                    mdmContact.PV_NAME1_VK__c                 =   String.isBlank(con.PV_NAME1_VK__c) ? null : con.PV_NAME1_VK__c;
                    mdmContact.PV_KNVKGB__c                   =   String.isBlank(con.PV_KNVKGB__c) ? null : con.PV_KNVKGB__c;
                    mdmContact.PV_TELF1_VK__c                 =   String.isBlank(con.PV_TELF1_VK__c) ? null : con.PV_TELF1_VK__c;
                    mdmContact.PV_ABTNR_VK__c                 =   String.isBlank(con.PV_ABTNR_VK__c) ? null : con.PV_ABTNR_VK__c;
                    mdmContact.PV_PAFKT_VK__c                 =   String.isBlank(con.PV_PAFKT_VK__c) ? null : con.PV_PAFKT_VK__c;
                    mdmContact.PV_TALKT_VK__c                 =   String.isBlank(con.PV_TALKT_VK__c) ? null : con.PV_TALKT_VK__c;
                    mdmContact.PV_EMAIL_VK__c                 =   String.isBlank(con.PV_EMAIL_VK__c) ? null : con.PV_EMAIL_VK__c; 
                    mdmContact.PV_KNVKGB_lu__c                =   codeToConIdMap.get(con?.PV_KNVKGB__c);
                    contactList.add(mdmContact);
                }

                System.debug('contactList => ' + contactList);

                insert contactList;

                MDMRegRequestBulkCustomer__c mdmBulk = new MDMRegRequestBulkCustomer__c();
                mdmbulk.id             = recordId;
                mdmBulk.isMDMCreateContact__c = true;
                update mdmBulk;

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
    
    public class DataWrapper {

		@AuraEnabled
        public String strStatus {get;set;}

        @AuraEnabled
        public String strMessage {get;set;}

        @AuraEnabled
        public List<MDMRegRequestBulkCustomer__c> searchResult {get;set;}

        @AuraEnabled
        public List<MDMRegRequestCustomer__c> listSearchResult {get;set;}

        @AuraEnabled
        public Integer totalCnt {get;set;}

        @AuraEnabled
        public String code {get;set;}

        @AuraEnabled
        public String inputId {get;set;}

        @AuraEnabled
        public String inputTextLabel {get;set;}

	}

    
}