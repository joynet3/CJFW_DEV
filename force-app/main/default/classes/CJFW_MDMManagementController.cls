/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 08-24-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-18-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMManagementController {
    /**
     * @description D
     * 
     * @return      `String`
     */
    @AuraEnabled
    public static DataWrapper setDefaultInfo(string  recordTypeName){
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';
        String MDMRecordTypeId = '';
        String strObjectType = 'MDMRegRequestCustomer';

        system.debug('>>> setDefaultInfo ' + recordTypeName);
        
        User objUser =[
            SELECT Id, LastName, EmployeeNumber FROM User
            WHERE Id =:UserInfo.getUserId()
            ];
            
            objWrapper.objUser = objUser;
            system.debug('objUser ' + JSON.serialize(objUser));
        
        if(strObjectType == 'MDMRegRequestCustomer'){
            MDMRecordTypeId = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            system.debug('>>> setDefaultInfo ' + MDMRecordTypeId);
            objWrapper.listCustomerOrderType = CommonUtil.getPickListValues('MDMRegRequestCustomer__c', 'PV_ODCLOSEGB__c', true);
            system.debug('objWrapper.listCustomerOrderType ' + objWrapper.listCustomerOrderType);
            system.debug('objWrapper.listCustomerOrderType ' + Json.serialize(objWrapper.listCustomerOrderType));
        }
        objWrapper.strStatus = strStatus;
        objWrapper.MDMRecordTypeId = MDMRecordTypeId;
        return objWrapper;
    }

    /**
     * @description 선택한 recordId를 이용해 Account정보 가져와 MDM 고객 등록 요청(관리처)에 보내주기
     * 
     * @return      `String`
     */ 
    @AuraEnabled
    public static List<AccountDataWrapper> getAccountInfo(String selectedId){
        system.debug('>>> Division Account Id ' + selectedId);
        List<AccountDataWrapper> result = new List<AccountDataWrapper>();
        //List<Account>    accList = getAccountRecord(customerId, customerName, managerMA);
        List<Account> accList = [SELECT Id
                                        , Name
                                        , NameKor__c
                                        , NameAlias__c
                                        , AccountGroup__c
                                        , Type
                                        , CompanyRegisterNumber__c
                                        , LegalStatus__c
                                        , RepresentativeName__c
                                        , RepresentativeBirthDate__c
                                        , Industry
                                        , BusinessConditions__c
                                        , Phone
                                        , PVVF_VKGRP__c
                                        , PVVF_PERNR__c
                                        , TaxInvoiceType__c
                                        , TaxationType__c
                                        , HeadOfficeCode__c
                                        , CountryKeyCode__c
                                        , LocationState__c
                                        , PostalCode__c
                                        , Address__c
                                        , Address2__c
                                        , AddressDetails2__c
                                    FROM Account 
                                    WHERE Id =: selectedId 
                                    LIMIT 1];
         if(!AccList.isEmpty()){
             for(Account acc : accList){
                 result.add(new AccountDataWrapper(acc));
             }
         }
         system.debug('>>> result ' + json.serialize(result));
        return result;
    }
    /**
     * @description 로딩시 뿌려줘야할 데이터 Wrapper
     */
    public class DataWrapper {
        /** @description 반환성공을 알려주는 Status*/
        @AuraEnabled public String strStatus {get;set;}
        /** @description 에러메세지*/
        @AuraEnabled public String strMessage {get;set;}
        /** @description 레코드아이디를 통해 알아낸 ObjectName*/
        @AuraEnabled public String strObjectType {get;set;}
         /** @description */
        @AuraEnabled public String MDMRecordTypeId {get;set;}
        /** @description */
        @AuraEnabled public List<Map<String, String>> listCustomerOrderType {get;set;}
        /** @description */
        @AuraEnabled public User objUser {get;set;}
        /** @description */
        @AuraEnabled public Opportunity objOpportunity {get;set;}
        /** @description */
        @AuraEnabled public MDMRegRequestCustomer__c objMDMRegReqCustomer {get;set;}
        /** @description */
        @AuraEnabled public List<MDMRegRequestContact__c> listMDMReqContact {get;set;}

        public DataWrapper() {}
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