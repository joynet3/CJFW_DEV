/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   11-06-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMAccountSearchController { 
    
    @AuraEnabled(cacheable=true)
    public static String getCookieValueFromService() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://external-service-url.com/get-cookie');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        return response.getBody();
    }

    @AuraEnabled(cacheable=true)
    public static DataWrapper getAccountInfo(List<Map<String, String>> searchKey, String selectedcustomerType, Integer pageNumber, Integer pageSize) {

        system.debug('### CJFW_MDMAccountSearchController ###');
        system.debug('>>> getAccountInfo()');
        system.debug('>>> selectedcustomerType ' + selectedcustomerType);


        String strStatus = 'SUCCESS';
        String strMessage = '';

        System.debug('===============> searchKey : ' + searchKey);

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
                system.debug('searchKeys ' + searchKeys);
                system.debug('searchValues ' + searchValues);
            } else if(searchWord != null && searchWord.length() > 0 && fieldName == 'CreatedDate') {
                searchWord = searchWord + 'T00:00:00.000+0000'; // UTC
                dateValues.put(datePoint, searchWord);
                system.debug('searchWord ' + searchWord);
            }

        }

        System.debug('===============> searchKeys : ' + searchKeys);
        System.debug('===============> searchValues : ' + searchValues);
        System.debug('===============> dateValues : ' + dateValues);

        DataWrapper objWrapper = new DataWrapper();
        
        try {

            List<Account> searchResult = new List<Account>(); // 분할해서 담은
            List<Account> listSearchResult = new List<Account>(); // 모두 담은

            String strQuery = 'SELECT Id, CustomerID__c, Name, Owner.Name, CustomerIDASIS__c, NameKor__c, NameAlias__c, AccountGroup__c, toLabel(AccountGroup__c) AccountGroupLabel, CustomerStatus__c, toLabel(CustomerStatus__c) CustomerStatusLabel, ';
            strQuery += ' CustomerType__c, toLabel(CustomerType__c) CustomerTypeLabel, CompanyRegisterNumber__c, 	CorporateCode__c, 	SubCompanyRegisterNumber__c, TaxationType__c, toLabel(TaxationType__c) TaxationTypeLabel, ';
            strQuery += ' LegalStatus__c, toLabel(LegalStatus__c) LegalStatusLabel, RepresentativeName__c, PV_BLCKYN__c,	RepresentativeBirthDate__c, BusinessConditions__c, BusinessCategory__c, FWReleaseCenter__c, toLabel(FWReleaseCenter__c) FWReleaseCenterLabel, ';
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
            strQuery += ' WHERE   CustomerType__c IN ( \'' + selectedcustomerType + '\' ) AND CustomerId__c != NULL ';
            for(Integer i = 0; i < searchKeys.size(); i++) {
                if(searchKeys[i] == 'OwnerId') {
                    strQuery += ' AND ' + searchKeys[i] + ' = \'' + searchValues[i] + '\'';
                }else if(searchKeys[i] == 'Name'){
                    strQuery += ' AND (Name LIKE \'%' + searchValues[i]+ '%\' OR CustomerId__c LIKE \'%' + searchValues[i] + '%\') ';
                    system.debug('serchKeys[i] == Name ' +' AND (Name LIKE \'%' + searchValues[i]+ '%\' OR CustomerId__c LIKE \'%' + searchValues[i] + '%\') ');
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

            System.debug('결과 => ' + json.serialize(searchResult));

            objWrapper.listSearchResult = listSearchResult;
            objWrapper.totalCnt = listSearchResultSize;
            system.debug('listSearchResult ' + Json.serialize(listSearchResult));
            
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    
    /**
     * @description : 화면에서 Param으로 보내준 AccountId로 customer 필드를 조회하여, 리턴
     *                customer 타입에 따라 화면을 분기 처리해 주기 위함.
     *
     * @return      `String`
     */
    @AuraEnabled
    public static DataWrapper getCustomerTypeInfo(Id recordId) {
        DataWrapper objWrapper = new DataWrapper();
        system.debug(' ###CJFW_MDMReferenceCreateController > getCustomerTypeInfo()');

        String customerType = '';
        
    
        system.debug(' ====================================> Account조회해서 CustomerType__c이 무엇인지 확인 후 리턴해야 함');
        List<Account> accountList = [SELECT Id, customerType__c
                                    FROM Account
                                    WHERE Id =: recordId
                                    LIMIT 1];

        List<Contact> listContact = [
            SELECT Id, AccountId  FROM Contact WHERE AccountId =:recordId
        ];

        if(listContact <> null && listContact.size() > 0) {
            objWrapper.isContact = true;
        }
        
        if(!accountList.isEmpty()) {
            objWrapper.customerType = accountList[0]?.customerType__c;
            system.debug(' ====================================> accountList[0]?.customerType__c ' + accountList[0]?.customerType__c);
        }
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
        /** @description 레코드아이디를 통해 알아낸 고객유형*/
        @AuraEnabled public String customerType {get;set;}
        /** @description Object Name*/
        @AuraEnabled public String strObjectType {get;set;}
        /** @description Object Name*/
        @AuraEnabled public Boolean isContact {get;set;}

	}

    
     /**
     * @description 참조생성 모달 > 검색어 입력 후 검색 > 검색어로 Like 
     * 
     * @return      `String`
     */ 
    // @AuraEnabled
    // public static List<DataWrapper> doSearch(String customerId, String customerName, String managerMA, String customerType){
    //     List<DataWrapper> result = new List<DataWrapper>();
    //     List<Account>    accList = doSelect(customerId, customerName, managerMA, customerType);

    //     if(!AccList.isEmpty()){
    //         for(Account acc : accList){
    //             result.add(new DataWrapper(acc));
    //         }
    //     }
    //     return result;
    // }

    // // 기본조회
    // public static List<Account> doSelect(String customerId, String customerName, String managerMA, String customerType){
    //     system.debug('customerId '   + customerId);
    //     system.debug('customerName ' + customerName);
    //     system.debug('managerMA '    + managerMA);
    //     system.debug('customerType ' + customerType);
    
    //     String S_SELECT = '';
    //     S_SELECT  ='  SELECT ' 
    //               +'  id '
    //               +' ,CustomerType__c '
    //               +' ,CustomerID__c ' 
    //               +' ,Name ' 
    //               +' ,CompanyRegisterNumber__c ' 
    //               +' ,fm_SalesGroup__c ' 
    //               +' ,CustomerRoute__c ' 
    //               +' ,Owner.Name ' 
    //               +' ,AccountStatus__c ' 
    //               +' ,CustomerIDASIS__c ' 
    //               +' ,CreatedDate ' 
    //               +' ,FWReleaseCenter__c ' 
    //               +' ,DisHisRegType__c ' 
    //               +' FROM Account ';
            
    //     String S_WHERE  = ' WHERE   CustomerType__c IN ( \'' + customerType + '\' ) AND CustomerId__c != NULL ';

    //     system.debug('doSearch');

    //     if(String.isNotBlank(customerId) || String.isNotBlank(customerName) || String.isNotBlank(managerMA)){
            
    //         if(String.isNotBlank(customerId)) {
    //             String pSearchCustomerId = '%' + customerId + '%';
    //             S_WHERE += ' AND CustomerID__c Like :pSearchCustomerId' ;
    //         }
    //         if(String.isNotBlank(customerName)) {
    //             system.debug('customerName 잘 들어옵니까 ' + customerName);
    //             String pSearchCustomerName = '%' + customerName + '%';
    //             S_WHERE += ' AND Name Like :pSearchCustomerName' ;
    //         }
    //         if(String.isNotBlank(managerMA)) {
    //             String pSearchManagerMA = '%' + managerMA + '%';
    //             S_WHERE += ' AND Owner.Name Like :pSearchManagerMA' ;
    //         }
    //     }
    //     //String S_ORDER  = ' ORDER BY NAME ASC '; //나중에 검색 조건이 생기면 그때 추가 할 예정임
        
    //     String S_LIMITS = ' ';
    //                                     // S_ORDER +
    //     system.debug(S_SELECT + S_WHERE +  S_LIMITS);
    //                                             // S_ORDER +
    //     return Database.query(S_SELECT + S_WHERE +  S_LIMITS);
    // }

    /** 
     * @description 참조생성 모달 List Data
     */
    // public class DataWrapper { 
    //     @AuraEnabled public String id{get;set;}                    // Account Object Id 
    //     @AuraEnabled public String customerID{get;set;}            // 고객ID 
    //     @AuraEnabled public String customerType{get;set;}          // 고객유형 
    //     @AuraEnabled public String name{get;set;}                  // 고객명(영문명포함) z
    //     @AuraEnabled public String companyRegisterNumber{get;set;} // 사업자등록번호 
    //     @AuraEnabled public String fm_SalesGroup{get;set;}         // 영업그룹 
    //     @AuraEnabled public String customerRoute{get;set;}         // 고객분류 
    //     @AuraEnabled public String ownerName{get;set;}             // 담당MA 
    //     @AuraEnabled public String accountStatus{get;set;}         // 고객상태 
    //     @AuraEnabled public String customerIDASIS{get;set;}        // 구코드(AS-IS) 
    //     @AuraEnabled public Date   createdDate{get;set;}           // 등록일시 
    //     @AuraEnabled public String fWReleaseCenter{get;set;}       // FW출고센터 
    //     @AuraEnabled public String disHisRegType{get;set;}         // 유통이력신고대상유형 

    //     public DataWrapper(){}
    //     public DataWrapper(Account acc) {
    //         system.debug('acc ' + acc);
    //         this.id                     = acc.Id;
    //         this.customerID             = acc.CustomerID__c;
    //         this.customerType           = acc.CustomerType__c;
    //         this.name                   = acc.Name;
    //         this.companyRegisterNumber  = acc.CompanyRegisterNumber__c;
    //         this.fm_SalesGroup          = acc.fm_SalesGroup__c;
    //         this.customerRoute          = acc.CustomerRoute__c;
    //         this.ownerName              = acc.Owner.Name;
    //         this.accountStatus          = acc.AccountStatus__c;
    //         this.customerIDASIS         = acc.CustomerIDASIS__c;
    //         this.createdDate            = Date.valueOf(acc.CreatedDate);
    //         this.fWReleaseCenter        = acc.FWReleaseCenter__c;
    //         this.disHisRegType          = acc.DisHisRegType__c;
    //     }
    // }


}