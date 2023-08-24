/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 08-24-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-24-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMReferenceCreateController {
    /**
     * @description 참조생성 모달 로딩 시, Default 데이터 (Account데이터 10개)
     * 
     * @return      `String`
     */ 
    @AuraEnabled
    public static List<DataWrapper> doInit(){
        system.debug('doInit!!!');
        List<DataWrapper> result = new List<DataWrapper>();

        List<Account> accList = doSelect(null, null, null);

        if(!AccList.isEmpty()) {
            for(Account acc : accList){
                result.add(new DataWrapper(acc));
            }
        }
        return result;
    }
     /**
     * @description 참조생성 모달 > 검색어 입력 후 검색 > 검색어로 Like 
     * 
     * @return      `String`
     */ 
    @AuraEnabled
    public static List<DataWrapper> doSearch(String customerId, String customerName, String managerMA){
        List<DataWrapper> result = new List<DataWrapper>();
        List<Account>    accList = doSelect(customerId, customerName, managerMA);

        if(!AccList.isEmpty()){
            for(Account acc : accList){
                result.add(new DataWrapper(acc));
            }
        }
        return result;
    }

    // 기본조회
    public static List<Account> doSelect(String customerId, String customerName, String managerMA ){
        String S_SELECT = '';
        S_SELECT  ='  SELECT ' 
                  +'  id '
                  +' ,CustomerID__c ' 
                  +' ,Name ' 
                  +' ,CompanyRegisterNumber__c ' 
                  +' ,fm_SalesGroup__c ' 
                  +' ,CustomerRoute__c ' 
                  +' ,Owner.Name ' 
                  +' ,AccountStatus__c ' 
                  +' ,CustomerIDASIS__c ' 
                  +' ,CreatedDate ' 
                  +' ,FWReleaseCenter__c ' 
                  +' ,DisHisRegType__c ' 
                  +' FROM Account ';
            
        String S_WHERE  = ' WHERE CustomerID__c != null';
        system.debug('doSearch');

        if(String.isNotBlank(customerId) || String.isNotBlank(customerName) || String.isNotBlank(managerMA)){
            String pSearchLike = '';

            if(String.isNotBlank(customerId)) {
                pSearchLike = '%' + customerId + '%';
                S_WHERE += ' AND CustomerID__c Like : pSearchLike' ;
            }
            if(String.isNotBlank(customerName)) {
                system.debug('customerName 잘 들어옵니까 ' + customerName);
                pSearchLike = '%' + customerName + '%';
                S_WHERE += ' AND Name Like : pSearchLike' ;
            }
            if(String.isNotBlank(managerMA)) {
                pSearchLike = '%' + managerMA + '%';
                S_WHERE += ' AND Owner.Name Like : pSearchLike' ;
            }
        }

        //String S_ORDER  = ' ORDER BY NAME ASC '; //나중에 검색 조건이 생기면 그때 추가 할 예정임
        
        String S_LIMITS = ' LIMIT 10';
                                        // S_ORDER +
        system.debug(S_SELECT + S_WHERE +  S_LIMITS);
                                                // S_ORDER +
        return Database.query(S_SELECT + S_WHERE +  S_LIMITS);
    }

    /** 
     * @description 참조생성 모달 List Data
     */
    public class DataWrapper { 
        @AuraEnabled public String id{get;set;}                    // Account Object Id 
        @AuraEnabled public String customerID{get;set;}            // 고객ID 
        @AuraEnabled public String name{get;set;}                  // 고객명(영문명포함) 
        @AuraEnabled public String companyRegisterNumber{get;set;} // 사업자등록번호 
        @AuraEnabled public String fm_SalesGroup{get;set;}         // 영업그룹 
        @AuraEnabled public String customerRoute{get;set;}         // 고객분류 
        @AuraEnabled public String ownerName{get;set;}             // 담당MA 
        @AuraEnabled public String accountStatus{get;set;}         // 고객상태 
        @AuraEnabled public String customerIDASIS{get;set;}        // 구코드(AS-IS) 
        @AuraEnabled public Date   createdDate{get;set;}           // 등록일시 
        @AuraEnabled public String fWReleaseCenter{get;set;}       // FW출고센터 
        @AuraEnabled public String disHisRegType{get;set;}         // 유통이력신고대상유형 

        public DataWrapper(){}
        public DataWrapper(Account acc) {
            this.id                     = acc.Id;
            this.customerID             = acc.CustomerID__c;
            this.name                   = acc.Name;
            this.companyRegisterNumber  = acc.CompanyRegisterNumber__c;
            this.fm_SalesGroup          = acc.fm_SalesGroup__c;
            this.customerRoute          = acc.CustomerRoute__c;
            this.ownerName              = acc.Owner.Name;
            this.accountStatus          = acc.AccountStatus__c;
            this.customerIDASIS         = acc.CustomerIDASIS__c;
            this.createdDate            = Date.valueOf(acc.CreatedDate);
            this.fWReleaseCenter        = acc.FWReleaseCenter__c;
            this.disHisRegType          = acc.DisHisRegType__c;
        }
    }

    /** 
     * @description 참조생성 모달에서 선택한 Account Data Wrapper
     */
    public class AccountDataWrapper { 
        @AuraEnabled public String id{get;set;}                                   // 판매처 
        @AuraEnabled public String name{get;set;}                                 // 고객명(영문명포함)
        @AuraEnabled public String nameKor{get;set;}                              // 고객명(G)/자국명 
        @AuraEnabled public String nameAlias{get;set;}                            // 고객약칭명(변경)
        @AuraEnabled public String accountGroup{get;set;}                         // 고객계정그룹
        @AuraEnabled public String type{get;set;}                                 // 고객유형
        @AuraEnabled public String companyRegisterNumber{get;set;}                // 사업자등록번호
        @AuraEnabled public String legalStatus{get;set;}                          // 법적상태
        @AuraEnabled public String representativeName{get;set;}                   // 대표자이름 
        @AuraEnabled public String representativeBirthDate{get;set;}              // 대표자생년월일
        @AuraEnabled public String industry{get;set;}                             // 업태
        @AuraEnabled public String businessConditions{get;set;}                   // 업종
        @AuraEnabled public String phone{get;set;}                                // 업태 
        @AuraEnabled public Date   pVVF_VKGRP{get;set;}                           // 전화번호
        @AuraEnabled public Date   pVVF_PERNR{get;set;}                           // 영업그룹유효일자 
        @AuraEnabled public String taxInvoiceType{get;set;}                       // 담당MA유효일자
        @AuraEnabled public String taxationType{get;set;}                         // 세금계산서발행유형
        @AuraEnabled public String headOfficeCode{get;set;}                       // 과세유형
        @AuraEnabled public String countryKeyCode{get;set;}                       // 본점코드
        @AuraEnabled public String locationState{get;set;}                        // 국가
        @AuraEnabled public String postalCode{get;set;}                           // 지역 
        @AuraEnabled public String address{get;set;}                              // 우편번호
        @AuraEnabled public String address2{get;set;}                             // 도로명주소
        @AuraEnabled public String addressDetails2{get;set;}                      // 지번주소

        public AccountDataWrapper(){}
        public AccountDataWrapper(Account acc) {
            this.id                                   = acc.Id;
            this.name                                 = acc.Name;
            this.nameKor                              = acc.NameKor__c;
            this.nameAlias                            = acc.NameAlias__c;
            this.accountGroup                         = acc.AccountGroup__c;
            this.type                                 = acc.Type;
            this.companyRegisterNumber                = acc.CompanyRegisterNumber__c;
            this.legalStatus                          = acc.LegalStatus__c;
            //this.representativeName                   = acc.RepresentativeName__c;
            this.representativeBirthDate              = acc.RepresentativeBirthDate__c;
            this.industry                             = acc.Industry;
            this.businessConditions                   = acc.BusinessConditions__c;
            this.phone                                = acc.Phone;
            this.pVVF_VKGRP                           = Date.valueOf(acc.PVVF_VKGRP__c);
            this.pVVF_PERNR                           = Date.valueOf(acc.PVVF_PERNR__c);
            this.taxInvoiceType                       = acc.TaxInvoiceType__c;
            this.taxationType                         = acc.TaxationType__c;
            this.headOfficeCode                       = acc.HeadOfficeCode__c;
            this.countryKeyCode                       = acc.CountryKeyCode__c;
            this.locationState                        = acc.LocationState__c;
            //this.postalCode                           = acc.PostalCode__c;
            this.address                              = acc.Address__c;
            this.address2                             = acc.Address2__c;
            this.addressDetails2                      = acc.AddressDetails2__c;
        }
    }
}