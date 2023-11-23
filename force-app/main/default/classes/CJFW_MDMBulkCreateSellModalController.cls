/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 11-22-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   10-12-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMBulkCreateSellModalController {
    /**
   * Save 버튼을 클릭 했을 때 호출
   * 
   * @params mdmCustomer : 화면 mdmCustomer 데이터
   * @params contacts :화면 contacts (List)데이터 > 왜 리스트가 나올까? 데이터가 다건인가?
   * @params banks : 화면 banks (List) 데이터 
   * 
   * CRM 오브젝트 = wrapper class다 
   * contact < 스탠다드 오브젝트 
   */
    @AuraEnabled                 
    public static SaveResult doSave(List<MDMRequest> mdmCustomer, String type){
        system.debug('gd');
        system.debug('doSave' + mdmCustomer);
        system.debug('type' + type);

        SaveResult saveResult = new SaveResult();

        String recordTypeName = 'MDMChild';     // 판매처
        Id recordIdEx = null;
        String MDMRecordTypeId = '';  
        String Status = 'Waiting';              // 이거
        
        recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMChild').getRecordTypeId();
        MDMRecordTypeId = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(); // 이거

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


        // 각종 ID 필요한 MDMReferenceCode__c 조회해서 Id값 가지고 오기
        Set<String> codeSet = new Set<String>();
        for(MDMRequest mdm : mdmCustomer){

            // JS에서 넘겨준 mdmCustomer 래퍼클래스에
            // 해당하는 필드가 null인데 toUpperCase 같은 String 제공 메소드를 사용한다면 에러가 발생함
            // ex)
            // String isNullStr = null;
            // isNullStr.toUpperCase();
            // Attempt to de-reference a null object 에러 발생

            // 만약 삼항연산자를 사용한다면 codeSet에 String값을 공백이라도 넣어야함
            codeSet.add(String.isNotBlank(mdm.PV_VKGRP)            ? mdm.PV_VKGRP.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_LOGISCENTER)      ? mdm.PV_LOGISCENTER.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_STCDT)            ? mdm.PV_STCDT.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_VBUND)            ? mdm.PV_VBUND.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_LAND1)            ? mdm.PV_LAND1.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_REGIO)            ? mdm.PV_REGIO.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_ZUAWA)            ? mdm.PV_ZUAWA.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_AKONT)            ? mdm.PV_AKONT.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_CUHR1)            ? mdm.PV_CUHR1.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_KONDA)            ? mdm.PV_KONDA.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_KVGR1)            ? mdm.PV_KVGR1.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_WAERS)            ? mdm.PV_WAERS.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_KVGR3)            ? mdm.PV_KVGR3.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_KVGR3_BOT)        ? mdm.PV_KVGR3_BOT.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_ZTERM_VV)         ? mdm.PV_ZTERM_VV.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_OLD_BIZPLACE_NEW) ? mdm.PV_OLD_BIZPLACE_NEW.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_DELIGROUP)        ? mdm.PV_DELIGROUP.toUpperCase() : '');
            codeSet.add(String.isNotBlank(mdm.PV_KATR10)           ? mdm.PV_KATR10.toUpperCase() : '');
        }
        // 겹치는 Code 제외한 MDM 참조 코드 List
        List<MDMReferenceCode__c> referenceCodeList = [SELECT Id, Name, Code__c, GroupId__c FROM MDMReferenceCode__c WHERE code__c = :codeSet];
        // AND GroupId__c NOT IN ('TVV3', 'TVV3_BOT', 'DELIGROUP', 'TVV1', 'TVKO1', 'TZUN', 'TVV2'

        System.debug('# referenceCodeList => ' + referenceCodeList);

        // Key : code , value : Id
        Map<String, String> codeToIdMap = new Map<String, String>();
        Map<String, String> deliveryIdMap = new Map<String, String>(); // 배송그룹
        Map<String, String> statementIdMap = new Map<String, String>(); // 납품서유형
        Map<String, String> statementBotIdMap = new Map<String, String>(); // 납품서하단유형
        Map<String, String> unitPriceIdMap = new Map<String, String>(); // 단가그룹
        Map<String, String> shipmentIdMap = new Map<String, String>(); // 출하권역
        Map<String, String> sortKeyIdMap = new Map<String, String>(); // 정렬키
        // Map<String, String> subsidIdMap = new Map<String, String>(); // 장려금유형
        
        for(MDMReferenceCode__c mdmCode :referenceCodeList){
            if(mdmCode.GroupId__c == 'DELIGROUP') {
                deliveryIdMap.put(mdmCode.Code__c, mdmCode.id);
            } else if(mdmCode.GroupId__c == 'TVV3') {
                statementIdMap.put(mdmCode.Code__c, mdmCode.id);
            } else if(mdmCode.GroupId__c == 'TVV3_BOT') {
                statementBotIdMap.put(mdmCode.Code__c, mdmCode.id);
            } else if(mdmCode.GroupId__c == 'TVV1') {
                unitPriceIdMap.put(mdmCode.Code__c, mdmCode.id);
            } else if(mdmCode.GroupId__c == 'TVKO1') {
                shipmentIdMap.put(mdmCode.Code__c, mdmCode.id);
            } else if(mdmCode.GroupId__c == 'TZUN') {
                sortKeyIdMap.put(mdmCode.Code__c, mdmCode.id);
            } else {
                codeToIdMap.put(mdmCode.Code__c, mdmCode.id);
            }
        }

        // User의 사번필드(ResponsibilityAMA__c)로 User 조회해서 Id값 알아내기
        Set<String> accUserSet = new Set<String>();
        for(MDMRequest mdm : mdmCustomer){
            accUserSet.add(mdm.PV_PERNR);
            accUserSet.add(mdm.PV_ADMINMA);
        }

        accUserSet.remove(null);
        accUserSet.remove('');

        List<User> userList = [SELECT Id, EmployeeNumber FROM User WHERE EmployeeNumber = :accUserSet];
        
        // Key :code , value :Id
        Map<String, String> codeToUserIdMap = new Map<String, String>();
        for(User us : userList){ 
            codeToUserIdMap.put(us.EmployeeNumber, us.Id);
        }


        List<MDMRegRequestCustomer__c> customerList = new List<MDMRegRequestCustomer__c>();
        
        try {
            if(mdmCustomer != null){    
                MDMRegRequestBulkCustomer__c mdmRequestbulk = new MDMRegRequestBulkCustomer__c();
                //bulk 첫번째 => (0번째 Name) + 외 ( )건;
                // 얘가
                //   mdmRequestbulk.Name
                mdmRequestbulk.Name = mdmCustomer[0].PV_NAME1 + ' 외 ' + mdmCustomer.size() + '건';
                mdmRequestbulk.RequestType__c = 'Create';
                insert mdmRequestbulk;

                saveResult.bulkId = mdmRequestbulk.id;
                
                for (MDMRequest mdm : mdmCustomer) {

                    MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c();
                    mdmRequest.MDMRegRequestBulkCustomer__c    =  mdmRequestbulk.Id;
                    mdmRequest.RecordTypeId                    =      String.isBlank(type) ? null     : recordIdEx;
                    mdmRequest.PV_NAME1__c                     =      String.isBlank(mdm.PV_NAME1) ? null : mdm.PV_NAME1;
                    mdmRequest.PV_KUNNR__c                     =      String.isBlank(mdm.PV_KUNNR) ? null : mdm.PV_KUNNR;  
                    mdmRequest.PV_OLDCD__c                     =      String.isBlank(mdm.PV_OLDCD) ? null : mdm.PV_OLDCD;  
                    mdmRequest.PV_NAME_G__c                    =      String.isBlank(mdm.PV_NAME_G) ? null : mdm.PV_NAME_G;  
                    mdmRequest.PV_NAME2__c                     =      String.isBlank(mdm.PV_NAME2) ? null : mdm.PV_NAME2;  
                    mdmRequest.PV_KTOKD__c                     =      String.isBlank(mdm.PV_KTOKD) ? null : mdm.PV_KTOKD;  
                    mdmRequest.PV_CUSTTYPE__c                  =      String.isBlank(mdm.PV_CUSTTYPE) ? null : mdm.PV_CUSTTYPE;      
                    mdmRequest.PV_STCD2__c                     =      String.isBlank(mdm.PV_STCD2) ? null : mdm.PV_STCD2;  
                    mdmRequest.PV_STCD3__c                     =      String.isBlank(mdm.PV_STCD3) ? null : mdm.PV_STCD3;  
                    mdmRequest.PV_STCD4__c                     =      String.isBlank(mdm.PV_STCD4) ? null : mdm.PV_STCD4;  
                    mdmRequest.PV_GFORM__c                     =      String.isBlank(mdm.PV_GFORM) ? null : mdm.PV_GFORM;  
                    mdmRequest.PV_J_1KFREPRE__c                =      String.isBlank(mdm.PV_J_1KFREPRE) ? null : mdm.PV_J_1KFREPRE;      
                    mdmRequest.PV_STCD1__c                     =      String.isBlank(mdm.PV_STCD1) ? null : mdm.PV_STCD1;  
                    mdmRequest.PV_J_1KFTBUS__c                 =      String.isBlank(mdm.PV_J_1KFTBUS) ? null : mdm.PV_J_1KFTBUS;      
                    mdmRequest.PV_J_1KFTIND__c                 =      String.isBlank(mdm.PV_J_1KFTIND) ? null : mdm.PV_J_1KFTIND;      
                    mdmRequest.PV_TELF1__c                     =      String.isBlank(mdm.PV_TELF1) ? null : mdm.PV_TELF1;  
                    mdmRequest.PV_TELFX__c                     =      String.isBlank(mdm.PV_TELFX) ? null : mdm.PV_TELFX;  
                    mdmRequest.PV_PAYCUST__c                   =      String.isBlank(mdm.PV_PAYCUST) ? null : mdm.PV_PAYCUST;      
                    mdmRequest.PV_PAYCUST_lu__c                =      codeToAccIdMap.get(mdmRequest.PV_PAYCUST__c);      
                    mdmRequest.PV_CHARGECUST__c                =      String.isBlank(mdm.PV_CHARGECUST) ? null : mdm.PV_CHARGECUST;      
                    mdmRequest.PV_CHARGECUST_lu__c             =      codeToAccIdMap.get(mdmRequest.PV_CHARGECUST__c);
                    mdmRequest.PV_VKGRP__c                     =      String.isBlank(mdm.PV_VKGRP) ? null : mdm.PV_VKGRP;  
                    mdmRequest.PV_VKGRP_lu__c                  =      codeToIdMap.get(mdmRequest.PV_VKGRP__c);
                    mdmRequest.PVRA_VKGRP__c                   =      (String.isBlank(mdm.PVRA_VKGRP)) ? null : Date.valueOf(mdm.PVRA_VKGRP);
                    mdmRequest.PV_PERNR__c                     =      String.isBlank(mdm.PV_PERNR) ? null : mdm.PV_PERNR;  
                    mdmRequest.PV_PERNR_lu__c                  =      codeToUserIdMap.get(mdmRequest.PV_PERNR__c);
                    mdmRequest.PVRA_PERNR__c                   =      (String.isBlank(mdm.PVRA_PERNR)) ? null : Date.valueOf(mdm.PVRA_PERNR);      
                    mdmRequest.PV_ADMINMA__c                   =      String.isBlank(mdm.PV_ADMINMA) ? null : mdm.PV_ADMINMA;      
                    mdmRequest.PV_ADMINMA_lu__c                =      codeToUserIdMap.get(mdmRequest.PV_ADMINMA__c);
                    mdmRequest.PV_LOGISCENTER__c               =      String.isBlank(mdm.PV_LOGISCENTER) ? null : mdm.PV_LOGISCENTER;          
                    mdmRequest.PV_LOGISCENTER_lu__c            =      codeToIdMap.get(mdmRequest.PV_LOGISCENTER__c);
                    mdmRequest.PVRA_LOGISCENTER__c             =      (String.isBlank(mdm.PVRA_LOGISCENTER)) ? null : Date.valueOf(mdm.PVRA_LOGISCENTER);          
                    mdmRequest.PV_STCDT__c                     =      String.isBlank(mdm.PV_STCDT) ? null : mdm.PV_STCDT;  
                    mdmRequest.PV_STCDT_lu__c                  =      codeToIdMap.get(mdmRequest.PV_STCDT__c);
                    mdmRequest.PV_FITYP__c                     =      String.isBlank(mdm.PV_FITYP) ? null : mdm.PV_FITYP;  
                    mdmRequest.PV_HDOFFICEYN__c                =      (!String.isBlank(mdm.PV_HDOFFICEYN) && mdm.PV_HDOFFICEYN.equalsIgnoreCase('Y')) ? true : false;
                    mdmRequest.PV_HKUNNR__c                    =      String.isBlank(mdm.PV_HKUNNR) ? null : mdm.PV_HKUNNR;  
                    mdmRequest.PV_HKUNNR_lu__c                 =      codeToAccIdMap.get(mdmRequest.PV_HKUNNR__c);
                    mdmRequest.PV_SUBSIDIARYYN__c              =      (!String.isBlank(mdm.PV_SUBSIDIARYYN) && mdm.PV_SUBSIDIARYYN.equalsIgnoreCase('Y')) ? true : false;      
                    mdmRequest.PV_VBUND__c                     =      String.isBlank(mdm.PV_VBUND) ? null : mdm.PV_VBUND;  
                    mdmRequest.PV_VBUND_lu__c                  =      codeToIdMap.get(mdmRequest.PV_VBUND__c);
                    mdmRequest.PV_LAND1__c                     =      String.isBlank(mdm.PV_LAND1) ? null : mdm.PV_LAND1;  
                    mdmRequest.PV_LAND1_lu__c                  =      codeToIdMap.get(mdmRequest.PV_LAND1__c);
                    mdmRequest.PV_KNVKTYPE__c                  =      String.isBlank(mdm.PV_KNVKTYPE) ? null : mdm.PV_KNVKTYPE;      
                    mdmRequest.PV_CLOSEDT__c                   =      (String.isBlank(mdm.PV_CLOSEDT)) ? null : Date.valueOf(mdm.PV_CLOSEDT);      
                    mdmRequest.PV_REGIO__c                     =      String.isBlank(mdm.PV_REGIO) ? null : mdm.PV_REGIO;  
                    mdmRequest.PV_REGIO_lu__c                  =      codeToIdMap.get(mdmRequest.PV_REGIO__c);
                    mdmRequest.PV_ADRES_ZIPCODE__c             =      String.isBlank(mdm.PV_ADRES_ZIPCODE) ? null : mdm.PV_ADRES_ZIPCODE;          
                    mdmRequest.PV_ADRES_ADDR1__c               =      String.isBlank(mdm.PV_ADRES_ADDR1) ? null : mdm.PV_ADRES_ADDR1;          
                    mdmRequest.PV_ADRES_ADDR2__c               =      String.isBlank(mdm.PV_ADRES_ADDR2) ? null : mdm.PV_ADRES_ADDR2;          
                    mdmRequest.PV_ADRES_ROADADDR1__c           =      String.isBlank(mdm.PV_ADRES_ROADADDR1) ? null : mdm.PV_ADRES_ROADADDR1;              
                    mdmRequest.PV_ADRES_ROADADDR2__c           =      String.isBlank(mdm.PV_ADRES_ROADADDR2) ? null : mdm.PV_ADRES_ROADADDR2;              
                    mdmRequest.PV_BUSAB__c                     =      String.isBlank(mdm.PV_BUSAB) ? null : mdm.PV_BUSAB;  
                    mdmRequest.PV_CESSION_KZ__c                =      String.isBlank(mdm.PV_CESSION_KZ) ? null : mdm.PV_CESSION_KZ;      
                    mdmRequest.PV_ZUAWA__c                     =      String.isBlank(mdm.PV_ZUAWA) ? null : mdm.PV_ZUAWA;  
                    mdmRequest.PV_ZUAWA_lu__c                  =      sortKeyIdMap.get(mdmRequest.PV_ZUAWA__c);
                    mdmRequest.PV_AKONT__c                     =      String.isBlank(mdm.PV_AKONT) ? null : mdm.PV_AKONT;  
                    mdmRequest.PV_AKONT_lu__c                  =      codeToIdMap.get(mdmRequest.PV_AKONT__c);
                    mdmRequest.PV_FDGRV__c                     =      String.isBlank(mdm.PV_FDGRV) ? null : mdm.PV_FDGRV;  
                    mdmRequest.PV_VRSDG__c                     =      String.isBlank(mdm.PV_VRSDG) ? null : mdm.PV_VRSDG;  
                    mdmRequest.PV_TAXKDD__c                    =      String.isBlank(mdm.PV_TAXKDD) ? null : mdm.PV_TAXKDD;  
                    mdmRequest.PV_KATR5__c                     =      String.isBlank(mdm.PV_KATR5) ? null : mdm.PV_KATR5;  
                    mdmRequest.PV_CUHR1__c                     =      String.isBlank(mdm.PV_CUHR1) ? null : mdm.PV_CUHR1;  
                    mdmRequest.PV_CUHR1_lu__c                  =      codeToIdMap.get(mdmRequest.PV_CUHR1__c);
                    mdmRequest.PVRA_CUHR1__c                   =      (String.isBlank(mdm.PVRA_CUHR1)) ? null : Date.valueOf(mdm.PVRA_CUHR1);      
                    mdmRequest.PV_KONDA__c                     =      String.isBlank(mdm.PV_KONDA) ? null : mdm.PV_KONDA;  
                    mdmRequest.PV_KONDA_lu__c                  =      codeToIdMap.get(mdmRequest.PV_KONDA__c);
                    mdmRequest.PVRA_KONDA__c                   =      (String.isBlank(mdm.PVRA_KONDA)) ? null : Date.valueOf(mdm.PVRA_KONDA);      
                    mdmRequest.PV_KVGR1__c                     =      String.isBlank(mdm.PV_KVGR1) ? null : mdm.PV_KVGR1;  
                    mdmRequest.PV_KVGR1_lu__c                  =      unitPriceIdMap.get(mdmRequest.PV_KVGR1__c);
                    mdmRequest.PVRA_KVGR1__c                   =      (String.isBlank(mdm.PVRA_KVGR1)) ? null : Date.valueOf(mdm.PVRA_KVGR1);      
                    mdmRequest.PV_WAERS__c                     =      String.isBlank(mdm.PV_WAERS) ? null : mdm.PV_WAERS;  
                    mdmRequest.PV_WAERS_lu__c                  =      codeToIdMap.get(mdmRequest.PV_WAERS__c);
                    mdmRequest.PV_KDGRP__c                     =      String.isBlank(mdm.PV_KDGRP) ? null : mdm.PV_KDGRP;  
                    mdmRequest.PV_KVGR3__c                     =      String.isBlank(mdm.PV_KVGR3) ? null : mdm.PV_KVGR3;  
                    mdmRequest.PV_KVGR3_lu__c                  =      statementIdMap.get(mdmRequest.PV_KVGR3__c);
                    mdmRequest.PV_KVGR2__c                     =      String.isBlank(mdm.PV_KVGR2) ? null : mdm.PV_KVGR2;  
                    mdmRequest.PV_KVGR3_BOT__c                 =      String.isBlank(mdm.PV_KVGR3_BOT) ? null : mdm.PV_KVGR3_BOT;      
                    mdmRequest.PV_KVGR3_BOT_lu__c              =      statementBotIdMap.get(mdmRequest.PV_KVGR3_BOT__c);
                    mdmRequest.PV_ODCLOSEGB__c                 =      String.isBlank(mdm.PV_ODCLOSEGB) ? null : mdm.PV_ODCLOSEGB;      
                    mdmRequest.PV_VACCPRTEXCYN__c              =      (!String.isBlank(mdm.PV_VACCPRTEXCYN)) && mdm.PV_VACCPRTEXCYN.equalsIgnoreCase('Y') ? true : false;          
                    mdmRequest.PV_ZTERM_VV__c                  =      String.isBlank(mdm.PV_ZTERM_VV) ? null : mdm.PV_ZTERM_VV;      
                    mdmRequest.PV_ZTERM_VV_lu__c               =      codeToIdMap.get(mdmRequest.PV_ZTERM_VV__c);
                    mdmRequest.PV_DSTRHISTREGYN__c             =      String.isBlank(mdm.PV_DSTRHISTREGYN) ? null : mdm.PV_DSTRHISTREGYN;          
                    mdmRequest.PV_KULTG__c                     =      String.isBlank(mdm.PV_KULTG) ? null : mdm.PV_KULTG;  
                    mdmRequest.PV_OLD_BIZPLACE_NEW__c          =      String.isBlank(mdm.PV_OLD_BIZPLACE_NEW) ? null : mdm.PV_OLD_BIZPLACE_NEW;              
                    mdmRequest.PV_OLD_BIZPLACE_NEW_lu__c       =      codeToIdMap.get(mdmRequest.PV_OLD_BIZPLACE_NEW__c);
                    mdmRequest.PVRA_OLD_BIZPLACE_NEW__c        =      (String.isBlank(mdm.PVRA_OLD_BIZPLACE_NEW)) ? null : Date.valueOf(mdm.PVRA_OLD_BIZPLACE_NEW);              
                    mdmRequest.PV_SHAPE__c                     =      String.isBlank(mdm.PV_SHAPE) ? null : mdm.PV_SHAPE;  
                    mdmRequest.PV_EXAMYN__c                    =      (!String.isBlank(mdm.PV_EXAMYN)) && mdm.PV_EXAMYN.equalsIgnoreCase('Y') ? true : false;  
                    mdmRequest.PV_SHIPREQTIME__c               =      String.isBlank(mdm.PV_SHIPREQTIME) ? null : mdm.PV_SHIPREQTIME;          
                    mdmRequest.PV_PRODLOADCOND__c              =      String.isBlank(mdm.PV_PRODLOADCOND) ? null : mdm.PV_PRODLOADCOND;          
                    mdmRequest.PV_RETURNLOC__c                 =      String.isBlank(mdm.PV_RETURNLOC) ? null : mdm.PV_RETURNLOC;      
                    mdmRequest.PV_ENTERCOND1__c                =      String.isBlank(mdm.PV_ENTERCOND1) ? null : mdm.PV_ENTERCOND1;      
                    mdmRequest.PV_UNLOADCOND1__c               =      String.isBlank(mdm.PV_UNLOADCOND1) ? null : mdm.PV_UNLOADCOND1;          
                    mdmRequest.PV_UNLOADCOND2__c               =      String.isBlank(mdm.PV_UNLOADCOND2) ? null : mdm.PV_UNLOADCOND2;          
                    mdmRequest.PV_DELIGROUP__c                 =      String.isBlank(mdm.PV_DELIGROUP) ? null : mdm.PV_DELIGROUP;      
                    mdmRequest.PV_KATR10__c                    =      String.isBlank(mdm.PV_KATR10) ? null : mdm.PV_KATR10;  
                    mdmRequest.PV_KEYYN__c                     =      (!String.isBlank(mdm.PV_KEYYN)) && mdm.PV_KEYYN.equalsIgnoreCase('Y') ? true : false;  
                    mdmRequest.PV_KEYINFO__c                   =      String.isBlank(mdm.PV_KEYINFO) ? null : mdm.PV_KEYINFO;      
                    mdmRequest.PV_KXOTD__c                     =      (!String.isBlank(mdm.PV_KXOTD)) && mdm.PV_KXOTD.equalsIgnoreCase('Y') ? true : false;  
                    mdmRequest.PV_KXOTDTIME__c                 =      String.isBlank(mdm.PV_KXOTDTIME) ? null : mdm.PV_KXOTDTIME;      
                    mdmRequest.PV_FDINFO__c                    =      (!String.isBlank(mdm.PV_FDINFO)) && mdm.PV_FDINFO.equalsIgnoreCase('Y') ? true : false;  
                    mdmRequest.PV_FDREQD__c                    =      (String.isBlank(mdm.PV_FDREQD)) ? null : Date.valueOf(mdm.PV_FDREQD);  
                    mdmRequest.PV_FDREQT__c                    =      String.isBlank(mdm.PV_FDREQT) ? null : mdm.PV_FDREQT;  
                    mdmRequest.PV_ISFDFTF__c                   =      (!String.isBlank(mdm.PV_ISFDFTF)) && mdm.PV_ISFDFTF.equalsIgnoreCase('Y') ? true : false;      
                    mdmRequest.PV_FDCTINFO__c                  =      String.isBlank(mdm.PV_FDCTINFO) ? null : mdm.PV_FDCTINFO;      
                    mdmRequest.PV_FDNOTICE__c                  =      String.isBlank(mdm.PV_FDNOTICE) ? null : mdm.PV_FDNOTICE;      
                    mdmRequest.PV_SHIPTYPE__c                  =      String.isBlank(mdm.PV_SHIPTYPE) ? null : mdm.PV_SHIPTYPE;      
                    mdmRequest.PV_TEMPTARGET__c                =      String.isBlank(mdm.PV_TEMPTARGET) ? null : mdm.PV_TEMPTARGET;     
                    customerList.add(mdmRequest);
                }
                insert customerList;

                saveResult.status = 'S';
                saveResult.massage = '성공 하였습니다.';
            }
        } catch (Exception e) {
            saveResult.error = e.getMessage() +', '+ e.getLineNumber();
            saveResult.status = 'F';
            saveResult.massage = '실패 하였습니다.';
            
            throw new AuraHandledException(e.getMessage()+ ', '+ e.getLineNumber());
        }
        return saveResult;
    }
     /**
    * =======================================================================================================================
    * @description : 대량생성 유효성 검사 (대량의 경우 JS에서 하면 시간이 너무 올래 걸려서 Controller로 이동)
    * @params      : X
    * @return      : `List<ErrorData>`
    * =======================================================================================================================
    */
   @AuraEnabled
   public static List<ErrorData> validationCheckBeforeSave(List<MDMRequest> mdmList) {
       System.debug(' ### validationCheckBeforeSave() ' );
       try {
           System.debug('mdmList ' + mdmList);
   
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
   
           for (Integer i = 0; i < mdmList.size(); i++) {
               MDMRequest mdm = mdmList[i];
                checkRequiredField(mdm.PV_NAME1, i,  '고객명(영문명 포함)', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_NAME_G, i, '고객명(G) / 자국명', '필수값', errorDataidList);
                //checkRequiredField(mdm.PV_NAME2, i, '고객약칭명(변경)', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KTOKD, i, '고객계정그룹[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_CUSTTYPE, i, '고객유형[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_STCD2, i, '사업자등록번호', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_STCD3, i, '법인코드', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_STCD4, i, '종사업장번호', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_GFORM, i, '법적상태[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_J_1KFREPRE, i, '대표자이름', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_STCD1, i, '대표자 생년월일', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_J_1KFTBUS, i, '업태', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_J_1KFTIND, i, '업종', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_TELF1, i, '전화번호', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_TELFX, i, '팩스번호', '필수값', errorDataidList);                      // 판매처 팩스번호 추가
                // checkRequiredField(mdm.PV_PAYCUST, i, '지급처[ID]', '필수값', errorDataidList);                  // 판매처 지급처 추가
                // checkRequiredField(mdm.PV_CHARGECUST, i, '청구처[ID]', '필수값', errorDataidList);               // 판매처 청구처 추가
                // checkRequiredField(mdm.PV_VKGRP, i, '영업그룹[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PVRA_VKGRP, i, '영업그룹[VALID FROM]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_PERNR, i, '담당MA[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PVRA_PERNR, i, '담당MA[VALID FROM]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_LOGISCENTER, i, 'FW 출고센터[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PVRA_LOGISCENTER, i, 'FW 출고센터[VALID FROM]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_STCDT, i, '세금계산서발행유형[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_FITYP, i, '과세유형[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_HDOFFICEYN, i, '본점사용 유무', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_HKUNNR, i, '본점코드[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_SUBSIDIARYYN, i, '관계사여부', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_VBUND, i, '관계사 코드[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_LAND1, i, '국가키[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KNVKTYPE, i, '주문유형[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_REGIO, i, '지역[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_ADRES_ZIPCODE, i, '주소[ZIPCODE]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_ADRES_ADDR1, i, '주소[ADDR1]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_ADRES_ADDR2, i, '주소[ADDR2]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_ADRES_ROADADDR1, i, '주소[ROAD ADDR1]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_ADRES_ROADADDR2, i, '주소[ROAD ADDR2]', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_SALESCUST, i, '판매처[ID]', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_BUSAB, i, '매출형태[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_CESSION_KZ, i, '고객상태[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_ZUAWA, i, '정렬키[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_AKONT, i, '조정계정[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_FDGRV, i, '현금관리그룹[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_VRSDG, i, '입금여부(FS만 사용)[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_TAXKDD, i, '세금분류[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KATR5, i, '세금납부방법[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_CUHR1, i, '고객분류[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PVRA_CUHR1, i, '고객분류[VALID FROM]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KONDA, i, '가격그룹[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PVRA_KONDA, i, '가격그룹[VALID FROM]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KVGR1, i, '단가그룹[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PVRA_KVGR1, i, '단가그룹[VALID FROM]', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_WAERS, i, '통화[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KDGRP, i, '여신관리(고객향)[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KVGR3, i, '납품서유형[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KVGR3_BOT, i, '납품서 하단유형[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_ODCLOSEGB, i, '고객 주문마감 유형코드[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_VACCPRTEXCYN, i, '가상계좌 출력 제외', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_ZTERM_VV, i, '지급조건[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_DSTRHISTREGYN, i, '유통이력 신고대상 유형[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_KULTG, i, '약정회전일', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_OLD_BIZPLACE_NEW, i, '경로(사업부)[ID]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PVRA_OLD_BIZPLACE_NEW, i, '경로(사업부)[VALID FROM]', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_SHAPE, i, '외형(정원)', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_EXAMYN, i, '대면검수여부', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_DELIGROUP, i, '배송그룹[ID]', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_KEYYN, i, '업장key 여부', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_KEYINFO, i, '업장key 정보', '필수값', errorDataidList);
                // [판매처]checkRequiredField(mdm.PV_ISFDFTF, i, '초도배송 대면검수', '필수값', errorDataidList);
                // checkRequiredField(mdm.PV_TEMPTARGET, i, '온도기록지 제출 대상 여부[ID]', '필수값', errorDataidList);
               
               // 구코드(As-Is)
               if(mdm.PV_OLDCD != null){
                   System.debug('## mdm.PV_OLDCD => ' + mdm.PV_OLDCD);

                   Matcher matcher = pattern1.matcher(mdm.PV_OLDCD);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_OLDCD != '' && mdm.PV_OLDCD != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '구코드(As-Is)', '구코드(As-Is): 구코드는 10자리 이하의 숫자만 가능합니다.', '유효성');
                       System.debug('## obj : PV_OLDCD => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               // 사업자등록번호 
               if(mdm.PV_STCD2 != null ){
                   System.debug('## mdm.PV_STCD2 => ' + mdm.PV_STCD2);

                   Matcher matcher = pattern2.matcher(mdm.PV_STCD2);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_STCD2 != '' && mdm.PV_STCD2 != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '사업자등록번호', '올바른 형식의 사업자등록번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.', '유효성');
                       System.debug('## obj : PV_STCD2 => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               // 종사업자번호
               if(mdm.PV_STCD4 != null ){
                   System.debug('## mdm.PV_STCD4 => ' + mdm.PV_STCD4);

                   Matcher matcher = pattern9.matcher(mdm.PV_STCD4);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_STCD4 != '' && mdm.PV_STCD4 != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '종사업자번호', '올바른 형식의 종사업자번호가 아닙니다. 4자리 숫자만 입력이 가능합니다.', '유효성');
                       System.debug('## obj : PV_STCD2 => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               // 법인코드 
               if(mdm.PV_STCD3 != null){
                   System.debug('## mdm.PV_STCD3 => ' + mdm.PV_STCD3);

                   Matcher matcher = pattern3.matcher(mdm.PV_STCD3);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_STCD3 != '' && mdm.PV_STCD3 != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '법인코드', '올바른 형식의 법인코드가 아닙니다. 13자리 숫자만 입력이 가능합니다.', '유효성');
                       System.debug('## obj : PV_STCD2 => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               // 대표자 생년월일 
               if(mdm.PV_STCD1 != null){
                   System.debug('## mdm.PV_STCD1 => ' + mdm.PV_STCD1);

                   Matcher matcher = pattern4.matcher(mdm.PV_STCD1);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_STCD1 != '' && mdm.PV_STCD1 != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '대표자 생년월일', '올바른 형식의 대표자 생년월일이 아닙니다. 6자리만 입력이 가능합니다. 예시) 750101', '유효성');
                       System.debug('## obj : PV_STCD1 => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               // 전화번호
               if(mdm.PV_TELF1 != null){
                   System.debug('## mdm.PV_TELF1 => ' + mdm.PV_TELF1);

                   Matcher matcher = pattern5.matcher(mdm.PV_TELF1);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_TELF1 != '' && mdm.PV_TELF1 != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '전화번호', '올바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력', '유효성');
                       System.debug('## obj : PV_TELF1 => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               // 팩스번호
               if(mdm.PV_TELFX != null){
                   System.debug('## mdm.PV_TELF1 => ' + mdm.PV_TELFX);

                   Matcher matcher = pattern6.matcher(mdm.PV_TELFX);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_TELFX != '' && mdm.PV_TELFX != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '전화번호', '올바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력', '유효성');
                       System.debug('## obj : PV_TELFX => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               // 약정회전일
               if(mdm.PV_KULTG != null){
                   System.debug('## mdm.PV_TELF1 => ' + mdm.PV_KULTG);

                   Matcher matcher = pattern7.matcher(mdm.PV_KULTG);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_KULTG != '' && mdm.PV_KULTG != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '약정회전일', '올바른 형식의 약정회전일이 아닙니다.', '유효성');
                       System.debug('## obj : PV_KULTG => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               // 외형(정원)
               if(mdm.PV_SHAPE != null){
                   System.debug('## mdm.PV_TELF1 => ' + mdm.PV_SHAPE);

                   Matcher matcher = pattern8.matcher(mdm.PV_SHAPE);

                   System.debug('matcher.matches()' + matcher.matches());

                   if(mdm.PV_SHAPE != '' && mdm.PV_SHAPE != null && !matcher.matches()) {
                       ErrorData obj = new ErrorData(i + 1, '외형(정원)', '올바른 형식의 외형이 아닙니다.', '유효성');
                       System.debug('## obj : PV_SHAPE => ' + obj);
                       errorDataidList.add(obj);
                   }
               }
               
           }
   
           System.debug('errorDataidList => ' + errorDataidList);
           return errorDataidList;
   
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
    /**
    * =======================================================================================================================
    * @description : 대량생성의 참조코드 매뉴얼 다운로드 URL 
    * @params      : (필드API명, i, 필드명, '필수값', errorDataidList);
    * @return      : X
    * =======================================================================================================================
    */
    public static void checkRequiredField(Object fieldValue, Integer index, String fieldName, String type, List<ErrorData> errorDataidList) {
        if (fieldValue == null || (fieldValue instanceof String && String.isBlank((String)fieldValue))) {
            ErrorData obj = new ErrorData(index + 1, fieldName, '필수 값 입니다.', '필수값');
            System.debug('## obj => ' + obj);
            errorDataidList.add(obj);
        }
    } 
   /**
    * =======================================================================================================================
    * @description : 대량생성의 참조코드 매뉴얼 다운로드 URL 
    * @params      : X
    * @return      : `String`
    *              let hiddenElement = document.createElement('a');
    *                  hiddenElement.href = result;
    *                  hiddenElement.target = '_blank';
    *                  hiddenElement.download = 'download';
    *                  hiddenElement.click();
    * =======================================================================================================================
    */
    @AuraEnabled  
    public static String downloadMenualExcel(){
        ContentVersion cv = [SELECT   Title, id, VersionNumber 
                                FROM     ContentVersion 
                                WHERE    Title = 'MDM 참조코드 매뉴얼' 
                                ORDER BY VersionNumber DESC LIMIT 1];

        String contentId = cv.Id;

        return URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentId;
    }
   
  
    /**
    * SaveResult Wrapper
    */
    public class SaveResult{
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String massage{get;set;}
        @AuraEnabled public String customerId{get;set;}
        @AuraEnabled public String bulkId{get;set;}
        @AuraEnabled public String error{get;set;}

      public SaveResult(){}
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
        @AuraEnabled public String PV_ADRES_ZIPCODE {get;set;}    //수정에 없는지?
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

    /**
    * ErrorData Wrapper
    */
    public class ErrorData {
        @AuraEnabled public Integer no;
        @AuraEnabled public String field;
        @AuraEnabled public String errorMsg;
        @AuraEnabled public String type;

        public ErrorData(Integer no, String field, String errorMsg, String type) {
            this.no = no;
            this.field = field;
            this.errorMsg = errorMsg;
            this.type = type;
        }
    }
}