public with sharing class CJFW_MDMBulkUpdateManagementController {
    /**
    * Save 버튼을 클릭 했을 때 호출
    * 
    * @params mdmCustomer : 화면 mdmCustomer 데이터
    * @params type : 본점 OR 판매처 OR 관리처
    * 
    * MDMRequest = wrapper class다 
    */
    @AuraEnabled
    public static SaveResult doSave(List<MDMRequest> mdmCustomer, String type) {

        system.debug('#CJFW_MDMBulkUpdateHeadController >>>doSave ');
        SaveResult saveResult = new SaveResult();
        // aura  String 으로 넘어와서 JSON.des
        // mdmCustomer obj =  JSON.deserialize(mdmCustomer, 래퍼클래스명.class);
        system.debug('>>>doSave # mdmCustomer ' + JSON.serialize(mdmCustomer));
        //값을 나눠서 값이 없으면 안되는친구들
        //값이 없어도 되는친구들

        Id recordIdEx = null;
        
        if(type == '본점') {
            recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMParent').getRecordTypeId();
        } else if(type == '판매처') {
            recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMChild').getRecordTypeId();
        } else if(type == '관리처') {
            recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMManagement').getRecordTypeId();
        }
        
        List<MDMRegRequestCustomer__c> customerList = new List<MDMRegRequestCustomer__c>();

        System.debug(' type => ' + type);
        System.debug(' recordIdEx => ' + recordIdEx);
        
        // 이름이 null값이 되지 않도록 null일 경우 기존 값을 찾아서 기입해 줄 Map 생성
        Map<String, String> nameMaps = getNameOfNull(mdmCustomer);

        try {
            
            if(mdmCustomer != null){

                MDMRegRequestBulkCustomer__c mdmRequestbulk = new MDMRegRequestBulkCustomer__c();

                String bulkName = mdmCustomer[0].PV_NAME1;
                if(String.isBlank(bulkName) == true) {
                    bulkName = nameMaps.get(mdmCustomer[0].PV_KUNNR);
                }

                mdmRequestbulk.RequestType__c = 'Edit';
                
                mdmRequestbulk.Name = bulkName + ' 외 ' + (mdmCustomer.size() -1) + '건';
                insert mdmRequestbulk;
                
                for (MDMRequest mdm : mdmCustomer) {
                    MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c();
                    // system.debug('안녕하세요 ' + mdmRequestbulk.id);
                    // system.debug('MDM 고객 ID => ' + mdm.PV_KUNNR); // 고객 ID
                    // system.debug('MDM 고객명 => ' + mdm.PV_NAME1); // 고객명
                    // system.debug('MDM 법적상태 => ' + mdm.PV_GFORM); // 법적상태
                    // system.debug('MDM 대표자이름 => ' + mdm.PV_J_1KFREPRE); // 대표자이름
                    // system.debug('MDM 대표자생년월일 => ' + mdm.PV_STCD1); // 대표자생년월일
                    // system.debug('MDM 업태 => ' + mdm.PV_J_1KFTBUS); // 업태
                    // system.debug('MDM 레코드유형 => ' + recordIdEx); // 레코드 유형

                    mdmRequest.RecordTypeId      =      String.isBlank(type) ? null : recordIdEx;
                    mdmRequest.PV_KUNNR__c       =      String.isBlank(mdm.PV_KUNNR) ? null : mdm.PV_KUNNR;
                    mdmRequest.PV_NAME1__c       =      String.isBlank(mdm.PV_NAME1) ? nameMaps.get(mdm.PV_KUNNR) : mdm.PV_NAME1;
                    mdmRequest.PV_GFORM__c       =      String.isBlank(mdm.PV_GFORM) ? null : mdm.PV_GFORM;
                    mdmRequest.PV_J_1KFREPRE__c  =      String.isBlank(mdm.PV_J_1KFREPRE) ? null : mdm.PV_J_1KFREPRE;
                    mdmRequest.PV_STCD1__c       =      String.isBlank(mdm.PV_STCD1) ? null : mdm.PV_STCD1;
                    mdmRequest.PV_J_1KFTBUS__c   =      String.isBlank(mdm.PV_J_1KFTBUS) ? null : mdm.PV_J_1KFTBUS;
                    
                    mdmRequest.MDMRegRequestBulkCustomer__c  = mdmRequestbulk.id;
                    
                    customerList.add(mdmRequest);
                }

                // System.debug('customerList => ' + customerList);

                insert customerList;

                saveResult.bulkId = mdmRequestbulk.id;

            }
            
        } catch (Exception e) {
            saveResult = new SaveResult('F', e.getMessage() + e.getLineNumber());
        }

        return saveResult;
    }

    // 이름이 null값이 되지 않도록 null일 경우 기존 값을 찾아서 기입해 줄 Map 생성
    public static Map<String, String> getNameOfNull(List<MDMRequest> mdmCustomer) {

        // Custom Id 넣을 List 생성
        List<String> ids = new List<String>();
        
        for(MDMRequest mdm : mdmCustomer) {
            if(mdm.PV_NAME1 == null) {
                ids.add(mdm.PV_KUNNR);
            }
        }
        
        System.debug('ids => ' + ids);
        
        // Account로부터 해당 Custom Id의 이름 받아서 넣기
        List<Account> accList = [SELECT Name, CustomerID__c FROM Account WHERE CustomerID__c IN :ids];
        
        // Map[{"Id": "이름"}, ...] 형식
        Map<String, String> nameMaps = new Map<String, String>();

        // Map에 Key, Value 저장
        for(Account acc : accList) {
            nameMaps.put(acc.CustomerID__c, acc.Name);
        }

        System.debug('accList => ' + accList);

        return nameMaps;
    }

    public class SaveResult{
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String massage{get;set;}
        @AuraEnabled public String bulkId{get;set;}

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

    /*
    * MDMRequest 공통
    */
    public class MDMRequest{
        @AuraEnabled public String PV_KUNNR {get;set;}
        @AuraEnabled public String PV_NAME1 {get;set;}
        @AuraEnabled public String PV_GFORM {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        @AuraEnabled public String PV_STCD1 {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS {get;set;}
    }
}