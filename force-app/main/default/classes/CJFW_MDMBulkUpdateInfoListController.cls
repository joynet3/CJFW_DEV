/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 10-12-2023
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
                mdmRequest.PV_INDEX           =      i + 1;
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
                System.debug('mdmRequest => ' + mdmRequest);
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

        List<Integer> headerList = getHeadList(mdmList);

        System.debug('result => ' + result);
        System.debug('mdmList => ' + mdmList);
        System.debug('headerList => ' + headerList);

        objWrapper.mdmList = result;
        objWrapper.headerList = headerList;
        objWrapper.lastPageNumber = lastPageNumber;

        return objWrapper;

    }

    /* 헤더 List 얻기 */
    public static List<Integer> getHeadList(List<MDMRequest> mdmList) {

        List<Integer> headerList = new List<Integer>();
        headerList.add(0);
        headerList.add(1);

        for(Integer i = 0; i < mdmList.size(); i++) {
            if(mdmList[i].PV_NAME1 != mdmList[i].PV_NAME1_MOD && mdmList[i].PV_NAME1_MOD != null) {
                headerList.add(2);
                headerList.add(3);
            }
            
            if(mdmList[i].PV_GFORM != mdmList[i].PV_GFORM_MOD && mdmList[i].PV_GFORM_MOD != null) {
                headerList.add(4);
                headerList.add(5);
            }
    
            if(mdmList[i].PV_J_1KFREPRE != mdmList[i].PV_J_1KFREPRE_MOD && mdmList[i].PV_J_1KFREPRE_MOD != null) {
                headerList.add(6);
                headerList.add(7);
            }
    
            if(mdmList[i].PV_STCD1 != mdmList[i].PV_STCD1_MOD && mdmList[i].PV_STCD1_MOD != null) {
                headerList.add(8);
                headerList.add(9);
            }
    
            if(mdmList[i].PV_J_1KFTBUS != mdmList[i].PV_J_1KFTBUS_MOD && mdmList[i].PV_J_1KFTBUS_MOD != null) {
                headerList.add(10);
                headerList.add(11);
            }
        }

        Set<Integer> headerSet = new Set<Integer>(headerList);

        List<Integer> newHeaderList = new List<Integer>(headerSet);

        newHeaderList.sort();

        System.debug('newHeaderList => ' + newHeaderList);
        
        return newHeaderList;

    }

    public class DataWrapper {
        @AuraEnabled
        public List<MDMRequest> mdmList {get;set;}
        @AuraEnabled
        public List<Integer> headerList {get;set;}
        @AuraEnabled
        public Integer lastPageNumber {get;set;}
	}

    /*
    MDMRequest 공통
    */
    public class MDMRequest {
        @AuraEnabled public Integer PV_INDEX {get;set;}
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