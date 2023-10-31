/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkAccountSearchController {

    @AuraEnabled(cacheable=true)
    public static DataWrapper getAccountInfo(List<Map<String, String>> searchKey, String type, Integer pageNumber, Integer pageSize) {

        system.debug('### CJFW_MDMBulkAccountSearchController ###');
        system.debug('>>> getAccountInfo()');
        system.debug('>>> type ' + type);

        String searchCode = null;

        if(type == '본점') {
            searchCode = 'C01';
        } else if(type == '판매처') {
            searchCode = 'C02';
        } else if(type == '관리처-배송') {
            searchCode = 'C03';
        } else if(type == '관리처-분할') {
            searchCode = 'C04';
        } else if(type == '관리처-2차') {
            searchCode = 'C11';
        }

        // 공백 제거 (trim)
        searchCode = searchCode.replace(' ', '');

        String strStatus = 'SUCCESS';
        String strMessage = '';

        System.debug('===============> searchKey : ' + searchKey);
        System.debug('===============> searchCode : ' + searchCode);

        // Key와 Value 따로 담아 주기
        List<String> searchKeys = new List<String>();
        List<String> searchValues = new List<String>();
        Map<String, String> dateValues = new Map<String, String>();

        for(Map<String, String> data : searchKey) {

            String apiType = data.get('type');
            String fieldName = data.get('fieldName');
            String datePoint = data.get('datePoint');
            String searchWord = data.get('searchKey');

            System.debug('## get param > ' + 'fieldName: ' + fieldName + ', apiType: ' + apiType + ', datePoint: ' + datePoint + ', searchWord: ' + searchWord);

            if(searchWord != null) {
                searchWord = searchWord.trim();
            }

            if(searchWord != null && searchWord.length() > 0 && fieldName != 'CreatedDate') {
                searchKeys.add(fieldName);
                searchValues.add(searchWord);
            } else if(searchWord != null && searchWord.length() > 0 && fieldName == 'CreatedDate') {
                searchWord = searchWord + 'T00:00:00.000+0000'; // UTC
                dateValues.put(datePoint, searchWord);
            }

        }

        System.debug('===============> searchKeys : ' + searchKeys);
        System.debug('===============> searchValues : ' + searchValues);
        System.debug('===============> dateValues : ' + dateValues);

        DataWrapper objWrapper = new DataWrapper();
        
        try {

            List<Account> searchResult = new List<Account>(); // 분할해서 담은
            List<Account> listSearchResult = new List<Account>(); // 모두 담은

            String strQuery = 'SELECT Id, CustomerID__c, Name, Owner.Name, CustomerIDASIS__c, NameKor__c, NameAlias__c, AccountGroup__c, toLabel(AccountGroup__c) AccountGroupLabel, ';
            strQuery += ' CustomerType__c, toLabel(CustomerType__c) CustomerTypeLabel, CompanyRegisterNumber__c, 	CorporateCode__c, 	SubCompanyRegisterNumber__c, TaxationType__c, toLabel(TaxationType__c) TaxationTypeLabel, ';
            strQuery += ' LegalStatus__c, toLabel(LegalStatus__c) LegalStatusLabel, RepresentativeName__c, PV_BLCKYN__c,	RepresentativeBirthDate__c, BusinessConditions__c, BusinessCategory__c, ';
            strQuery += ' Phone, Fax, PaymentAccountCode__c, PaymentAccountName__c, ShippingAccountCode__c, ShippingAccountName__c, PV_VKGRP__c, toLabel(PV_VKGRP__c) PV_VKGRP__LABEL, ';
            strQuery += ' PVVF_VKGRP__c, SalesGroupFromDate__c, OwnerId, PVVF_PERNR__c, ResponsibilityMAFromDate__c, ResponsibilityAMA__c, TaxInvoiceType__c, toLabel(TaxInvoiceType__c) TaxInvoiceLabel, ';
            strQuery += ' IsHeadShopUseYN__c, HeadOfficeCode__c, IsAffiliatedcompanyYN__c, AffiliatedCompany__c, toLabel(AffiliatedCompany__c) AffiliatedCompanyLabel, CountryKeyCode__c, toLabel(CountryKeyCode__c) CountryKeyCodeLabel, ';
            strQuery += ' PV_KNVKTYPE__c, toLabel(PV_KNVKTYPE__c) PV_KNVKTYPE__LABEL, ShutDownDate__c, LocationState__c, toLabel(LocationState__c) LocationStateLabel, Address__c, AddressDetails__c, ';
            strQuery += ' Address2__c, AddressDetails2__c, SalesForm__c, toLabel(SalesForm__c) SalesFormLabel, AccountStatus__c, toLabel(AccountStatus__c) AccountStatusLabel, SortKey__c, toLabel(SortKey__c) SortKeyLabel, ';
            strQuery += ' MediateAccount__c, toLabel(MediateAccount__c) MediateAccountLabel, CashManagementGroup__c, toLabel(CashManagementGroup__c) CashManagementGroupLabel, IsDeposit__c, toLabel(IsDeposit__c) IsDepositLabel, ';
            strQuery += ' TaxClassification__c, toLabel(TaxClassification__c) TaxClassificationLabel, TaxPaymentMethod__c, toLabel(TaxPaymentMethod__c) TaxPaymentMethodLabel, CustomerRoute__c, toLabel(CustomerRoute__c) CustomerRouteLabel, ';
            strQuery += ' PV_CUHR1__c, CustomerRouteFromDate__c, PriceGroup__c, toLabel(PriceGroup__c) PriceGroupLabel, PVVF_KONDA__c, PriceGroupFromDate__c,  UnitPriceGroup__c, toLabel(UnitPriceGroup__c) UnitPriceGroupLabel, PVVF_KVGR1__c, UnitPriceGroupFromDate__c, CurrencyIsoCode, ';
            strQuery += ' toLabel(CurrencyIsoCode) CurrencyIsoLabel, CreditManagement__c, toLabel(CreditManagement__c) CreditManagementLabel, StatementOfDeliveryType__c, toLabel(StatementOfDeliveryType__c) StatementOfDeliveryTypeLabel, SubsidyType__c, toLabel(SubsidyType__c) SubsidyTypeLabel, ';
            strQuery += ' StatementOfDeliveryType2__c, toLabel(StatementOfDeliveryType2__c) StatementOfDeliveryType2Label, CustomerOrderDeadlineType__c, toLabel(CustomerOrderDeadlineType__c) CustomerOrderDeadlineTypeLabel, IsPrintVirtualAccount__c, ';
            strQuery += ' TermsOfPayment__c, toLabel(TermsOfPayment__c) TermsOfPaymentLabel, DisHisRegType__c, toLabel(DisHisRegType__c) DisHisRegTypeLabel, ContractRocationDate__c, CustomerPath__c, toLabel(CustomerPath__c) CustomerPathLabel, PVVF_OLD_BIZPLACE_NEW__c, CustomerPathFromDate__c, ';
            strQuery += ' Shape__c, IsFaceToFaceInspectionStatus__c, OTD__c, ProductLoadingCondition__c, ReturnLocation__c, VehicleEntryCondtions__c, toLabel(VehicleEntryCondtions__c) VehicleEntryCondtionsLabel, DeliveryGroup__c, toLabel(DeliveryGroup__c) DeliveryGroupLabel, ';
            strQuery += ' UnloadConditions1__c, toLabel(UnloadConditions1__c) UnloadConditions1Label, UnloadConditions2__c, toLabel(UnloadConditions2__c) UnloadConditions2Label, ShipmentArea__c, toLabel(ShipmentArea__c) ShipmentAreaLabel, ';
            strQuery += ' IsBusinessPlaceKey__c, BusinessPlaceKeyInfo__c, KXOTD__c, toLabel(KXOTD__c) KXOTDLabel, KXOTDRequestDate__c, InitialDeliveryShare__c, toLabel(InitialDeliveryShare__c) InitialDeliveryShareLabel, InitialDeliveryRequestDate__c, ';
            strQuery += ' InitialDeliveryRequestTime__c, IsInitialDeliveryFTFInspection__c, InitialDeliveryContact__c, InitialDeliveryDescription__c, PV_SHIPTYPE__c, toLabel(PV_SHIPTYPE__c) PV_SHIPTYPE__LABEL, PV_TEMPTARGET__c, toLabel(PV_TEMPTARGET__c) PV_TEMPTARGET__LABEL, ';
            strQuery += ' PV_SALESCUST__c, PV_DELICUST__c, PV_BIZPLCODE__c ';
            strQuery += ' FROM    Account';
            strQuery += ' WHERE   CustomerType__c IN ( \'' + searchCode + '\' ) AND CustomerId__c != NULL ';
            for(Integer i = 0; i < searchKeys.size(); i++) {
                if(searchKeys[i] == 'OwnerId') {
                    strQuery += ' AND ' + searchKeys[i] + ' = \'' + searchValues[i] + '\'';
                } else {
                    strQuery += ' AND ' + searchKeys[i] + ' LIKE \'%' + searchValues[i] + '%\' ';
                }
            }
            if(dateValues.size() > 0) {
                if(dateValues.get('start') != null) {
                    strQuery += ' AND CreatedDate >= ' + dateValues.get('start');
                } else if(dateValues.get('end') != null) {
                    strQuery += ' AND CreatedDate <= ' + dateValues.get('end');
                }
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