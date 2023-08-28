/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 08-28-2023
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
        List<Account> accList = [SELECT 
                                          Name                            // 고객명(영문명포함)
                                        , NameAlias__c                    // 고객약칭명(변경)
                                        , CustomerType__c                 //고객유형
                                        , LegalStatus__c                  //법적상태
                                        , BusinessCategory__c             //업종
                                        , TaxInvoiceType__c               // 세금계산서발행유형
                                        , PostalCode__c                   //우편번호
                                        , Address__c                      //도로명 주소
                                        , Id                              //판매처
                                        , NameKor__c                      //고객명(G)/자국명
                                        , AccountGroup__c                 //고객계정그룹
                                        , CompanyRegisterNumber__c        //사업자등록번호
                                        , RepresentativeName__c           //대표자이름
                                        , BusinessConditions__c           //업태
                                        , Phone                           //전화번호
                                        , HeadOfficeCode__c               //본점코드
                                        , LocationState__c                //지역
                                        , SubsidyType__c                  //장려금유형
                                        , CustomerOrderDeadlineType__c    // 고객 주문마감 유형 (값 네임, api 코드인듯)
                                        , TermsOfPayment__c               //지급조건
                                        , CustomerPath__c                 //경로사업부
                                        , ShipmentArea__c                 //출하권역
                                        , StatementOfDeliveryType__c      //납품서유형
                                        , StatementOfDeliveryType2__c     //납품서하단유형
                                        , DisHisRegType__c                //유통이력 신고대상 유형
                                        , DeliveryGroup__c                // 배송그룹
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
     * @description 세금계산서 발행 Tab의 to발행일자 오늘날짜로 Setting
     *
     * @return      `Date`
     */
    @AuraEnabled
    public static Date getFirstDayOfMonthDate() {
        Date result = System.today();

        return result;
    }

        /**
     * 주소정보 API 조회
     * 
     * @params sSearchKey : 조회 키워드
     * @params intCntPerPage : 현재 페이지
     * @params intCurrentPage : 페이지당 출력할 결과 Row 수
     * @return WrapperResponse : 조회된 결과
     *
    **/
   @AuraEnabled
   public static WrapperResponse doSearchAddress(String sSearchKey, Integer intCntPerPage, Integer intCurrentPage) {
       WrapperResponse objResponse = new WrapperResponse();

       IF_RELAY_INFO__c objRelayInfo = IF_RELAY_INFO__c.getOrgDefaults();

       // Interface parameter 생성
       DN_AddrSearch_wb.Input objInput = new DN_AddrSearch_wb.Input();
       objInput.confmKey       = objRelayInfo.AddressConfirmKey__c;
       objInput.keyword        = sSearchKey;
       objInput.resultType     = 'json';
       objInput.currentPage    = intCurrentPage;
       objInput.countPerPage   = intCntPerPage;

       // 생성 된 Interface parameter로 메소드 실행하고 인터페이스 결과 값 저장
       DN_AddrSearch_wb.Output objOutput = new DN_AddrSearch_wb.Output();
       objOutput = DN_AddrSearch_wb.getInstance().execute(objInput);
       System.debug('objOutput : ' + objOutput);

       // Lightning component에서 사용하기 위해 인터페이스 클래스와 AuraEnabled 클래스를 매핑하여 새로운 리스트 생성
       if(objOutput.results != null) {
           DN_AddrSearch_wb.Common objCommon = objOutput.results.common;

           objResponse.sErrorCode         = objCommon.errorCode;
           objResponse.sErrorMessage      = objCommon.errorMessage;
           objResponse.sTotalCount        = objCommon.totalCount;
           objResponse.intCurrentPage     = objCommon.currentPage;

           if(objCommon.errorCode == '0') {
               List<WrapperAddress> listWrapperAddress = new List<WrapperAddress>();
               for(DN_AddrSearch_wb.Address objAddress : objOutput.results.juso) {
                   listWrapperAddress.add(new WrapperAddress(objAddress));
               }

               objResponse.listWrapperAddress = listWrapperAddress; 
           }
       }

       return objResponse;
   }

  /**
   * Save 버튼을 클릭 했을 때 호출
   * 
   * @params objCustomer : 화면 objCustomer 데이터
   * @params contacts :화면 contacts (List)데이터 > 왜 리스트가 나올까? 데이터가 다건인가?
   * @params banks : 화면 banks (List) 데이터 
   * 
   * CRM 오브젝트 = wrapper class다 
   * contact < 스탠다드 오브젝트 
   */
    @AuraEnabled
    public static SaveResult doSave(MDMRequest objCustomer, List<CustomContacts> contacts, List<Banks> banks)
    {
        // JSON.deserialize(objCustomer, ObjCustomer.class);
        SaveResult saveResult = new SaveResult();

        // aura  String 으로 넘어와서 JSON.des
        // ObjCustomer obj =  JSON.deserialize(objCustomer, 래퍼클래스명.class);
        system.debug('>>>doSave # objCustomer ' + JSON.serialize(objCustomer));
        try {
            if(objCustomer != null){    
                MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c();
                // mdmdRequest.PV_OLDCD__c              = objCustomer.PV_OLDCD;
                // mdmdRequest.PV_KEYYN__c              = Boolean.valueOf(objCustomer.PV_KEYYN);
                // mdmdRequest.PV_KXOTD__c              = Boolean.valueOf(objCustomer.PV_KXOTD);
                // mdmdRequest.PV_FDINFO__c             = Boolean.valueOf(objCustomer.PV_FDINFO);
                // mdmdRequest.PV_KTOKD__c              = objCustomer.PV_KTOKD;
                // mdmdRequest.PV_CUSTTYPE__c           = objCustomer.PV_CUSTTYPE;
                // mdmdRequest.PVRA_VKGRP__c            = Date.valueOf(objCustomer?.PVRA_VKGRP);
                // mdmdRequest.PVRA_PERNR__c            = Date.valueOf(objCustomer?.PVRA_PERNR);
                // mdmdRequest.PVRA_LOGISCENTER__c      = Date.valueOf(objCustomer?.PVRA_LOGISCENTER);
                // mdmdRequest.PV_LAND1__c              = objCustomer.PV_LAND1;
                // mdmdRequest.PV_WAERS__c              = objCustomer.PV_WAERS;
                // mdmdRequest.PVRA_CUHR1__c            = Date.valueOf(objCustomer?.PVRA_CUHR1);
                // mdmdRequest.PVRA_KONDA__c            = Date.valueOf(objCustomer?.PVRA_KONDA);
                // mdmdRequest.PVRA_KVGR1__c            = Date.valueOf(objCustomer?.PVRA_KVGR1);
                // mdmdRequest.PVRA_OLD_BIZPLACE_NEW__c = Date.valueOf(objCustomer?.PVRA_OLD_BIZPLACE_NEW);
                // mdmdRequest.PV_DELIGROUP__c          = objCustomer.PV_DELIGROUP;
                // mdmdRequest.PV_BUSAB__c              = objCustomer.PV_BUSAB;
                // mdmdRequest.PV_CESSION_KZ__c         = objCustomer.PV_CESSION_KZ;
                // mdmdRequest.PV_ZUAWA__c              = objCustomer.PV_ZUAWA;
                // mdmdRequest.PV_AKONT__c              = objCustomer.PV_AKONT;
                // mdmdRequest.PV_FDGRV__c              = objCustomer.PV_FDGRV;
                // mdmdRequest.PV_TAXKDD__c             = objCustomer.PV_TAXKDD;
                // mdmdRequest.PV_KATR5__c              = objCustomer.PV_KATR5;
                // mdmdRequest.PV_SHIPTYPE__c           = objCustomer.PV_SHIPTYPE;
                // mdmdRequest.requestType__c           = objCustomer.requestType;
                // mdmdRequest.PV_NAME1__c              = objCustomer.PV_NAME1;
                // mdmdRequest.RecordTypeId             = objCustomer.RecordTypeId;
                // mdmdRequest.PV_J_1KFREPRE__c         = objCustomer.PV_J_1KFREPRE;
               mdmRequest.RecordTypeId             = objCustomer.RecordTypeId;
               mdmRequest.requestType__c           = objCustomer.requestType;
               mdmRequest.PVRA_VKGRP__c                                        = Date.valueOf(objCustomer?.PVRA_VKGRP);
               mdmRequest.PVRA_PERNR__c                                        = Date.valueOf(objCustomer?.PVRA_PERNR);
               mdmRequest.PVRA_LOGISCENTER__c                                  = Date.valueOf(objCustomer?.PVRA_LOGISCENTER);               
               mdmRequest.PV_NAME1__c                                          = objCustomer?.PV_NAME1;
               mdmRequest.PV_NAME2__c                                          = objCustomer?.PV_NAME2;
               mdmRequest.PV_STCD3__c                                          = objCustomer?.PV_STCD3;
               mdmRequest.PV_GFORM__c                                          = objCustomer?.PV_GFORM;
               mdmRequest.PV_STCD1__c                                          = objCustomer?.PV_STCD1;
               mdmRequest.PV_J_1KFTIND__c                                      = objCustomer?.PV_J_1KFTIND;
               mdmRequest.PV_TELFX__c                                          = objCustomer?.PV_TELFX;
               mdmRequest.PV_VKGRP__c                                          = objCustomer?.PV_VKGRP; // 참조코드 Id 넣어줘야함
               //mdmRequest.PV_PERNR_lu__c                                       = objCustomer?.PV_PERNR_lu; // user lookup
               //mdmRequest.PV_ADMINMA_lu__c                                     = objCustomer?.PV_ADMINMA_lu; 
               mdmRequest.PV_LOGISCENTER__c                                    = objCustomer?.PV_LOGISCENTER; // 참조코드 Id 넣어줘야함
               mdmRequest.PV_STCDT__c                                          = objCustomer?.PV_STCDT; // 참조코드 Id 넣어줘야함
               //mdmRequest.PV_HDOFFICEYN__c                                     = Boolean.valueOf(objCustomer?.PV_HDOFFICEYN);
               //mdmRequest.PV_HKUNNR_lu__c                                      = objCustomer?.PV_HKUNNR_lu; // user lookup
               //mdmRequest.PV_CLOSEDT__c                                        = Date.valueOf(objCustomer?.PV_CLOSEDT);
               mdmRequest.PV_ADRES_ZIPCODE__c                                  = objCustomer?.PV_ADRES_ZIPCODE;
               mdmRequest.PV_ADRES_ROADADDR1__c                                = objCustomer?.PV_ADRES_ROADADDR1;
               mdmRequest.PV_OLDCD__c                                          = objCustomer?.PV_OLDCD;
               mdmRequest.PV_NAME_G__c                                         = objCustomer?.PV_NAME_G;
               mdmRequest.PV_STCD2__c                                          = objCustomer?.PV_STCD2;
               mdmRequest.PV_STCD4__c                                          = objCustomer?.PV_STCD4;
               mdmRequest.PV_J_1KFREPRE__c                                     = objCustomer?.PV_J_1KFREPRE;
               mdmRequest.PV_J_1KFTBUS__c                                      = objCustomer?.PV_J_1KFTBUS;
               mdmRequest.PV_TELF1__c                                          = objCustomer?.PV_TELF1;
               mdmRequest.PV_FITYP__c                                          = objCustomer?.PV_FITYP;
               //mdmRequest.PV_HKUNNR_lu__c                                      = objCustomer?.PV_HKUNNR_lu; // Account lookup
               mdmRequest.PV_VBUND__c                                          = objCustomer?.PV_VBUND; // 참조코드 Id 넣어줘야함
               mdmRequest.PV_KNVKTYPE__c                                       = objCustomer?.PV_KNVKTYPE;
               mdmRequest.PV_REGIO__c                                          = objCustomer?.PV_REGIO;
               mdmRequest.PV_BIZPLCODE__c                                      = objCustomer?.PV_BIZPLCODE;
               mdmRequest.PV_BUSAB__c                                          = objCustomer?.PV_BUSAB;
               mdmRequest.PV_CESSION_KZ__c                                     = objCustomer?.PV_CESSION_KZ;
               mdmRequest.PV_ZUAWA__c                                          = objCustomer?.PV_ZUAWA; // 참조코드 Id 넣어줘야함
               mdmRequest.PV_AKONT__c                                          = objCustomer?.PV_AKONT;
               mdmRequest.PV_FDGRV__c                                          = objCustomer?.PV_FDGRV;
               mdmRequest.PV_TAXKDD__c                                         = objCustomer?.PV_TAXKDD;
               mdmRequest.PV_KATR5__c                                          = objCustomer?.PV_KATR5;
               mdmRequest.PV_WAERS__c                                          = objCustomer?.PV_WAERS;
               mdmRequest.PV_SHIPTYPE__c                                       = objCustomer?.PV_SHIPTYPE;
               mdmRequest.PVRA_CUHR1__c                                        = Date.valueOf(objCustomer?.PVRA_CUHR1);
               mdmRequest.PV_KONDA__c                                          = objCustomer?.PV_KONDA;
               mdmRequest.PVRA_KVGR1__c                                        = Date.valueOf(objCustomer?.PVRA_KVGR1);
               mdmRequest.PVRA_OLD_BIZPLACE_NEW__c                             = Date.valueOf(objCustomer?.PVRA_OLD_BIZPLACE_NEW);
               mdmRequest.PV_DELIGROUP__c                                      = objCustomer?.PV_DELIGROUP;
               mdmRequest.PV_CUHR1__c                                          = objCustomer?.PV_CUHR1;
               mdmRequest.PV_KONDA__c                                          = objCustomer?.PV_KONDA;
               mdmRequest.PV_KVGR1__c                                          = objCustomer?.PV_KVGR1;
               mdmRequest.PV_KVGR2__c                                          = objCustomer?.PV_KVGR2;
               mdmRequest.PV_ODCLOSEGB__c                                      = objCustomer?.PV_ODCLOSEGB;
               mdmRequest.PV_ZTERM_VV__c                                       = objCustomer?.PV_ZTERM_VV;
               mdmRequest.PV_OLD_BIZPLACE_NEW__c                               = objCustomer?.PV_OLD_BIZPLACE_NEW;
               //mdmRequest.PV_EXAMYN__c                                         = Boolean.valueOf(objCustomer?.PV_EXAMYN);
               mdmRequest.PV_PRODLOADCOND__c                                   = objCustomer?.PV_PRODLOADCOND;
               mdmRequest.PV_ENTERCOND1__c                                     = objCustomer?.PV_ENTERCOND1;
               mdmRequest.PV_UNLOADCOND2__c                                    = objCustomer?.PV_UNLOADCOND2;
               mdmRequest.PV_KATR10__c                                         = objCustomer?.PV_KATR10;
               mdmRequest.PV_KEYINFO__c                                        = objCustomer?.PV_KEYINFO;
               mdmRequest.PV_KXOTD__c                                          = Boolean.valueOf(objCustomer?.PV_KXOTD);
               mdmRequest.PV_FDINFO__c                                         = Boolean.valueOf(objCustomer?.PV_FDINFO);
               mdmRequest.PV_FDREQT__c                                         = objCustomer?.PV_FDREQT;
               mdmRequest.PV_FDCTINFO__c                                       = objCustomer?.PV_FDCTINFO;
               mdmRequest.PV_FDNOTICE__c                                       = objCustomer?.PV_FDNOTICE;
               mdmRequest.PV_KVGR3__c                                          = objCustomer?.PV_KVGR3;
               mdmRequest.PV_KVGR3_BOT__c                                      = objCustomer?.PV_KVGR3_BOT;
               //mdmRequest.PV_VACCPRTEXCYN__c                                   = Boolean.valueOf(objCustomer?.PV_VACCPRTEXCYN);
               mdmRequest.PV_DSTRHISTREGYN__c                                  = objCustomer?.PV_DSTRHISTREGYN;
               mdmRequest.PV_SHIPREQTIME__c                                    = objCustomer?.PV_SHIPREQTIME;
               mdmRequest.PV_RETURNLOC__c                                      = objCustomer?.PV_RETURNLOC;
               mdmRequest.PV_UNLOADCOND1__c                                    = objCustomer?.PV_UNLOADCOND1;
               mdmRequest.PV_KEYYN__c                                          = Boolean.valueOf(objCustomer?.PV_KEYYN);
               mdmRequest.PV_KXOTDTIME__c                                      = objCustomer?.PV_KXOTDTIME;
               //mdmRequest.PV_FDREQD__c                                         = Date.valueOf(objCustomer?.PV_FDREQD);
               //mdmRequest.PV_ISFDFTF__c                                        = Boolean.valueOf(objCustomer?.PV_ISFDFTF);
               mdmRequest.PV_TEMPTARGET__c                                     = objCustomer?.PV_TEMPTARGET;

                        


                insert mdmRequest;
            }

        } catch (Exception e) {
            saveResult = new SaveResult('F', e.getMessage() + e.getLineNumber());
        }

        return saveResult;
    } 

    public class SaveResult{
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String massage{get;set;}

        // 생성자의 역할은 기본적으로
        // 전역변수(인스턴스변수) 초기화 해주는 역할을함
        public SaveResult(){
            this.status = 'S';
            this.massage = '성공 하였습니다.';
        }

        public SaveResult(String status, String massage){
            this.status  = status;
            this.massage = massage;
        }

    }


    public class CustomContacts{

    }
    public class Banks{

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
        //판매처에서 가져오는 기본정보
        @AuraEnabled public String PV_NAME1{get;set;}                   // 고객명(영문명포함                 
        @AuraEnabled public String PV_NAME2{get;set;}                   // 고객약칭명(변경
        @AuraEnabled public String PV_CUSTTYPE{get;set;}                // 고객유형
        @AuraEnabled public String PV_GFORM{get;set;}                   // 법적상태
        @AuraEnabled public String PV_J_1KFTIND{get;set;}               // 업종
        @AuraEnabled public String PV_STCDT{get;set;}                   // 세금계산서발행유형
        @AuraEnabled public String PV_ADRES_ZIPCODE{get;set;}           // 우편번호
        @AuraEnabled public String PV_ADRES_ROADADDR1{get;set;}         // 도로명주소
        @AuraEnabled public String id{get;set;}                         // 판매처
        @AuraEnabled public String PV_NAME_G{get;set;}                  // 고객명(G)/자국명
        @AuraEnabled public String PV_KTOKD{get;set;}                   // 고객계정그룹
        @AuraEnabled public String PV_STCD2{get;set;}                   // 사업자등록번호
        @AuraEnabled public String PV_J_1KFREPRE{get;set;}              // 대표자이름
        @AuraEnabled public String PV_J_1KFTBUS{get;set;}               // 업태
        @AuraEnabled public String PV_TELF1{get;set;}                   // 전화번호
        @AuraEnabled public String PV_HKUNNR_lu{get;set;}               // 본점코드
        @AuraEnabled public String PV_REGIO{get;set;}                   // 지역
        @AuraEnabled public String PV_KVGR2{get;set;}                   // 장려금유형 //영업정보
        @AuraEnabled public String PV_ODCLOSEGB{get;set;}               // 고객 주문마감 유형코드
        @AuraEnabled public String PV_ZTERM_VV{get;set;}                // 지급조건
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW{get;set;}        // 경로(사업부)
        @AuraEnabled public String PV_KATR10{get;set;}                  // 출하권역
        @AuraEnabled public String PV_KVGR3{get;set;}                   // 납품서유형    
        @AuraEnabled public String PV_KVGR3_BOT{get;set;}               // 납품서 하단유형
        @AuraEnabled public String PV_DSTRHISTREGYN{get;set;}           // 유통이력 신고대상 유형
        @AuraEnabled public String PV_DELIGROUP{get;set;}               // 배송그룹

        // Default
        @AuraEnabled public String PV_OLDCD {get;set;}
        @AuraEnabled public String PV_KEYYN {get;set;}
        @AuraEnabled public String PV_KXOTD {get;set;}
        @AuraEnabled public String PV_FDINFO {get;set;}
        @AuraEnabled public String PVRA_VKGRP {get;set;}
        @AuraEnabled public String PVRA_PERNR {get;set;}
        @AuraEnabled public String PVRA_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_LAND1 {get;set;}
        @AuraEnabled public String PV_WAERS {get;set;}
        @AuraEnabled public String PVRA_CUHR1 {get;set;}
        @AuraEnabled public String PVRA_KONDA {get;set;}
        @AuraEnabled public String PVRA_KVGR1 {get;set;}
        @AuraEnabled public String PVRA_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_BUSAB {get;set;}
        @AuraEnabled public String PV_CESSION_KZ {get;set;}
        @AuraEnabled public String PV_ZUAWA {get;set;}
        @AuraEnabled public String PV_AKONT {get;set;}
        @AuraEnabled public String PV_FDGRV {get;set;}
        @AuraEnabled public String PV_TAXKDD {get;set;}
        @AuraEnabled public String PV_KATR5 {get;set;}
        @AuraEnabled public String PV_SHIPTYPE {get;set;}
        @AuraEnabled public String requestType {get;set;}
        @AuraEnabled public String RecordTypeId {get;set;}


        public AccountDataWrapper(){}
        public AccountDataWrapper(Account acc) {
            this.PV_NAME1                             = acc.Name;                                               
            this.PV_NAME2                             = acc.NameAlias__c;                                                   
            this.PV_CUSTTYPE                          = acc.CustomerType__c;                                                       
            this.PV_GFORM                             = acc.LegalStatus__c;                                                   
            this.PV_J_1KFTIND                         = acc.BusinessCategory__c;                                                       
            this.PV_STCDT                             = acc.TaxInvoiceType__c;                                                   
            this.PV_ADRES_ZIPCODE                     = acc.PostalCode__c;                                                           
            this.PV_ADRES_ROADADDR1                   = acc.Address__c;                                                           
            this.id                                   = acc.Id;                                           
            this.PV_NAME_G                            = acc.NameKor__c;                                                   
            this.PV_KTOKD                             = acc.AccountGroup__c;                                                   
            this.PV_STCD2                             = acc.CompanyRegisterNumber__c;                                                   
            this.PV_J_1KFREPRE                        = acc.RepresentativeName__c;                                                       
            this.PV_J_1KFTBUS                         = acc.BusinessConditions__c;                                                       
            this.PV_TELF1                             = acc.Phone;                                                   
            this.PV_HKUNNR_lu                         = acc.HeadOfficeCode__c;                                                       
            this.PV_REGIO                             = acc.LocationState__c;                                                   
            this.PV_KVGR2                             = acc.SubsidyType__c;                                                   
            this.PV_ODCLOSEGB                         = acc.CustomerOrderDeadlineType__c;                                                       
            this.PV_ZTERM_VV                          = acc.TermsOfPayment__c;                                                   
            this.PV_OLD_BIZPLACE_NEW                  = acc.CustomerPath__c;                                                       
            this.PV_KATR10                            = acc.ShipmentArea__c;                                                   
            this.PV_KVGR3                             = acc.StatementOfDeliveryType__c;                                                   
            this.PV_KVGR3_BOT                         = acc.StatementOfDeliveryType2__c;                                                   
            this.PV_DSTRHISTREGYN                     = acc.DisHisRegType__c;                                                   
            this.PV_DELIGROUP                         = acc.DeliveryGroup__c;

            //default
            this.PV_OLDCD = '';
            this.PV_KEYYN = '';
            this.PV_KXOTD = '';
            this.PV_FDINFO = '';
            this.PVRA_VKGRP = '';
            this.PVRA_PERNR = '';
            this.PVRA_LOGISCENTER = '';
            this.PV_LAND1 = '';
            this.PV_WAERS = '';
            this.PVRA_CUHR1 = '';
            this.PVRA_KONDA = '';
            this.PVRA_KVGR1 = '';
            this.PVRA_OLD_BIZPLACE_NEW = '';
            this.PV_BUSAB = '';
            this.PV_CESSION_KZ = '';
            this.PV_ZUAWA = '';
            this.PV_AKONT = '';
            this.PV_FDGRV = '';
            this.PV_TAXKDD = '';
            this.PV_KATR5 = '';
            this.PV_SHIPTYPE = '';
            this.requestType = '';
            this.RecordTypeId = '';

            
        }
    }

    /**
     * MDMRequest 공통
     */
    public class MDMRequest{
        // @AuraEnabled public String PV_OLDCD {get;set;}
        // @AuraEnabled public String PV_KEYYN {get;set;}
        // @AuraEnabled public String PV_KXOTD {get;set;}
        // @AuraEnabled public String PV_FDINFO {get;set;}
        // @AuraEnabled public String PV_KTOKD {get;set;}
        // @AuraEnabled public String PV_CUSTTYPE {get;set;}
        // @AuraEnabled public String PVRA_VKGRP {get;set;}
        // @AuraEnabled public String PVRA_PERNR {get;set;}
        // @AuraEnabled public String PVRA_LOGISCENTER {get;set;}
        // @AuraEnabled public String PV_LAND1 {get;set;}
        // @AuraEnabled public String PV_WAERS {get;set;}
        // @AuraEnabled public String PVRA_CUHR1 {get;set;}
        // @AuraEnabled public String PVRA_KONDA {get;set;}
        // @AuraEnabled public String PVRA_KVGR1 {get;set;}
        // @AuraEnabled public String PVRA_OLD_BIZPLACE_NEW {get;set;}
        // @AuraEnabled public String PV_DELIGROUP {get;set;}
        // @AuraEnabled public String PV_BUSAB {get;set;}
        // @AuraEnabled public String PV_CESSION_KZ {get;set;}
        // @AuraEnabled public String PV_ZUAWA {get;set;}
        // @AuraEnabled public String PV_AKONT {get;set;}
        // @AuraEnabled public String PV_FDGRV {get;set;}
        // @AuraEnabled public String PV_TAXKDD {get;set;}
        // @AuraEnabled public String PV_KATR5 {get;set;}
        // @AuraEnabled public String PV_SHIPTYPE {get;set;}
        // @AuraEnabled public String requestType {get;set;}
        // @AuraEnabled public String PV_NAME1 {get;set;}
        // @AuraEnabled public String RecordTypeId {get;set;}
        // @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        @AuraEnabled public String RecordTypeId {get;set;}
        @AuraEnabled public String requestType {get;set;}
        @AuraEnabled public String PVRA_VKGRP {get;set;}
        @AuraEnabled public String PVRA_PERNR {get;set;}
        @AuraEnabled public String PVRA_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_NAME1 {get;set;}
        @AuraEnabled public String PV_NAME2 {get;set;}
        @AuraEnabled public String PV_STCD3 {get;set;}
        @AuraEnabled public String PV_GFORM {get;set;}
        @AuraEnabled public String PV_STCD1 {get;set;}
        @AuraEnabled public String PV_J_1KFTIND {get;set;}
        @AuraEnabled public String PV_TELFX {get;set;}
        @AuraEnabled public String PV_VKGRP {get;set;}
        @AuraEnabled public String PV_PERNR_lu {get;set;}
        @AuraEnabled public String PV_ADMINMA_lu {get;set;}
        @AuraEnabled public String PV_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_STCDT {get;set;}
        @AuraEnabled public String PV_HDOFFICEYN {get;set;}
        @AuraEnabled public String PV_HKUNNR_lu {get;set;}
        @AuraEnabled public String PV_CLOSEDT {get;set;}
        @AuraEnabled public String PV_ADRES_ZIPCODE {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR1 {get;set;}
        @AuraEnabled public String PV_OLDCD {get;set;}
        @AuraEnabled public String PV_NAME_G {get;set;}
        @AuraEnabled public String PV_STCD2 {get;set;}
        @AuraEnabled public String PV_STCD4 {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS {get;set;}
        @AuraEnabled public String PV_TELF1 {get;set;}
        @AuraEnabled public String PV_FITYP {get;set;}
        // @AuraEnabled public String PV_HKUNNR_lu {get;set;}
        @AuraEnabled public String PV_VBUND {get;set;}
        @AuraEnabled public String PV_KNVKTYPE {get;set;}
        @AuraEnabled public String PV_REGIO {get;set;}
        @AuraEnabled public String PV_BIZPLCODE {get;set;}
        @AuraEnabled public String PV_BUSAB {get;set;}
        @AuraEnabled public String PV_CESSION_KZ {get;set;}
        @AuraEnabled public String PV_ZUAWA {get;set;}
        @AuraEnabled public String PV_AKONT {get;set;}
        @AuraEnabled public String PV_FDGRV {get;set;}
        @AuraEnabled public String PV_TAXKDD {get;set;}
        @AuraEnabled public String PV_KATR5 {get;set;}
        @AuraEnabled public String PV_WAERS {get;set;}
        @AuraEnabled public String PV_SHIPTYPE {get;set;}
        @AuraEnabled public String PVRA_CUHR1 {get;set;}
        @AuraEnabled public String PV_KONDA {get;set;}
        @AuraEnabled public String PVRA_KVGR1 {get;set;}
        @AuraEnabled public String PVRA_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_DELIGROUP {get;set;}
        @AuraEnabled public String PV_CUHR1 {get;set;}
        // @AuraEnabled public String PV_KONDA {get;set;}
        @AuraEnabled public String PV_KVGR1 {get;set;}
        @AuraEnabled public String PV_KVGR2 {get;set;}
        @AuraEnabled public String PV_ODCLOSEGB {get;set;}
        @AuraEnabled public String PV_ZTERM_VV {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_EXAMYN {get;set;}
        @AuraEnabled public String PV_PRODLOADCOND {get;set;}
        @AuraEnabled public String PV_ENTERCOND1 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND2 {get;set;}
        @AuraEnabled public String PV_KATR10 {get;set;}
        @AuraEnabled public String PV_KEYINFO {get;set;}
        @AuraEnabled public String PV_KXOTD {get;set;}
        @AuraEnabled public String PV_FDINFO {get;set;}
        @AuraEnabled public String PV_FDREQT {get;set;}
        @AuraEnabled public String PV_FDCTINFO {get;set;}
        @AuraEnabled public String PV_FDNOTICE {get;set;}
        @AuraEnabled public String PV_KVGR3 {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT {get;set;}
        @AuraEnabled public String PV_VACCPRTEXCYN {get;set;}
        @AuraEnabled public String PV_DSTRHISTREGYN {get;set;}
        @AuraEnabled public String PV_SHIPREQTIME {get;set;}
        @AuraEnabled public String PV_RETURNLOC {get;set;}
        @AuraEnabled public String PV_UNLOADCOND1 {get;set;}
        @AuraEnabled public String PV_KEYYN {get;set;}
        @AuraEnabled public String PV_KXOTDTIME {get;set;}
        @AuraEnabled public String PV_FDREQD {get;set;}
        @AuraEnabled public String PV_ISFDFTF {get;set;}
        @AuraEnabled public String PV_TEMPTARGET {get;set;}

    }



    public class WrapperResponse {
        @AuraEnabled public String  sErrorCode      {get; set;} // 에러 코드
        @AuraEnabled public String  sErrorMessage   {get; set;} // 에러 메시지
        @AuraEnabled public String  sTotalCount     {get; set;} // 총 검색 데이터수
        @AuraEnabled public Integer intCurrentPage  {get; set;} // 페이지 번호

        @AuraEnabled public List<WrapperAddress> listWrapperAddress {get; set;}
    }

    public class WrapperAddress {
        @AuraEnabled public String sRoadAddr    {get; set;} // 전체 도로명 주소
        @AuraEnabled public String sJibunAddr   {get; set;} // 지번 주소
        @AuraEnabled public String sZipNo       {get; set;} // 우편 번호
        @AuraEnabled public String sSiName      {get; set;} // 시도 명
        @AuraEnabled public String sSggName     {get; set;} // 시군구 명
        @AuraEnabled public String sEmdName     {get; set;} // 읍면동 명
        @AuraEnabled public String sAddrDetail  {get; set;} // 상세주소
        @AuraEnabled public String sAddr        {get; set;} // 주소

        public WrapperAddress(DN_AddrSearch_wb.Address objAddress) {
            sRoadAddr  = objAddress.roadAddr;   
            sJibunAddr = objAddress.jibunAddr;
            sZipNo     = objAddress.zipNo;
            sSiName    = objAddress.siNm;
            sSggName   = objAddress.sggNm;
            sEmdName   = objAddress.emdNm;
          
            
        }
    }
}