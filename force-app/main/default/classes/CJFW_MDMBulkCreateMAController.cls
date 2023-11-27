/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-27-2023
 * @last modified by  : hyeeun.song@dkbmc.com
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

            List<MDMRequest> mdmList = new List<MDMRequest>();

            for(MDMRegRequestCustomer__c con : mdmRegRequestList) {
                MDMRequest mdm = new MDMRequest();
                mdm.MDMRegRequestCustomer    = con.Id;
                mdm.PV_NAME1                 = con.PV_NAME1__c;
                mdmList.add(mdm);
            }

            Integer listSearchResultSize = mdmRegRequestList.size();

            objWrapper.listSearchResult = mdmList;

        } catch(Exception e) {
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
    public static SaveResult doSave(List<MDMRequestContact> mdmContacts, String recordId) {

        system.debug('# CJFW_MDMBulkCreateMAController >>> doSave ');
        system.debug('Params 1 # mdmContacts ' + JSON.serialize(mdmContacts));
        system.debug('Params 2 # bulkId ' + recordId);

        SaveResult saveResult = new SaveResult();

        List<MDMRegRequestContact__c> contactList = new List<MDMRegRequestContact__c>();
        List<Contact> contactList2 = new List<Contact>();
        
        Savepoint sp = Database.setSavepoint();

        try {

            Set<String> conCodeSet = new Set<String>();
            for(MDMRequestContact con :mdmContacts){
                conCodeSet.add(con.PV_KNVKGB);
            }
            
            List<MDMReferenceCode__c> conReferenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c =: conCodeSet AND GROUPID__c = 'KNVKGB'];
            
            // Key :code , value :Id
            Map<String, String> codeToConIdMap = new Map<String, String>();
            for(MDMReferenceCode__c conCode :conReferenceCodeList){ 
                codeToConIdMap.put(conCode.Code__c, conCode.id);
            }

            if(mdmContacts != null){

                for (MDMRequestContact con : mdmContacts) {
                    Contact newCon = new Contact();
                    newCon.MDMRegRequestCustomer__c           =   String.isBlank(con.MDMRegRequestCustomer) ? null : con.MDMRegRequestCustomer;
                    newCon.LastName                           =   String.isBlank(con.PV_NAME1_VK) ? null : con.PV_NAME1_VK;
                    newCon.PV_KNVKGB__c                       =   String.isBlank(con.PV_KNVKGB) ? null : con.PV_KNVKGB;
                    newCon.Phone                              =   String.isBlank(con.PV_TELF1_VK) ? null : con.PV_TELF1_VK;
                    newCon.Department                         =   String.isBlank(con.PV_ABTNR_VK) ? null : con.PV_ABTNR_VK;
                    newCon.PV_PAFKT_VK__c                     =   String.isBlank(con.PV_PAFKT_VK) ? null : con.PV_PAFKT_VK;
                    newCon.PV_TALKT_VK__c                     =   String.isBlank(con.PV_TALKT_VK) ? null : con.PV_TALKT_VK;
                    newCon.Email                              =   String.isBlank(con.PV_EMAIL_VK) ? null : con.PV_EMAIL_VK;
                    contactList2.add(newCon);
                }

                System.debug('contactList2 => ' + contactList2);

                insert contactList2;

                // for(Contact con : contactList2) {
                //     contactIdMap.put(, con.Id);
                // }

                for(MDMRequestContact con : mdmContacts) {
                    MDMRegRequestContact__c mdmContact = new MDMRegRequestContact__c();
                    mdmContact.MDMRegRequestBulkCustomer__c   =   recordId;
                    mdmContact.MDMRegRequestCustomer__c       =   String.isBlank(con.MDMRegRequestCustomer) ? null : con.MDMRegRequestCustomer;
                    mdmContact.PV_NAME1_VK__c                 =   String.isBlank(con.PV_NAME1_VK) ? null : con.PV_NAME1_VK;
                    mdmContact.PV_KNVKGB__c                   =   String.isBlank(con.PV_KNVKGB) ? null : con.PV_KNVKGB;
                    mdmContact.PV_TELF1_VK__c                 =   String.isBlank(con.PV_TELF1_VK) ? null : con.PV_TELF1_VK;
                    mdmContact.PV_ABTNR_VK__c                 =   String.isBlank(con.PV_ABTNR_VK) ? null : con.PV_ABTNR_VK;
                    mdmContact.PV_PAFKT_VK__c                 =   String.isBlank(con.PV_PAFKT_VK) ? null : con.PV_PAFKT_VK;
                    mdmContact.PV_TALKT_VK__c                 =   String.isBlank(con.PV_TALKT_VK) ? null : con.PV_TALKT_VK;
                    mdmContact.PV_EMAIL_VK__c                 =   String.isBlank(con.PV_EMAIL_VK) ? null : con.PV_EMAIL_VK; 
                    mdmContact.PV_KNVKGB_lu__c                =   codeToConIdMap.get(con?.PV_KNVKGB);
                    contactList.add(mdmContact);
                }

                insert contactList;

                MDMRegRequestBulkCustomer__c mdmBulk = new MDMRegRequestBulkCustomer__c();
                mdmBulk.id                    = recordId;
                mdmBulk.isMDMCreateContact__c = true;

                update mdmBulk;

            }
            
        } catch (Exception e) {
            saveResult = new SaveResult('F', e.getMessage() + e.getLineNumber());

            // 실패 시 모든 data 롤백
            Database.rollback(sp);
        }

        return saveResult;

    }
    /**
    *                  let hiddenElement = document.createElement('a');
                       hiddenElement.href = result;
                       hiddenElement.target = '_blank';
                       hiddenElement.download = 'download';
                       hiddenElement.click();
    */
    @AuraEnabled  
    public static String downloadMenualExcel(){
        ContentVersion cv = [SELECT   Title, id, VersionNumber 
                             FROM     ContentVersion 
                             WHERE    Title = 'MDM 담당자유형 매뉴얼' 
                             ORDER BY VersionNumber DESC LIMIT 1];

        String contentId = cv.Id;

        return URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentId;
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

    public class MDMRequest {
        @AuraEnabled public String MDMRegRequestCustomer {get;set;}
        @AuraEnabled public String PV_NAME1 {get;set;}
    }

    public class MDMRequestContact {
        @AuraEnabled public String MDMRegRequestCustomer {get;set;}
        @AuraEnabled public String PV_NAME1_VK {get;set;}
        @AuraEnabled public String PV_KNVKGB {get;set;}
        @AuraEnabled public String PV_TELF1_VK {get;set;}
        @AuraEnabled public String PV_ABTNR_VK {get;set;}
        @AuraEnabled public String PV_PAFKT_VK {get;set;}
        @AuraEnabled public String PV_EMAIL_VK {get;set;}
        @AuraEnabled public String PV_TALKT_VK {get;set;}
    }
    
    public class DataWrapper {

		@AuraEnabled
        public String strStatus {get;set;}

        @AuraEnabled
        public String strMessage {get;set;}

        @AuraEnabled
        public List<MDMRegRequestBulkCustomer__c> searchResult {get;set;}

        @AuraEnabled
        public List<MDMRequest> listSearchResult {get;set;}

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