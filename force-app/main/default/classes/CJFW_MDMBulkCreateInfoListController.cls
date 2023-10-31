/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
**/
public with sharing class CJFW_MDMBulkCreateInfoListController {

    /* 대량 생성 요청 Id를 통해 받아 온 리스트를 기존의 것과 조사 */
    @AuraEnabled(cacheable=true)
    public static DataWrapper getAccountInfo (String recordId, Integer pageNumber, Integer pageSize) {

        List<MDMRegRequestCustomer__c> mdms = [SELECT PV_NAME1__c, PV_NAME_G__c, PV_KUNNR__c, PV_OLDCD__c, PV_NAME2__c, PV_KTOKD__c, PV_CUSTTYPE__c, PV_STCD2__c  FROM MDMRegRequestCustomer__c WHERE MDMRegRequestBulkCustomer__c = :recordId ORDER BY Name];

        DataWrapper objWrapper = new DataWrapper();
        
        System.debug('mdms => ' + mdms);

        List<MDMRequest> result = new List<MDMRequest>(); // 해당 페이지에 담은
        List<MDMRequest> mdmList = new List<MDMRequest>(); // 모든 페이지에 담은

        for (Integer i = 0; i < mdms.size(); i++) {
            MDMRequest mdmRequest = new MDMRequest();
            mdmRequest.PV_INDEX         =      i + 1;
            mdmRequest.PV_NAME1         =      String.isBlank(mdms[i].PV_NAME1__c) ? null : mdms[i].PV_NAME1__c;
            mdmRequest.PV_NAME_G        =      String.isBlank(mdms[i].PV_NAME_G__c) ? null : mdms[i].PV_NAME_G__c;
            mdmRequest.PV_KUNNR         =      String.isBlank(mdms[i].PV_KUNNR__c) ? null : mdms[i].PV_KUNNR__c;
            mdmRequest.PV_OLDCD         =      String.isBlank(mdms[i].PV_OLDCD__c) ? null : mdms[i].PV_OLDCD__c;
            mdmRequest.PV_NAME2         =      String.isBlank(mdms[i].PV_NAME2__c) ? null : mdms[i].PV_NAME2__c;
            mdmRequest.PV_KTOKD         =      String.isBlank(mdms[i].PV_KTOKD__c) ? null : mdms[i].PV_KTOKD__c;
            mdmRequest.PV_CUSTTYPE      =      String.isBlank(mdms[i].PV_CUSTTYPE__c) ? null : mdms[i].PV_CUSTTYPE__c;
            mdmRequest.PV_STCD2         =      String.isBlank(mdms[i].PV_STCD2__c) ? null : mdms[i].PV_STCD2__c;
            System.debug((i+1) + ' 번째 mdmRequest => ' + mdmRequest);
            mdmList.add(mdmRequest);
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

        System.debug('result => ' + result);
        System.debug('mdmList => ' + mdmList);

        objWrapper.mdmList = result;
        objWrapper.lastPageNumber = lastPageNumber;

        return objWrapper;

    }

    public class DataWrapper {
        @AuraEnabled
        public List<MDMRequest> mdmList {get;set;}
        // @AuraEnabled
        // public List<Integer> headerList {get;set;}
        @AuraEnabled
        public Integer lastPageNumber {get;set;}
	}

    /*
    MDMRequest 공통
    */
    public class MDMRequest {
        @AuraEnabled public Integer PV_INDEX {get;set;}
        @AuraEnabled public String PV_NAME1 {get;set;}
        @AuraEnabled public String PV_NAME_G {get;set;}
        @AuraEnabled public String PV_KUNNR {get;set;}
        @AuraEnabled public String PV_OLDCD {get;set;}
        @AuraEnabled public String PV_NAME2 {get;set;}
        @AuraEnabled public String PV_KTOKD {get;set;}
        @AuraEnabled public String PV_CUSTTYPE {get;set;}
        @AuraEnabled public String PV_STCD2 {get;set;}
    }

}