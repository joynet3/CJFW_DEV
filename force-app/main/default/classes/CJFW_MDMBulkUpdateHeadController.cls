/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-16-2023
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
        } else if(type.startsWith('관리처')) {
            recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMManagement').getRecordTypeId();
        }
        
        System.debug(' type => ' + type);
        System.debug(' recordIdEx => ' + recordIdEx);
        
        // 이름이 null값이 되지 않도록 null일 경우 기존 값을 찾아서 기입해 줄 Map 생성
        Map<String, String> nameMaps = getNameOfNull(mdmCustomer);

        // 각종 ID 필요한 MDMReferenceCode__c 조회해서 Id값 가지고 오기
        Set<String> codeSet = new Set<String>();
        for(MDMRequest mdm : mdmCustomer){
            codeSet.add(mdm.PV_VKGRP);
            codeSet.add(mdm.PV_LOGISCENTER);
            codeSet.add(mdm.PV_STCDT);
            codeSet.add(mdm.PV_VBUND);
            codeSet.add(mdm.PV_LAND1);
            codeSet.add(mdm.PV_REGIO);
            codeSet.add(mdm.PV_ZUAWA);
            codeSet.add(mdm.PV_AKONT);
            codeSet.add(mdm.PV_CUHR1);
            codeSet.add(mdm.PV_KONDA);
            codeSet.add(mdm.PV_KVGR1);
            codeSet.add(mdm.PV_WAERS);
            codeSet.add(mdm.PV_KVGR3);
            codeSet.add(mdm.PV_KVGR3_BOT);
            codeSet.add(mdm.PV_ZTERM_VV);
            codeSet.add(mdm.PV_OLD_BIZPLACE_NEW);
            codeSet.add(mdm.PV_DELIGROUP);
            codeSet.add(mdm.PV_KATR10);
            codeSet.remove(null);
            codeSet.remove('');
        }
        
        List<MDMReferenceCode__c> referenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c = :codeSet];

        System.debug('# referenceCodeList => ' + referenceCodeList);

        // Key : code , value : Id
        Map<String, String> codeToIdMap = new Map<String, String>();
        for(MDMReferenceCode__c mdmCode :referenceCodeList){ 
            codeToIdMap.put(mdmCode.Code__c, mdmCode.id);
        }

        System.debug('# codeToIdMap => ' + codeToIdMap);

        // 고객의 CustomerId 필드(CustomerId__c)로 조회해서 Id값 알아내기
        Set<String> accSet = new Set<String>();
        for(MDMRequest mdm : mdmCustomer){
            accSet.add(mdm.PV_PAYCUST);
            accSet.add(mdm.PV_CHARGECUST);
            accSet.add(mdm.PV_SALESCUST);
            accSet.add(mdm.PV_DELICUST);
            accSet.add(mdm.PV_BIZPLCODE);
            accSet.add(mdm.PV_HKUNNR);
            accSet.remove(null);
            accSet.remove('');
        }

        List<Account> accList = [SELECT Id, Name, CustomerId__c FROM Account WHERE CustomerId__c = :accSet];

        System.debug('# accList => ' + accList);
        
        // Key :code , value :Id
        Map<String, String> codeToAccIdMap = new Map<String, String>();
        for(Account acc : accList){ 
            codeToAccIdMap.put(acc.CustomerId__c, acc.Id);
        }

        System.debug('# codeToAccIdMap => ' + codeToAccIdMap);

        // User의 사번필드(ResponsibilityAMA__c)로 User 조회해서 Id값 알아내기
        Set<String> accUserSet = new Set<String>();
        for(MDMRequest mdm : mdmCustomer){
            accUserSet.add(mdm.PV_PERNR);
            accUserSet.add(mdm.PV_ADMINMA);
            accUserSet.remove(null);
            accUserSet.remove('');
        }
        List<User> userList = [SELECT Id, EmployeeNumber FROM User WHERE EmployeeNumber = :accUserSet];

        System.debug('# accUserSet => ' + accUserSet);
        
        // Key :code , value :Id
        Map<String, String> codeToUserIdMap = new Map<String, String>();
        for(User us : userList){ 
            codeToUserIdMap.put(us.EmployeeNumber, us.Id);
        }

        // CustomerID로 Boolean 값들 받아서 오기
        Set<String> custIds = new Set<String>();
        for(MDMRequest mdm : mdmCustomer){
            custIds.add(mdm.PV_KUNNR);
            custIds.remove(null);
            custIds.remove('');
        }

        List<Account> booleanList = [SELECT Id, CustomerId__c, PV_BLCKYN__c, IsHeadShopUseYN__c, IsAffiliatedcompanyYN__c, IsPrintVirtualAccount__c, IsFaceToFaceInspectionStatus__c, IsInitialDeliveryFTFInspection__c, IsBusinessPlaceKey__c, InitialDeliveryShare__c, KXOTD__c FROM Account WHERE CustomerID__c = :custIds];

        System.debug('# booleanList => ' + booleanList);
        
        // Key : Id , value : boolean
        Map<String, Boolean> blckYnMap = new Map<String, Boolean>();           // 사용 중지
        Map<String, Boolean> headShopYnMap = new Map<String, Boolean>();       // 본점 사용 유무
        Map<String, Boolean> affCompanyYnMap = new Map<String, Boolean>();     // 관계사 여부
        Map<String, Boolean> accountYnMap = new Map<String, Boolean>();        // 가상 계좌
        Map<String, Boolean> faceYnMap = new Map<String, Boolean>();           // 대면 검수
        Map<String, Boolean> kxOtdMap = new Map<String, Boolean>();            // KX OTD
        Map<String, Boolean> bKeyYnMap = new Map<String, Boolean>();           // 업장 Key
        Map<String, Boolean> isFaceYnMap = new Map<String, Boolean>();         // 초도배송 대면 검수
        Map<String, Boolean> fdInfoMap = new Map<String, Boolean>();           // 초도배송 정보 공유

        // Map<String, Account> booleanAccMap = new Map<String, Account>();

        for(Account acc : booleanList){ 
            // booleanAccMap.put(acc.CustomerId__c, acc);

            blckYnMap.put(acc.CustomerId__c, acc.PV_BLCKYN__c);
            headShopYnMap.put(acc.CustomerId__c, acc.IsHeadShopUseYN__c);
            affCompanyYnMap.put(acc.CustomerId__c, acc.IsAffiliatedcompanyYN__c);
            accountYnMap.put(acc.CustomerId__c, acc.IsPrintVirtualAccount__c);
            faceYnMap.put(acc.CustomerId__c, acc.IsFaceToFaceInspectionStatus__c);

            Boolean isKxOtd = false;
            if(acc.KXOTD__c == 'Y') {
                isKxOtd = true;
            } else if(acc.KXOTD__c == 'N') {
                isKxOtd = false;
            }

            kxOtdMap.put(acc.CustomerId__c, isKxOtd);
            bKeyYnMap.put(acc.CustomerId__c, acc.IsBusinessPlaceKey__c);
            isFaceYnMap.put(acc.CustomerId__c, acc.IsInitialDeliveryFTFInspection__c);

            Boolean isFdInfo = false;
            if(acc.InitialDeliveryShare__c == 'Y') {
                isFdInfo = true;
            } else if(acc.InitialDeliveryShare__c == 'N') {
                isFdInfo = false;
            }

            fdInfoMap.put(acc.CustomerId__c, isFdInfo);
        }

        System.debug('# blckYnMap => ' + blckYnMap);
        System.debug('# headShopYnMap => ' + headShopYnMap);
        System.debug('# affCompanyYnMap => ' + affCompanyYnMap);
        System.debug('# accountYnMap => ' + accountYnMap);
        System.debug('# faceYnMap => ' + faceYnMap);
        System.debug('# bKeyYnMap => ' + bKeyYnMap);
        System.debug('# isFaceYnMap => ' + isFaceYnMap);
        
        List<MDMRegRequestCustomer__c> customerList = new List<MDMRegRequestCustomer__c>();

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

                    mdmRequest.RecordTypeId                    =      String.isBlank(type) ? null : recordIdEx;
                    mdmRequest.PV_KUNNR__c                     =      String.isBlank(mdm.PV_KUNNR) ? null : mdm.PV_KUNNR;
                    mdmRequest.PV_OLDCD__c                     =      String.isBlank(mdm.PV_OLDCD) ? null : mdm.PV_OLDCD;
                    mdmRequest.PV_NAME1__c                     =      String.isBlank(mdm.PV_NAME1) ? nameMaps.get(mdm.PV_KUNNR) : mdm.PV_NAME1;
                    mdmRequest.PV_NAME_G__c                    =      String.isBlank(mdm.PV_NAME_G) ? null : mdm.PV_NAME_G;
                    mdmRequest.PV_NAME2__c                     =      String.isBlank(mdm.PV_NAME2) ? null : mdm.PV_NAME2;
                    mdmRequest.PV_KTOKD__c                     =      String.isBlank(mdm.PV_KTOKD) ? null : mdm.PV_KTOKD;
                    mdmRequest.PV_CUSTTYPE__c                  =      String.isBlank(mdm.PV_CUSTTYPE) ? null : mdm.PV_CUSTTYPE;
                    mdmRequest.PV_STCD2__c                     =      String.isBlank(mdm.PV_STCD2) ? null : mdm.PV_STCD2;
                    mdmRequest.PV_STCD3__c                     =      String.isBlank(mdm.PV_STCD3) ? null : mdm.PV_STCD3;
                    mdmRequest.PV_STCD4__c                     =      String.isBlank(mdm.PV_STCD4) ? null : mdm.PV_STCD4;
                    mdmRequest.PV_GFORM__c                     =      String.isBlank(mdm.PV_GFORM) ? null : mdm.PV_GFORM;
                    mdmRequest.PV_J_1KFREPRE__c                =      String.isBlank(mdm.PV_J_1KFREPRE) ? null : mdm.PV_J_1KFREPRE;
                    mdmRequest.PV_BLCKYN__c                    =      (mdm.PV_BLCKYN == '' || mdm.PV_BLCKYN == null) ? blckYnMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_BLCKYN);
                    mdmRequest.PV_STCD1__c                     =      String.isBlank(mdm.PV_STCD1) ? null : mdm.PV_STCD1;
                    mdmRequest.PV_J_1KFTBUS__c                 =      String.isBlank(mdm.PV_J_1KFTBUS) ? null : mdm.PV_J_1KFTBUS;
                    mdmRequest.PV_J_1KFTIND__c                 =      String.isBlank(mdm.PV_J_1KFTIND) ? null : mdm.PV_J_1KFTIND;
                    mdmRequest.PV_TELF1__c                     =      String.isBlank(mdm.PV_TELF1) ? null : mdm.PV_TELF1;
                    mdmRequest.PV_TELFX__c                     =      String.isBlank(mdm.PV_TELFX) ? null : mdm.PV_TELFX;
                    mdmRequest.PV_PAYCUST__c                   =      String.isBlank(mdm.PV_PAYCUST) ? null : mdm.PV_PAYCUST;
                    mdmRequest.PV_PAYCUST_lu__c                =      codeToAccIdMap.get(mdm?.PV_PAYCUST);
                    mdmRequest.PV_CHARGECUST__c                =      String.isBlank(mdm.PV_CHARGECUST) ? null : mdm.PV_CHARGECUST;
                    mdmRequest.PV_CHARGECUST_lu__c             =      codeToAccIdMap.get(mdm?.PV_CHARGECUST);
                    mdmRequest.PV_VKGRP__c                     =      String.isBlank(mdm.PV_VKGRP) ? null : mdm.PV_VKGRP;
                    mdmRequest.PV_VKGRP_lu__c                  =      codeToIdMap.get(mdm?.PV_VKGRP);
                    mdmRequest.PVVF_VKGRP__c                   =      (mdm.PVVF_VKGRP == null || mdm.PVVF_VKGRP == '') ? null : Date.valueOf(mdm.PVVF_VKGRP);
                    mdmRequest.PVRA_VKGRP__c                   =      (mdm.PVRA_VKGRP == null || mdm.PVRA_VKGRP == '') ? null : Date.valueOf(mdm.PVRA_VKGRP);
                    mdmRequest.PV_PERNR__c                     =      String.isBlank(mdm.PV_PERNR) ? null : mdm.PV_PERNR;
                    mdmRequest.PV_PERNR_lu__c                  =      codeToUserIdMap.get(mdm?.PV_PERNR);
                    mdmRequest.PVVF_PERNR__c                   =      (mdm.PVVF_PERNR == null || mdm.PVVF_PERNR == '') ? null : Date.valueOf(mdm.PVVF_PERNR);
                    mdmRequest.PVRA_PERNR__c                   =      (mdm.PVRA_PERNR == null || mdm.PVRA_PERNR == '') ? null : Date.valueOf(mdm.PVRA_PERNR);
                    mdmRequest.PV_ADMINMA__c                   =      String.isBlank(mdm.PV_ADMINMA) ? null : mdm.PV_ADMINMA;
                    mdmRequest.PV_ADMINMA_lu__c                =      codeToUserIdMap.get(mdm?.PV_ADMINMA);
                    mdmRequest.PV_LOGISCENTER__c               =      String.isBlank(mdm.PV_LOGISCENTER) ? null : mdm.PV_LOGISCENTER;
                    mdmRequest.PV_LOGISCENTER_lu__c            =      codeToIdMap.get(mdm?.PV_LOGISCENTER);
                    mdmRequest.PVVF_LOGISCENTER__c             =      (mdm.PVVF_LOGISCENTER == null || mdm.PVVF_LOGISCENTER == '') ? null : Date.valueOf(mdm.PVVF_LOGISCENTER);
                    mdmRequest.PVRA_LOGISCENTER__c             =      (mdm.PVRA_LOGISCENTER == null || mdm.PVRA_LOGISCENTER == '') ? null : Date.valueOf(mdm.PVRA_LOGISCENTER);
                    mdmRequest.PV_STCDT__c                     =      String.isBlank(mdm.PV_STCDT) ? null : mdm.PV_STCDT;
                    mdmRequest.PV_STCDT_lu__c                  =      codeToIdMap.get(mdm?.PV_STCDT);
                    mdmRequest.PV_FITYP__c                     =      String.isBlank(mdm.PV_FITYP) ? null : mdm.PV_FITYP;
                    mdmRequest.PV_HDOFFICEYN__c                =      (mdm.PV_HDOFFICEYN == '' || mdm.PV_HDOFFICEYN == null) ? headShopYnMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_HDOFFICEYN);
                    mdmRequest.PV_HKUNNR__c                    =      String.isBlank(mdm.PV_HKUNNR) ? null : mdm.PV_HKUNNR;
                    mdmRequest.PV_HKUNNR_lu__c                 =      codeToAccIdMap.get(mdm?.PV_HKUNNR);
                    mdmRequest.PV_SUBSIDIARYYN__c              =      (mdm.PV_SUBSIDIARYYN == '' || mdm.PV_SUBSIDIARYYN == null) ? affCompanyYnMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_SUBSIDIARYYN);
                    mdmRequest.PV_VBUND__c                     =      String.isBlank(mdm.PV_VBUND) ? null : mdm.PV_VBUND;
                    mdmRequest.PV_VBUND_lu__c                  =      codeToIdMap.get(mdm?.PV_VBUND);
                    mdmRequest.PV_LAND1__c                     =      String.isBlank(mdm.PV_LAND1) ? null : mdm.PV_LAND1;
                    mdmRequest.PV_LAND1_lu__c                  =      codeToIdMap.get(mdm?.PV_LAND1);
                    mdmRequest.PV_KNVKTYPE__c                  =      String.isBlank(mdm.PV_KNVKTYPE) ? null : mdm.PV_KNVKTYPE;
                    mdmRequest.PV_CLOSEDT__c                   =      (mdm.PV_CLOSEDT == '' || mdm.PV_CLOSEDT == null) ? null : Date.valueOf(mdm.PV_CLOSEDT);
                    mdmRequest.PV_REGIO__c                     =      String.isBlank(mdm.PV_REGIO) ? null : mdm.PV_REGIO;
                    mdmRequest.PV_REGIO_lu__c                  =      codeToIdMap.get(mdm?.PV_REGIO);
                    mdmRequest.PV_ADRES_ROADADDR1__c           =      String.isBlank(mdm.PV_ADRES_ROADADDR1) ? null : mdm.PV_ADRES_ROADADDR1;
                    mdmRequest.PV_ADRES_ROADADDR2__c           =      String.isBlank(mdm.PV_ADRES_ROADADDR2) ? null : mdm.PV_ADRES_ROADADDR2;
                    mdmRequest.PV_ADRES_ADDR1__c               =      String.isBlank(mdm.PV_ADRES_ADDR1) ? null : mdm.PV_ADRES_ADDR1;
                    mdmRequest.PV_ADRES_ADDR2__c               =      String.isBlank(mdm.PV_ADRES_ADDR2) ? null : mdm.PV_ADRES_ADDR2;
                    mdmRequest.PV_DELICUST__c                  =      String.isBlank(mdm.PV_DELICUST) ? null : mdm.PV_DELICUST;
                    mdmRequest.PV_DELICUST_lu__c               =      codeToAccIdMap.get(mdm?.PV_DELICUST);
                    mdmRequest.PV_SALESCUST__c                 =      String.isBlank(mdm.PV_SALESCUST) ? null : mdm.PV_SALESCUST;
                    mdmRequest.PV_SALESCUST_lu__c              =      codeToAccIdMap.get(mdm?.PV_SALESCUST);
                    mdmRequest.PV_BIZPLCODE__c                 =      String.isBlank(mdm.PV_BIZPLCODE) ? null : mdm.PV_BIZPLCODE;
                    mdmRequest.PV_BIZPLCODE_lu__c              =      codeToAccIdMap.get(mdm?.PV_BIZPLCODE);
                    mdmRequest.PV_BUSAB__c                     =      String.isBlank(mdm.PV_BUSAB) ? null : mdm.PV_BUSAB;
                    mdmRequest.PV_CESSION_KZ__c                =      String.isBlank(mdm.PV_CESSION_KZ) ? null : mdm.PV_CESSION_KZ;
                    mdmRequest.PV_ZUAWA__c                     =      String.isBlank(mdm.PV_ZUAWA) ? null : mdm.PV_ZUAWA;
                    mdmRequest.PV_ZUAWA_lu__c                  =      codeToIdMap.get(mdm?.PV_ZUAWA);
                    mdmRequest.PV_AKONT__c                     =      String.isBlank(mdm.PV_AKONT) ? null : mdm.PV_AKONT;
                    mdmRequest.PV_AKONT_lu__c                  =      codeToIdMap.get(mdm?.PV_AKONT);
                    mdmRequest.PV_FDGRV__c                     =      String.isBlank(mdm.PV_FDGRV) ? null : mdm.PV_FDGRV;
                    mdmRequest.PV_VRSDG__c                     =      String.isBlank(mdm.PV_VRSDG) ? null : mdm.PV_VRSDG;
                    mdmRequest.PV_TAXKDD__c                    =      String.isBlank(mdm.PV_TAXKDD) ? null : mdm.PV_TAXKDD;
                    mdmRequest.PV_KATR5__c                     =      String.isBlank(mdm.PV_KATR5) ? null : mdm.PV_KATR5;
                    mdmRequest.PV_CUHR1__c                     =      String.isBlank(mdm.PV_CUHR1) ? null : mdm.PV_CUHR1;
                    mdmRequest.PV_CUHR1_lu__c                  =      codeToIdMap.get(mdm?.PV_CUHR1);
                    mdmRequest.PVVF_CUHR1__c                   =      (mdm.PVVF_CUHR1 == null || mdm.PVVF_CUHR1 == '') ? null : Date.valueOf(mdm.PVVF_CUHR1);
                    mdmRequest.PVRA_CUHR1__c                   =      (mdm.PVRA_CUHR1 == null || mdm.PVRA_CUHR1 == '') ? null : Date.valueOf(mdm.PVRA_CUHR1);
                    mdmRequest.PV_KONDA__c                     =      String.isBlank(mdm.PV_KONDA) ? null : mdm.PV_KONDA;
                    mdmRequest.PV_KONDA_lu__c                  =      codeToIdMap.get(mdm?.PV_KONDA);
                    mdmRequest.PVVF_KONDA__c                   =      (mdm.PVVF_KONDA == null || mdm.PVVF_KONDA == '') ? null : Date.valueOf(mdm.PVVF_KONDA);
                    mdmRequest.PVRA_KONDA__c                   =      (mdm.PVRA_KONDA == null || mdm.PVRA_KONDA == '') ? null : Date.valueOf(mdm.PVRA_KONDA);
                    mdmRequest.PV_KVGR1__c                     =      String.isBlank(mdm.PV_KVGR1) ? null : mdm.PV_KVGR1;
                    mdmRequest.PV_KVGR1_lu__c                  =      codeToIdMap.get(mdm?.PV_KVGR1);
                    mdmRequest.PVVF_KVGR1__c                   =      (mdm.PVVF_KVGR1 == null || mdm.PVVF_KVGR1 == '') ? null : Date.valueOf(mdm.PVVF_KVGR1);
                    mdmRequest.PVRA_KVGR1__c                   =      (mdm.PVRA_KVGR1 == null || mdm.PVRA_KVGR1 == '') ? null : Date.valueOf(mdm.PVRA_KVGR1);
                    mdmRequest.PV_WAERS__c                     =      String.isBlank(mdm.PV_WAERS) ? null : mdm.PV_WAERS;
                    mdmRequest.PV_WAERS_lu__c                  =      codeToIdMap.get(mdm?.PV_WAERS);
                    mdmRequest.PV_KDGRP__c                     =      String.isBlank(mdm.PV_KDGRP) ? null : mdm.PV_KDGRP;
                    mdmRequest.PV_KVGR3__c                     =      String.isBlank(mdm.PV_KVGR3) ? null : mdm.PV_KVGR3;
                    mdmRequest.PV_KVGR3_lu__c                  =      codeToIdMap.get(mdm?.PV_KVGR3);
                    mdmRequest.PV_KVGR2__c                     =      String.isBlank(mdm.PV_KVGR2) ? null : mdm.PV_KVGR2;
                    mdmRequest.PV_KVGR3_BOT__c                 =      String.isBlank(mdm.PV_KVGR3_BOT) ? null : mdm.PV_KVGR3_BOT;
                    mdmRequest.PV_KVGR3_BOT_lu__c              =      codeToIdMap.get(mdm?.PV_KVGR3_BOT);
                    mdmRequest.PV_ODCLOSEGB__c                 =      String.isBlank(mdm.PV_ODCLOSEGB) ? null : mdm.PV_ODCLOSEGB;
                    mdmRequest.PV_VACCPRTEXCYN__c              =      (mdm.PV_VACCPRTEXCYN == '' || mdm.PV_VACCPRTEXCYN == null) ? accountYnMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_VACCPRTEXCYN);
                    mdmRequest.PV_ZTERM_VV__c                  =      String.isBlank(mdm.PV_ZTERM_VV) ? null : mdm.PV_ZTERM_VV;
                    mdmRequest.PV_ZTERM_VV_lu__c               =      codeToIdMap.get(mdm?.PV_ZTERM_VV);
                    mdmRequest.PV_DSTRHISTREGYN__c             =      String.isBlank(mdm.PV_DSTRHISTREGYN) ? null : mdm.PV_DSTRHISTREGYN;
                    mdmRequest.PV_KULTG__c                     =      String.isBlank(mdm.PV_KULTG) ? null : mdm.PV_KULTG;
                    mdmRequest.PV_OLD_BIZPLACE_NEW__c          =      String.isBlank(mdm.PV_OLD_BIZPLACE_NEW) ? null : mdm.PV_OLD_BIZPLACE_NEW;
                    mdmRequest.PV_OLD_BIZPLACE_NEW_lu__c       =      codeToIdMap.get(mdm?.PV_OLD_BIZPLACE_NEW);
                    mdmRequest.PVVF_OLD_BIZPLACE_NEW__c        =      (mdm.PVVF_OLD_BIZPLACE_NEW == null || mdm.PVVF_OLD_BIZPLACE_NEW == '') ? null : Date.valueOf(mdm.PVVF_OLD_BIZPLACE_NEW);
                    mdmRequest.PVRA_OLD_BIZPLACE_NEW__c        =      (mdm.PVRA_OLD_BIZPLACE_NEW == null || mdm.PVRA_OLD_BIZPLACE_NEW == '') ? null : Date.valueOf(mdm.PVRA_OLD_BIZPLACE_NEW);
                    mdmRequest.PV_SHAPE__c                     =      String.isBlank(mdm.PV_SHAPE) ? null : mdm.PV_SHAPE;
                    mdmRequest.PV_EXAMYN__c                    =      (mdm.PV_EXAMYN == '' || mdm.PV_EXAMYN == null) ? faceYnMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_EXAMYN);
                    mdmRequest.PV_SHIPREQTIME__c               =      String.isBlank(mdm.PV_SHIPREQTIME) ? null : mdm.PV_SHIPREQTIME;
                    mdmRequest.PV_PRODLOADCOND__c              =      String.isBlank(mdm.PV_PRODLOADCOND) ? null : mdm.PV_PRODLOADCOND;
                    mdmRequest.PV_RETURNLOC__c                 =      String.isBlank(mdm.PV_RETURNLOC) ? null : mdm.PV_RETURNLOC;
                    mdmRequest.PV_ENTERCOND1__c                =      String.isBlank(mdm.PV_ENTERCOND1) ? null : mdm.PV_ENTERCOND1;
                    mdmRequest.PV_UNLOADCOND1__c               =      String.isBlank(mdm.PV_UNLOADCOND1) ? null : mdm.PV_UNLOADCOND1;
                    mdmRequest.PV_UNLOADCOND2__c               =      String.isBlank(mdm.PV_UNLOADCOND2) ? null : mdm.PV_UNLOADCOND2;
                    mdmRequest.PV_DELIGROUP__c                 =      String.isBlank(mdm.PV_DELIGROUP) ? null : mdm.PV_DELIGROUP;
                    mdmRequest.PV_DELIGROUP_lu__c              =      codeToIdMap.get(mdm?.PV_DELIGROUP);
                    mdmRequest.PV_KATR10__c                    =      String.isBlank(mdm.PV_KATR10) ? null : mdm.PV_KATR10;
                    mdmRequest.PV_KATR10_lu__c                 =      codeToIdMap.get(mdm?.PV_KATR10);
                    mdmRequest.PV_KEYYN__c                     =      (mdm.PV_KEYYN == '' || mdm.PV_KEYYN == null) ? bKeyYnMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_KEYYN);
                    mdmRequest.PV_KEYINFO__c                   =      String.isBlank(mdm.PV_KEYINFO) ? null : mdm.PV_KEYINFO;
                    mdmRequest.PV_KXOTD__c                     =      (mdm.PV_KXOTD == '' || mdm.PV_KXOTD == null) ? kxOtdMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_KXOTD);
                    mdmRequest.PV_KXOTDTIME__c                 =      String.isBlank(mdm.PV_KXOTDTIME) ? null : mdm.PV_KXOTDTIME;
                    mdmRequest.PV_FDINFO__c                    =      (mdm.PV_FDINFO == '' || mdm.PV_FDINFO == null) ? fdInfoMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_FDINFO);
                    mdmRequest.PV_FDREQD__c                    =      (mdm.PV_FDREQD == '' || mdm.PV_FDREQD == null) ? null : Date.valueOf(mdm.PV_FDREQD);
                    mdmRequest.PV_FDREQT__c                    =      String.isBlank(mdm.PV_FDREQT) ? null : mdm.PV_FDREQT;
                    mdmRequest.PV_ISFDFTF__c                   =      (mdm.PV_ISFDFTF == '' || mdm.PV_ISFDFTF == null) ? isFaceYnMap.get(mdm.PV_KUNNR) : Boolean.valueOf(mdm.PV_ISFDFTF);
                    mdmRequest.PV_FDCTINFO__c                  =      String.isBlank(mdm.PV_FDCTINFO) ? null : mdm.PV_FDCTINFO;
                    mdmRequest.PV_FDNOTICE__c                  =      String.isBlank(mdm.PV_FDNOTICE) ? null : mdm.PV_FDNOTICE;
                    mdmRequest.PV_SHIPTYPE__c                  =      String.isBlank(mdm.PV_SHIPTYPE) ? null : mdm.PV_SHIPTYPE;
                    mdmRequest.PV_TEMPTARGET__c                =      String.isBlank(mdm.PV_TEMPTARGET) ? null : mdm.PV_TEMPTARGET;

                    mdmRequest.RequestType__c                  =      'Edit';

                    mdmRequest.MDMRegRequestBulkCustomer__c    =      mdmRequestbulk.id;

                    customerList.add(mdmRequest);       
                }

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

    @AuraEnabled
    public static List<ErrorData> validationCheckBeforeSave(List<MDMRequest> mdmList, List<String> headerList){
        try {

            List<ErrorData> errorDataidList = new List<ErrorData>();

            // 구코드 validation
            String regex1 = '^(\\d{0,10}|)$';
            Pattern pattern1 = Pattern.compile(regex1);
            // 사업자등록번호 제어 validation
            String regex2 = '^(\\d{10}|)$';
            Pattern pattern2 = Pattern.compile(regex2);
            // 법인코드 제어 validation
            String regex3 = '^(\\d{13}|)$';
            Pattern pattern3 = Pattern.compile(regex3);
            // 대표자 생년월일 validation
            String regex4 = '^(?:[0-9]{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[1,2][0-9]|3[0,1]))$|^$';
            Pattern pattern4 = Pattern.compile(regex4);
            // 전화번호 validation
            String regex5 = '^\\d{2,3}-\\d{3,4}-\\d{4}$';
            Pattern pattern5 = Pattern.compile(regex5);
            // 팩스번호 validation
            String regex6 = '^\\d{2,3}-\\d{3,4}-\\d{4}$';
            Pattern pattern6 = Pattern.compile(regex6);
            // 약정회전일 validation
            String regex7 = '^\\d{1,3}$|^$';
            Pattern pattern7 = Pattern.compile(regex7);
            // 외형(정원) validation
            String regex8 = '^\\d{0,11}$';
            Pattern pattern8 = Pattern.compile(regex8);
            // 종사업자번호 제어 validation
            String regex9 = '^(\\d{4}|)$';
            Pattern pattern9 = Pattern.compile(regex9);

            for(Integer i = 0; i < mdmList.size(); i++) {

                MDMRequest mdm = mdmList[i];

                if(headerList.contains('구코드(As-Is)')) {
                    if(mdm.PV_OLDCD != null) {

                        System.debug('## mdm.PV_OLDCD => ' + mdm.PV_OLDCD);

                        Matcher matcher = pattern1.matcher(mdm.PV_OLDCD);

                        System.debug('matcher.matches()' + matcher.matches());

                        if(mdm.PV_OLDCD != '' && mdm.PV_OLDCD != null && !matcher.matches()) {
                            ErrorData obj = new ErrorData(mdm.PV_INDEX, '구코드(As-Is)', '구코드(As-Is): 구코드는 10자리 이하의 숫자만 가능합니다.');
                            System.debug('## obj => ' + obj);
                            errorDataidList.add(obj);
                        }
                    }
                }

                if(headerList.contains('사업자등록번호')) {
                    if(mdm.PV_STCD2 != null) {

                        System.debug('## mdm.PV_STCD2 => ' + mdm.PV_STCD2);

                        Matcher matcher = pattern2.matcher(mdm.PV_STCD2);

                        System.debug('matcher.matches()' + matcher.matches());

                        if(mdm.PV_STCD2 != '' && mdm.PV_STCD2 != null && !matcher.matches()) {
                            ErrorData obj = new ErrorData(mdm.PV_INDEX, '사업자등록번호', '올바른 형식의 사업자등록번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.');
                            System.debug('## obj => ' + obj);
                            errorDataidList.add(obj);
                        }
                    }
                }

                if(headerList.contains('법인코드')) {
                    if(mdm.PV_STCD3 != null) {

                        System.debug('## mdm.PV_STCD3 => ' + mdm.PV_STCD3);

                        Matcher matcher = pattern3.matcher(mdm.PV_STCD3);

                        System.debug('matcher.matches()' + matcher.matches());

                        if(mdm.PV_STCD3 != '' && mdm.PV_STCD3 != null && !matcher.matches()) {
                            ErrorData obj = new ErrorData(mdm.PV_INDEX, '법인코드', '올바른 형식의 법인코드가 아닙니다. 13자리 숫자만 입력이 가능합니다.');
                            System.debug('## obj => ' + obj);
                            errorDataidList.add(obj);
                        }
                    }
                }

                if(headerList.contains('대표자 생년월일')) {
                    if(mdm.PV_STCD1 != null) {

                        System.debug('## mdm.PV_STCD1 => ' + mdm.PV_STCD1);

                        Matcher matcher = pattern4.matcher(mdm.PV_STCD1);

                        System.debug('matcher.matches()' + matcher.matches());

                        if(mdm.PV_STCD1 != '' && mdm.PV_STCD1 != null && !matcher.matches()) {
                            ErrorData obj = new ErrorData(mdm.PV_INDEX, '대표자 생년월일', '올바른 형식의 대표자 생년월일이 아닙니다. 6자리만 입력이 가능합니다. 예시) 750101');
                            System.debug('## obj => ' + obj);
                            errorDataidList.add(obj);
                        }
                    }
                }

                if(headerList.contains('전화번호')) {
                    if(mdm.PV_TELF1 != null) {

                        System.debug('## mdm.PV_TELF1 => ' + mdm.PV_TELF1);

                        Matcher matcher = pattern5.matcher(mdm.PV_TELF1);

                        System.debug('matcher.matches()' + matcher.matches());

                        if(mdm.PV_TELF1 != '' && mdm.PV_TELF1 != null && !matcher.matches()) {
                            ErrorData obj = new ErrorData(mdm.PV_INDEX, '전화번호', '올바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력');
                            System.debug('## obj => ' + obj);
                            errorDataidList.add(obj);
                        }
                    }
                }

                if(headerList.contains('팩스번호')) {
                    if(mdm.PV_TELFX != null) {

                        System.debug('## mdm.PV_TELFX => ' + mdm.PV_TELFX);

                        Matcher matcher = pattern6.matcher(mdm.PV_TELFX);

                        System.debug('matcher.matches()' + matcher.matches());

                        if(mdm.PV_TELFX != '' && mdm.PV_TELFX != null && !matcher.matches()) {
                            ErrorData obj = new ErrorData(mdm.PV_INDEX, '팩스번호', '올바른 형식의 팩스번호가 아닙니다. "-" 값을 포함하여 입력');
                            System.debug('## obj => ' + obj);
                            errorDataidList.add(obj);
                        }
                    }
                }

                if(headerList.contains('약정회전일')) {
                    if(mdm.PV_KULTG != null) {

                        System.debug('## mdm.PV_KULTG => ' + mdm.PV_KULTG);

                        Matcher matcher = pattern7.matcher(mdm.PV_KULTG);

                        System.debug('matcher.matches()' + matcher.matches());

                        if(mdm.PV_KULTG != '' && mdm.PV_KULTG != null && !matcher.matches()) {
                            ErrorData obj = new ErrorData(mdm.PV_INDEX, '약정회전일', '올바른 형식의 약정회전일이 아닙니다.');
                            System.debug('## obj => ' + obj);
                            errorDataidList.add(obj);
                        }
                    }
                }

                if(headerList.contains('외형(정원)')) {
                    if(mdm.PV_SHAPE != null) {

                        System.debug('## mdm.PV_SHAPE => ' + mdm.PV_SHAPE);

                        Matcher matcher = pattern8.matcher(mdm.PV_SHAPE);

                        System.debug('matcher.matches()' + matcher.matches());

                        if(mdm.PV_SHAPE != '' && mdm.PV_SHAPE != null && !matcher.matches()) {
                            ErrorData obj = new ErrorData(mdm.PV_INDEX, '외형(정원)', '올바른 형식의 외형이 아닙니다.');
                            System.debug('## obj => ' + obj);
                            errorDataidList.add(obj);
                        }
                    }
                }

            }

            System.debug('errorDataidList => ' + errorDataidList);

            return errorDataidList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* 필드값 모두 가지고 오기 */
    // @AuraEnabled
    // public static Map<String, String> getAllField() {

    //     Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('MDMRegRequestCustomer__c').getDescribe().fields.getMap();

    //     System.debug(fieldMap);

    //     Map<String, String> labels = new Map<String, String>();

    //     for (String fieldName: fieldMap.keySet()) {
    //         DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
    //         if(fieldResult.getName().contains('__c')) {
    //             labels.put(fieldResult.getLabel(), fieldResult.getName());
    //         }
    //     }
    //     return labels;
    // }

    // @AuraEnabled
    // public static List<Map<String, String>> parseExcelData(String data, List<String> headerInfo){
    //     try {

    //         List<String> rows = data.trim().split('\n');
    //         List<Map<String, String>> parsedData = new List<Map<String, String>>();

    //         for (String row : rows) {
    //             List<String> cells = row.split('\t');
    //             Map<String, String> rowData = new Map<String, String>();

    //             // 각 열의 데이터를 필드 컬럼에 매핑된 이름으로 저장
    //             for (Integer i = 0; i < cells.size(); i++) {
    //                 // INDEX 제외하기 위해 i+1로 담아 줌
    //                 String columnName = headerInfo[i + 1];
    //                 rowData.put(columnName, cells[i]);
    //             }
    //             parsedData.add(rowData);
    //         }

    //         return parsedData;
            
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage() +  e.getLineNumber());
    //     }

    // }

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

    public class ErrorData {
        @AuraEnabled public Integer no;
        @AuraEnabled public String field;
        @AuraEnabled public String errorMsg;
        
        public ErrorData(Integer no, String field, String errorMsg) {
            this.no = no;
            this.field = field;
            this.errorMsg = errorMsg;
        }
    }

    /* Wrapper */
    public class MDMRequest {
        @AuraEnabled public String RecordTypeId {get;set;}
        @AuraEnabled public Integer PV_INDEX {get;set;}
        @AuraEnabled public String PV_KUNNR {get;set;}
        @AuraEnabled public String PV_OLDCD {get;set;}
        @AuraEnabled public String PV_NAME1 {get;set;}
        @AuraEnabled public String PV_NAME_G {get;set;}
        @AuraEnabled public String PV_NAME2 {get;set;}
        @AuraEnabled public String PV_KTOKD {get;set;}
        @AuraEnabled public String PV_CUSTTYPE {get;set;}
        @AuraEnabled public String PV_STCD2 {get;set;}
        @AuraEnabled public String PV_STCD3 {get;set;}
        @AuraEnabled public String PV_STCD4 {get;set;}
        @AuraEnabled public String PV_GFORM {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        @AuraEnabled public String PV_BLCKYN {get;set;}
        @AuraEnabled public String PV_STCD1 {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS {get;set;}
        @AuraEnabled public String PV_J_1KFTIND {get;set;}
        @AuraEnabled public String PV_TELF1 {get;set;}
        @AuraEnabled public String PV_TELFX {get;set;}
        @AuraEnabled public String PV_PAYCUST {get;set;}
        @AuraEnabled public String PV_PAYCUST_lu {get;set;}
        @AuraEnabled public String PV_CHARGECUST {get;set;}
        @AuraEnabled public String PV_CHARGECUST_lu {get;set;}
        @AuraEnabled public String PV_VKGRP {get;set;}
        @AuraEnabled public String PV_VKGRP_lu {get;set;}
        @AuraEnabled public String PVVF_VKGRP {get;set;}
        @AuraEnabled public String PVRA_VKGRP {get;set;}
        @AuraEnabled public String PV_PERNR {get;set;}
        @AuraEnabled public String PV_PERNR_lu {get;set;}
        @AuraEnabled public String PVVF_PERNR {get;set;}
        @AuraEnabled public String PVRA_PERNR {get;set;}
        @AuraEnabled public String PV_ADMINMA {get;set;}
        @AuraEnabled public String PV_ADMINMA_lu {get;set;}
        @AuraEnabled public String PV_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_LOGISCENTER_lu {get;set;}
        @AuraEnabled public String PVVF_LOGISCENTER {get;set;}
        @AuraEnabled public String PVRA_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_STCDT {get;set;}
        @AuraEnabled public String PV_STCDT_lu {get;set;}
        @AuraEnabled public String PV_FITYP {get;set;}
        @AuraEnabled public String PV_HDOFFICEYN {get;set;}
        @AuraEnabled public String PV_HKUNNR {get;set;}
        @AuraEnabled public String PV_HKUNNR_lu {get;set;}
        @AuraEnabled public String PV_SUBSIDIARYYN {get;set;}
        @AuraEnabled public String PV_VBUND {get;set;}
        @AuraEnabled public String PV_VBUND_lu {get;set;}
        @AuraEnabled public String PV_LAND1 {get;set;}
        @AuraEnabled public String PV_LAND1_lu {get;set;}
        @AuraEnabled public String PV_KNVKTYPE {get;set;}
        @AuraEnabled public String PV_CLOSEDT {get;set;}
        @AuraEnabled public String PV_REGIO {get;set;}
        @AuraEnabled public String PV_REGIO_lu {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR2 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR2 {get;set;}
        @AuraEnabled public String PV_DELICUST {get;set;}
        @AuraEnabled public String PV_SALESCUST {get;set;}
        @AuraEnabled public String PV_BIZPLCODE {get;set;}
        @AuraEnabled public String PV_BUSAB {get;set;}
        @AuraEnabled public String PV_CESSION_KZ {get;set;}
        @AuraEnabled public String PV_ZUAWA {get;set;}
        @AuraEnabled public String PV_ZUAWA_lu {get;set;}
        @AuraEnabled public String PV_AKONT {get;set;}
        @AuraEnabled public String PV_AKONT_lu {get;set;}
        @AuraEnabled public String PV_FDGRV {get;set;}
        @AuraEnabled public String PV_VRSDG {get;set;}
        @AuraEnabled public String PV_TAXKDD {get;set;}
        @AuraEnabled public String PV_KATR5 {get;set;}
        @AuraEnabled public String PV_CUHR1 {get;set;}
        @AuraEnabled public String PV_CUHR1_lu {get;set;}
        @AuraEnabled public String PVVF_CUHR1 {get;set;}
        @AuraEnabled public String PVRA_CUHR1 {get;set;}
        @AuraEnabled public String PV_KONDA {get;set;}
        @AuraEnabled public String PV_KONDA_lu {get;set;}
        @AuraEnabled public String PVVF_KONDA {get;set;}
        @AuraEnabled public String PVRA_KONDA {get;set;}
        @AuraEnabled public String PV_KVGR1 {get;set;}
        @AuraEnabled public String PV_KVGR1_lu {get;set;}
        @AuraEnabled public String PVVF_KVGR1 {get;set;}
        @AuraEnabled public String PVRA_KVGR1 {get;set;}
        @AuraEnabled public String PV_WAERS {get;set;}
        @AuraEnabled public String PV_WAERS_lu {get;set;}
        @AuraEnabled public String PV_KDGRP {get;set;}
        @AuraEnabled public String PV_KVGR3 {get;set;}
        @AuraEnabled public String PV_KVGR3_lu {get;set;}
        @AuraEnabled public String PV_KVGR2 {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT_lu {get;set;}
        @AuraEnabled public String PV_ODCLOSEGB {get;set;}
        @AuraEnabled public String PV_VACCPRTEXCYN {get;set;}
        @AuraEnabled public String PV_ZTERM_VV {get;set;}
        @AuraEnabled public String PV_ZTERM_VV_lu {get;set;}
        @AuraEnabled public String PV_DSTRHISTREGYN {get;set;}
        @AuraEnabled public String PV_KULTG {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW_lu {get;set;}
        @AuraEnabled public String PVVF_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PVRA_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_SHAPE {get;set;}
        @AuraEnabled public String PV_EXAMYN {get;set;}
        @AuraEnabled public String PV_SHIPREQTIME {get;set;}
        @AuraEnabled public String PV_PRODLOADCOND {get;set;}
        @AuraEnabled public String PV_RETURNLOC {get;set;}
        @AuraEnabled public String PV_ENTERCOND1 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND1 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND2 {get;set;}
        @AuraEnabled public String PV_DELIGROUP {get;set;}
        @AuraEnabled public String PV_DELIGROUP_lu {get;set;}
        @AuraEnabled public String PV_KATR10 {get;set;}
        @AuraEnabled public String PV_KATR10_lu {get;set;}
        @AuraEnabled public String PV_KEYYN {get;set;}
        @AuraEnabled public String PV_KEYINFO {get;set;}
        @AuraEnabled public String PV_KXOTD {get;set;}
        @AuraEnabled public String PV_KXOTDTIME {get;set;}
        @AuraEnabled public String PV_FDINFO {get;set;}
        @AuraEnabled public String PV_FDREQD {get;set;}
        @AuraEnabled public String PV_FDREQT {get;set;}
        @AuraEnabled public String PV_ISFDFTF {get;set;}
        @AuraEnabled public String PV_FDCTINFO {get;set;}
        @AuraEnabled public String PV_FDNOTICE {get;set;}
        @AuraEnabled public String PV_SHIPTYPE {get;set;}
        @AuraEnabled public String PV_TEMPTARGET {get;set;}
    }

}