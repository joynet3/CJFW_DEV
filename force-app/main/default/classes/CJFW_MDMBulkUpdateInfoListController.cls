/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkUpdateInfoListController {

    /* 대량 수정 요청 Id를 통해 받아 온 리스트를 기존의 것과 조사 */
    @AuraEnabled(cacheable=true)
    public static DataWrapper getAccountInfo (String recordId, Integer pageNumber, Integer pageSize) {

        List<MDMRegRequestCustomer__c> mdms = [SELECT PV_KUNNR__c, PV_OLDCD__c, PV_NAME1__c, PV_NAME_G__c, PV_NAME2__c, PV_KTOKD__c, PV_CUSTTYPE__c, PV_STCD2__c, PV_STCD3__c, PV_GFORM__c, PV_J_1KFREPRE__c, PV_BLCKYN__c, PV_STCD1__c, PV_J_1KFTBUS__c, PV_J_1KFTIND__c, PV_TELF1__c, PV_TELFX__c, PV_PAYCUST__c, PV_CHARGECUST__c, PV_VKGRP__c, PVVF_VKGRP__c, PVRA_VKGRP__c, PV_PERNR__c, PVVF_PERNR__c, PVRA_PERNR__c, PV_ADMINMA__c, PV_STCDT__c, PV_FITYP__c, PV_HDOFFICEYN__c, PV_SUBSIDIARYYN__c, PV_VBUND__c, PV_LAND1__c, PV_KNVKTYPE__c, PV_CLOSEDT__c, PV_REGIO__c, PV_ADRES_ROADADDR1__c, PV_ADRES_ROADADDR2__c, PV_ADRES_ADDR1__c, PV_ADRES_ADDR2__c, PV_BUSAB__c, PV_CESSION_KZ__c, PV_ZUAWA__c, PV_AKONT__c, PV_FDGRV__c, PV_VRSDG__c, PV_TAXKDD__c, PV_KATR5__c, PV_CUHR1__c, PVVF_CUHR1__c, PVRA_CUHR1__c, PV_KONDA__c, PVVF_KONDA__c, PVRA_KONDA__c, PV_KVGR1__c, PVVF_KVGR1__c, PVRA_KVGR1__c, PV_WAERS__c, PV_KDGRP__c, PV_KVGR2__c, PV_VACCPRTEXCYN__c, PV_ZTERM_VV__c, PV_DSTRHISTREGYN__c, PV_KULTG__c, PV_OLD_BIZPLACE_NEW__c, PVVF_OLD_BIZPLACE_NEW__c, PVRA_OLD_BIZPLACE_NEW__c, PV_SHAPE__c, PV_DELIGROUP__c FROM MDMRegRequestCustomer__c WHERE MDMRegRequestBulkCustomer__c = :recordId ORDER BY PV_KUNNR__c];
        List<String> ids = new List<String>();

        for(MDMRegRequestCustomer__c mdm : mdms) {
            ids.add('\'' + mdm.PV_KUNNR__c + '\'');
        }

        System.debug('mdms => ' + mdms);
        System.debug('ids => ' + ids);

        DataWrapper objWrapper = new DataWrapper();

        String strQuery = 'SELECT Id, CustomerID__c, Name, Owner.Name, fm_empId__c, CustomerIDASIS__c, NameKor__c, NameAlias__c, AccountGroup__c, toLabel(AccountGroup__c) AccountGroupLabel, ';
        strQuery += ' CustomerType__c, toLabel(CustomerType__c) CustomerTypeLabel, CompanyRegisterNumber__c, CorporateCode__c, 	SubCompanyRegisterNumber__c, ';
        strQuery += ' LegalStatus__c, toLabel(LegalStatus__c) LegalStatusLabel, RepresentativeName__c, PV_BLCKYN__c,	RepresentativeBirthDate__c, BusinessConditions__c, BusinessCategory__c, ';
        strQuery += ' Phone, Fax, PaymentAccountCode__c, PaymentAccountName__c, ShippingAccountCode__c, ShippingAccountName__c, PV_VKGRP__c, toLabel(PV_VKGRP__c) PV_VKGRP__LABEL, ';
        strQuery += ' PVVF_VKGRP__c, SalesGroupFromDate__c, OwnerId, PVVF_PERNR__c, ResponsibilityMAFromDate__c, ResponsibilityAMA__c, TaxInvoiceType__c, toLabel(TaxInvoiceType__c) TaxInvoiceLabel, ';
        strQuery += ' IsHeadShopUseYN__c, IsAffiliatedcompanyYN__c, AffiliatedCompany__c, toLabel(AffiliatedCompany__c) AffiliatedCompanyLabel, CountryKeyCode__c, toLabel(CountryKeyCode__c) CountryKeyCodeLabel, ';
        strQuery += ' PV_KNVKTYPE__c, toLabel(PV_KNVKTYPE__c) PV_KNVKTYPE__LABEL, ShutDownDate__c, LocationState__c, toLabel(LocationState__c) LocationStateLabel, Address__c, AddressDetails__c, ';
        strQuery += ' Address2__c, AddressDetails2__c, SalesForm__c, toLabel(SalesForm__c) SalesFormLabel, CustomerStatus__c, toLabel(CustomerStatus__c) CustomerStatusLabel, SortKey__c, toLabel(SortKey__c) SortKeyLabel, ';
        strQuery += ' MediateAccount__c, toLabel(MediateAccount__c) MediateAccountLabel, CashManagementGroup__c, toLabel(CashManagementGroup__c) CashManagementGroupLabel, IsDeposit__c, toLabel(IsDeposit__c) IsDepositLabel, ';
        strQuery += ' TaxClassification__c, toLabel(TaxClassification__c) TaxClassificationLabel, TaxPaymentMethod__c, toLabel(TaxPaymentMethod__c) TaxPaymentMethodLabel, CustomerRoute__c, toLabel(CustomerRoute__c) CustomerRouteLabel, ';
        strQuery += ' PV_CUHR1__c, CustomerRouteFromDate__c, PriceGroup__c, toLabel(PriceGroup__c) PriceGroupLabel, UnitPriceGroup__c, toLabel(UnitPriceGroup__c) UnitPriceGroupLabel, CurrencyIsoCode, ';
        strQuery += ' toLabel(CurrencyIsoCode) CurrencyIsoLabel, CreditManagement__c, toLabel(CreditManagement__c) CreditManagementLabel, SubsidyType__c, toLabel(SubsidyType__c) SubsidyTypeLabel, ';
        strQuery += ' IsPrintVirtualAccount__c, TermsOfPayment__c, toLabel(TermsOfPayment__c) TermsOfPaymentLabel, DisHisRegType__c, toLabel(DisHisRegType__c) DisHisRegTypeLabel, ContractRocationDate__c, TaxationType__c, ';
        strQuery += ' CustomerPath__c, toLabel(CustomerPath__c) CustomerPathLabel, Shape__c, DeliveryGroup__c, toLabel(DeliveryGroup__c) DeliveryGroupLabel, ';
        strQuery += ' PVVF_KONDA__c, PriceGroupFromDate__c, PVVF_OLD_BIZPLACE_NEW__c, CustomerPathFromDate__c ';
        strQuery += ' FROM    Account';
        strQuery += ' WHERE CustomerId__c IN ' + ids + ' ORDER BY CustomerId__c';

        List<Account> accList = Database.query(strQuery);
        
        System.debug('accList => ' + accList);

        List<MDMRequest> result = new List<MDMRequest>(); // 해당 페이지에 담은
        List<MDMRequest> mdmList = new List<MDMRequest>(); // 모든 페이지에 담은

        for (Integer i = 0; i < mdms.size(); i++) {
            MDMRequest mdmRequest = new MDMRequest();
            mdmRequest.PV_KUNNR           =      String.isBlank(mdms[i].PV_KUNNR__c) ? null : mdms[i].PV_KUNNR__c;

            if(mdms[i].PV_KUNNR__c == accList[i].CustomerId__c) {
                mdmRequest.PV_INDEX                 =      i + 1;
                mdmRequest.PV_OLDCD                 =      String.isBlank(accList[i].CustomerIDASIS__c) ? null : accList[i].CustomerIDASIS__c;
                mdmRequest.PV_OLDCD_MOD             =      String.isBlank(mdms[i].PV_OLDCD__c) ? null : mdms[i].PV_OLDCD__c;
                mdmRequest.PV_NAME1                 =      String.isBlank(accList[i].Name) ? null : accList[i].Name;
                mdmRequest.PV_NAME1_MOD             =      String.isBlank(mdms[i].PV_NAME1__c) ? null : mdms[i].PV_NAME1__c;
                mdmRequest.PV_NAME_G                =      String.isBlank(accList[i].NameKor__c) ? null : accList[i].NameKor__c;
                mdmRequest.PV_NAME_G_MOD            =      String.isBlank(mdms[i].PV_NAME_G__c) ? null : mdms[i].PV_NAME_G__c;
                mdmRequest.PV_NAME2                 =      String.isBlank(accList[i].NameAlias__c) ? null : accList[i].NameAlias__c;
                mdmRequest.PV_NAME2_MOD             =      String.isBlank(mdms[i].PV_NAME2__c) ? null : mdms[i].PV_NAME2__c;
                mdmRequest.PV_KTOKD                 =      String.isBlank(accList[i].AccountGroup__c) ? null : accList[i].AccountGroup__c;
                mdmRequest.PV_KTOKD_MOD             =      String.isBlank(mdms[i].PV_KTOKD__c) ? null : mdms[i].PV_KTOKD__c;
                mdmRequest.PV_CUSTTYPE              =      String.isBlank(accList[i].CustomerType__c) ? null : accList[i].CustomerType__c;
                mdmRequest.PV_CUSTTYPE_MOD          =      String.isBlank(mdms[i].PV_CUSTTYPE__c) ? null : mdms[i].PV_CUSTTYPE__c;
                mdmRequest.PV_STCD2                 =      String.isBlank(accList[i].CompanyRegisterNumber__c) ? null : accList[i].CompanyRegisterNumber__c;
                mdmRequest.PV_STCD2_MOD             =      String.isBlank(mdms[i].PV_STCD2__c) ? null : mdms[i].PV_STCD2__c;
                mdmRequest.PV_STCD3                 =      String.isBlank(accList[i].CorporateCode__c) ? null : accList[i].CorporateCode__c;
                mdmRequest.PV_STCD3_MOD             =      String.isBlank(mdms[i].PV_STCD3__c) ? null : mdms[i].PV_STCD3__c;
                mdmRequest.PV_J_1KFREPRE            =      String.isBlank(accList[i].RepresentativeName__c) ? null : accList[i].RepresentativeName__c;
                mdmRequest.PV_J_1KFREPRE_MOD        =      String.isBlank(mdms[i].PV_J_1KFREPRE__c) ? null : mdms[i].PV_J_1KFREPRE__c;
                mdmRequest.PV_BLCKYN                =      accList[i].PV_BLCKYN__c ? null : accList[i].PV_BLCKYN__c;
                mdmRequest.PV_BLCKYN_MOD            =      mdms[i].PV_BLCKYN__c ? null : mdms[i].PV_BLCKYN__c;
                mdmRequest.PV_STCD1                 =      String.isBlank(accList[i].RepresentativeBirthDate__c) ? null : accList[i].RepresentativeBirthDate__c;
                mdmRequest.PV_STCD1_MOD             =      String.isBlank(mdms[i].PV_STCD1__c) ? null : mdms[i].PV_STCD1__c;
                mdmRequest.PV_J_1KFTBUS             =      String.isBlank(accList[i].BusinessConditions__c) ? null : accList[i].BusinessConditions__c;
                mdmRequest.PV_J_1KFTBUS_MOD         =      String.isBlank(mdms[i].PV_J_1KFTBUS__c) ? null : mdms[i].PV_J_1KFTBUS__c;
                mdmRequest.PV_J_1KFTIND             =      String.isBlank(accList[i].BusinessCategory__c) ? null : accList[i].BusinessCategory__c;
                mdmRequest.PV_J_1KFTIND_MOD         =      String.isBlank(mdms[i].PV_J_1KFTIND__c) ? null : mdms[i].PV_J_1KFTIND__c;
                mdmRequest.PV_TELF1                 =      String.isBlank(accList[i].Phone) ? null : accList[i].Phone;
                mdmRequest.PV_TELF1_MOD             =      String.isBlank(mdms[i].PV_TELF1__c) ? null : mdms[i].PV_TELF1__c;
                mdmRequest.PV_TELFX                 =      String.isBlank(accList[i].Fax) ? null : accList[i].Fax;
                mdmRequest.PV_TELFX_MOD             =      String.isBlank(mdms[i].PV_TELFX__c) ? null : mdms[i].PV_TELFX__c;
                mdmRequest.PV_PAYCUST               =      String.isBlank(accList[i].PaymentAccountCode__c) ? null : accList[i].PaymentAccountCode__c;
                mdmRequest.PV_PAYCUST_MOD           =      String.isBlank(mdms[i].PV_PAYCUST__c) ? null : mdms[i].PV_PAYCUST__c;
                mdmRequest.PV_CHARGECUST            =      String.isBlank(accList[i].ShippingAccountCode__c) ? null : accList[i].ShippingAccountCode__c;
                mdmRequest.PV_CHARGECUST_MOD        =      String.isBlank(mdms[i].PV_CHARGECUST__c) ? null : mdms[i].PV_CHARGECUST__c;
                mdmRequest.PV_VKGRP                 =      String.isBlank(accList[i].PV_VKGRP__c) ? null : accList[i].PV_VKGRP__c;
                mdmRequest.PV_VKGRP_MOD             =      String.isBlank(mdms[i].PV_VKGRP__c) ? null : mdms[i].PV_VKGRP__c;
                mdmRequest.PVVF_VKGRP               =      accList[i].PVVF_VKGRP__c;
                mdmRequest.PVVF_VKGRP_MOD           =      mdms[i].PVVF_VKGRP__c;
                mdmRequest.PVRA_VKGRP               =      accList[i].SalesGroupFromDate__c;
                mdmRequest.PVRA_VKGRP_MOD           =      mdms[i].PVRA_VKGRP__c;
                mdmRequest.PV_PERNR                 =      String.isBlank(accList[i].fm_empId__c) ? null : accList[i].fm_empId__c;
                mdmRequest.PV_PERNR_MOD             =      String.isBlank(mdms[i].PV_PERNR__c) ? null : mdms[i].PV_PERNR__c;
                mdmRequest.PV_ADMINMA               =      String.isBlank(accList[i].ResponsibilityAMA__c) ? null : accList[i].ResponsibilityAMA__c;
                mdmRequest.PV_ADMINMA_MOD           =      String.isBlank(mdms[i].PV_ADMINMA__c) ? null : mdms[i].PV_ADMINMA__c;
                mdmRequest.PV_STCDT                 =      String.isBlank(accList[i].TaxInvoiceType__c) ? null : accList[i].TaxInvoiceType__c;
                mdmRequest.PV_STCDT_MOD             =      String.isBlank(mdms[i].PV_STCDT__c) ? null : mdms[i].PV_STCDT__c;
                mdmRequest.PV_FITYP                 =      String.isBlank(accList[i].TaxationType__c) ? null : accList[i].TaxationType__c;
                mdmRequest.PV_FITYP_MOD             =      String.isBlank(mdms[i].PV_FITYP__c) ? null : mdms[i].PV_FITYP__c;
                mdmRequest.PV_HDOFFICEYN            =      accList[i].IsHeadShopUseYN__c ? accList[i].IsHeadShopUseYN__c : accList[i].IsHeadShopUseYN__c;
                mdmRequest.PV_HDOFFICEYN_MOD        =      mdms[i].PV_HDOFFICEYN__c ? mdms[i].PV_HDOFFICEYN__c : mdms[i].PV_HDOFFICEYN__c;
                mdmRequest.PV_SUBSIDIARYYN          =      accList[i].IsAffiliatedcompanyYN__c ? null : accList[i].IsAffiliatedcompanyYN__c;
                mdmRequest.PV_SUBSIDIARYYN_MOD      =      mdms[i].PV_SUBSIDIARYYN__c ? null : mdms[i].PV_SUBSIDIARYYN__c;
                mdmRequest.PV_VBUND                 =      String.isBlank(accList[i].AffiliatedCompany__c) ? null : accList[i].AffiliatedCompany__c;
                mdmRequest.PV_VBUND_MOD             =      String.isBlank(mdms[i].PV_VBUND__c) ? null : mdms[i].PV_VBUND__c;
                mdmRequest.PV_LAND1                 =      String.isBlank(accList[i].CountryKeyCode__c) ? null : accList[i].CountryKeyCode__c;
                mdmRequest.PV_LAND1_MOD             =      String.isBlank(mdms[i].PV_LAND1__c) ? null : mdms[i].PV_LAND1__c;
                mdmRequest.PV_KNVKTYPE              =      String.isBlank(accList[i].PV_KNVKTYPE__c) ? null : accList[i].PV_KNVKTYPE__c;
                mdmRequest.PV_KNVKTYPE_MOD          =      String.isBlank(mdms[i].PV_KNVKTYPE__c) ? null : mdms[i].PV_KNVKTYPE__c;
                mdmRequest.PV_CLOSEDT               =      accList[i].ShutDownDate__c;
                mdmRequest.PV_CLOSEDT_MOD           =      mdms[i].PV_CLOSEDT__c;
                mdmRequest.PV_REGIO                 =      String.isBlank(accList[i].LocationState__c) ? null : accList[i].LocationState__c;
                mdmRequest.PV_REGIO_MOD             =      String.isBlank(mdms[i].PV_REGIO__c) ? null : mdms[i].PV_REGIO__c;
                mdmRequest.PV_ADRES_ROADADDR1       =      String.isBlank(accList[i].Address__c) ? null : accList[i].Address__c;
                mdmRequest.PV_ADRES_ROADADDR1_MOD   =      String.isBlank(mdms[i].PV_ADRES_ROADADDR1__c) ? null : mdms[i].PV_ADRES_ROADADDR1__c;
                mdmRequest.PV_ADRES_ROADADDR2       =      String.isBlank(accList[i].AddressDetails__c) ? null : accList[i].AddressDetails__c;
                mdmRequest.PV_ADRES_ROADADDR2_MOD   =      String.isBlank(mdms[i].PV_ADRES_ROADADDR2__c) ? null : mdms[i].PV_ADRES_ROADADDR2__c;
                mdmRequest.PV_ADRES_ADDR1           =      String.isBlank(accList[i].Address2__c) ? null : accList[i].Address2__c;
                mdmRequest.PV_ADRES_ADDR1_MOD       =      String.isBlank(mdms[i].PV_ADRES_ADDR1__c) ? null : mdms[i].PV_ADRES_ADDR1__c;
                mdmRequest.PV_ADRES_ADDR2           =      String.isBlank(accList[i].AddressDetails2__c) ? null : accList[i].AddressDetails2__c;
                mdmRequest.PV_ADRES_ADDR2_MOD       =      String.isBlank(mdms[i].PV_ADRES_ADDR2__c) ? null : mdms[i].PV_ADRES_ADDR2__c;
                mdmRequest.PV_BUSAB                 =      String.isBlank(accList[i].SalesForm__c) ? null : accList[i].SalesForm__c;
                mdmRequest.PV_BUSAB_MOD             =      String.isBlank(mdms[i].PV_BUSAB__c) ? null : mdms[i].PV_BUSAB__c;
                mdmRequest.PV_CESSION_KZ            =      String.isBlank(accList[i].CustomerStatus__c) ? null : accList[i].CustomerStatus__c;
                mdmRequest.PV_CESSION_KZ_MOD        =      String.isBlank(mdms[i].PV_CESSION_KZ__c) ? null : mdms[i].PV_CESSION_KZ__c;
                mdmRequest.PV_ZUAWA                 =      String.isBlank(accList[i].SortKey__c) ? null : accList[i].SortKey__c;
                mdmRequest.PV_ZUAWA_MOD             =      String.isBlank(mdms[i].PV_ZUAWA__c) ? null : mdms[i].PV_ZUAWA__c;
                mdmRequest.PV_AKONT                 =      String.isBlank(accList[i].MediateAccount__c) ? null : accList[i].MediateAccount__c;
                mdmRequest.PV_AKONT_MOD             =      String.isBlank(mdms[i].PV_AKONT__c) ? null : mdms[i].PV_AKONT__c;
                mdmRequest.PV_FDGRV                 =      String.isBlank(accList[i].CashManagementGroup__c) ? null : accList[i].CashManagementGroup__c;
                mdmRequest.PV_FDGRV_MOD             =      String.isBlank(mdms[i].PV_FDGRV__c) ? null : mdms[i].PV_FDGRV__c;
                mdmRequest.PV_VRSDG                 =      String.isBlank(accList[i].IsDeposit__c) ? null : accList[i].IsDeposit__c;
                mdmRequest.PV_VRSDG_MOD             =      String.isBlank(mdms[i].PV_VRSDG__c) ? null : mdms[i].PV_VRSDG__c;
                mdmRequest.PV_TAXKDD                =      String.isBlank(accList[i].TaxClassification__c) ? null : accList[i].TaxClassification__c;
                mdmRequest.PV_TAXKDD_MOD            =      String.isBlank(mdms[i].PV_TAXKDD__c) ? null : mdms[i].PV_TAXKDD__c;
                mdmRequest.PV_KATR5                 =      String.isBlank(accList[i].TaxPaymentMethod__c) ? null : accList[i].TaxPaymentMethod__c;
                mdmRequest.PV_KATR5_MOD             =      String.isBlank(mdms[i].PV_KATR5__c) ? null : mdms[i].PV_KATR5__c;
                mdmRequest.PV_CUHR1                 =      String.isBlank(accList[i].CustomerRoute__c) ? null : accList[i].CustomerRoute__c;
                mdmRequest.PV_CUHR1_MOD             =      String.isBlank(mdms[i].PV_CUHR1__c) ? null : mdms[i].PV_CUHR1__c;
                mdmRequest.PVVF_CUHR1               =      accList[i].PV_CUHR1__c;
                mdmRequest.PVVF_CUHR1_MOD           =      mdms[i].PVVF_CUHR1__c;
                mdmRequest.PVRA_CUHR1               =      accList[i].CustomerRouteFromDate__c;
                mdmRequest.PVRA_CUHR1_MOD           =      mdms[i].PVRA_CUHR1__c;
                mdmRequest.PV_KONDA                 =      String.isBlank(accList[i].PriceGroup__c) ? null : accList[i].PriceGroup__c;
                mdmRequest.PV_KONDA_MOD             =      String.isBlank(mdms[i].PV_KONDA__c) ? null : mdms[i].PV_KONDA__c;
                mdmRequest.PVVF_KONDA               =      accList[i].PVVF_KONDA__c;
                mdmRequest.PVVF_KONDA_MOD           =      mdms[i].PVVF_KONDA__c;
                mdmRequest.PVRA_KONDA               =      accList[i].PriceGroupFromDate__c;
                mdmRequest.PVRA_KONDA_MOD           =      mdms[i].PVRA_KONDA__c;
                mdmRequest.PV_KVGR1                 =      String.isBlank(accList[i].UnitPriceGroup__c) ? null : accList[i].UnitPriceGroup__c;
                mdmRequest.PV_KVGR1_MOD             =      String.isBlank(mdms[i].PV_KVGR1__c) ? null : mdms[i].PV_KVGR1__c;
                mdmRequest.PV_WAERS                 =      String.isBlank(accList[i].CurrencyIsoCode) ? null : accList[i].CurrencyIsoCode;
                mdmRequest.PV_WAERS_MOD             =      String.isBlank(mdms[i].PV_WAERS__c) ? null : mdms[i].PV_WAERS__c;
                mdmRequest.PV_KDGRP                 =      String.isBlank(accList[i].CreditManagement__c) ? null : accList[i].CreditManagement__c;
                mdmRequest.PV_KDGRP_MOD             =      String.isBlank(mdms[i].PV_KDGRP__c) ? null : mdms[i].PV_KDGRP__c;
                mdmRequest.PV_KVGR2                 =      String.isBlank(accList[i].SubsidyType__c) ? null : accList[i].SubsidyType__c;
                mdmRequest.PV_KVGR2_MOD             =      String.isBlank(mdms[i].PV_KVGR2__c) ? null : mdms[i].PV_KVGR2__c;
                mdmRequest.PV_VACCPRTEXCYN          =      accList[i].IsPrintVirtualAccount__c ? null : accList[i].IsPrintVirtualAccount__c;
                mdmRequest.PV_VACCPRTEXCYN_MOD      =      mdms[i].PV_VACCPRTEXCYN__c ? null : mdms[i].PV_VACCPRTEXCYN__c;
                mdmRequest.PV_ZTERM_VV              =      String.isBlank(accList[i].TermsOfPayment__c) ? null : accList[i].TermsOfPayment__c;
                mdmRequest.PV_ZTERM_VV_MOD          =      String.isBlank(mdms[i].PV_ZTERM_VV__c) ? null : mdms[i].PV_ZTERM_VV__c;
                mdmRequest.PV_DSTRHISTREGYN         =      String.isBlank(accList[i].DisHisRegType__c) ? null : accList[i].DisHisRegType__c;
                mdmRequest.PV_DSTRHISTREGYN_MOD     =      String.isBlank(mdms[i].PV_DSTRHISTREGYN__c) ? null : mdms[i].PV_DSTRHISTREGYN__c;
                mdmRequest.PV_KULTG                 =      String.isBlank(accList[i].ContractRocationDate__c) ? null : accList[i].ContractRocationDate__c;
                mdmRequest.PV_KULTG_MOD             =      String.isBlank(mdms[i].PV_KULTG__c) ? null : mdms[i].PV_KULTG__c;
                mdmRequest.PV_OLD_BIZPLACE_NEW      =      String.isBlank(accList[i].CustomerPath__c) ? null : accList[i].CustomerPath__c;
                mdmRequest.PV_OLD_BIZPLACE_NEW_MOD  =      String.isBlank(mdms[i].PV_OLD_BIZPLACE_NEW__c) ? null : mdms[i].PV_OLD_BIZPLACE_NEW__c;
                mdmRequest.PVVF_OLD_BIZPLACE_NEW      =    accList[i].PVVF_OLD_BIZPLACE_NEW__c;
                mdmRequest.PVVF_OLD_BIZPLACE_NEW_MOD  =    mdms[i].PVVF_OLD_BIZPLACE_NEW__c;
                mdmRequest.PVRA_OLD_BIZPLACE_NEW      =    accList[i].CustomerPathFromDate__c;
                mdmRequest.PVRA_OLD_BIZPLACE_NEW_MOD  =    mdms[i].PVRA_OLD_BIZPLACE_NEW__c;
                mdmRequest.PV_SHAPE                 =      String.isBlank(accList[i].Shape__c) ? null : accList[i].Shape__c;
                mdmRequest.PV_SHAPE_MOD             =      String.isBlank(mdms[i].PV_SHAPE__c) ? null : mdms[i].PV_SHAPE__c;
                mdmRequest.PV_DELIGROUP             =      String.isBlank(accList[i].DeliveryGroup__c) ? null : accList[i].DeliveryGroup__c;
                mdmRequest.PV_DELIGROUP_MOD         =      String.isBlank(mdms[i].PV_DELIGROUP__c) ? null : mdms[i].PV_DELIGROUP__c;
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

        // 인덱스, 고객ID
        List<String> headerList = new List<String>();
        headerList.add('INDEX');
        headerList.add('PV_KUNNR__c');

        for(Integer i = 0; i < mdmList.size(); i++) {

            // 구코드
            if(mdmList[i].PV_OLDCD != mdmList[i].PV_OLDCD_MOD && mdmList[i].PV_OLDCD_MOD != null) {
                headerList.add('PV_OLDCD__c');
            }
            
            // 고객명(영문명 포함)
            if(mdmList[i].PV_NAME1 != mdmList[i].PV_NAME1_MOD && mdmList[i].PV_NAME1_MOD != null) {
                headerList.add('PV_NAME1__c');
            }
    
            // 고객명(G) / 자국명
            if(mdmList[i].PV_NAME_G != mdmList[i].PV_NAME_G_MOD && mdmList[i].PV_NAME_G_MOD != null) {
                headerList.add('PV_NAME_G__c');
            }
    
            // 고객약칭명
            if(mdmList[i].PV_NAME2 != mdmList[i].PV_NAME2_MOD && mdmList[i].PV_NAME2_MOD != null) {
                headerList.add('PV_NAME2__c');
            }
    
            // 고객계정그룹
            if(mdmList[i].PV_KTOKD != mdmList[i].PV_KTOKD_MOD && mdmList[i].PV_KTOKD_MOD != null) {
                headerList.add('PV_KTOKD__c');
            }

            // 고객유형
            if(mdmList[i].PV_CUSTTYPE != mdmList[i].PV_CUSTTYPE_MOD && mdmList[i].PV_CUSTTYPE_MOD != null) {
                headerList.add('PV_CUSTTYPE__c');
            }

            // 사업자등록번호
            if(mdmList[i].PV_STCD2 != mdmList[i].PV_STCD2_MOD && mdmList[i].PV_STCD2_MOD != null) {
                headerList.add('PV_STCD2__c');
            }

            // 법인코드
            if(mdmList[i].PV_STCD3 != mdmList[i].PV_STCD3_MOD && mdmList[i].PV_STCD3_MOD != null) {
                headerList.add('PV_STCD3__c');
            }

            // 종사업장번호
            if(mdmList[i].PV_STCD4 != mdmList[i].PV_STCD4_MOD && mdmList[i].PV_STCD4_MOD != null) {
                headerList.add('PV_STCD4__c');
            }

            // 법적상태
            if(mdmList[i].PV_GFORM != mdmList[i].PV_GFORM_MOD && mdmList[i].PV_GFORM_MOD != null) {
                headerList.add('PV_GFORM__c');
            }

            // 대표자이름
            if(mdmList[i].PV_J_1KFREPRE != mdmList[i].PV_J_1KFREPRE_MOD && mdmList[i].PV_J_1KFREPRE_MOD != null) {
                headerList.add('PV_J_1KFREPRE__c');
            }

            // 사용중지
            if(mdmList[i].PV_BLCKYN != mdmList[i].PV_BLCKYN_MOD && mdmList[i].PV_BLCKYN_MOD != null) {
                headerList.add('PV_BLCKYN__c');
            }

            // 대표자 생년월일
            if(mdmList[i].PV_STCD1 != mdmList[i].PV_STCD1_MOD && mdmList[i].PV_STCD1_MOD != null) {
                headerList.add('PV_STCD1__c');
            }

            // 업태
            if(mdmList[i].PV_J_1KFTBUS != mdmList[i].PV_J_1KFTBUS_MOD && mdmList[i].PV_J_1KFTBUS_MOD != null) {
                headerList.add('PV_J_1KFTBUS__c');
            }

            // 업종
            if(mdmList[i].PV_J_1KFTIND != mdmList[i].PV_J_1KFTIND_MOD && mdmList[i].PV_J_1KFTIND_MOD != null) {
                headerList.add('PV_J_1KFTIND__c');
            }

            // 전화
            if(mdmList[i].PV_TELF1 != mdmList[i].PV_TELF1_MOD && mdmList[i].PV_TELF1_MOD != null) {
                headerList.add('PV_TELF1__c');
            }
            
            // 팩스
            if(mdmList[i].PV_TELFX != mdmList[i].PV_TELFX_MOD && mdmList[i].PV_TELFX_MOD != null) {
                headerList.add('PV_TELFX__c');
            }

            // 지급처            
            if(mdmList[i].PV_PAYCUST != mdmList[i].PV_PAYCUST_MOD && mdmList[i].PV_PAYCUST_MOD != null) {
                headerList.add('PV_PAYCUST__c');
            }

            // 청구처
            if(mdmList[i].PV_CHARGECUST != mdmList[i].PV_CHARGECUST_MOD && mdmList[i].PV_CHARGECUST_MOD != null) {
                headerList.add('PV_CHARGECUST__c');
            }
            
            // 영업그룹
            if(mdmList[i].PV_VKGRP != mdmList[i].PV_VKGRP_MOD && mdmList[i].PV_VKGRP_MOD != null) {
                headerList.add('PV_VKGRP__c');
            }

            // 영업그룹 유효일자
            if(mdmList[i].PV_VKGRP != mdmList[i].PV_VKGRP_MOD && mdmList[i].PV_VKGRP_MOD != null) {
                headerList.add('PVVF_VKGRP__c');
            }

            // 영업그룹 적용일자
            if(mdmList[i].PV_VKGRP != mdmList[i].PV_VKGRP_MOD && mdmList[i].PV_VKGRP_MOD != null) {
                headerList.add('PVRA_VKGRP__c');
            }

            // 담당MA
            if(mdmList[i].PV_PERNR != mdmList[i].PV_PERNR_MOD && mdmList[i].PV_PERNR_MOD != null) {
                headerList.add('PV_PERNR__c');
            }
            
            // 담당MA 유효일자
            if(mdmList[i].PV_PERNR != mdmList[i].PV_PERNR_MOD && mdmList[i].PV_PERNR_MOD != null) {
                headerList.add('PVVF_PERNR__c');
            }
            
            // 담당MA 적용일자
            if(mdmList[i].PV_PERNR != mdmList[i].PV_PERNR_MOD && mdmList[i].PV_PERNR_MOD != null) {
                headerList.add('PVRA_PERNR__c');
            }

            // 담당AMA
            if(mdmList[i].PV_ADMINMA != mdmList[i].PV_ADMINMA_MOD && mdmList[i].PV_ADMINMA_MOD != null) {
                headerList.add('PV_ADMINMA__c');
            }
            
            // FW 출고센터
            if(mdmList[i].PV_LOGISCENTER != mdmList[i].PV_LOGISCENTER_MOD && mdmList[i].PV_LOGISCENTER_MOD != null) {
                headerList.add('PV_LOGISCENTER__c');
            }
            
            // FW 출고센터 유효일자
            if(mdmList[i].PVVF_LOGISCENTER != mdmList[i].PVVF_LOGISCENTER_MOD && mdmList[i].PVVF_LOGISCENTER_MOD != null) {
                headerList.add('PVVF_LOGISCENTER__c');
            }
            
            // FW 출고센터 적용일자
            if(mdmList[i].PVRA_LOGISCENTER != mdmList[i].PVRA_LOGISCENTER_MOD && mdmList[i].PVRA_LOGISCENTER_MOD != null) {
                headerList.add('PVRA_LOGISCENTER__c');
            }

            // 세금계산서발행유형
            if(mdmList[i].PV_STCDT != mdmList[i].PV_STCDT_MOD && mdmList[i].PV_STCDT_MOD != null) {
                headerList.add('PV_STCDT__c');
            }

            // 과세유형
            if(mdmList[i].PV_FITYP != mdmList[i].PV_FITYP_MOD && mdmList[i].PV_FITYP_MOD != null) {
                headerList.add('PV_FITYP__c');
            }

            // 본점 사용유무
            if(mdmList[i].PV_HDOFFICEYN != mdmList[i].PV_HDOFFICEYN_MOD && mdmList[i].PV_HDOFFICEYN_MOD != null) {
                headerList.add('PV_HDOFFICEYN__c');
            }
            
            // 본점코드
            if(mdmList[i].PV_HKUNNR != mdmList[i].PV_HKUNNR_MOD && mdmList[i].PV_HKUNNR_MOD != null) {
                headerList.add('PV_HKUNNR__c');
            }

            // 관계사여부
            if(mdmList[i].PV_SUBSIDIARYYN != mdmList[i].PV_SUBSIDIARYYN_MOD && mdmList[i].PV_SUBSIDIARYYN_MOD != null) {
                headerList.add('PV_SUBSIDIARYYN__c');
            }

            // 관계사코드
            if(mdmList[i].PV_VBUND != mdmList[i].PV_VBUND_MOD && mdmList[i].PV_VBUND_MOD != null) {
                headerList.add('PV_VBUND__c');
            }

            // 수수료지급처
            if(mdmList[i].PV_LIFNR != mdmList[i].PV_LIFNR_MOD && mdmList[i].PV_LIFNR_MOD != null) {
                headerList.add('PV_LIFNR__c');
            }

            // 국가키
            if(mdmList[i].PV_LAND1 != mdmList[i].PV_LAND1_MOD && mdmList[i].PV_LAND1_MOD != null) {
                headerList.add('PV_LAND1__c');
            }

            // 주문유형
            if(mdmList[i].PV_KNVKTYPE != mdmList[i].PV_KNVKTYPE_MOD && mdmList[i].PV_KNVKTYPE_MOD != null) {
                headerList.add('PV_KNVKTYPE__c');
            }

            // 휴폐업일자
            if(mdmList[i].PV_CLOSEDT != mdmList[i].PV_CLOSEDT_MOD && mdmList[i].PV_CLOSEDT_MOD != null) {
                headerList.add('PV_CLOSEDT__c');
            }

            // 지역
            if(mdmList[i].PV_REGIO != mdmList[i].PV_REGIO_MOD && mdmList[i].PV_REGIO_MOD != null) {
                headerList.add('PV_REGIO__c');
            }

            // 도로명 주소
            if(mdmList[i].PV_ADRES_ROADADDR1 != mdmList[i].PV_ADRES_ROADADDR1_MOD && mdmList[i].PV_ADRES_ROADADDR1_MOD != null) {
                headerList.add('PV_ADRES_ROADADDR1__c');
            }

            // 상세 주소
            if(mdmList[i].PV_ADRES_ROADADDR2 != mdmList[i].PV_ADRES_ROADADDR2_MOD && mdmList[i].PV_ADRES_ROADADDR2_MOD != null) {
                headerList.add('PV_ADRES_ROADADDR2__c');
            }

            // 지번주소
            if(mdmList[i].PV_ADRES_ADDR1 != mdmList[i].PV_ADRES_ADDR1_MOD && mdmList[i].PV_ADRES_ADDR1_MOD != null) {
                headerList.add('PV_ADRES_ADDR1__c');
            }

            // 지번주소상세
            if(mdmList[i].PV_ADRES_ADDR2 != mdmList[i].PV_ADRES_ADDR2_MOD && mdmList[i].PV_ADRES_ADDR2_MOD != null) {
                headerList.add('PV_ADRES_ADDR2__c');
            }

            // 배송관리처
            if(mdmList[i].PV_DELICUST != mdmList[i].PV_DELICUST_MOD && mdmList[i].PV_DELICUST_MOD != null) {
                headerList.add('PV_DELICUST__c');
            }

            // 판매처
            if(mdmList[i].PV_SALESCUST != mdmList[i].PV_SALESCUST_MOD && mdmList[i].PV_SALESCUST_MOD != null) {
                headerList.add('PV_SALESCUST__c');
            }

            // OnlyOneFoodNet사업장ID
            if(mdmList[i].PV_BIZPLCODE != mdmList[i].PV_BIZPLCODE_MOD && mdmList[i].PV_BIZPLCODE_MOD != null) {
                headerList.add('PV_BIZPLCODE__c');
            }

            // 매출형태
            if(mdmList[i].PV_BUSAB != mdmList[i].PV_BUSAB_MOD && mdmList[i].PV_BUSAB_MOD != null) {
                headerList.add('PV_BUSAB__c');
            }

            // 고객상태
            if(mdmList[i].PV_CESSION_KZ != mdmList[i].PV_CESSION_KZ_MOD && mdmList[i].PV_CESSION_KZ_MOD != null) {
                headerList.add('PV_CESSION_KZ__c');
            }

            // 정렬키
            if(mdmList[i].PV_ZUAWA != mdmList[i].PV_ZUAWA_MOD && mdmList[i].PV_ZUAWA_MOD != null) {
                headerList.add('PV_ZUAWA__c');
            }

            // 조정계정
            if(mdmList[i].PV_AKONT != mdmList[i].PV_AKONT_MOD && mdmList[i].PV_AKONT_MOD != null) {
                headerList.add('PV_AKONT__c');
            }

            // 현금관리그룹
            if(mdmList[i].PV_FDGRV != mdmList[i].PV_FDGRV_MOD && mdmList[i].PV_FDGRV_MOD != null) {
                headerList.add('PV_FDGRV__c');
            }

            // 입금여부(FS만 사용)
            if(mdmList[i].PV_VRSDG != mdmList[i].PV_VRSDG_MOD && mdmList[i].PV_VRSDG_MOD != null) {
                headerList.add('PV_VRSDG__c');
            }

            // 세금분류
            if(mdmList[i].PV_TAXKDD != mdmList[i].PV_TAXKDD_MOD && mdmList[i].PV_TAXKDD_MOD != null) {
                headerList.add('PV_TAXKDD__c');
            }

            // 세금납부방법
            if(mdmList[i].PV_KATR5 != mdmList[i].PV_KATR5_MOD && mdmList[i].PV_KATR5_MOD != null) {
                headerList.add('PV_KATR5__c');
            }

            // 고객분류
            if(mdmList[i].PV_CUHR1 != mdmList[i].PV_CUHR1_MOD && mdmList[i].PV_CUHR1_MOD != null) {
                headerList.add('PV_CUHR1__c');
            }

            // 고객분류 유효일자
            if(mdmList[i].PVVF_CUHR1 != mdmList[i].PVVF_CUHR1_MOD && mdmList[i].PVVF_CUHR1_MOD != null) {
                headerList.add('PVVF_CUHR1__c');
            }

            // 고객분류 적용일자
            if(mdmList[i].PVRA_CUHR1 != mdmList[i].PVRA_CUHR1_MOD && mdmList[i].PVRA_CUHR1_MOD != null) {
                headerList.add('PVRA_CUHR1__c');
            }
            
            // 가격그룹
            if(mdmList[i].PV_KONDA != mdmList[i].PV_KONDA_MOD && mdmList[i].PV_KONDA_MOD != null) {
                headerList.add('PV_KONDA__c');
            }

            // 가격그룹 유효일자
            if(mdmList[i].PVVF_KONDA != mdmList[i].PVVF_KONDA_MOD && mdmList[i].PVVF_KONDA_MOD != null) {
                headerList.add('PVVF_KONDA__c');
            }

            // 가격그룹 적용일자
            if(mdmList[i].PVRA_KONDA != mdmList[i].PVRA_KONDA_MOD && mdmList[i].PVRA_KONDA_MOD != null) {
                headerList.add('PVRA_KONDA__c');
            }

            // 단가그룹
            if(mdmList[i].PV_KVGR1 != mdmList[i].PV_KVGR1_MOD && mdmList[i].PV_KVGR1_MOD != null) {
                headerList.add('PV_KVGR1__c');
            }

            // 단가그룹 유효일자
            if(mdmList[i].PVVF_KVGR1 != mdmList[i].PVVF_KVGR1_MOD && mdmList[i].PVVF_KVGR1_MOD != null) {
                headerList.add('PVVF_KVGR1__c');
            }

            // 단가그룹 적용일자
            if(mdmList[i].PVRA_KVGR1 != mdmList[i].PVRA_KVGR1_MOD && mdmList[i].PVRA_KVGR1_MOD != null) {
                headerList.add('PVRA_KVGR1__c');
            }

            // 통화
            if(mdmList[i].PV_WAERS != mdmList[i].PV_WAERS_MOD && mdmList[i].PV_WAERS_MOD != null) {
                headerList.add('PV_WAERS__c');
            }

            // 여신관리(고객향)
            if(mdmList[i].PV_KDGRP != mdmList[i].PV_KDGRP_MOD && mdmList[i].PV_KDGRP_MOD != null) {
                headerList.add('PV_KDGRP__c');
            }

            // 납품서유형
            if(mdmList[i].PV_KVGR3 != mdmList[i].PV_KVGR3_MOD && mdmList[i].PV_KVGR3_MOD != null) {
                headerList.add('PV_KVGR3__c');
            }

            // 장려금유형
            if(mdmList[i].PV_KVGR2 != mdmList[i].PV_KVGR2_MOD && mdmList[i].PV_KVGR2_MOD != null) {
                headerList.add('PV_KVGR2__c');
            }

            // 납품서 하단유형
            if(mdmList[i].PV_KVGR3_BOT != mdmList[i].PV_KVGR3_BOT_MOD && mdmList[i].PV_KVGR3_BOT_MOD != null) {
                headerList.add('PV_KVGR2__c');
            }

            // 고객 주문마감 유형코드
            if(mdmList[i].PV_ODCLOSEGB != mdmList[i].PV_ODCLOSEGB_MOD && mdmList[i].PV_ODCLOSEGB_MOD != null) {
                headerList.add('PV_VACCPRTEXCYN__c');
            }

            // 가상계좌 출력 제외
            if(mdmList[i].PV_VACCPRTEXCYN != mdmList[i].PV_VACCPRTEXCYN_MOD && mdmList[i].PV_VACCPRTEXCYN_MOD != null) {
                headerList.add('PV_VACCPRTEXCYN__c');
            }

            // 지급조건
            if(mdmList[i].PV_ZTERM_VV != mdmList[i].PV_ZTERM_VV_MOD && mdmList[i].PV_ZTERM_VV_MOD != null) {
                headerList.add('PV_ZTERM_VV__c');
            }

            // 유통이력 신고대상 유형
            if(mdmList[i].PV_DSTRHISTREGYN != mdmList[i].PV_DSTRHISTREGYN_MOD && mdmList[i].PV_DSTRHISTREGYN_MOD != null) {
                headerList.add('PV_DSTRHISTREGYN__c');
            }

            // 약정회전일
            if(mdmList[i].PV_KULTG != mdmList[i].PV_KULTG_MOD && mdmList[i].PV_KULTG_MOD != null) {
                headerList.add('PV_KULTG__c');
            }

            // 경로(사업부)
            if(mdmList[i].PV_OLD_BIZPLACE_NEW != mdmList[i].PV_OLD_BIZPLACE_NEW_MOD && mdmList[i].PV_OLD_BIZPLACE_NEW_MOD != null) {
                headerList.add('PV_OLD_BIZPLACE_NEW__c');
            }

            // 경로(사업부) 유효일자
            if(mdmList[i].PVVF_OLD_BIZPLACE_NEW != mdmList[i].PVVF_OLD_BIZPLACE_NEW_MOD && mdmList[i].PVVF_OLD_BIZPLACE_NEW_MOD != null) {
                headerList.add('PVVF_OLD_BIZPLACE_NEW__c');
            }

            // 경로(사업부) 적용일자
            if(mdmList[i].PVRA_OLD_BIZPLACE_NEW != mdmList[i].PVRA_OLD_BIZPLACE_NEW_MOD && mdmList[i].PVRA_OLD_BIZPLACE_NEW_MOD != null) {
                headerList.add('PVRA_OLD_BIZPLACE_NEW__c');
            }

            // 외형(정원)
            if(mdmList[i].PV_SHAPE != mdmList[i].PV_SHAPE_MOD && mdmList[i].PV_SHAPE_MOD != null) {
                headerList.add('PV_SHAPE__c');
            }

            // 대면검수여부
            if(mdmList[i].PV_EXAMYN != mdmList[i].PV_EXAMYN_MOD && mdmList[i].PV_EXAMYN_MOD != null) {
                headerList.add('PV_EXAMYN__c');
            }

            // OTD(배송요구시간)
            if(mdmList[i].PV_SHIPREQTIME != mdmList[i].PV_SHIPREQTIME_MOD && mdmList[i].PV_SHIPREQTIME_MOD != null) {
                headerList.add('PV_SHIPREQTIME__c');
            }

            // 상품적재조건
            if(mdmList[i].PV_PRODLOADCOND != mdmList[i].PV_PRODLOADCOND_MOD && mdmList[i].PV_PRODLOADCOND_MOD != null) {
                headerList.add('PV_PRODLOADCOND__c');
            }

            // 반품회수 위치
            if(mdmList[i].PV_RETURNLOC != mdmList[i].PV_RETURNLOC_MOD && mdmList[i].PV_RETURNLOC_MOD != null) {
                headerList.add('PV_RETURNLOC__c');
            }

            // 차량 진입조건-1
            if(mdmList[i].PV_ENTERCOND1 != mdmList[i].PV_ENTERCOND1_MOD && mdmList[i].PV_ENTERCOND1_MOD != null) {
                headerList.add('PV_ENTERCOND1__c');
            }

            // 하역조건-1
            if(mdmList[i].PV_UNLOADCOND1 != mdmList[i].PV_UNLOADCOND1_MOD && mdmList[i].PV_UNLOADCOND1_MOD != null) {
                headerList.add('PV_UNLOADCOND1__c');
            }

            // 하역조건-2
            if(mdmList[i].PV_UNLOADCOND2 != mdmList[i].PV_UNLOADCOND2_MOD && mdmList[i].PV_UNLOADCOND2_MOD != null) {
                headerList.add('PV_UNLOADCOND2__c');
            }
            
            // 배송그룹
            if(mdmList[i].PV_DELIGROUP != mdmList[i].PV_DELIGROUP_MOD && mdmList[i].PV_DELIGROUP_MOD != null) {
                headerList.add('PV_DELIGROUP__c');
            }
            
            // 출하권역
            if(mdmList[i].PV_KATR10 != mdmList[i].PV_KATR10_MOD && mdmList[i].PV_KATR10_MOD != null) {
                headerList.add('PV_KATR10__c');
            }
            
            // 업장Key 여부
            if(mdmList[i].PV_KEYYN != mdmList[i].PV_KEYYN_MOD && mdmList[i].PV_KEYYN_MOD != null) {
                headerList.add('PV_KEYYN__c');
            }
            
            // 업장Key 정보
            if(mdmList[i].PV_KEYINFO != mdmList[i].PV_KEYINFO_MOD && mdmList[i].PV_KEYINFO_MOD != null) {
                headerList.add('PV_KEYINFO__c');
            }
            
            // KX OTD
            if(mdmList[i].PV_KXOTD != mdmList[i].PV_KXOTD_MOD && mdmList[i].PV_KXOTD_MOD != null) {
                headerList.add('PV_KXOTD__c');
            }
            
            // KX OTD 요청시간
            if(mdmList[i].PV_KXOTDTIME != mdmList[i].PV_KXOTDTIME_MOD && mdmList[i].PV_KXOTDTIME_MOD != null) {
                headerList.add('PV_KXOTDTIME__c');
            }
            
            // 초도배송 정보공유
            if(mdmList[i].PV_FDINFO != mdmList[i].PV_FDINFO_MOD && mdmList[i].PV_FDINFO_MOD != null) {
                headerList.add('PV_FDINFO__c');
            }
            
            // 초도배송 요청일자
            if(mdmList[i].PV_FDREQD != mdmList[i].PV_FDREQD_MOD && mdmList[i].PV_FDREQD_MOD != null) {
                headerList.add('PV_FDREQD__c');
            }
            
            // 초도배송 요청시간
            if(mdmList[i].PV_FDREQT != mdmList[i].PV_FDREQT_MOD && mdmList[i].PV_FDREQT_MOD != null) {
                headerList.add('PV_FDREQT__c');
            }
            
            // 초도배송 대면검수
            if(mdmList[i].PV_ISFDFTF != mdmList[i].PV_ISFDFTF_MOD && mdmList[i].PV_ISFDFTF_MOD != null) {
                headerList.add('PV_ISFDFTF__c');
            }
            
            // 초도배송 담당자 연락처
            if(mdmList[i].PV_FDCTINFO != mdmList[i].PV_FDCTINFO_MOD && mdmList[i].PV_FDCTINFO_MOD != null) {
                headerList.add('PV_FDCTINFO__c');
            }
            
            // 초도배송 시 전달사항
            if(mdmList[i].PV_FDNOTICE != mdmList[i].PV_FDNOTICE_MOD && mdmList[i].PV_FDNOTICE_MOD != null) {
                headerList.add('PV_FDNOTICE__c');
            }
            
            // 배송유형
            if(mdmList[i].PV_SHIPTYPE != mdmList[i].PV_SHIPTYPE_MOD && mdmList[i].PV_SHIPTYPE_MOD != null) {
                headerList.add('PV_SHIPTYPE__c');
            }
            
            // 온도기록지 제출 대상 여부
            if(mdmList[i].PV_TEMPTARGET != mdmList[i].PV_TEMPTARGET_MOD && mdmList[i].PV_TEMPTARGET_MOD != null) {
                headerList.add('PV_TEMPTARGET__c');
            }

        }

        // 중복 제거를 위해 set에 담아 주기
        Set<String> headerSet = new Set<String>(headerList);

        List<String> newHeaderList = new List<String>(headerSet);

        System.debug('newHeaderList => ' + newHeaderList);
        
        return newHeaderList;

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
        @AuraEnabled public Integer PV_INDEX {get;set;}
        @AuraEnabled public String PV_KUNNR {get;set;}
        @AuraEnabled public String PV_OLDCD {get;set;}
        @AuraEnabled public String PV_OLDCD_MOD {get;set;}
        @AuraEnabled public String PV_NAME1 {get;set;}
        @AuraEnabled public String PV_NAME1_MOD {get;set;}
        @AuraEnabled public String PV_NAME_G {get;set;}
        @AuraEnabled public String PV_NAME_G_MOD {get;set;}
        @AuraEnabled public String PV_NAME2 {get;set;}
        @AuraEnabled public String PV_NAME2_MOD {get;set;}
        @AuraEnabled public String PV_KTOKD {get;set;}
        @AuraEnabled public String PV_KTOKD_MOD {get;set;}
        @AuraEnabled public String PV_CUSTTYPE {get;set;}
        @AuraEnabled public String PV_CUSTTYPE_MOD {get;set;}
        @AuraEnabled public String PV_STCD2 {get;set;}
        @AuraEnabled public String PV_STCD2_MOD {get;set;}
        @AuraEnabled public String PV_STCD3 {get;set;}
        @AuraEnabled public String PV_STCD3_MOD {get;set;}
        @AuraEnabled public String PV_STCD4 {get;set;}
        @AuraEnabled public String PV_STCD4_MOD {get;set;}
        @AuraEnabled public String PV_GFORM {get;set;}
        @AuraEnabled public String PV_GFORM_MOD {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE_MOD {get;set;}
        @AuraEnabled public Boolean PV_BLCKYN {get;set;}
        @AuraEnabled public Boolean PV_BLCKYN_MOD {get;set;}
        @AuraEnabled public String PV_STCD1 {get;set;}
        @AuraEnabled public String PV_STCD1_MOD {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS_MOD {get;set;}
        @AuraEnabled public String PV_J_1KFTIND {get;set;}
        @AuraEnabled public String PV_J_1KFTIND_MOD {get;set;}
        @AuraEnabled public String PV_TELF1 {get;set;}
        @AuraEnabled public String PV_TELF1_MOD {get;set;}
        @AuraEnabled public String PV_TELFX {get;set;}
        @AuraEnabled public String PV_TELFX_MOD {get;set;}
        @AuraEnabled public String PV_PAYCUST {get;set;}
        @AuraEnabled public String PV_PAYCUST_MOD {get;set;}
        @AuraEnabled public String PV_CHARGECUST {get;set;}
        @AuraEnabled public String PV_CHARGECUST_MOD {get;set;}
        @AuraEnabled public String PV_VKGRP {get;set;}
        @AuraEnabled public String PV_VKGRP_MOD {get;set;}
        @AuraEnabled public Date PVVF_VKGRP {get;set;}
        @AuraEnabled public Date PVVF_VKGRP_MOD {get;set;}
        @AuraEnabled public Date PVRA_VKGRP {get;set;}
        @AuraEnabled public Date PVRA_VKGRP_MOD {get;set;}
        @AuraEnabled public String PV_PERNR {get;set;}
        @AuraEnabled public String PV_PERNR_MOD {get;set;}
        @AuraEnabled public Date PVVF_PERNR {get;set;}
        @AuraEnabled public Date PVVF_PERNR_MOD {get;set;}
        @AuraEnabled public Date PVRA_PERNR {get;set;}
        @AuraEnabled public Date PVRA_PERNR_MOD {get;set;}
        @AuraEnabled public String PV_ADMINMA {get;set;}
        @AuraEnabled public String PV_ADMINMA_MOD {get;set;}
        @AuraEnabled public String PV_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_LOGISCENTER_MOD {get;set;}
        @AuraEnabled public Date PVVF_LOGISCENTER {get;set;}
        @AuraEnabled public Date PVVF_LOGISCENTER_MOD {get;set;}
        @AuraEnabled public Date PVRA_LOGISCENTER {get;set;}
        @AuraEnabled public Date PVRA_LOGISCENTER_MOD {get;set;}
        @AuraEnabled public String PV_STCDT {get;set;}
        @AuraEnabled public String PV_STCDT_MOD {get;set;}
        @AuraEnabled public String PV_FITYP {get;set;}
        @AuraEnabled public String PV_FITYP_MOD {get;set;}
        @AuraEnabled public Boolean PV_HDOFFICEYN {get;set;}
        @AuraEnabled public Boolean PV_HDOFFICEYN_MOD {get;set;}
        @AuraEnabled public Boolean PV_HKUNNR {get;set;}
        @AuraEnabled public Boolean PV_HKUNNR_MOD {get;set;}
        @AuraEnabled public Boolean PV_SUBSIDIARYYN {get;set;}
        @AuraEnabled public Boolean PV_SUBSIDIARYYN_MOD {get;set;}
        @AuraEnabled public String PV_VBUND {get;set;}
        @AuraEnabled public String PV_VBUND_MOD {get;set;}
        @AuraEnabled public String PV_LIFNR {get;set;}
        @AuraEnabled public String PV_LIFNR_MOD {get;set;}
        @AuraEnabled public String PV_LAND1 {get;set;}
        @AuraEnabled public String PV_LAND1_MOD {get;set;}
        @AuraEnabled public String PV_KNVKTYPE {get;set;}
        @AuraEnabled public String PV_KNVKTYPE_MOD {get;set;}
        @AuraEnabled public Date PV_CLOSEDT {get;set;}
        @AuraEnabled public Date PV_CLOSEDT_MOD {get;set;}
        @AuraEnabled public String PV_REGIO {get;set;}
        @AuraEnabled public String PV_REGIO_MOD {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR1_MOD {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR2 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR2_MOD {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR1_MOD {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR2 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR2_MOD {get;set;}
        @AuraEnabled public String PV_DELICUST {get;set;}
        @AuraEnabled public String PV_DELICUST_MOD {get;set;}
        @AuraEnabled public String PV_SALESCUST {get;set;}
        @AuraEnabled public String PV_SALESCUST_MOD {get;set;}
        @AuraEnabled public String PV_BIZPLCODE {get;set;}
        @AuraEnabled public String PV_BIZPLCODE_MOD {get;set;}
        @AuraEnabled public String PV_BUSAB {get;set;}
        @AuraEnabled public String PV_BUSAB_MOD {get;set;}
        @AuraEnabled public String PV_CESSION_KZ {get;set;}
        @AuraEnabled public String PV_CESSION_KZ_MOD {get;set;}
        @AuraEnabled public String PV_ZUAWA {get;set;}
        @AuraEnabled public String PV_ZUAWA_MOD {get;set;}
        @AuraEnabled public String PV_AKONT {get;set;}
        @AuraEnabled public String PV_AKONT_MOD {get;set;}
        @AuraEnabled public String PV_FDGRV {get;set;}
        @AuraEnabled public String PV_FDGRV_MOD {get;set;}
        @AuraEnabled public String PV_VRSDG {get;set;}
        @AuraEnabled public String PV_VRSDG_MOD {get;set;}
        @AuraEnabled public String PV_TAXKDD {get;set;}
        @AuraEnabled public String PV_TAXKDD_MOD {get;set;}
        @AuraEnabled public String PV_KATR5 {get;set;}
        @AuraEnabled public String PV_KATR5_MOD {get;set;}
        @AuraEnabled public String PV_CUHR1 {get;set;}
        @AuraEnabled public String PV_CUHR1_MOD {get;set;}
        @AuraEnabled public Date PVVF_CUHR1 {get;set;}
        @AuraEnabled public Date PVVF_CUHR1_MOD {get;set;}
        @AuraEnabled public Date PVRA_CUHR1 {get;set;}
        @AuraEnabled public Date PVRA_CUHR1_MOD {get;set;}
        @AuraEnabled public String PV_KONDA {get;set;}
        @AuraEnabled public String PV_KONDA_MOD {get;set;}
        @AuraEnabled public Date PVVF_KONDA {get;set;}
        @AuraEnabled public Date PVVF_KONDA_MOD {get;set;}
        @AuraEnabled public Date PVRA_KONDA {get;set;}
        @AuraEnabled public Date PVRA_KONDA_MOD {get;set;}
        @AuraEnabled public String PV_KVGR1 {get;set;}
        @AuraEnabled public String PV_KVGR1_MOD {get;set;}
        @AuraEnabled public Date PVVF_KVGR1 {get;set;}
        @AuraEnabled public Date PVVF_KVGR1_MOD {get;set;}
        @AuraEnabled public Date PVRA_KVGR1 {get;set;}
        @AuraEnabled public Date PVRA_KVGR1_MOD {get;set;}
        @AuraEnabled public String PV_WAERS {get;set;}
        @AuraEnabled public String PV_WAERS_MOD {get;set;}
        @AuraEnabled public String PV_KDGRP {get;set;}
        @AuraEnabled public String PV_KDGRP_MOD {get;set;}
        @AuraEnabled public String PV_KVGR3 {get;set;}
        @AuraEnabled public String PV_KVGR3_MOD {get;set;}
        @AuraEnabled public String PV_KVGR2 {get;set;}
        @AuraEnabled public String PV_KVGR2_MOD {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT_MOD {get;set;}
        @AuraEnabled public String PV_ODCLOSEGB {get;set;}
        @AuraEnabled public String PV_ODCLOSEGB_MOD {get;set;}
        @AuraEnabled public Boolean PV_VACCPRTEXCYN {get;set;}
        @AuraEnabled public Boolean PV_VACCPRTEXCYN_MOD {get;set;}
        @AuraEnabled public String PV_ZTERM_VV {get;set;}
        @AuraEnabled public String PV_ZTERM_VV_MOD {get;set;}
        @AuraEnabled public String PV_DSTRHISTREGYN {get;set;}
        @AuraEnabled public String PV_DSTRHISTREGYN_MOD {get;set;}
        @AuraEnabled public String PV_KULTG {get;set;}
        @AuraEnabled public String PV_KULTG_MOD {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW_MOD {get;set;}
        @AuraEnabled public Date PVVF_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public Date PVVF_OLD_BIZPLACE_NEW_MOD {get;set;}
        @AuraEnabled public Date PVRA_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public Date PVRA_OLD_BIZPLACE_NEW_MOD {get;set;}
        @AuraEnabled public String PV_SHAPE {get;set;}
        @AuraEnabled public String PV_SHAPE_MOD {get;set;}
        @AuraEnabled public String PV_EXAMYN {get;set;}
        @AuraEnabled public String PV_EXAMYN_MOD {get;set;}
        @AuraEnabled public String PV_SHIPREQTIME {get;set;}
        @AuraEnabled public String PV_SHIPREQTIME_MOD {get;set;}
        @AuraEnabled public String PV_PRODLOADCOND {get;set;}
        @AuraEnabled public String PV_PRODLOADCOND_MOD {get;set;}
        @AuraEnabled public String PV_RETURNLOC {get;set;}
        @AuraEnabled public String PV_RETURNLOC_MOD {get;set;}
        @AuraEnabled public String PV_ENTERCOND1 {get;set;}
        @AuraEnabled public String PV_ENTERCOND1_MOD {get;set;}
        @AuraEnabled public String PV_UNLOADCOND1 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND1_MOD {get;set;}
        @AuraEnabled public String PV_UNLOADCOND2 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND2_MOD {get;set;}
        @AuraEnabled public String PV_DELIGROUP {get;set;}
        @AuraEnabled public String PV_DELIGROUP_MOD {get;set;}
        @AuraEnabled public String PV_KATR10 {get;set;}
        @AuraEnabled public String PV_KATR10_MOD {get;set;}
        @AuraEnabled public String PV_KEYYN {get;set;}
        @AuraEnabled public String PV_KEYYN_MOD {get;set;}
        @AuraEnabled public String PV_KEYINFO {get;set;}
        @AuraEnabled public String PV_KEYINFO_MOD {get;set;}
        @AuraEnabled public String PV_KXOTD {get;set;}
        @AuraEnabled public String PV_KXOTD_MOD {get;set;}
        @AuraEnabled public String PV_KXOTDTIME {get;set;}
        @AuraEnabled public String PV_KXOTDTIME_MOD {get;set;}
        @AuraEnabled public String PV_FDINFO {get;set;}
        @AuraEnabled public String PV_FDINFO_MOD {get;set;}
        @AuraEnabled public String PV_FDREQD {get;set;}
        @AuraEnabled public String PV_FDREQD_MOD {get;set;}
        @AuraEnabled public String PV_FDREQT {get;set;}
        @AuraEnabled public String PV_FDREQT_MOD {get;set;}
        @AuraEnabled public String PV_ISFDFTF {get;set;}
        @AuraEnabled public String PV_ISFDFTF_MOD {get;set;}
        @AuraEnabled public String PV_FDCTINFO {get;set;}
        @AuraEnabled public String PV_FDCTINFO_MOD {get;set;}
        @AuraEnabled public String PV_FDNOTICE {get;set;}
        @AuraEnabled public String PV_FDNOTICE_MOD {get;set;}
        @AuraEnabled public String PV_SHIPTYPE {get;set;}
        @AuraEnabled public String PV_SHIPTYPE_MOD {get;set;}
        @AuraEnabled public String PV_TEMPTARGET {get;set;}
        @AuraEnabled public String PV_TEMPTARGET_MOD {get;set;}
    }

}