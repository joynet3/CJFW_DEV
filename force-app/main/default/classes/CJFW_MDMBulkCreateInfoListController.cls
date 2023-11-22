/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-17-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
**/
public with sharing class CJFW_MDMBulkCreateInfoListController {

    /* 대량 생성 요청 Id를 통해 받아 온 리스트를 기존의 것과 조사 */
    @AuraEnabled(cacheable=true)
    public static DataWrapper getMDMInfo (String recordId, Integer pageNumber, Integer pageSize) {

        List<MDMRegRequestCustomer__c> mdms = [SELECT PV_NAME1__c, PV_NAME_G__c, PV_KUNNR__c, PV_OLDCD__c, PV_NAME2__c, PV_KTOKD__c, toLabel(PV_KTOKD__c) PV_KTOKDLabel, PV_CUSTTYPE__c, toLabel(PV_CUSTTYPE__c) PV_CUSTTYPELabel, PV_STCD2__c,
                                                      PV_STCD3__c, PV_STCD4__c, PV_GFORM__c, PV_J_1KFREPRE__c, PV_STCD1__c, PV_J_1KFTBUS__c, PV_J_1KFTIND__c, PV_TELF1__c, PV_TELFX__c, PV_VKGRP__c, PVRA_VKGRP__c, PV_PERNR__c, 
                                                      PVRA_PERNR__c, PV_ADMINMA__c, PV_LOGISCENTER__c, PVRA_LOGISCENTER__c, PV_STCDT__c, PV_FITYP__c, PV_HDOFFICEYN__c, PV_HKUNNR__c, PV_SUBSIDIARYYN__c, PV_VBUND__c, PV_LAND1__c, 
                                                      PV_KNVKTYPE__c, PV_CLOSEDT__c, PV_REGIO__c, PV_ADRES_ZIPCODE__c, PV_ADRES_ADDR1__c, PV_ADRES_ADDR2__c, PV_ADRES_ROADADDR1__c, PV_ADRES_ROADADDR2__c, PV_SALESCUST__c, 
                                                      PV_BIZPLCODE__c, PV_BUSAB__c, PV_CESSION_KZ__c, PV_ZUAWA__c, PV_AKONT__c, PV_FDGRV__c, PV_TAXKDD__c, PV_KATR5__c, PV_CUHR1__c, PVRA_CUHR1__c, PV_KONDA__c, PVRA_KONDA__c, 
                                                      PV_KVGR1__c, PVRA_KVGR1__c, PV_WAERS__c, PV_KVGR3__c, PV_KVGR2__c, PV_KVGR3_BOT__c, PV_ODCLOSEGB__c, PV_VACCPRTEXCYN__c, PV_ZTERM_VV__c, PV_DSTRHISTREGYN__c, PV_OLD_BIZPLACE_NEW__c, 
                                                      PVRA_OLD_BIZPLACE_NEW__c, PV_EXAMYN__c, PV_SHIPREQTIME__c, PV_PRODLOADCOND__c, PV_RETURNLOC__c, PV_ENTERCOND1__c, PV_UNLOADCOND1__c, PV_UNLOADCOND2__c, PV_DELIGROUP__c, PV_KATR10__c, 
                                                      PV_KEYYN__c, PV_KEYINFO__c, PV_KXOTD__c, PV_KXOTDTIME__c, PV_FDINFO__c, PV_FDREQD__c, PV_FDREQT__c, PV_ISFDFTF__c, PV_FDCTINFO__c, PV_FDNOTICE__c, PV_SHIPTYPE__c, PV_TEMPTARGET__c 
                                              FROM MDMRegRequestCustomer__c WHERE MDMRegRequestBulkCustomer__c = :recordId ORDER BY Name];

        DataWrapper objWrapper = new DataWrapper();
        
        System.debug('mdms => ' + mdms);

        List<MDMRequest> result = new List<MDMRequest>(); // 해당 페이지에 담은
        List<MDMRequest> mdmList = new List<MDMRequest>(); // 모든 페이지에 담은

        for (Integer i = 0; i < mdms.size(); i++) {
            MDMRequest mdmRequest = new MDMRequest();
            mdmRequest.PV_INDEX                      =            i + 1;
            mdmRequest.PV_NAME1                      =            String.isBlank(mdms[i].PV_NAME1__c) ? null : mdms[i].PV_NAME1__c;
            mdmRequest.PV_NAME_G                     =            String.isBlank(mdms[i].PV_NAME_G__c) ? null : mdms[i].PV_NAME_G__c;
            mdmRequest.PV_KUNNR                      =            String.isBlank(mdms[i].PV_KUNNR__c) ? null : mdms[i].PV_KUNNR__c;
            mdmRequest.PV_OLDCD                      =            String.isBlank(mdms[i].PV_OLDCD__c) ? null : mdms[i].PV_OLDCD__c;
            mdmRequest.PV_NAME2                      =            String.isBlank(mdms[i].PV_NAME2__c) ? null : mdms[i].PV_NAME2__c;
            mdmRequest.PV_KTOKD                      =            String.isBlank(mdms[i].PV_KTOKD__c) ? null : mdms[i].PV_KTOKD__c;
            mdmRequest.PV_CUSTTYPE                   =            String.isBlank(mdms[i].PV_CUSTTYPE__c) ? null : mdms[i].PV_CUSTTYPE__c;
            mdmRequest.PV_STCD2                      =            String.isBlank(mdms[i].PV_STCD2__c) ? null : mdms[i].PV_STCD2__c;
            mdmRequest.PV_STCD3                      =            String.isBlank(mdms[i].PV_STCD3__c) ? null : mdms[i].PV_STCD3__c;
            mdmRequest.PV_STCD4                      =            String.isBlank(mdms[i].PV_STCD4__c) ? null : mdms[i].PV_STCD4__c;
            mdmRequest.PV_GFORM                      =            String.isBlank(mdms[i].PV_GFORM__c) ? null : mdms[i].PV_GFORM__c;
            mdmRequest.PV_J_1KFREPRE                 =            String.isBlank(mdms[i].PV_J_1KFREPRE__c) ? null : mdms[i].PV_J_1KFREPRE__c;
            mdmRequest.PV_STCD1                      =            String.isBlank(mdms[i].PV_STCD1__c) ? null : mdms[i].PV_STCD1__c;
            mdmRequest.PV_J_1KFTBUS                  =            String.isBlank(mdms[i].PV_J_1KFTBUS__c) ? null : mdms[i].PV_J_1KFTBUS__c;
            mdmRequest.PV_J_1KFTIND                  =            String.isBlank(mdms[i].PV_J_1KFTIND__c) ? null : mdms[i].PV_J_1KFTIND__c;
            mdmRequest.PV_TELF1                      =            String.isBlank(mdms[i].PV_TELF1__c) ? null : mdms[i].PV_TELF1__c;
            mdmRequest.PV_TELFX                      =            String.isBlank(mdms[i].PV_TELFX__c) ? null : mdms[i].PV_TELFX__c;
            mdmRequest.PV_VKGRP                      =            String.isBlank(mdms[i].PV_VKGRP__c) ? null : mdms[i].PV_VKGRP__c;
            mdmRequest.PVRA_VKGRP                    =            mdms[i].PVRA_VKGRP__c == null ? null : mdms[i].PVRA_VKGRP__c;
            mdmRequest.PV_PERNR                      =            String.isBlank(mdms[i].PV_PERNR__c) ? null : mdms[i].PV_PERNR__c;
            mdmRequest.PVRA_PERNR                    =            mdms[i].PVRA_PERNR__c == null ? null : mdms[i].PVRA_PERNR__c;
            mdmRequest.PV_ADMINMA                    =            String.isBlank(mdms[i].PV_ADMINMA__c) ? null : mdms[i].PV_ADMINMA__c;
            mdmRequest.PV_LOGISCENTER                =            String.isBlank(mdms[i].PV_LOGISCENTER__c) ? null : mdms[i].PV_LOGISCENTER__c;
            mdmRequest.PVRA_LOGISCENTER              =            mdms[i].PVRA_LOGISCENTER__c == null ? null : mdms[i].PVRA_LOGISCENTER__c;
            mdmRequest.PV_STCDT                      =            String.isBlank(mdms[i].PV_STCDT__c) ? null : mdms[i].PV_STCDT__c;
            mdmRequest.PV_FITYP                      =            String.isBlank(mdms[i].PV_FITYP__c) ? null : mdms[i].PV_FITYP__c;
            mdmRequest.PV_HDOFFICEYN                 =            mdms[i].PV_HDOFFICEYN__c;
            mdmRequest.PV_HKUNNR                     =            String.isBlank(mdms[i].PV_HKUNNR__c) ? null : mdms[i].PV_HKUNNR__c;
            mdmRequest.PV_SUBSIDIARYYN               =            mdms[i].PV_HDOFFICEYN__c;
            mdmRequest.PV_VBUND                      =            String.isBlank(mdms[i].PV_VBUND__c) ? null : mdms[i].PV_VBUND__c;
            mdmRequest.PV_LAND1                      =            String.isBlank(mdms[i].PV_LAND1__c) ? null : mdms[i].PV_LAND1__c;
            mdmRequest.PV_KNVKTYPE                   =            String.isBlank(mdms[i].PV_KNVKTYPE__c) ? null : mdms[i].PV_KNVKTYPE__c;
            mdmRequest.PV_CLOSEDT                    =            mdms[i].PV_HDOFFICEYN__c;
            mdmRequest.PV_REGIO                      =            String.isBlank(mdms[i].PV_REGIO__c) ? null : mdms[i].PV_REGIO__c;
            mdmRequest.PV_ADRES_ZIPCODE              =            String.isBlank(mdms[i].PV_ADRES_ZIPCODE__c) ? null : mdms[i].PV_ADRES_ZIPCODE__c;
            mdmRequest.PV_ADRES_ADDR1                =            String.isBlank(mdms[i].PV_ADRES_ADDR1__c) ? null : mdms[i].PV_ADRES_ADDR1__c;
            mdmRequest.PV_ADRES_ADDR2                =            String.isBlank(mdms[i].PV_ADRES_ADDR2__c) ? null : mdms[i].PV_ADRES_ADDR2__c;
            mdmRequest.PV_ADRES_ROADADDR1            =            String.isBlank(mdms[i].PV_ADRES_ROADADDR1__c) ? null : mdms[i].PV_ADRES_ROADADDR1__c;
            mdmRequest.PV_ADRES_ROADADDR2            =            String.isBlank(mdms[i].PV_ADRES_ROADADDR2__c) ? null : mdms[i].PV_ADRES_ROADADDR2__c;
            mdmRequest.PV_SALESCUST                  =            String.isBlank(mdms[i].PV_SALESCUST__c) ? null : mdms[i].PV_SALESCUST__c;
            mdmRequest.PV_BIZPLCODE                  =            String.isBlank(mdms[i].PV_BIZPLCODE__c) ? null : mdms[i].PV_BIZPLCODE__c;
            mdmRequest.PV_BUSAB                      =            String.isBlank(mdms[i].PV_BUSAB__c) ? null : mdms[i].PV_BUSAB__c;
            mdmRequest.PV_CESSION_KZ                 =            String.isBlank(mdms[i].PV_CESSION_KZ__c) ? null : mdms[i].PV_CESSION_KZ__c;
            mdmRequest.PV_ZUAWA                      =            String.isBlank(mdms[i].PV_ZUAWA__c) ? null : mdms[i].PV_ZUAWA__c;
            mdmRequest.PV_AKONT                      =            String.isBlank(mdms[i].PV_AKONT__c) ? null : mdms[i].PV_AKONT__c;
            mdmRequest.PV_FDGRV                      =            String.isBlank(mdms[i].PV_FDGRV__c) ? null : mdms[i].PV_FDGRV__c;
            mdmRequest.PV_TAXKDD                     =            String.isBlank(mdms[i].PV_TAXKDD__c) ? null : mdms[i].PV_TAXKDD__c;
            mdmRequest.PV_KATR5                      =            String.isBlank(mdms[i].PV_KATR5__c) ? null : mdms[i].PV_KATR5__c;
            mdmRequest.PV_CUHR1                      =            String.isBlank(mdms[i].PV_CUHR1__c) ? null : mdms[i].PV_CUHR1__c;
            mdmRequest.PVRA_CUHR1                    =            mdms[i].PVRA_CUHR1__c == null ? null : mdms[i].PVRA_CUHR1__c;
            mdmRequest.PV_KONDA                      =            String.isBlank(mdms[i].PV_KONDA__c) ? null : mdms[i].PV_KONDA__c;
            mdmRequest.PVRA_KONDA                    =            mdms[i].PVRA_KONDA__c == null ? null : mdms[i].PVRA_KONDA__c;
            mdmRequest.PV_KVGR1                      =            String.isBlank(mdms[i].PV_KVGR1__c) ? null : mdms[i].PV_KVGR1__c;
            mdmRequest.PVRA_KVGR1                    =            mdms[i].PVRA_KVGR1__c == null ? null : mdms[i].PVRA_KVGR1__c;
            mdmRequest.PV_WAERS                      =            String.isBlank(mdms[i].PV_WAERS__c) ? null : mdms[i].PV_WAERS__c;
            mdmRequest.PV_KVGR3                      =            String.isBlank(mdms[i].PV_KVGR3__c) ? null : mdms[i].PV_KVGR3__c;
            mdmRequest.PV_KVGR2                      =            String.isBlank(mdms[i].PV_KVGR2__c) ? null : mdms[i].PV_KVGR2__c;
            mdmRequest.PV_KVGR3_BOT                  =            String.isBlank(mdms[i].PV_KVGR3_BOT__c) ? null : mdms[i].PV_KVGR3_BOT__c;
            mdmRequest.PV_ODCLOSEGB                  =            String.isBlank(mdms[i].PV_ODCLOSEGB__c) ? null : mdms[i].PV_ODCLOSEGB__c;
            mdmRequest.PV_VACCPRTEXCYN               =            mdms[i].PV_VACCPRTEXCYN__c;
            mdmRequest.PV_ZTERM_VV                   =            String.isBlank(mdms[i].PV_ZTERM_VV__c) ? null : mdms[i].PV_ZTERM_VV__c;
            mdmRequest.PV_DSTRHISTREGYN              =            String.isBlank(mdms[i].PV_DSTRHISTREGYN__c) ? null : mdms[i].PV_DSTRHISTREGYN__c;
            mdmRequest.PV_OLD_BIZPLACE_NEW           =            String.isBlank(mdms[i].PV_OLD_BIZPLACE_NEW__c) ? null : mdms[i].PV_OLD_BIZPLACE_NEW__c;
            mdmRequest.PVRA_OLD_BIZPLACE_NEW         =            mdms[i].PVRA_OLD_BIZPLACE_NEW__c == null ? null : mdms[i].PVRA_OLD_BIZPLACE_NEW__c;
            mdmRequest.PV_EXAMYN                     =            mdms[i].PV_EXAMYN__c;
            mdmRequest.PV_SHIPREQTIME                =            String.isBlank(mdms[i].PV_SHIPREQTIME__c) ? null : mdms[i].PV_SHIPREQTIME__c;
            mdmRequest.PV_PRODLOADCOND               =            String.isBlank(mdms[i].PV_PRODLOADCOND__c) ? null : mdms[i].PV_PRODLOADCOND__c;
            mdmRequest.PV_RETURNLOC                  =            String.isBlank(mdms[i].PV_RETURNLOC__c) ? null : mdms[i].PV_RETURNLOC__c;
            mdmRequest.PV_ENTERCOND1                 =            String.isBlank(mdms[i].PV_ENTERCOND1__c) ? null : mdms[i].PV_ENTERCOND1__c;
            mdmRequest.PV_UNLOADCOND1                =            String.isBlank(mdms[i].PV_UNLOADCOND1__c) ? null : mdms[i].PV_UNLOADCOND1__c;
            mdmRequest.PV_UNLOADCOND2                =            String.isBlank(mdms[i].PV_UNLOADCOND2__c) ? null : mdms[i].PV_UNLOADCOND2__c;
            mdmRequest.PV_DELIGROUP                  =            String.isBlank(mdms[i].PV_DELIGROUP__c) ? null : mdms[i].PV_DELIGROUP__c;
            mdmRequest.PV_KATR10                     =            String.isBlank(mdms[i].PV_KATR10__c) ? null : mdms[i].PV_KATR10__c;
            mdmRequest.PV_KEYYN                      =            mdms[i].PV_KEYYN__c;
            mdmRequest.PV_KEYINFO                    =            String.isBlank(mdms[i].PV_KEYINFO__c) ? null : mdms[i].PV_KEYINFO__c;
            mdmRequest.PV_KXOTD                      =            mdms[i].PV_KXOTD__c;
            mdmRequest.PV_KXOTDTIME                  =            String.isBlank(mdms[i].PV_KXOTDTIME__c) ? null : mdms[i].PV_KXOTDTIME__c;
            mdmRequest.PV_FDINFO                     =            mdms[i].PV_FDINFO__c;
            mdmRequest.PV_FDREQD                     =            mdms[i].PV_FDREQD__c == null ? null : mdms[i].PV_FDREQD__c;
            mdmRequest.PV_FDREQT                     =            String.isBlank(mdms[i].PV_FDREQT__c) ? null : mdms[i].PV_FDREQT__c;
            mdmRequest.PV_ISFDFTF                    =            mdms[i].PV_ISFDFTF__c;
            mdmRequest.PV_FDCTINFO                   =            String.isBlank(mdms[i].PV_FDCTINFO__c) ? null : mdms[i].PV_FDCTINFO__c;
            mdmRequest.PV_FDNOTICE                   =            String.isBlank(mdms[i].PV_FDNOTICE__c) ? null : mdms[i].PV_FDNOTICE__c;
            mdmRequest.PV_SHIPTYPE                   =            String.isBlank(mdms[i].PV_SHIPTYPE__c) ? null : mdms[i].PV_SHIPTYPE__c;
            mdmRequest.PV_TEMPTARGET                 =            String.isBlank(mdms[i].PV_TEMPTARGET__c) ? null : mdms[i].PV_TEMPTARGET__c;
            //mdmRequest.PV_KTOKDLabel    =      String.isBlank(mdms[i].PV_KTOKDLabel) ? null : mdms[i].PV_KTOKDLabel;
            //mdmRequest.PV_CUSTTYPELabel =      String.isBlank(mdms[i].PV_CUSTTYPELabel) ? null : mdms[i].PV_CUSTTYPELabel;
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
        @AuraEnabled public String PV_KTOKDLabel {get;set;}
        @AuraEnabled public String PV_CUSTTYPELabel {get;set;}
        @AuraEnabled public String PV_STCD3 {get;set;}
        @AuraEnabled public String PV_STCD4 {get;set;}
        @AuraEnabled public String PV_GFORM {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        @AuraEnabled public String PV_STCD1 {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS {get;set;}
        @AuraEnabled public String PV_J_1KFTIND {get;set;}
        @AuraEnabled public String PV_TELF1 {get;set;}
        @AuraEnabled public String PV_TELFX {get;set;}
        @AuraEnabled public String PV_VKGRP {get;set;}
        @AuraEnabled public Date PVRA_VKGRP {get;set;}
        @AuraEnabled public String PV_PERNR {get;set;}
        @AuraEnabled public Date PVRA_PERNR {get;set;}
        @AuraEnabled public String PV_ADMINMA {get;set;}
        @AuraEnabled public String PV_LOGISCENTER {get;set;}
        @AuraEnabled public Date PVRA_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_STCDT {get;set;}
        @AuraEnabled public String PV_FITYP {get;set;}
        @AuraEnabled public Boolean PV_HDOFFICEYN {get;set;}
        @AuraEnabled public String PV_HKUNNR {get;set;}
        @AuraEnabled public Boolean PV_SUBSIDIARYYN {get;set;}
        @AuraEnabled public String PV_VBUND {get;set;}
        @AuraEnabled public String PV_LAND1 {get;set;}
        @AuraEnabled public String PV_KNVKTYPE {get;set;}
        @AuraEnabled public Boolean PV_CLOSEDT {get;set;}
        @AuraEnabled public String PV_REGIO {get;set;}
        @AuraEnabled public String PV_ADRES_ZIPCODE {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR2 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR2 {get;set;}
        @AuraEnabled public String PV_SALESCUST {get;set;}
        @AuraEnabled public String PV_BIZPLCODE {get;set;}
        @AuraEnabled public String PV_BUSAB {get;set;}
        @AuraEnabled public String PV_CESSION_KZ {get;set;}
        @AuraEnabled public String PV_ZUAWA {get;set;}
        @AuraEnabled public String PV_AKONT {get;set;}
        @AuraEnabled public String PV_FDGRV {get;set;}
        @AuraEnabled public String PV_TAXKDD {get;set;}
        @AuraEnabled public String PV_KATR5 {get;set;}
        @AuraEnabled public String PV_CUHR1 {get;set;}
        @AuraEnabled public Date PVRA_CUHR1 {get;set;}
        @AuraEnabled public String PV_KONDA {get;set;}
        @AuraEnabled public Date PVRA_KONDA {get;set;}
        @AuraEnabled public String PV_KVGR1 {get;set;}
        @AuraEnabled public Date PVRA_KVGR1 {get;set;}
        @AuraEnabled public String PV_WAERS {get;set;}
        @AuraEnabled public String PV_KVGR3 {get;set;}
        @AuraEnabled public String PV_KVGR2 {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT {get;set;}
        @AuraEnabled public String PV_ODCLOSEGB {get;set;}
        @AuraEnabled public Boolean PV_VACCPRTEXCYN {get;set;}
        @AuraEnabled public String PV_ZTERM_VV {get;set;}
        @AuraEnabled public String PV_DSTRHISTREGYN {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public Date PVRA_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public Boolean PV_EXAMYN {get;set;}
        @AuraEnabled public String PV_SHIPREQTIME {get;set;}
        @AuraEnabled public String PV_PRODLOADCOND {get;set;}
        @AuraEnabled public String PV_RETURNLOC {get;set;}
        @AuraEnabled public String PV_ENTERCOND1 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND1 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND2 {get;set;}
        @AuraEnabled public String PV_DELIGROUP {get;set;}
        @AuraEnabled public String PV_KATR10 {get;set;}
        @AuraEnabled public Boolean PV_KEYYN {get;set;}
        @AuraEnabled public String PV_KEYINFO {get;set;}
        @AuraEnabled public Boolean PV_KXOTD {get;set;}
        @AuraEnabled public String PV_KXOTDTIME {get;set;}
        @AuraEnabled public Boolean PV_FDINFO {get;set;}
        @AuraEnabled public Date PV_FDREQD {get;set;}
        @AuraEnabled public String PV_FDREQT {get;set;}
        @AuraEnabled public Boolean PV_ISFDFTF {get;set;}
        @AuraEnabled public String PV_FDCTINFO {get;set;}
        @AuraEnabled public String PV_FDNOTICE {get;set;}
        @AuraEnabled public String PV_SHIPTYPE {get;set;}
        @AuraEnabled public String PV_TEMPTARGET {get;set;}
    }

}