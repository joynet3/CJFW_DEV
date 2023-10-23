/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkUpdateHeadController {
    
    /**
    * Save 버튼을 클릭 했을 때 호출
    * 
    * @params mdmCustomer : 화면 mdmCustomer 데이터
    * @params type : 본점 OR 판매처 OR 관리처
    * 
    * MDMRequest = wrapper class다 
    */
    @AuraEnabled
    public static SaveResult doSave(List<MDMRegRequestCustomer__c> mdmCustomer, String type) {

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

                String bulkName = mdmCustomer[0].PV_NAME1__c;
                if(String.isBlank(bulkName) == true) {
                    bulkName = nameMaps.get(mdmCustomer[0].PV_KUNNR__c);
                }

                mdmRequestbulk.RequestType__c = 'Edit';
                
                mdmRequestbulk.Name = bulkName + ' 외 ' + (mdmCustomer.size() -1) + '건';
                insert mdmRequestbulk;
                
                for (MDMRegRequestCustomer__c mdm : mdmCustomer) {
                    MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c();
                    // system.debug('안녕하세요 ' + mdmRequestbulk.id);
                    // system.debug('MDM 고객 ID => ' + mdm.PV_KUNNR); // 고객 ID
                    // system.debug('MDM 고객명 => ' + mdm.PV_NAME1); // 고객명
                    // system.debug('MDM 법적상태 => ' + mdm.PV_GFORM); // 법적상태
                    // system.debug('MDM 대표자이름 => ' + mdm.PV_J_1KFREPRE); // 대표자이름
                    // system.debug('MDM 대표자생년월일 => ' + mdm.PV_STCD1); // 대표자생년월일
                    // system.debug('MDM 업태 => ' + mdm.PV_J_1KFTBUS); // 업태
                    // system.debug('MDM 레코드유형 => ' + recordIdEx); // 레코드 유형

                    mdmRequest.RecordTypeId             =      String.isBlank(type) ? null : recordIdEx;
                    mdmRequest.PV_KUNNR__c              =      String.isBlank(mdm.PV_KUNNR__c) ? null : mdm.PV_KUNNR__c;
                    mdmRequest.PV_OLDCD__c              =      String.isBlank(mdm.PV_OLDCD__c) ? null : mdm.PV_OLDCD__c;
                    mdmRequest.PV_NAME1__c              =      String.isBlank(mdm.PV_NAME1__c) ? nameMaps.get(mdm.PV_KUNNR__c) : mdm.PV_NAME1__c;
                    mdmRequest.PV_NAME_G__c             =      String.isBlank(mdm.PV_NAME_G__c) ? null : mdm.PV_NAME_G__c;
                    mdmRequest.PV_NAME2__c              =      String.isBlank(mdm.PV_NAME2__c) ? null : mdm.PV_NAME2__c;
                    mdmRequest.PV_KTOKD__c              =      String.isBlank(mdm.PV_KTOKD__c) ? null : mdm.PV_KTOKD__c;
                    mdmRequest.PV_CUSTTYPE__c           =      String.isBlank(mdm.PV_CUSTTYPE__c) ? null : mdm.PV_CUSTTYPE__c;
                    mdmRequest.PV_STCD2__c              =      String.isBlank(mdm.PV_STCD2__c) ? null : mdm.PV_STCD2__c;
                    mdmRequest.PV_STCD3__c              =      String.isBlank(mdm.PV_STCD3__c) ? null : mdm.PV_STCD3__c;
                    mdmRequest.PV_GFORM__c              =      String.isBlank(mdm.PV_GFORM__c) ? null : mdm.PV_GFORM__c;
                    mdmRequest.PV_J_1KFREPRE__c         =      String.isBlank(mdm.PV_J_1KFREPRE__c) ? null : mdm.PV_J_1KFREPRE__c;
                    mdmRequest.PV_BLCKYN__c             =      mdm.PV_BLCKYN__c;
                    mdmRequest.PV_STCD1__c              =      String.isBlank(mdm.PV_STCD1__c) ? null : mdm.PV_STCD1__c;
                    mdmRequest.PV_J_1KFTBUS__c          =      String.isBlank(mdm.PV_J_1KFTBUS__c) ? null : mdm.PV_J_1KFTBUS__c;
                    mdmRequest.PV_J_1KFTIND__c          =      String.isBlank(mdm.PV_J_1KFTIND__c) ? null : mdm.PV_J_1KFTIND__c;
                    mdmRequest.PV_TELF1__c              =      String.isBlank(mdm.PV_TELF1__c) ? null : mdm.PV_TELF1__c;
                    mdmRequest.PV_TELFX__c              =      String.isBlank(mdm.PV_TELFX__c) ? null : mdm.PV_TELFX__c;
                    mdmRequest.PV_PAYCUST__c            =      String.isBlank(mdm.PV_PAYCUST__c) ? null : mdm.PV_PAYCUST__c;
                    mdmRequest.PV_CHARGECUST__c         =      String.isBlank(mdm.PV_CHARGECUST__c) ? null : mdm.PV_CHARGECUST__c;
                    mdmRequest.PV_VKGRP__c              =      String.isBlank(mdm.PV_VKGRP__c) ? null : mdm.PV_VKGRP__c;
                    mdmRequest.PV_PERNR__c              =      String.isBlank(mdm.PV_PERNR__c) ? null : mdm.PV_PERNR__c;
                    mdmRequest.PV_ADMINMA__c            =      String.isBlank(mdm.PV_ADMINMA__c) ? null : mdm.PV_ADMINMA__c;
                    mdmRequest.PV_STCDT__c              =      String.isBlank(mdm.PV_STCDT__c) ? null : mdm.PV_STCDT__c;
                    mdmRequest.PV_FITYP__c              =      String.isBlank(mdm.PV_FITYP__c) ? null : mdm.PV_FITYP__c;
                    mdmRequest.PV_HDOFFICEYN__c         =      mdm.PV_HDOFFICEYN__c;
                    mdmRequest.PV_SUBSIDIARYYN__c       =      mdm.PV_SUBSIDIARYYN__c;
                    mdmRequest.PV_VBUND__c              =      String.isBlank(mdm.PV_VBUND__c) ? null : mdm.PV_VBUND__c;
                    mdmRequest.PV_LAND1__c              =      String.isBlank(mdm.PV_LAND1__c) ? null : mdm.PV_LAND1__c;
                    mdmRequest.PV_KNVKTYPE__c           =      String.isBlank(mdm.PV_KNVKTYPE__c) ? null : mdm.PV_KNVKTYPE__c;
                    mdmRequest.PV_CLOSEDT__c            =      mdm.PV_CLOSEDT__c;
                    mdmRequest.PV_REGIO__c              =      String.isBlank(mdm.PV_REGIO__c) ? null : mdm.PV_REGIO__c;
                    mdmRequest.PV_ADRES_ROADADDR1__c    =      String.isBlank(mdm.PV_ADRES_ROADADDR1__c) ? null : mdm.PV_ADRES_ROADADDR1__c;
                    mdmRequest.PV_ADRES_ROADADDR2__c    =      String.isBlank(mdm.PV_ADRES_ROADADDR2__c) ? null : mdm.PV_ADRES_ROADADDR2__c;
                    mdmRequest.PV_ADRES_ADDR1__c        =      String.isBlank(mdm.PV_ADRES_ADDR1__c) ? null : mdm.PV_ADRES_ADDR1__c;
                    mdmRequest.PV_ADRES_ADDR2__c        =      String.isBlank(mdm.PV_ADRES_ADDR2__c) ? null : mdm.PV_ADRES_ADDR2__c;
                    mdmRequest.PV_BUSAB__c              =      String.isBlank(mdm.PV_BUSAB__c) ? null : mdm.PV_BUSAB__c;
                    mdmRequest.PV_CESSION_KZ__c         =      String.isBlank(mdm.PV_CESSION_KZ__c) ? null : mdm.PV_CESSION_KZ__c;
                    mdmRequest.PV_ZUAWA__c              =      String.isBlank(mdm.PV_ZUAWA__c) ? null : mdm.PV_ZUAWA__c;
                    mdmRequest.PV_AKONT__c              =      String.isBlank(mdm.PV_AKONT__c) ? null : mdm.PV_AKONT__c;
                    mdmRequest.PV_FDGRV__c              =      String.isBlank(mdm.PV_FDGRV__c) ? null : mdm.PV_FDGRV__c;
                    mdmRequest.PV_VRSDG__c              =      String.isBlank(mdm.PV_VRSDG__c) ? null : mdm.PV_VRSDG__c;
                    mdmRequest.PV_TAXKDD__c             =      String.isBlank(mdm.PV_TAXKDD__c) ? null : mdm.PV_TAXKDD__c;
                    mdmRequest.PV_KATR5__c              =      String.isBlank(mdm.PV_KATR5__c) ? null : mdm.PV_KATR5__c;
                    mdmRequest.PV_CUHR1__c              =      String.isBlank(mdm.PV_CUHR1__c) ? null : mdm.PV_CUHR1__c;
                    mdmRequest.PV_KONDA__c              =      String.isBlank(mdm.PV_KONDA__c) ? null : mdm.PV_KONDA__c;
                    mdmRequest.PV_KVGR1__c              =      String.isBlank(mdm.PV_KVGR1__c) ? null : mdm.PV_KVGR1__c;
                    mdmRequest.CurrencyIsoCode          =      String.isBlank(mdm.CurrencyIsoCode) ? null : mdm.CurrencyIsoCode;
                    mdmRequest.PV_KDGRP__c              =      String.isBlank(mdm.PV_KDGRP__c) ? null : mdm.PV_KDGRP__c;
                    mdmRequest.PV_KVGR2__c              =      String.isBlank(mdm.PV_KVGR2__c) ? null : mdm.PV_KVGR2__c;
                    mdmRequest.PV_VACCPRTEXCYN__c       =      mdm.PV_VACCPRTEXCYN__c;
                    mdmRequest.PV_ZTERM_VV__c           =      String.isBlank(mdm.PV_ZTERM_VV__c) ? null : mdm.PV_ZTERM_VV__c;
                    mdmRequest.PV_DSTRHISTREGYN__c      =      String.isBlank(mdm.PV_DSTRHISTREGYN__c) ? null : mdm.PV_DSTRHISTREGYN__c;
                    mdmRequest.PV_KULTG__c              =      String.isBlank(mdm.PV_KULTG__c) ? null : mdm.PV_KULTG__c;
                    mdmRequest.PV_OLD_BIZPLACE_NEW__c   =      String.isBlank(mdm.PV_OLD_BIZPLACE_NEW__c) ? null : mdm.PV_OLD_BIZPLACE_NEW__c;
                    mdmRequest.PV_SHAPE__c              =      String.isBlank(mdm.PV_SHAPE__c) ? null : mdm.PV_SHAPE__c;
                    mdmRequest.PV_DELIGROUP__c          =      String.isBlank(mdm.PV_DELIGROUP__c) ? null : mdm.PV_DELIGROUP__c;
                    
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
    public static Map<String, String> getNameOfNull(List<MDMRegRequestCustomer__c> mdmCustomer) {

        // Custom Id 넣을 List 생성
        List<String> ids = new List<String>();
        
        for(MDMRegRequestCustomer__c mdm : mdmCustomer) {
            if(mdm.PV_NAME1__c == null) {
                ids.add(mdm.PV_KUNNR__c);
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

    /* 필드값 모두 가지고 오기 */
    @AuraEnabled
    public static Map<String, String> getAllField() {
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('MDMRegRequestCustomer__c').getDescribe().fields.getMap();
        System.debug(fieldMap);
        Map<String, String> labels = new Map<String, String>();
        for (String fieldName: fieldMap.keySet()) {
            DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
            if(fieldResult.getName().contains('__c')) {
                labels.put(fieldResult.getLabel(), fieldResult.getName());
            }
        }
        return labels;
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

}