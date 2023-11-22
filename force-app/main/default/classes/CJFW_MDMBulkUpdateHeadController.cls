/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-22-2023
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
    public static SaveResult doSave(List<MDMRequest> mdmCustomer, String type, List<String> headerList) {
        system.debug('headerList ' + JSON.serialize(headerList));
        system.debug(' # CJFW_MDMBulkUpdateHeadController >>> doSave ');
        SaveResult saveResult = new SaveResult();
        // aura  String 으로 넘어와서 JSON.des
        // mdmCustomer obj =  JSON.deserialize(mdmCustomer, 래퍼클래스명.class);
        system.debug(' >>> doSave # mdmCustomer => ' + JSON.serialize(mdmCustomer));
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
        // Map<String, String> nameMaps = getNameOfNull(mdmCustomer);

        // CustomerID로 Boolean 값들 받아서 오기
        Set<String> custIds = new Set<String>();
        for(MDMRequest mdm : mdmCustomer){
            custIds.add(mdm.PV_KUNNR);
            custIds.remove(null);
            custIds.remove('');
        }
        
        // List<Account> booleanList = [SELECT Id, CustomerId__c, PV_BLCKYN__c, IsHeadShopUseYN__c, IsAffiliatedcompanyYN__c, IsPrintVirtualAccount__c, IsFaceToFaceInspectionStatus__c, IsInitialDeliveryFTFInspection__c, IsBusinessPlaceKey__c, InitialDeliveryShare__c, KXOTD__c FROM Account WHERE CustomerID__c = :custIds];
        List<Account> booleanList = [SELECT Id, CustomerID__c, Name, PICCode__c, CustomerIDASIS__c, NameKor__c, NameAlias__c, AccountGroup__c, toLabel(AccountGroup__c) AccountGroupLabel, CustomerType__c, toLabel(CustomerType__c) CustomerTypeLabel, CompanyRegisterNumber__c, CorporateCode__c, SubCompanyRegisterNumber__c,  LegalStatus__c, toLabel(LegalStatus__c) LegalStatusLabel, RepresentativeName__c, PV_BLCKYN__c, RepresentativeBirthDate__c, BusinessConditions__c, BusinessCategory__c,  Phone, Fax, PaymentAccountCode__c, PaymentAccountName__c, ShippingAccountCode__c, ShippingAccountName__c, PV_VKGRP__c, toLabel(PV_VKGRP__c) PV_VKGRP__LABEL,  PVVF_VKGRP__c, SalesGroupFromDate__c, OwnerId, PVVF_PERNR__c, ResponsibilityMAFromDate__c, ResponsibilityAMA__c, ResponsibilityAMACode__c, TaxInvoiceType__c, toLabel(TaxInvoiceType__c) TaxInvoiceLabel,  IsHeadShopUseYN__c, IsAffiliatedcompanyYN__c, AffiliatedCompany__c, toLabel(AffiliatedCompany__c) AffiliatedCompanyLabel, CountryKeyCode__c, toLabel(CountryKeyCode__c) CountryKeyCodeLabel,  PV_KNVKTYPE__c, toLabel(PV_KNVKTYPE__c) PV_KNVKTYPE__LABEL, ShutDownDate__c, LocationState__c, toLabel(LocationState__c) LocationStateLabel, Address__c, AddressDetails__c,  Address2__c, AddressDetails2__c, SalesForm__c, toLabel(SalesForm__c) SalesFormLabel, CustomerStatus__c, toLabel(CustomerStatus__c) CustomerStatusLabel, SortKey__c, toLabel(SortKey__c) SortKeyLabel,  MediateAccount__c, toLabel(MediateAccount__c) MediateAccountLabel, CashManagementGroup__c, toLabel(CashManagementGroup__c) CashManagementGroupLabel, IsDeposit__c, toLabel(IsDeposit__c) IsDepositLabel,  TaxClassification__c, toLabel(TaxClassification__c) TaxClassificationLabel, TaxPaymentMethod__c, toLabel(TaxPaymentMethod__c) TaxPaymentMethodLabel, CustomerRoute__c, toLabel(CustomerRoute__c) CustomerRouteLabel,  PV_CUHR1__c, CustomerRouteFromDate__c, PriceGroup__c, toLabel(PriceGroup__c) PriceGroupLabel, UnitPriceGroup__c, toLabel(UnitPriceGroup__c) UnitPriceGroupLabel, CurrencyIsoCode,  toLabel(CurrencyIsoCode) CurrencyIsoLabel, CreditManagement__c, toLabel(CreditManagement__c) CreditManagementLabel, SubsidyType__c, toLabel(SubsidyType__c) SubsidyTypeLabel,  IsPrintVirtualAccount__c, TermsOfPayment__c, toLabel(TermsOfPayment__c) TermsOfPaymentLabel, DisHisRegType__c, toLabel(DisHisRegType__c) DisHisRegTypeLabel, ContractRocationDate__c, TaxationType__c,  CustomerPath__c, toLabel(CustomerPath__c) CustomerPathLabel, Shape__c, DeliveryGroup__c, toLabel(DeliveryGroup__c) DeliveryGroupLabel, CustomerOrderDeadlineType__c,  PVVF_KONDA__c, PriceGroupFromDate__c, PVVF_OLD_BIZPLACE_NEW__c, CustomerPathFromDate__c, FWReleaseCenterFromDate__c, PVVF_LOGISCENTER__c, FWReleaseCenter__c, IsFaceToFaceInspectionStatus__c,  DeliveryCustomerCode__c, SalesCustomerCode__c, BizPLCode__c, HeadOfficeCode__c, PVVF_KVGR1__c, UnitPriceGroupFromDate__c, StatementOfDeliveryType__c, StatementOfDeliveryType2__c,   OTD__c, ProductLoadingCondition__c, ReturnLocation__c, VehicleEntryCondtions__c, UnloadConditions1__c, UnloadConditions2__c, ShipmentArea__c, IsBusinessPlaceKey__c, BusinessPlaceKeyInfo__c, KXOTD__c, KXOTDRequestDate__c, InitialDeliveryShare__c, InitialDeliveryRequestDate__c, InitialDeliveryRequestTime__c, IsInitialDeliveryFTFInspection__c, InitialDeliveryContact__c, InitialDeliveryDescription__c, PV_SHIPTYPE__c, PV_TEMPTARGET__c FROM Account WHERE CustomerID__c = :custIds];
        
        System.debug('# booleanList => ' + booleanList);
        
        Map<String, Account> accountMap = new Map<String, Account>();
        
        // Key : Id , value : boolean
        // Map<String, Boolean> blckYnMap = new Map<String, Boolean>();           // 사용 중지
        // Map<String, Boolean> headShopYnMap = new Map<String, Boolean>();       // 본점 사용 유무
        // Map<String, Boolean> affCompanyYnMap = new Map<String, Boolean>();     // 관계사 여부
        // Map<String, Boolean> accountYnMap = new Map<String, Boolean>();        // 가상 계좌
        // Map<String, Boolean> faceYnMap = new Map<String, Boolean>();           // 대면 검수
        // Map<String, Boolean> kxOtdMap = new Map<String, Boolean>();            // KX OTD
        // Map<String, Boolean> bKeyYnMap = new Map<String, Boolean>();           // 업장 Key
        // Map<String, Boolean> isFaceYnMap = new Map<String, Boolean>();         // 초도배송 대면 검수
        // Map<String, Boolean> fdInfoMap = new Map<String, Boolean>();           // 초도배송 정보 공유
        
        // Map<String, Account> booleanAccMap = new Map<String, Account>();
        
        for(Account acc : booleanList){
            accountMap.put(acc.CustomerId__c, acc);
            
            // blckYnMap.put(acc.CustomerId__c, acc.PV_BLCKYN__c);
            // headShopYnMap.put(acc.CustomerId__c, acc.IsHeadShopUseYN__c);
            // affCompanyYnMap.put(acc.CustomerId__c, acc.IsAffiliatedcompanyYN__c);
            // accountYnMap.put(acc.CustomerId__c, acc.IsPrintVirtualAccount__c);
            // faceYnMap.put(acc.CustomerId__c, acc.IsFaceToFaceInspectionStatus__c);
            
            // Boolean isKxOtd = false;
            // if(acc.KXOTD__c == 'Y') {
            //     isKxOtd = true;
            // } else if(acc.KXOTD__c == 'N') {
            //     isKxOtd = false;
            // }
        
        // kxOtdMap.put(acc.CustomerId__c, isKxOtd);
        // bKeyYnMap.put(acc.CustomerId__c, acc.IsBusinessPlaceKey__c);
        // isFaceYnMap.put(acc.CustomerId__c, acc.IsInitialDeliveryFTFInspection__c);
        
        // Boolean isFdInfo = false;
        // if(acc.InitialDeliveryShare__c == 'Y') {
            //     isFdInfo = true;
            // } else if(acc.InitialDeliveryShare__c == 'N') {
            //     isFdInfo = false;
            // }
            
            // fdInfoMap.put(acc.CustomerId__c, isFdInfo);
        }
            
        // System.debug('# blckYnMap => ' + blckYnMap);
        // System.debug('# headShopYnMap => ' + headShopYnMap);
        // System.debug('# affCompanyYnMap => ' + affCompanyYnMap);
        // System.debug('# accountYnMap => ' + accountYnMap);
        // System.debug('# faceYnMap => ' + faceYnMap);
        // System.debug('# bKeyYnMap => ' + bKeyYnMap);
        // System.debug('# isFaceYnMap => ' + isFaceYnMap);
                    
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
        
        // 기존 Account로부터도 받아 오기
        for(Account acc : booleanList) {
            accSet.add(acc.ShippingAccountCode__c);
            accSet.add(acc.PaymentAccountCode__c);
            accSet.add(acc.SalesCustomerCode__c);
            accSet.add(acc.DeliveryCustomerCode__c);
            accSet.add(acc.BizPLCode__c);
            accSet.add(acc.HeadOfficeCode__c);
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
        
        for(Account acc : booleanList) {
            codeSet.add(acc.PV_VKGRP__c);
            codeSet.add(acc.FWReleaseCenter__c);
            codeSet.add(acc.TaxInvoiceType__c);
            codeSet.add(acc.AffiliatedCompany__c);
            codeSet.add(acc.CountryKeyCode__c);
            codeSet.add(acc.LocationState__c);
            codeSet.add(acc.SortKey__c);
            codeSet.add(acc.MediateAccount__c);
            codeSet.add(acc.CustomerRoute__c);
            codeSet.add(acc.PriceGroup__c);
            codeSet.add(acc.UnitPriceGroup__c);
            codeSet.add(acc.CurrencyIsoCode);
            codeSet.add(acc.StatementOfDeliveryType__c);
            codeSet.add(acc.StatementOfDeliveryType2__c);
            codeSet.add(acc.TermsOfPayment__c);
            codeSet.add(acc.CustomerPath__c);
            codeSet.add(acc.DeliveryGroup__c);
            codeSet.add(acc.ShipmentArea__c);
        }

        // null이나 공백 제거함
        codeSet.remove(null);
        codeSet.remove('');
        
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

        System.debug('# codeToIdMap => ' + codeToIdMap);

        // User의 사번필드(ResponsibilityAMA__c)로 User 조회해서 Id값 알아내기
        Set<String> accUserSet = new Set<String>();
        for(MDMRequest mdm : mdmCustomer){
            accUserSet.add(mdm.PV_PERNR);
            accUserSet.add(mdm.PV_ADMINMA);
        }
        
        for(Account acc : booleanList) {
            accUserSet.add(acc.PICCode__c);
            accUserSet.add(acc.ResponsibilityAMACode__c);
        }
        
        accUserSet.remove(null);
        accUserSet.remove('');

        List<User> userList = [SELECT Id, EmployeeNumber FROM User WHERE EmployeeNumber = :accUserSet];

        System.debug('# accUserSet => ' + accUserSet);

        // Key :code , value :Id
        Map<String, String> codeToUserIdMap = new Map<String, String>();
        for(User us : userList){ 
            codeToUserIdMap.put(us.EmployeeNumber, us.Id);
        }
        
        List<MDMRegRequestCustomer__c> customerList = new List<MDMRegRequestCustomer__c>();
                    
        try {
            
            if(mdmCustomer != null){

                MDMRegRequestBulkCustomer__c mdmRequestbulk = new MDMRegRequestBulkCustomer__c();

                String bulkName = mdmCustomer[0].PV_NAME1;
                if(String.isBlank(bulkName) == true) {
                    bulkName = accountMap.get(mdmCustomer[0].PV_KUNNR).Name;
                }

                mdmRequestbulk.RequestType__c = 'Edit';
                
                mdmRequestbulk.Name = bulkName + ' 외 ' + (mdmCustomer.size() -1) + '건';
                insert mdmRequestbulk;
                
                for (MDMRequest mdm : mdmCustomer) {

                    MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c();

                    mdmRequest.RecordTypeId                    =      String.isBlank(type) ? null : recordIdEx;
                    mdmRequest.PV_KUNNR__c                     =      String.isBlank(mdm.PV_KUNNR) ? null : mdm.PV_KUNNR;
                    mdmRequest.PV_OLDCD__c                     =      getValue(mdm.PV_OLDCD, accountMap.get(mdm?.PV_KUNNR)?.CustomerIDASIS__c, headerList.contains('PV_OLDCD'));
                                                                                                                                  // 선택한 헤더리스트에 지금 매핑해줄 필드가 포함 되어있으면 true
                    mdmRequest.PV_NAME1__c                     =      getValue(mdm.PV_NAME1, accountMap.get(mdm?.PV_KUNNR)?.Name, headerList.contains('PV_NAME1'));

                    mdmRequest.PV_NAME_G__c                    =      getValue(mdm.PV_NAME_G, accountMap.get(mdm?.PV_KUNNR)?.NameKor__c, headerList.contains('PV_NAME_G'));
                    mdmRequest.PV_NAME2__c                     =      getValue(mdm.PV_NAME2, accountMap.get(mdm?.PV_KUNNR)?.NameAlias__c,  headerList.contains('PV_NAME2'));
                    mdmRequest.PV_KTOKD__c                     =      getValue(mdm.PV_KTOKD, accountMap.get(mdm?.PV_KUNNR)?.AccountGroup__c);
                    mdmRequest.PV_CUSTTYPE__c                  =      getValue(mdm.PV_CUSTTYPE, accountMap.get(mdm?.PV_KUNNR)?.CustomerType__c);
                    mdmRequest.PV_STCD2__c                     =      getValue(mdm.PV_STCD2, accountMap.get(mdm?.PV_KUNNR)?.CompanyRegisterNumber__c);
                    mdmRequest.PV_STCD3__c                     =      getValue(mdm.PV_STCD3, accountMap.get(mdm?.PV_KUNNR)?.CorporateCode__c);
                    mdmRequest.PV_STCD4__c                     =      getValue(mdm.PV_STCD4, accountMap.get(mdm?.PV_KUNNR)?.SubCompanyRegisterNumber__c);
                    mdmRequest.PV_GFORM__c                     =      getValue(mdm.PV_GFORM, accountMap.get(mdm?.PV_KUNNR)?.LegalStatus__c);
                    mdmRequest.PV_J_1KFREPRE__c                =      getValue(mdm.PV_J_1KFREPRE, accountMap.get(mdm?.PV_KUNNR)?.RepresentativeName__c);
                    mdmRequest.PV_BLCKYN__c                    =      (mdm.PV_BLCKYN == '' || mdm.PV_BLCKYN == null) ? accountMap.get(mdm?.PV_KUNNR).PV_BLCKYN__c : Boolean.valueOf(mdm.PV_BLCKYN);
                    mdmRequest.PV_STCD1__c                     =      getValue(mdm.PV_STCD1, accountMap.get(mdm?.PV_KUNNR)?.RepresentativeBirthDate__c);
                    mdmRequest.PV_J_1KFTBUS__c                 =      getValue(mdm.PV_J_1KFTBUS, accountMap.get(mdm?.PV_KUNNR)?.BusinessConditions__c);
                    mdmRequest.PV_J_1KFTIND__c                 =      getValue(mdm.PV_J_1KFTIND, accountMap.get(mdm?.PV_KUNNR)?.BusinessCategory__c);
                    mdmRequest.PV_TELF1__c                     =      getValue(mdm.PV_TELF1, accountMap.get(mdm?.PV_KUNNR)?.Phone);
                    mdmRequest.PV_TELFX__c                     =      getValue(mdm.PV_TELFX, accountMap.get(mdm?.PV_KUNNR)?.Fax);
                    mdmRequest.PV_PAYCUST__c                   =      getValue(mdm.PV_PAYCUST, accountMap.get(mdm?.PV_KUNNR)?.PaymentAccountCode__c);
                    mdmRequest.PV_PAYCUST_lu__c                =      codeToAccIdMap.get(mdmRequest.PV_PAYCUST__c);
                    mdmRequest.PV_CHARGECUST__c                =      getValue(mdm.PV_CHARGECUST, accountMap.get(mdm?.PV_KUNNR)?.ShippingAccountCode__c);
                    mdmRequest.PV_CHARGECUST_lu__c             =      codeToAccIdMap.get(mdmRequest.PV_CHARGECUST__c);
                    mdmRequest.PV_VKGRP__c                     =      getValue(String.isBlank(mdm.PV_VKGRP) ? '' : mdm.PV_VKGRP.toUpperCase(), accountMap.get(mdm?.PV_KUNNR)?.PV_VKGRP__c);
                    mdmRequest.PV_VKGRP_lu__c                  =      codeToIdMap.get(mdmRequest.PV_VKGRP__c);
                    mdmRequest.PVVF_VKGRP__c                   =      (mdm.PVVF_VKGRP == null || mdm.PVVF_VKGRP == '') ? accountMap.get(mdm?.PV_KUNNR).PVVF_VKGRP__c : Date.valueOf(mdm.PVVF_VKGRP);
                    mdmRequest.PVRA_VKGRP__c                   =      (mdm.PVRA_VKGRP == null || mdm.PVRA_VKGRP == '') ? accountMap.get(mdm?.PV_KUNNR).SalesGroupFromDate__c : Date.valueOf(mdm.PVRA_VKGRP);
                    mdmRequest.PV_PERNR__c                     =      getValue(mdm.PV_PERNR, accountMap.get(mdm?.PV_KUNNR)?.PICCode__c);
                    mdmRequest.PV_PERNR_lu__c                  =      codeToUserIdMap.get(mdmRequest.PV_PERNR__c);
                    mdmRequest.PVVF_PERNR__c                   =      (mdm.PVVF_PERNR == null || mdm.PVVF_PERNR == '') ? accountMap.get(mdm?.PV_KUNNR).PVVF_PERNR__c : Date.valueOf(mdm.PVVF_PERNR);
                    mdmRequest.PVRA_PERNR__c                   =      (mdm.PVRA_PERNR == null || mdm.PVRA_PERNR == '') ? accountMap.get(mdm?.PV_KUNNR).ResponsibilityMAFromDate__c : Date.valueOf(mdm.PVRA_PERNR);
                    mdmRequest.PV_ADMINMA__c                   =      getValue(mdm.PV_ADMINMA, accountMap.get(mdm?.PV_KUNNR)?.ResponsibilityAMA__c);
                    mdmRequest.PV_ADMINMA_lu__c                =      codeToUserIdMap.get(mdmRequest.PV_ADMINMA__c);
                    mdmRequest.PV_LOGISCENTER__c               =      getValue(String.isBlank(mdm.PV_LOGISCENTER) ? '' : mdm.PV_LOGISCENTER.toUpperCase(), accountMap.get(mdm?.PV_KUNNR)?.FWReleaseCenter__c);
                    mdmRequest.PV_LOGISCENTER_lu__c            =      codeToIdMap.get(mdmRequest.PV_LOGISCENTER__c);
                    mdmRequest.PVVF_LOGISCENTER__c             =      (mdm.PVVF_LOGISCENTER == null || mdm.PVVF_LOGISCENTER == '') ? accountMap.get(mdm?.PV_KUNNR).PVVF_LOGISCENTER__c : Date.valueOf(mdm.PVVF_LOGISCENTER);
                    mdmRequest.PVRA_LOGISCENTER__c             =      (mdm.PVRA_LOGISCENTER == null || mdm.PVRA_LOGISCENTER == '') ? accountMap.get(mdm?.PV_KUNNR).FWReleaseCenterFromDate__c : Date.valueOf(mdm.PVRA_LOGISCENTER);
                    mdmRequest.PV_STCDT__c                     =      getValue(String.isBlank(mdm.PV_STCDT) ? '' : mdm.PV_STCDT.toUpperCase(), accountMap.get(mdm?.PV_KUNNR)?.TaxInvoiceType__c);
                    mdmRequest.PV_STCDT_lu__c                  =      codeToIdMap.get(mdmRequest.PV_STCDT__c);
                    mdmRequest.PV_FITYP__c                     =      getValue(mdm.PV_FITYP, accountMap.get(mdm?.PV_KUNNR)?.TaxationType__c);
                    mdmRequest.PV_HDOFFICEYN__c                =      (mdm.PV_HDOFFICEYN == '' || mdm.PV_HDOFFICEYN == null) ? accountMap.get(mdm?.PV_KUNNR).IsHeadShopUseYN__c : Boolean.valueOf(mdm.PV_HDOFFICEYN);
                    mdmRequest.PV_HKUNNR__c                    =      String.isBlank(mdm.PV_HKUNNR) ? accountMap.get(mdm?.PV_KUNNR).HeadOfficeCode__c : mdm.PV_HKUNNR;
                    mdmRequest.PV_HKUNNR_lu__c                 =      codeToAccIdMap.get(mdmRequest.PV_HKUNNR__c);
                    mdmRequest.PV_SUBSIDIARYYN__c              =      (mdm.PV_SUBSIDIARYYN == '' || mdm.PV_SUBSIDIARYYN == null) ? accountMap.get(mdm?.PV_KUNNR).IsAffiliatedcompanyYN__c : Boolean.valueOf(mdm.PV_SUBSIDIARYYN);
                    mdmRequest.PV_VBUND__c                     =      String.isBlank(mdm.PV_VBUND) ? accountMap.get(mdm?.PV_KUNNR).AffiliatedCompany__c : mdm.PV_VBUND.toUpperCase();
                    mdmRequest.PV_VBUND_lu__c                  =      codeToIdMap.get(mdmRequest.PV_VBUND__c);
                    mdmRequest.PV_LAND1__c                     =      String.isBlank(mdm.PV_LAND1) ? accountMap.get(mdm?.PV_KUNNR).CountryKeyCode__c : mdm.PV_LAND1.toUpperCase();
                    mdmRequest.PV_LAND1_lu__c                  =      codeToIdMap.get(mdmRequest.PV_LAND1__c);
                    mdmRequest.PV_KNVKTYPE__c                  =      String.isBlank(mdm.PV_KNVKTYPE) ? accountMap.get(mdm?.PV_KUNNR).PV_KNVKTYPE__c : mdm.PV_KNVKTYPE;
                    mdmRequest.PV_CLOSEDT__c                   =      (mdm.PV_CLOSEDT == '' || mdm.PV_CLOSEDT == null) ? accountMap.get(mdm?.PV_KUNNR).ShutDownDate__c : Date.valueOf(mdm.PV_CLOSEDT);
                    mdmRequest.PV_REGIO__c                     =      String.isBlank(mdm.PV_REGIO) ? accountMap.get(mdm?.PV_KUNNR).LocationState__c : mdm.PV_REGIO.toUpperCase();
                    mdmRequest.PV_REGIO_lu__c                  =      codeToIdMap.get(mdmRequest.PV_REGIO__c);
                    mdmRequest.PV_ADRES_ROADADDR1__c           =      String.isBlank(mdm.PV_ADRES_ROADADDR1) ? accountMap.get(mdm?.PV_KUNNR).Address__c : mdm.PV_ADRES_ROADADDR1;
                    mdmRequest.PV_ADRES_ROADADDR2__c           =      String.isBlank(mdm.PV_ADRES_ROADADDR2) ? accountMap.get(mdm?.PV_KUNNR).AddressDetails__c : mdm.PV_ADRES_ROADADDR2;
                    mdmRequest.PV_ADRES_ADDR1__c               =      String.isBlank(mdm.PV_ADRES_ADDR1) ? accountMap.get(mdm?.PV_KUNNR).Address2__c : mdm.PV_ADRES_ADDR1;
                    mdmRequest.PV_ADRES_ADDR2__c               =      String.isBlank(mdm.PV_ADRES_ADDR2) ? accountMap.get(mdm?.PV_KUNNR).AddressDetails2__c : mdm.PV_ADRES_ADDR2;
                    mdmRequest.PV_DELICUST__c                  =      String.isBlank(mdm.PV_DELICUST) ? accountMap.get(mdm?.PV_KUNNR).DeliveryCustomerCode__c : mdm.PV_DELICUST;
                    mdmRequest.PV_DELICUST_lu__c               =      codeToAccIdMap.get(mdmRequest.PV_DELICUST__c);
                    mdmRequest.PV_SALESCUST__c                 =      String.isBlank(mdm.PV_SALESCUST) ? accountMap.get(mdm?.PV_KUNNR).SalesCustomerCode__c : mdm.PV_SALESCUST;
                    mdmRequest.PV_SALESCUST_lu__c              =      codeToAccIdMap.get(mdmRequest.PV_SALESCUST__c);
                    mdmRequest.PV_BIZPLCODE__c                 =      String.isBlank(mdm.PV_BIZPLCODE) ? accountMap.get(mdm?.PV_KUNNR).BizPLCode__c : mdm.PV_BIZPLCODE;
                    mdmRequest.PV_BIZPLCODE_lu__c              =      codeToAccIdMap.get(mdmRequest.PV_BIZPLCODE__c);
                    mdmRequest.PV_BUSAB__c                     =      String.isBlank(mdm.PV_BUSAB) ? accountMap.get(mdm?.PV_KUNNR).SalesForm__c : mdm.PV_BUSAB;
                    mdmRequest.PV_CESSION_KZ__c                =      String.isBlank(mdm.PV_CESSION_KZ) ? accountMap.get(mdm?.PV_KUNNR).CustomerStatus__c : mdm.PV_CESSION_KZ;
                    mdmRequest.PV_ZUAWA__c                     =      String.isBlank(mdm.PV_ZUAWA) ? accountMap.get(mdm?.PV_KUNNR).SortKey__c : mdm.PV_ZUAWA.toUpperCase();
                    mdmRequest.PV_ZUAWA_lu__c                  =      sortKeyIdMap.get(mdmRequest.PV_ZUAWA__c);
                    mdmRequest.PV_AKONT__c                     =      String.isBlank(mdm.PV_AKONT) ? accountMap.get(mdm?.PV_KUNNR).MediateAccount__c : mdm.PV_AKONT.toUpperCase();
                    mdmRequest.PV_AKONT_lu__c                  =      codeToIdMap.get(mdmRequest.PV_AKONT__c);
                    mdmRequest.PV_FDGRV__c                     =      String.isBlank(mdm.PV_FDGRV) ? accountMap.get(mdm?.PV_KUNNR).CashManagementGroup__c : mdm.PV_FDGRV;
                    mdmRequest.PV_VRSDG__c                     =      String.isBlank(mdm.PV_VRSDG) ? accountMap.get(mdm?.PV_KUNNR).IsDeposit__c : mdm.PV_VRSDG;
                    mdmRequest.PV_TAXKDD__c                    =      String.isBlank(mdm.PV_TAXKDD) ? accountMap.get(mdm?.PV_KUNNR).TaxClassification__c : mdm.PV_TAXKDD;
                    mdmRequest.PV_KATR5__c                     =      String.isBlank(mdm.PV_KATR5) ? accountMap.get(mdm?.PV_KUNNR).TaxPaymentMethod__c : mdm.PV_KATR5;
                    mdmRequest.PV_CUHR1__c                     =      String.isBlank(mdm.PV_CUHR1) ? accountMap.get(mdm?.PV_KUNNR).CustomerRoute__c : mdm.PV_CUHR1.toUpperCase();
                    mdmRequest.PV_CUHR1_lu__c                  =      codeToIdMap.get(mdmRequest.PV_CUHR1__c);
                    mdmRequest.PVVF_CUHR1__c                   =      (mdm.PVVF_CUHR1 == null || mdm.PVVF_CUHR1 == '') ? accountMap.get(mdm?.PV_KUNNR).PV_CUHR1__c : Date.valueOf(mdm.PVVF_CUHR1);
                    mdmRequest.PVRA_CUHR1__c                   =      (mdm.PVRA_CUHR1 == null || mdm.PVRA_CUHR1 == '') ? accountMap.get(mdm?.PV_KUNNR).CustomerRouteFromDate__c : Date.valueOf(mdm.PVRA_CUHR1);
                    mdmRequest.PV_KONDA__c                     =      String.isBlank(mdm.PV_KONDA) ? accountMap.get(mdm?.PV_KUNNR).PriceGroup__c : mdm.PV_KONDA.toUpperCase();
                    mdmRequest.PV_KONDA_lu__c                  =      codeToIdMap.get(mdmRequest.PV_KONDA__c);
                    mdmRequest.PVVF_KONDA__c                   =      (mdm.PVVF_KONDA == null || mdm.PVVF_KONDA == '') ? accountMap.get(mdm?.PV_KUNNR).PVVF_KONDA__c : Date.valueOf(mdm.PVVF_KONDA);
                    mdmRequest.PVRA_KONDA__c                   =      (mdm.PVRA_KONDA == null || mdm.PVRA_KONDA == '') ? accountMap.get(mdm?.PV_KUNNR).PriceGroupFromDate__c : Date.valueOf(mdm.PVRA_KONDA);
                    mdmRequest.PV_KVGR1__c                     =      String.isBlank(mdm.PV_KVGR1) ? accountMap.get(mdm?.PV_KUNNR).UnitPriceGroup__c : mdm.PV_KVGR1.toUpperCase();
                    mdmRequest.PV_KVGR1_lu__c                  =      unitPriceIdMap.get(mdmRequest.PV_KVGR1__c);
                    mdmRequest.PVVF_KVGR1__c                   =      (mdm.PVVF_KVGR1 == null || mdm.PVVF_KVGR1 == '') ? accountMap.get(mdm?.PV_KUNNR).PVVF_KVGR1__c : Date.valueOf(mdm.PVVF_KVGR1);
                    mdmRequest.PVRA_KVGR1__c                   =      (mdm.PVRA_KVGR1 == null || mdm.PVRA_KVGR1 == '') ? accountMap.get(mdm?.PV_KUNNR).UnitPriceGroupFromDate__c : Date.valueOf(mdm.PVRA_KVGR1);
                    mdmRequest.PV_WAERS__c                     =      String.isBlank(mdm.PV_WAERS) ? accountMap.get(mdm?.PV_KUNNR).CurrencyIsoCode : mdm.PV_WAERS.toUpperCase();
                    mdmRequest.PV_WAERS_lu__c                  =      codeToIdMap.get(mdmRequest.PV_WAERS__c);
                    mdmRequest.PV_KDGRP__c                     =      String.isBlank(mdm.PV_KDGRP) ? accountMap.get(mdm?.PV_KUNNR).CreditManagement__c : mdm.PV_KDGRP;
                    mdmRequest.PV_KVGR3__c                     =      String.isBlank(mdm.PV_KVGR3) ? accountMap.get(mdm?.PV_KUNNR).StatementOfDeliveryType__c : mdm.PV_KVGR3.toUpperCase();
                    mdmRequest.PV_KVGR3_lu__c                  =      statementIdMap.get(mdmRequest.PV_KVGR3__c);
                    mdmRequest.PV_KVGR2__c                     =      String.isBlank(mdm.PV_KVGR2) ? accountMap.get(mdm?.PV_KUNNR).SubsidyType__c : mdm.PV_KVGR2;
                    mdmRequest.PV_KVGR3_BOT__c                 =      String.isBlank(mdm.PV_KVGR3_BOT) ? accountMap.get(mdm?.PV_KUNNR).StatementOfDeliveryType2__c : mdm.PV_KVGR3_BOT.toUpperCase();
                    mdmRequest.PV_KVGR3_BOT_lu__c              =      statementBotIdMap.get(mdmRequest.PV_KVGR3_BOT__c);
                    mdmRequest.PV_ODCLOSEGB__c                 =      String.isBlank(mdm.PV_ODCLOSEGB) ? accountMap.get(mdm?.PV_KUNNR).CustomerOrderDeadlineType__c : mdm.PV_ODCLOSEGB;
                    mdmRequest.PV_VACCPRTEXCYN__c              =      (mdm.PV_VACCPRTEXCYN == '' || mdm.PV_VACCPRTEXCYN == null) ? accountMap.get(mdm?.PV_KUNNR).IsPrintVirtualAccount__c : Boolean.valueOf(mdm.PV_VACCPRTEXCYN);
                    mdmRequest.PV_ZTERM_VV__c                  =      String.isBlank(mdm.PV_ZTERM_VV) ? accountMap.get(mdm?.PV_KUNNR).TermsOfPayment__c : mdm.PV_ZTERM_VV.toUpperCase();
                    mdmRequest.PV_ZTERM_VV_lu__c               =      codeToIdMap.get(mdmRequest.PV_ZTERM_VV__c);
                    mdmRequest.PV_DSTRHISTREGYN__c             =      String.isBlank(mdm.PV_DSTRHISTREGYN) ? accountMap.get(mdm?.PV_KUNNR).DisHisRegType__c : mdm.PV_DSTRHISTREGYN;
                    mdmRequest.PV_KULTG__c                     =      String.isBlank(mdm.PV_KULTG) ? accountMap.get(mdm?.PV_KUNNR).ContractRocationDate__c : mdm.PV_KULTG;
                    mdmRequest.PV_OLD_BIZPLACE_NEW__c          =      String.isBlank(mdm.PV_OLD_BIZPLACE_NEW) ? accountMap.get(mdm?.PV_KUNNR).CustomerPath__c : mdm.PV_OLD_BIZPLACE_NEW.toUpperCase();
                    mdmRequest.PV_OLD_BIZPLACE_NEW_lu__c       =      codeToIdMap.get(mdmRequest.PV_OLD_BIZPLACE_NEW__c);
                    mdmRequest.PVVF_OLD_BIZPLACE_NEW__c        =      (mdm.PVVF_OLD_BIZPLACE_NEW == null || mdm.PVVF_OLD_BIZPLACE_NEW == '') ? accountMap.get(mdm?.PV_KUNNR).PVVF_OLD_BIZPLACE_NEW__c : Date.valueOf(mdm.PVVF_OLD_BIZPLACE_NEW);
                    mdmRequest.PVRA_OLD_BIZPLACE_NEW__c        =      (mdm.PVRA_OLD_BIZPLACE_NEW == null || mdm.PVRA_OLD_BIZPLACE_NEW == '') ? accountMap.get(mdm?.PV_KUNNR).CustomerPathFromDate__c : Date.valueOf(mdm.PVRA_OLD_BIZPLACE_NEW);
                    mdmRequest.PV_SHAPE__c                     =      String.isBlank(mdm.PV_SHAPE) ? accountMap.get(mdm?.PV_KUNNR).Shape__c : mdm.PV_SHAPE;
                    mdmRequest.PV_EXAMYN__c                    =      (mdm.PV_EXAMYN == '' || mdm.PV_EXAMYN == null) ? accountMap.get(mdm?.PV_KUNNR).IsFaceToFaceInspectionStatus__c : Boolean.valueOf(mdm.PV_EXAMYN);
                    mdmRequest.PV_SHIPREQTIME__c               =      String.isBlank(mdm.PV_SHIPREQTIME) ? accountMap.get(mdm?.PV_KUNNR).OTD__c : mdm.PV_SHIPREQTIME;
                    mdmRequest.PV_PRODLOADCOND__c              =      String.isBlank(mdm.PV_PRODLOADCOND) ? accountMap.get(mdm?.PV_KUNNR).ProductLoadingCondition__c : mdm.PV_PRODLOADCOND;
                    mdmRequest.PV_RETURNLOC__c                 =      String.isBlank(mdm.PV_RETURNLOC) ? accountMap.get(mdm?.PV_KUNNR).ReturnLocation__c : mdm.PV_RETURNLOC;
                    mdmRequest.PV_ENTERCOND1__c                =      String.isBlank(mdm.PV_ENTERCOND1) ? accountMap.get(mdm?.PV_KUNNR).VehicleEntryCondtions__c : mdm.PV_ENTERCOND1;
                    mdmRequest.PV_UNLOADCOND1__c               =      String.isBlank(mdm.PV_UNLOADCOND1) ? accountMap.get(mdm?.PV_KUNNR).UnloadConditions1__c : mdm.PV_UNLOADCOND1;
                    mdmRequest.PV_UNLOADCOND2__c               =      String.isBlank(mdm.PV_UNLOADCOND2) ? accountMap.get(mdm?.PV_KUNNR).UnloadConditions2__c : mdm.PV_UNLOADCOND2;
                    mdmRequest.PV_DELIGROUP__c                 =      String.isBlank(mdm.PV_DELIGROUP) ? accountMap.get(mdm?.PV_KUNNR).DeliveryGroup__c : mdm.PV_DELIGROUP.toUpperCase();
                    mdmRequest.PV_DELIGROUP_lu__c              =      deliveryIdMap.get(mdmRequest.PV_DELIGROUP__c);
                    mdmRequest.PV_KATR10__c                    =      String.isBlank(mdm.PV_KATR10) ? accountMap.get(mdm?.PV_KUNNR).ShipmentArea__c : mdm.PV_KATR10.toUpperCase();
                    mdmRequest.PV_KATR10_lu__c                 =      shipmentIdMap.get(mdmRequest.PV_KATR10__c);
                    mdmRequest.PV_KEYYN__c                     =      (mdm.PV_KEYYN == '' || mdm.PV_KEYYN == null) ? accountMap.get(mdm?.PV_KUNNR).IsBusinessPlaceKey__c : Boolean.valueOf(mdm.PV_KEYYN);
                    mdmRequest.PV_KEYINFO__c                   =      String.isBlank(mdm.PV_KEYINFO) ? accountMap.get(mdm?.PV_KUNNR).BusinessPlaceKeyInfo__c : mdm.PV_KEYINFO;
                    mdmRequest.PV_KXOTD__c                     =      (mdm.PV_KXOTD == '' || mdm.PV_KXOTD == null) ? (accountMap.get(mdm?.PV_KUNNR).KXOTD__c == 'Y' ? true : false) : Boolean.valueOf(mdm.PV_KXOTD);
                    mdmRequest.PV_KXOTDTIME__c                 =      String.isBlank(mdm.PV_KXOTDTIME) ? accountMap.get(mdm?.PV_KUNNR).KXOTDRequestDate__c : mdm.PV_KXOTDTIME;
                    mdmRequest.PV_FDINFO__c                    =      (mdm.PV_FDINFO == '' || mdm.PV_FDINFO == null) ? (accountMap.get(mdm?.PV_KUNNR).InitialDeliveryShare__c == 'Y' ? true : false) : Boolean.valueOf(mdm.PV_FDINFO);
                    mdmRequest.PV_FDREQD__c                    =      (mdm.PV_FDREQD == '' || mdm.PV_FDREQD == null) ? accountMap.get(mdm?.PV_KUNNR).InitialDeliveryRequestDate__c : Date.valueOf(mdm.PV_FDREQD);
                    mdmRequest.PV_FDREQT__c                    =      String.isBlank(mdm.PV_FDREQT) ? accountMap.get(mdm?.PV_KUNNR).InitialDeliveryRequestTime__c : mdm.PV_FDREQT;
                    mdmRequest.PV_ISFDFTF__c                   =      (mdm.PV_ISFDFTF == '' || mdm.PV_ISFDFTF == null) ? accountMap.get(mdm?.PV_KUNNR).IsInitialDeliveryFTFInspection__c : Boolean.valueOf(mdm.PV_ISFDFTF);
                    mdmRequest.PV_FDCTINFO__c                  =      String.isBlank(mdm.PV_FDCTINFO) ? accountMap.get(mdm?.PV_KUNNR).InitialDeliveryContact__c : mdm.PV_FDCTINFO;
                    mdmRequest.PV_FDNOTICE__c                  =      String.isBlank(mdm.PV_FDNOTICE) ? accountMap.get(mdm?.PV_KUNNR).InitialDeliveryDescription__c : mdm.PV_FDNOTICE;
                    mdmRequest.PV_SHIPTYPE__c                  =      String.isBlank(mdm.PV_SHIPTYPE) ? accountMap.get(mdm?.PV_KUNNR).PV_SHIPTYPE__c : mdm.PV_SHIPTYPE;
                    mdmRequest.PV_TEMPTARGET__c                =      String.isBlank(mdm.PV_TEMPTARGET) ? accountMap.get(mdm?.PV_KUNNR).PV_TEMPTARGET__c : mdm.PV_TEMPTARGET;

                    mdmRequest.RequestType__c                  =      'Edit';

                    mdmRequest.MDMRegRequestBulkCustomer__c    =      mdmRequestbulk.id;

                    customerList.add(mdmRequest);       
                    system.debug('@@ mdmRequest.PV_OLDCD__c ' + mdmRequest.PV_OLDCD__c);
                }

                insert customerList;

                saveResult.bulkId = mdmRequestbulk.id;

            }
            
        } catch (Exception e) {
            saveResult = new SaveResult('F', e.getMessage() + e.getLineNumber());
        }

        return saveResult;

    }

    // 조건문 줄이기
    public static String getValue2(String mdmName, String accountName) {
        System.debug(mdmName);
        if (mdmName != null) {
            // 조건 1: mdmName이 null이 아니면 mdmName 반환
            return mdmName;
        } else if (mdmName == null) {
            return accountName;
        }
        // 조건을 그냥 뜯어고쳐야 함 모두 null으로 들어옴 231121
        // 조건 2: mdmName이 blank이고 accountName이 blank가 아니면 accountName 반환
        return accountName;
    }
    public static String getValue(String mdmName, String accountName) {
        system.debug('mdmName ' + mdmName);
        system.debug('accountName ' + accountName);
    
        // mdmName이 null이 아니고 빈 문자열이 아니면 mdmName 반환
        if (!String.isBlank(mdmName)) {
            return mdmName;
        }

        // 1. mdmName != null || mdmName != ''  => mdmName
        // 2. mdmName == null || mdmName  = '' + 항목 설정X => accountName
        // 3. mdmName == null || mdmName  = '' + 항목 설정O => accountName X => mdmName이여야한다..


        // mdmName이 빈 문자열이면서 accountName이 null이 아니고 다르면 accountName 반환
        if (String.isBlank(mdmName) && accountName != null && !accountName.equals(mdmName)) {
            return accountName;
        }
    

    
        // 위의 조건에 해당하지 않으면 빈 문자열 반환
        return '';
    }

    public static String getValue(String mdmName, String accountName, Boolean isSelectdHeader) {

        // mdmName 현재 수정하는 필드의 값이 비어있지 않으면
        if(String.isNotBlank(mdmName)){
            // 그대로 mdmName 리턴
            return mdmName;
        
        // mdmName 현재 수정하는 필드의 값이 비어 있으면
        }else{
            // isSelectdHeader = 얘가 선택된 헤더이냐 아니냐

            // true 선택된 얘
            if(isSelectdHeader) {
                // mdm
                return mdmName;
            // false 선택되지 않은 얘
            } else {
                return accountName;
            }
        }
    }

    // // 이름이 null값이 되지 않도록 null일 경우 기존 값을 찾아서 기입해 줄 Map 생성
    // public static Map<String, String> getNameOfNull(List<MDMRequest> mdmCustomer) {

    //     // Custom Id 넣을 List 생성
    //     List<String> ids = new List<String>();
        
    //     for(MDMRequest mdm : mdmCustomer) {
    //         if(mdm.PV_NAME1 == null) {
    //             ids.add(mdm.PV_KUNNR);
    //         }
    //     }
        
    //     System.debug('ids => ' + ids);
        
    //     // Account로부터 해당 Custom Id의 이름 받아서 넣기
    //     List<Account> accList = [SELECT Name, CustomerID__c FROM Account WHERE CustomerID__c IN :ids];
        
    //     // Map[{"Id": "이름"}, ...] 형식
    //     Map<String, String> nameMaps = new Map<String, String>();

    //     // Map에 Key, Value 저장
    //     for(Account acc : accList) {
    //         nameMaps.put(acc.CustomerID__c, acc.Name);
    //     }

    //     System.debug('accList => ' + accList);

    //     return nameMaps;
    // }

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