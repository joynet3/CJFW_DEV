/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-21-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkUpdateMAController {
    
    /**
    * Save 버튼을 클릭 했을 때 호출
    * 
    * @params mdmContacts : 화면 mdmContact 데이터
    * 
    */
    @AuraEnabled
    public static SaveResult doSave(List<MDMRegRequestContact__c> mdmContacts, String recordId) {

        system.debug('# CJFW_MDMBulkCreateMAController >>> doSave ');

        SaveResult saveResult = new SaveResult();
        system.debug('>>>doSave # mdmContacts ' + JSON.serialize(mdmContacts));
        system.debug('>>>doSave # recordId ' + recordId);

        List<MDMRegRequestContact__c> contactList = new List<MDMRegRequestContact__c>();

        // 각종 ID 필요한 MDMReferenceCode__c 조회해서 Id값 가지고 오기
        Set<String> codeSet = new Set<String>();
        for(MDMRegRequestContact__c con : mdmContacts){
            String upperCode = con.PV_KNVKGB__c;
            codeSet.add(upperCode.toUpperCase());
            System.debug('# upperCode => ' + upperCode);
            codeSet.remove(null);
        }

        System.debug('# codeSet => ' + codeSet);
        
        List<MDMReferenceCode__c> referenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c = :codeSet AND GROUPID__c = 'KNVKGB'];

        System.debug('# referenceCodeList => ' + referenceCodeList);

        // Key : code , value : Id
        Map<String, String> codeToIdMap = new Map<String, String>();
        for(MDMReferenceCode__c mdmCode :referenceCodeList){
            codeToIdMap.put(mdmCode.Code__c, mdmCode.Id);
        }

        System.debug('# codeToIdMap => ' + codeToIdMap);

        // 받아 온 CustomerId로 MDM 혹은 Account로부터 Id 가지고 오기
        Set<String> idSet = new Set<String>();
        for(MDMRegRequestContact__c con : mdmContacts){
            idSet.add(con.MDMRegRequestCustomer__c);
            idSet.remove(null);
            idSet.remove('');
        }

        // Key : code , value : Id
        Map<String, String> kunnrToIdMap = new Map<String, String>();

        // Key : code , value : Id
        Map<String, String> newMDMToIdMap = new Map<String, String>();

        if(recordId != null) {
            
            List<MDMRegRequestCustomer__c> customerList = [SELECT Id, PV_KUNNR__c FROM MDMRegRequestCustomer__c WHERE PV_KUNNR__c = :idSet AND MDMRegRequestBulkCustomer__c = :recordId];

            System.debug('# <MDM> customerList => ' + customerList);
    
            for(MDMRegRequestCustomer__c cus : customerList){
                kunnrToIdMap.put(cus.PV_KUNNR__c, cus.Id);
            }
    
            System.debug('# kunnrToIdMap => ' + kunnrToIdMap);

            saveResult.bulkId = recordId;

        } else {

            List<Account> customerList = [SELECT Id, CustomerID__c, Name, PICCode__c, CustomerIDASIS__c, NameKor__c, NameAlias__c, AccountGroup__c, toLabel(AccountGroup__c) AccountGroupLabel, CustomerType__c, toLabel(CustomerType__c) CustomerTypeLabel, CompanyRegisterNumber__c, CorporateCode__c, SubCompanyRegisterNumber__c,  LegalStatus__c, toLabel(LegalStatus__c) LegalStatusLabel, RepresentativeName__c, PV_BLCKYN__c, RepresentativeBirthDate__c, BusinessConditions__c, BusinessCategory__c,  Phone, Fax, PaymentAccountCode__c, PaymentAccountName__c, ShippingAccountCode__c, ShippingAccountName__c, PV_VKGRP__c, toLabel(PV_VKGRP__c) PV_VKGRP__LABEL,  PVVF_VKGRP__c, SalesGroupFromDate__c, OwnerId, PVVF_PERNR__c, ResponsibilityMAFromDate__c, ResponsibilityAMA__c, ResponsibilityAMACode__c, TaxInvoiceType__c, toLabel(TaxInvoiceType__c) TaxInvoiceLabel,  IsHeadShopUseYN__c, IsAffiliatedcompanyYN__c, AffiliatedCompany__c, toLabel(AffiliatedCompany__c) AffiliatedCompanyLabel, CountryKeyCode__c, toLabel(CountryKeyCode__c) CountryKeyCodeLabel,  PV_KNVKTYPE__c, toLabel(PV_KNVKTYPE__c) PV_KNVKTYPE__LABEL, ShutDownDate__c, LocationState__c, toLabel(LocationState__c) LocationStateLabel, Address__c, AddressDetails__c,  Address2__c, AddressDetails2__c, SalesForm__c, toLabel(SalesForm__c) SalesFormLabel, CustomerStatus__c, toLabel(CustomerStatus__c) CustomerStatusLabel, SortKey__c, toLabel(SortKey__c) SortKeyLabel,  MediateAccount__c, toLabel(MediateAccount__c) MediateAccountLabel, CashManagementGroup__c, toLabel(CashManagementGroup__c) CashManagementGroupLabel, IsDeposit__c, toLabel(IsDeposit__c) IsDepositLabel,  TaxClassification__c, toLabel(TaxClassification__c) TaxClassificationLabel, TaxPaymentMethod__c, toLabel(TaxPaymentMethod__c) TaxPaymentMethodLabel, CustomerRoute__c, toLabel(CustomerRoute__c) CustomerRouteLabel,  PV_CUHR1__c, CustomerRouteFromDate__c, PriceGroup__c, toLabel(PriceGroup__c) PriceGroupLabel, UnitPriceGroup__c, toLabel(UnitPriceGroup__c) UnitPriceGroupLabel, CurrencyIsoCode,  toLabel(CurrencyIsoCode) CurrencyIsoLabel, CreditManagement__c, toLabel(CreditManagement__c) CreditManagementLabel, SubsidyType__c, toLabel(SubsidyType__c) SubsidyTypeLabel,  IsPrintVirtualAccount__c, TermsOfPayment__c, toLabel(TermsOfPayment__c) TermsOfPaymentLabel, DisHisRegType__c, toLabel(DisHisRegType__c) DisHisRegTypeLabel, ContractRocationDate__c, TaxationType__c,  CustomerPath__c, toLabel(CustomerPath__c) CustomerPathLabel, Shape__c, DeliveryGroup__c, toLabel(DeliveryGroup__c) DeliveryGroupLabel, CustomerOrderDeadlineType__c,  PVVF_KONDA__c, PriceGroupFromDate__c, PVVF_OLD_BIZPLACE_NEW__c, CustomerPathFromDate__c, FWReleaseCenterFromDate__c, PVVF_LOGISCENTER__c, FWReleaseCenter__c, IsFaceToFaceInspectionStatus__c,  DeliveryCustomerCode__c, SalesCustomerCode__c, BizPLCode__c, HeadOfficeCode__c, PVVF_KVGR1__c, UnitPriceGroupFromDate__c, StatementOfDeliveryType__c, StatementOfDeliveryType2__c,   OTD__c, ProductLoadingCondition__c, ReturnLocation__c, VehicleEntryCondtions__c, UnloadConditions1__c, UnloadConditions2__c, ShipmentArea__c, IsBusinessPlaceKey__c, BusinessPlaceKeyInfo__c, KXOTD__c, KXOTDRequestDate__c, InitialDeliveryShare__c, InitialDeliveryRequestDate__c, InitialDeliveryRequestTime__c, IsInitialDeliveryFTFInspection__c, InitialDeliveryContact__c, InitialDeliveryDescription__c, PV_SHIPTYPE__c, PV_TEMPTARGET__c FROM Account WHERE CustomerID__c = :idSet];

            System.debug('# <Acc> customerList => ' + customerList);

            // 고객의 CustomerId 필드(CustomerId__c)로 조회해서 Id값 알아내기
            Set<String> accSet = new Set<String>();
            for(Account acc : customerList){
                accSet.add(acc.ShippingAccountCode__c);
                accSet.add(acc.PaymentAccountCode__c);
                accSet.add(acc.SalesCustomerCode__c);
                accSet.add(acc.DeliveryCustomerCode__c);
                accSet.add(acc.BizPLCode__c);
                accSet.add(acc.HeadOfficeCode__c);
            }

            accSet.remove(null);
            accSet.remove('');

            List<Account> accList = [SELECT Id, Name, CustomerId__c FROM Account WHERE CustomerId__c = :accSet];

            System.debug('# accList => ' + accList);

            // Key :code , value :Id
            Map<String, String> codeToAccIdMap = new Map<String, String>();
            for(Account acc : accList){ 
                codeToAccIdMap.put(acc.CustomerId__c, acc.Id);
            }

            System.debug('# codeToAccIdMap => ' + codeToAccIdMap);

            // 각종 ID 필요한 MDMReferenceCode__c 조회해서 Id값 가지고 오기
            Set<String> codeSet2 = new Set<String>();

            for(Account acc : customerList) {
                codeSet2.add(acc.PV_VKGRP__c);
                codeSet2.add(acc.FWReleaseCenter__c);
                codeSet2.add(acc.TaxInvoiceType__c);
                codeSet2.add(acc.AffiliatedCompany__c);
                codeSet2.add(acc.CountryKeyCode__c);
                codeSet2.add(acc.LocationState__c);
                codeSet2.add(acc.SortKey__c);
                codeSet2.add(acc.MediateAccount__c);
                codeSet2.add(acc.CustomerRoute__c);
                codeSet2.add(acc.PriceGroup__c);
                codeSet2.add(acc.UnitPriceGroup__c);
                codeSet2.add(acc.CurrencyIsoCode);
                codeSet2.add(acc.StatementOfDeliveryType__c);
                codeSet2.add(acc.StatementOfDeliveryType2__c);
                codeSet2.add(acc.TermsOfPayment__c);
                codeSet2.add(acc.CustomerPath__c);
                codeSet2.add(acc.DeliveryGroup__c);
                codeSet2.add(acc.ShipmentArea__c);
            }

            // null이나 공백 제거함
            codeSet2.remove(null);
            codeSet2.remove('');
            
            // 겹치는 Code 제외한 MDM 참조 코드 List
            List<MDMReferenceCode__c> referenceCodeList2 = [SELECT Id, Name, Code__c, GroupId__c FROM MDMReferenceCode__c WHERE code__c = :codeSet2];
            // AND GroupId__c NOT IN ('TVV3', 'TVV3_BOT', 'DELIGROUP', 'TVV1', 'TVKO1', 'TZUN', 'TVV2'

            System.debug('# referenceCodeList => ' + referenceCodeList);

            // Key : code , value : Id
            Map<String, String> codeToIdMap2 = new Map<String, String>();
            Map<String, String> deliveryIdMap = new Map<String, String>(); // 배송그룹
            Map<String, String> statementIdMap = new Map<String, String>(); // 납품서유형
            Map<String, String> statementBotIdMap = new Map<String, String>(); // 납품서하단유형
            Map<String, String> unitPriceIdMap = new Map<String, String>(); // 단가그룹
            Map<String, String> shipmentIdMap = new Map<String, String>(); // 출하권역
            Map<String, String> sortKeyIdMap = new Map<String, String>(); // 정렬키
            // Map<String, String> subsidIdMap = new Map<String, String>(); // 장려금유형

            for(MDMReferenceCode__c mdmCode :referenceCodeList2){
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
                    codeToIdMap2.put(mdmCode.Code__c, mdmCode.id);
                }
            }

            System.debug('# codeToIdMap2 => ' + codeToIdMap2);

            // User의 사번필드(ResponsibilityAMA__c)로 User 조회해서 Id값 알아내기
            Set<String> accUserSet = new Set<String>();

            for(Account acc : customerList) {
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

            // MDM 요청 insert할 객체들 담기
            List<MDMRegRequestCustomer__c> mdmList = new List<MDMRegRequestCustomer__c>();

            MDMRegRequestBulkCustomer__c mdmRequestbulk = new MDMRegRequestBulkCustomer__c();

            String bulkName = customerList[0].Name;
            mdmRequestbulk.RequestType__c = 'Edit';
            
            mdmRequestbulk.Name = bulkName + ' 외 ' + (customerList.size() -1) + '건';

            insert mdmRequestbulk;
            
            for(Account acc : customerList) {

                MDMRegRequestCustomer__c customer = new MDMRegRequestCustomer__c();

                String recordIdEx = null;
                List<String> managementList = new List<String>{'C03', 'C04', 'C11'}; // 관리처 코드

                if(acc.CustomerType__c == 'C01') {
                    recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMParent').getRecordTypeId();
                } else if(acc.CustomerType__c == 'C02') {
                    recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMChild').getRecordTypeId();
                } else if(managementList.contains(acc.CustomerType__c)) {
                    recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMManagement').getRecordTypeId();
                }

                customer.MDMRegRequestBulkCustomer__c    =       mdmRequestbulk.id;
                customer.RecordTypeId                    =       recordIdEx;
                customer.PV_KUNNR__c                     =       acc.CustomerId__c;
                customer.PV_OLDCD__c                     =       acc.CustomerIDASIS__c;
                customer.PV_NAME1__c                     =       acc.Name;
                customer.PV_NAME_G__c                    =       acc.NameKor__c;
                customer.PV_NAME2__c                     =       acc.NameAlias__c;
                customer.PV_KTOKD__c                     =       acc.AccountGroup__c;
                customer.PV_CUSTTYPE__c                  =       acc.CustomerType__c;
                customer.PV_STCD2__c                     =       acc.CompanyRegisterNumber__c;
                customer.PV_STCD3__c                     =       acc.CorporateCode__c;
                customer.PV_STCD4__c                     =       acc.SubCompanyRegisterNumber__c;
                customer.PV_GFORM__c                     =       acc.LegalStatus__c;
                customer.PV_J_1KFREPRE__c                =       acc.RepresentativeName__c;
                customer.PV_BLCKYN__c                    =       acc.PV_BLCKYN__c;
                customer.PV_STCD1__c                     =       acc.RepresentativeBirthDate__c;
                customer.PV_J_1KFTBUS__c                 =       acc.BusinessConditions__c;
                customer.PV_J_1KFTIND__c                 =       acc.BusinessCategory__c;
                customer.PV_TELF1__c                     =       acc.Phone;
                customer.PV_TELFX__c                     =       acc.Fax;
                customer.PV_PAYCUST__c                   =       acc.PaymentAccountCode__c;
                customer.PV_PAYCUST_lu__c                =       codeToAccIdMap.get(acc.PaymentAccountCode__c);
                customer.PV_CHARGECUST__c                =       acc.ShippingAccountCode__c;
                customer.PV_CHARGECUST_lu__c             =       codeToAccIdMap.get(acc.ShippingAccountCode__c);
                customer.PV_VKGRP__c                     =       acc.PV_VKGRP__c;
                customer.PV_VKGRP_lu__c                  =       codeToIdMap2.get(acc.PV_VKGRP__c);
                customer.PVVF_VKGRP__c                   =       acc.PVVF_VKGRP__c;
                customer.PVRA_VKGRP__c                   =       acc.SalesGroupFromDate__c;
                customer.PV_PERNR__c                     =       acc.PICCode__c;
                customer.PV_PERNR_lu__c                  =       codeToUserIdMap.get(acc.PICCode__c);
                customer.PVVF_PERNR__c                   =       acc.PVVF_PERNR__c;
                customer.PVRA_PERNR__c                   =       acc.ResponsibilityMAFromDate__c;
                customer.PV_ADMINMA__c                   =       acc.ResponsibilityAMA__c;
                customer.PV_ADMINMA_lu__c                =       codeToUserIdMap.get(acc.ResponsibilityAMA__c);
                customer.PV_LOGISCENTER__c               =       acc.FWReleaseCenter__c;
                customer.PV_LOGISCENTER_lu__c            =       codeToIdMap2.get(acc.FWReleaseCenter__c);
                customer.PVVF_LOGISCENTER__c             =       acc.PVVF_LOGISCENTER__c;
                customer.PVRA_LOGISCENTER__c             =       acc.FWReleaseCenterFromDate__c;
                customer.PV_STCDT__c                     =       acc.TaxInvoiceType__c;
                customer.PV_STCDT_lu__c                  =       codeToIdMap2.get(acc.TaxInvoiceType__c);
                customer.PV_FITYP__c                     =       acc.TaxationType__c;
                customer.PV_HDOFFICEYN__c                =       acc.IsHeadShopUseYN__c;
                customer.PV_HKUNNR__c                    =       acc.HeadOfficeCode__c;
                customer.PV_HKUNNR_lu__c                 =       codeToAccIdMap.get(acc.HeadOfficeCode__c);
                customer.PV_VBUND__c                     =       acc.AffiliatedCompany__c;
                customer.PV_VBUND_lu__c                  =       codeToIdMap2.get(acc.AffiliatedCompany__c);
                customer.PV_LAND1__c                     =       acc.CountryKeyCode__c;
                customer.PV_LAND1_lu__c                  =       codeToIdMap2.get(acc.CountryKeyCode__c);
                customer.PV_KNVKTYPE__c                  =       acc.PV_KNVKTYPE__c;
                customer.PV_CLOSEDT__c                   =       acc.ShutDownDate__c;
                customer.PV_REGIO__c                     =       acc.LocationState__c;
                customer.PV_REGIO_lu__c                  =       codeToIdMap2.get(acc.LocationState__c);
                customer.PV_ADRES_ROADADDR1__c           =       acc.Address__c;
                customer.PV_ADRES_ROADADDR2__c           =       acc.AddressDetails__c;
                customer.PV_ADRES_ADDR1__c               =       acc.Address2__c;
                customer.PV_ADRES_ADDR2__c               =       acc.AddressDetails2__c;
                customer.PV_DELICUST__c                  =       acc.DeliveryCustomerCode__c;
                customer.PV_DELICUST_lu__c               =       codeToAccIdMap.get(acc.DeliveryCustomerCode__c);
                customer.PV_SALESCUST__c                 =       acc.SalesCustomerCode__c;
                customer.PV_SALESCUST_lu__c              =       codeToAccIdMap.get(acc.SalesCustomerCode__c);
                customer.PV_BIZPLCODE__c                 =       acc.BizPLCode__c;
                customer.PV_BIZPLCODE_lu__c              =       codeToAccIdMap.get(acc.BizPLCode__c);
                customer.PV_BUSAB__c                     =       acc.SalesForm__c;
                customer.PV_CESSION_KZ__c                =       acc.CustomerStatus__c;
                customer.PV_ZUAWA__c                     =       acc.SortKey__c;
                customer.PV_ZUAWA_lu__c                  =       sortKeyIdMap.get(acc.SortKey__c);
                customer.PV_AKONT__c                     =       acc.MediateAccount__c;
                customer.PV_AKONT_lu__c                  =       codeToIdMap2.get(acc.MediateAccount__c);
                customer.PV_FDGRV__c                     =       acc.CashManagementGroup__c;
                customer.PV_VRSDG__c                     =       acc.IsDeposit__c;
                customer.PV_TAXKDD__c                    =       acc.TaxClassification__c;
                customer.PV_KATR5__c                     =       acc.TaxPaymentMethod__c;
                customer.PV_CUHR1__c                     =       acc.CustomerRoute__c;
                customer.PV_CUHR1_lu__c                  =       codeToIdMap2.get(acc.CustomerRoute__c);
                customer.PVVF_CUHR1__c                   =       acc.PV_CUHR1__c;
                customer.PVRA_CUHR1__c                   =       acc.CustomerRouteFromDate__c;
                customer.PV_KONDA__c                     =       acc.PriceGroup__c;
                customer.PV_KONDA_lu__c                  =       codeToIdMap2.get(acc.PriceGroup__c);
                customer.PVVF_KONDA__c                   =       acc.PVVF_KONDA__c;
                customer.PVRA_KONDA__c                   =       acc.PriceGroupFromDate__c;
                customer.PV_KVGR1__c                     =       acc.UnitPriceGroup__c;
                customer.PV_KVGR1_lu__c                  =       unitPriceIdMap.get(acc.UnitPriceGroup__c);
                customer.PVVF_KVGR1__c                   =       acc.PVVF_KVGR1__c;
                customer.PVRA_KVGR1__c                   =       acc.UnitPriceGroupFromDate__c;
                customer.PV_WAERS__c                     =       acc.CurrencyIsoCode;
                customer.PV_WAERS_lu__c                  =       codeToIdMap2.get(acc.CurrencyIsoCode);
                customer.PV_KDGRP__c                     =       acc.CreditManagement__c;
                customer.PV_KVGR3__c                     =       acc.StatementOfDeliveryType__c;
                customer.PV_KVGR3_lu__c                  =       statementIdMap.get(acc.StatementOfDeliveryType__c);
                customer.PV_KVGR2__c                     =       acc.SubsidyType__c;
                customer.PV_KVGR3_BOT__c                 =       acc.StatementOfDeliveryType2__c;
                customer.PV_KVGR3_BOT_lu__c              =       statementBotIdMap.get(acc.StatementOfDeliveryType2__c);
                customer.PV_ODCLOSEGB__c                 =       acc.CustomerOrderDeadlineType__c;
                customer.PV_ZTERM_VV__c                  =       acc.TermsOfPayment__c;
                customer.PV_ZTERM_VV_lu__c               =       codeToIdMap2.get(acc.TermsOfPayment__c);
                customer.PV_DSTRHISTREGYN__c             =       acc.DisHisRegType__c;
                customer.PV_KULTG__c                     =       acc.ContractRocationDate__c;
                customer.PV_OLD_BIZPLACE_NEW__c          =       acc.CustomerPath__c;
                customer.PV_OLD_BIZPLACE_NEW_lu__c       =       codeToIdMap2.get(acc.CustomerPath__c);
                customer.PVVF_OLD_BIZPLACE_NEW__c        =       acc.PVVF_OLD_BIZPLACE_NEW__c;
                customer.PVRA_OLD_BIZPLACE_NEW__c        =       acc.CustomerPathFromDate__c;
                customer.PV_SHAPE__c                     =       acc.Shape__c;
                customer.PV_SHIPREQTIME__c               =       acc.OTD__c;
                customer.PV_PRODLOADCOND__c              =       acc.ProductLoadingCondition__c;
                customer.PV_RETURNLOC__c                 =       acc.ReturnLocation__c;
                customer.PV_ENTERCOND1__c                =       acc.VehicleEntryCondtions__c;
                customer.PV_UNLOADCOND1__c               =       acc.UnloadConditions1__c;
                customer.PV_UNLOADCOND2__c               =       acc.UnloadConditions2__c;
                customer.PV_DELIGROUP__c                 =       acc.DeliveryGroup__c;
                customer.PV_DELIGROUP_lu__c              =       deliveryIdMap.get(Acc.DeliveryGroup__c);
                customer.PV_KATR10__c                    =       acc.ShipmentArea__c;
                customer.PV_KATR10_lu__c                 =       shipmentIdMap.get(acc.ShipmentArea__c);
                customer.PV_KEYINFO__c                   =       acc.BusinessPlaceKeyInfo__c;
                customer.PV_KXOTDTIME__c                 =       acc.KXOTDRequestDate__c;
                customer.PV_FDREQD__c                    =       acc.InitialDeliveryRequestDate__c;
                customer.PV_FDREQT__c                    =       acc.InitialDeliveryRequestTime__c;
                customer.PV_FDCTINFO__c                  =       acc.InitialDeliveryContact__c;
                customer.PV_FDNOTICE__c                  =       acc.InitialDeliveryDescription__c;
                customer.PV_SHIPTYPE__c                  =       acc.PV_SHIPTYPE__c;
                customer.PV_TEMPTARGET__c                =       acc.PV_TEMPTARGET__c;
                
                Boolean isKxOtd = false;
                if(acc.KXOTD__c == 'Y') {
                    isKxOtd = true;
                } else if(acc.KXOTD__c == 'N') {
                    isKxOtd = false;
                }

                Boolean isFdInfo = false;
                if(acc.InitialDeliveryShare__c == 'Y') {
                    isFdInfo = true;
                } else if(acc.InitialDeliveryShare__c == 'N') {
                    isFdInfo = false;
                }
                
                customer.PV_SUBSIDIARYYN__c              =       acc.IsAffiliatedcompanyYN__c;
                customer.PV_VACCPRTEXCYN__c              =       acc.IsPrintVirtualAccount__c;
                customer.PV_EXAMYN__c                    =       acc.IsFaceToFaceInspectionStatus__c;
                customer.PV_KEYYN__c                     =       acc.IsBusinessPlaceKey__c;
                customer.PV_KXOTD__c                     =       isKxOtd;
                customer.PV_FDINFO__c                    =       isFdInfo;
                customer.PV_ISFDFTF__c                   =       acc.IsInitialDeliveryFTFInspection__c;
                customer.PV_BUSAB__c                     =       acc.SalesForm__c;
                customer.PV_CESSION_KZ__c                =       acc.CustomerStatus__c;
                customer.RequestType__c                  =       'Edit';

                mdmList.add(customer);
            }

            System.debug('# <Acc> mdmList => ' + mdmList);

            insert mdmList;

            // 커스텀ID : ID
            for(MDMRegRequestCustomer__c mdm : mdmList) {
                newMDMToIdMap.put(mdm.PV_KUNNR__c, mdm.Id);
            }

            System.debug('# <Acc> newMDMToIdMap => ' + newMDMToIdMap);

            saveResult.bulkId = mdmRequestbulk.id;

        }

        try {
            
            if(mdmContacts != null){

                for (MDMRegRequestContact__c con : mdmContacts) {
                    MDMRegRequestContact__c mdmContact = new MDMRegRequestContact__c();

                    mdmContact.PV_NAME1_VK__c           =      String.isBlank(con.PV_NAME1_VK__c) ? null : con.PV_NAME1_VK__c;
                    mdmContact.PV_KNVKGB__c             =      String.isBlank(con.PV_KNVKGB__c) ? null : con.PV_KNVKGB__c.toUpperCase();
                    mdmContact.PV_KNVKGB_lu__c          =      codeToIdMap.get(con.PV_KNVKGB__c.toUpperCase());
                    mdmContact.PV_TELF1_VK__c           =      String.isBlank(con.PV_TELF1_VK__c) ? null : con.PV_TELF1_VK__c;
                    mdmContact.PV_ABTNR_VK__c           =      String.isBlank(con.PV_ABTNR_VK__c) ? null : con.PV_ABTNR_VK__c;
                    mdmContact.PV_PAFKT_VK__c           =      String.isBlank(con.PV_PAFKT_VK__c) ? null : con.PV_PAFKT_VK__c;
                    mdmContact.PV_TALKT_VK__c           =      String.isBlank(con.PV_TALKT_VK__c) ? null : con.PV_TALKT_VK__c;
                    mdmContact.PV_EMAIL_VK__c           =      String.isBlank(con.PV_EMAIL_VK__c) ? null : con.PV_EMAIL_VK__c;
                    mdmContact.Contact__c               =      String.isBlank(con.Contact__c) ? null : con.Contact__c;
                    if(recordId != null) {
                        mdmContact.MDMRegRequestCustomer__c     =      kunnrToIdMap.get(con.MDMRegRequestCustomer__c);
                        mdmContact.MDMRegRequestBulkCustomer__c =      recordId;
                    } else {
                        mdmContact.MDMRegRequestCustomer__c     =      newMDMToIdMap.get(con.MDMRegRequestCustomer__c);
                        mdmContact.MDMRegRequestBulkCustomer__c =      saveResult.bulkId;
                    }
                    
                    contactList.add(mdmContact);
                }

                System.debug('contactList => ' + contactList);

                insert contactList;

            }
            
        } catch (Exception e) {
            saveResult = new SaveResult('F', e.getMessage() + e.getLineNumber());
        }

        return saveResult;

    }

    public class SaveResult{

        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String massage {get;set;}
        @AuraEnabled public String bulkId {get;set;}

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