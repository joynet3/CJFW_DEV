/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 09-26-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkUpdateInfoListController {

    /* 대량 수정 요청 Id를 통해 받아 온 리스트를 기존의 것과 조사 */
    @AuraEnabled(cacheable=true)
    public static DataWrapper getAccountInfo (String recordId, Integer pageNumber, Integer pageSize) {

        List<MDMRegRequestCustomer__c> mdms = [SELECT PV_KUNNR__c, PV_NAME1__c, PV_GFORM__c, PV_J_1KFREPRE__c, PV_STCD1__c, PV_J_1KFTBUS__c FROM MDMRegRequestCustomer__c WHERE MDMRegRequestBulkCustomer__c = :recordId ORDER BY PV_KUNNR__c];
        List<String> ids = new List<String>();

        for(MDMRegRequestCustomer__c mdm : mdms) {
            ids.add(mdm.PV_KUNNR__c);
        }

        System.debug('mdms => ' + mdms);
        System.debug('ids => ' + ids);

        DataWrapper objWrapper = new DataWrapper();

        List<Account> accList = [SELECT Id, CustomerId__c, Name, LegalStatus__c, RepresentativeName__c, RepresentativeBirthDate__c, BusinessConditions__c FROM Account WHERE CustomerId__c IN :ids ORDER BY CustomerId__c];
        
        System.debug('accList => ' + accList);

        List<MDMRequest> result = new List<MDMRequest>(); // 해당 페이지에 담은
        List<MDMRequest> mdmList = new List<MDMRequest>(); // 모든 페이지에 담은

        for (Integer i = 0; i < mdms.size(); i++) {
            MDMRequest mdmRequest = new MDMRequest();
            mdmRequest.PV_KUNNR           =      String.isBlank(mdms[i].PV_KUNNR__c) ? null : mdms[i].PV_KUNNR__c;

            if(mdms[i].PV_KUNNR__c == accList[i].CustomerId__c) {
                mdmRequest.PV_NAME1           =      String.isBlank(accList[i].Name) ? null : accList[i].Name;
                mdmRequest.PV_NAME1_MOD       =      String.isBlank(mdms[i].PV_NAME1__c) ? null : mdms[i].PV_NAME1__c;
                mdmRequest.PV_GFORM           =      String.isBlank(accList[i].LegalStatus__c) ? null : accList[i].LegalStatus__c;
                mdmRequest.PV_GFORM_MOD       =      String.isBlank(mdms[i].PV_GFORM__c) ? null : mdms[i].PV_GFORM__c;
                mdmRequest.PV_J_1KFREPRE      =      String.isBlank(accList[i].RepresentativeName__c) ? null : accList[i].RepresentativeName__c;
                mdmRequest.PV_J_1KFREPRE_MOD  =      String.isBlank(mdms[i].PV_J_1KFREPRE__c) ? null : mdms[i].PV_J_1KFREPRE__c;
                mdmRequest.PV_STCD1           =      String.isBlank(accList[i].RepresentativeBirthDate__c) ? null : accList[i].RepresentativeBirthDate__c;
                mdmRequest.PV_STCD1_MOD       =      String.isBlank(mdms[i].PV_STCD1__c) ? null : mdms[i].PV_STCD1__c;
                mdmRequest.PV_J_1KFTBUS       =      String.isBlank(accList[i].BusinessConditions__c) ? null : accList[i].BusinessConditions__c;
                mdmRequest.PV_J_1KFTBUS_MOD   =      String.isBlank(mdms[i].PV_J_1KFTBUS__c) ? null : mdms[i].PV_J_1KFTBUS__c;
                mdmList.add(mdmRequest);
            }
        }

        Integer resultSize = mdmList.size();

        Integer startIndex = (pageNumber - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, resultSize);
        Integer lastPageNumber = resultSize / pageSize;
        if(lastPageNumber == 0) {
            lastPageNumber = 1;
        }

        if(endIndex > startIndex){
            for (Integer i = startIndex; i < endIndex; i++) {
                result.add(mdmList[i]);
            }
        }

        List<String> headerList = getHeadList(mdmList);

        System.debug('result => ' + result);
        System.debug('mdmList => ' + mdmList);
        System.debug('headerList => ' + headerList);

        objWrapper.mdmList = result;
        objWrapper.headerList = headerList;
        objWrapper.lastPageNumber = lastPageNumber;

        return objWrapper;

    }

    /* 헤더 List 얻기 */
    public static List<String> getHeadList(List<MDMRequest> mdmList) {

        List<String> headerList = new List<String>();
        headerList.add('0');

        if(mdmList[0].PV_NAME1 != mdmList[0].PV_NAME1_MOD) {
            headerList.add('1');
            headerList.add('2');
        }
        
        if(mdmList[0].PV_GFORM != mdmList[0].PV_GFORM_MOD) {
            headerList.add('3');
            headerList.add('4');
        }

        if(mdmList[0].PV_J_1KFREPRE != mdmList[0].PV_J_1KFREPRE_MOD) {
            headerList.add('5');
            headerList.add('6');
        }

        if(mdmList[0].PV_STCD1 != mdmList[0].PV_STCD1_MOD) {
            headerList.add('7');
            headerList.add('8');
        }

        if(mdmList[0].PV_J_1KFTBUS != mdmList[0].PV_J_1KFTBUS_MOD) {
            headerList.add('9');
            headerList.add('10');
        }

        return headerList;

    }

    public class DataWrapper {
        @AuraEnabled
        public List<MDMRequest> mdmList {get;set;}
        @AuraEnabled
        public List<String> headerList {get;set;}
        @AuraEnabled
        public Integer lastPageNumber {get;set;}
	}

    /*
    MDMRequest 공통
    */
    public class MDMRequest {
        @AuraEnabled public String PV_KUNNR {get;set;}
        @AuraEnabled public String PV_NAME1 {get;set;}
        @AuraEnabled public String PV_NAME1_MOD {get;set;}
        @AuraEnabled public String PV_GFORM {get;set;}
        @AuraEnabled public String PV_GFORM_MOD {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE_MOD {get;set;}
        @AuraEnabled public String PV_STCD1 {get;set;}
        @AuraEnabled public String PV_STCD1_MOD {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS_MOD {get;set;}
    }

}