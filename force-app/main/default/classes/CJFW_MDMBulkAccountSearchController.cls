/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkAccountSearchController {

    @AuraEnabled(cacheable=true)
    public static DataWrapper getAccountInfo(String searchWord, String type, Integer pageNumber, Integer pageSize) {

        system.debug('### CJFW_MDMBulkAccountSearchController ###');
        system.debug('>>> getAccountInfo()');
        system.debug('>>> searchWord ' + searchWord);
        system.debug('>>> type ' + type);

        String searchCode = null;

        if(type == '본점') {
            searchCode = 'C01';
        } else if(type == '판매처') {
            searchCode = 'C02';
        } else if(type == '관리처') {
            searchCode = 'C03\', \'C04\', \'C11';
        }

        searchCode = searchCode.replace(' ', '');

        String[] codeList = searchCode.split(',');

        String strStatus = 'SUCCESS';
        String strMessage = '';

        System.debug('===============> searchWord : '+searchWord);
        System.debug('===============> searchCode : '+searchCode);

        DataWrapper objWrapper = new DataWrapper();

        
        try {

            List<Account> searchResult = new List<Account>(); // 분할해서 담은
            List<Account> listSearchResult = new List<Account>(); // 모두 담은

            String strQuery = 'SELECT Id, CustomerID__c, Name, Owner.Name, CustomerIDASIS__c, NameKor__c, NameAlias__c, AccountGroup__c, toLabel(AccountGroup__c) AccountGroupLabel, ';
            strQuery += ' CustomerType__c, toLabel(CustomerType__c) CustomerTypeLabel, CompanyRegisterNumber__c, 	CorporateCode__c, 	SubCompanyRegisterNumber__c, ';
            strQuery += ' LegalStatus__c, toLabel(LegalStatus__c) LegalStatusLabel, RepresentativeName__c, PV_BLCKYN__c,	RepresentativeBirthDate__c, BusinessConditions__c, BusinessCategory__c, ';
            strQuery += ' Phone, Fax, PaymentAccountCode__c, PaymentAccountName__c, ShippingAccountCode__c, ShippingAccountName__c, PV_VKGRP__c, toLabel(PV_VKGRP__c) PV_VKGRP__LABEL, ';
            strQuery += ' PVVF_VKGRP__c, SalesGroupFromDate__c, OwnerId, PVVF_PERNR__c, ResponsibilityMAFromDate__c, ResponsibilityAMA__c, TaxInvoiceType__c, toLabel(TaxInvoiceType__c) TaxInvoiceLabel, ';
            strQuery += ' IsHeadShopUseYN__c, IsAffiliatedcompanyYN__c, AffiliatedCompany__c, toLabel(AffiliatedCompany__c) AffiliatedCompanyLabel, CountryKeyCode__c, toLabel(CountryKeyCode__c) CountryKeyCodeLabel, ';
            strQuery += ' PV_KNVKTYPE__c, toLabel(PV_KNVKTYPE__c) PV_KNVKTYPE__LABEL, ShutDownDate__c, LocationState__c, toLabel(LocationState__c) LocationStateLabel, Address__c, AddressDetails__c, ';
            strQuery += ' Address2__c, AddressDetails2__c, SalesForm__c, toLabel(SalesForm__c) SalesFormLabel, AccountStatus__c, toLabel(AccountStatus__c) AccountStatusLabel, SortKey__c, toLabel(SortKey__c) SortKeyLabel, ';
            strQuery += ' MediateAccount__c, toLabel(MediateAccount__c) MediateAccountLabel, CashManagementGroup__c, toLabel(CashManagementGroup__c) CashManagementGroupLabel, IsDeposit__c, toLabel(IsDeposit__c) IsDepositLabel, ';
            strQuery += ' TaxClassification__c, toLabel(TaxClassification__c) TaxClassificationLabel, TaxPaymentMethod__c, toLabel(TaxPaymentMethod__c) TaxPaymentMethodLabel, CustomerRoute__c, toLabel(CustomerRoute__c) CustomerRouteLabel, ';
            strQuery += ' PV_CUHR1__c, CustomerRouteFromDate__c, PriceGroup__c, toLabel(PriceGroup__c) PriceGroupLabel, UnitPriceGroup__c, toLabel(UnitPriceGroup__c) UnitPriceGroupLabel, CurrencyIsoCode, ';
            strQuery += ' toLabel(CurrencyIsoCode) CurrencyIsoLabel, CreditManagement__c, toLabel(CreditManagement__c) CreditManagementLabel, SubsidyType__c, toLabel(SubsidyType__c) SubsidyTypeLabel, ';
            strQuery += ' IsPrintVirtualAccount__c, TermsOfPayment__c, toLabel(TermsOfPayment__c) TermsOfPaymentLabel, DisHisRegType__c, toLabel(DisHisRegType__c) DisHisRegTypeLabel, ContractRocationDate__c, ';
            strQuery += ' CustomerPath__c, toLabel(CustomerPath__c) CustomerPathLabel, Shape__c, DeliveryGroup__c, toLabel(DeliveryGroup__c) DeliveryGroupLabel ';
            strQuery += ' FROM    Account';
            strQuery += ' WHERE   CustomerType__c IN ( \'' + searchCode + '\' ) AND CustomerId__c != NULL ';
            if(searchWord <> null) {
                strQuery += ' AND     (Name LIKE \'%' + searchWord + '%\' OR Owner.Name LIKE \'%' + searchWord + '%\')';
            }

            System.debug('============> strQuery : '+strQuery);
            
            listSearchResult = Database.query(strQuery);

            Integer listSearchResultSize = listSearchResult.size();

            Integer startIndex = (pageNumber - 1) * pageSize;
            Integer endIndex = Math.min(startIndex + pageSize, listSearchResultSize);

            if(endIndex > startIndex){
                for (Integer i = startIndex; i < endIndex; i++) {
                    searchResult.add(listSearchResult[i]);
                }
            }

            objWrapper.searchResult = searchResult;

            System.debug('결과 => ' + searchResult);

            objWrapper.listSearchResult = listSearchResult;
            objWrapper.totalCnt = listSearchResultSize;
            
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    public class DataWrapper {

		@AuraEnabled
        public String strStatus {get;set;}

        @AuraEnabled
        public String strMessage {get;set;}

        @AuraEnabled
        public List<Account> searchResult {get;set;}

        @AuraEnabled
        public List<Account> listSearchResult {get;set;}

        @AuraEnabled
        public Integer totalCnt {get;set;}

        @AuraEnabled
        public String code {get;set;}

        @AuraEnabled
        public String inputId {get;set;}

        @AuraEnabled
        public String inputTextLabel {get;set;}

	}

}