/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 09-11-2023
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
            system.debug('objWrapper.listCustomerOrderType ' + Json.serialize(objWrapper.listCustomerOrderType));
        }
        objWrapper.strStatus = strStatus;
        objWrapper.MDMRecordTypeId = MDMRecordTypeId;
        return objWrapper;
    }

    /**
     * @description 선택한 recordId를 이용해 Account정보/ Contact정보 가져와 MDM 고객 등록 요청(관리처)에 보내주기
     * 
     * @return      `String`
     */ 
    @AuraEnabled
    public static List<AccountDataWrapper> getAccountInfo(String selectedId){
        system.debug('### CJFW_MDMManagementController.getAccountInfo(String selectedId) ### ');
        system.debug('>>> Division Account Id ' + selectedId);
        List<AccountDataWrapper> result = new List<AccountDataWrapper>();
        
        //SELECT Name, (SELECT LastName FROM Contacts)  FROM Account
        //List<Account>    accList = getAccountRecord(customerId, customerName, managerMA);
        List<Account> accList = [SELECT  Id
                                        ,  Name                            
                                        , NameAlias__c                    
                                        , CustomerType__c                 
                                        , LegalStatus__c                  
                                        , BusinessCategory__c             
                                        , TaxInvoiceType__c               
                                        , PostalCode__c                   
                                        , Address__c                      
                                        , NameKor__c                      
                                        , AccountGroup__c                 
                                        , CompanyRegisterNumber__c        
                                        , RepresentativeName__c           
                                        , BusinessConditions__c           
                                        , Phone                           
                                        , HeadOfficeCode__c               
                                        , LocationState__c                
                                        , SubsidyType__c                  
                                        , CustomerOrderDeadlineType__c    
                                        , TermsOfPayment__c               
                                        , CustomerPath__c                 
                                        , ShipmentArea__c                 
                                        , StatementOfDeliveryType__c      
                                        , StatementOfDeliveryType2__c     
                                        , DisHisRegType__c                
                                        , DeliveryGroup__c                
                                        , (SELECT Id, Lastname, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c FROM Contacts) 
                                    FROM Account 
                                    WHERE Id =: selectedId 
                                    LIMIT 1];

         system.debug('>>> accList ' + json.serialize(accList));
         system.debug('>>> accList.size() ' + accList.size());
         if(!AccList.isEmpty()){
             for(Account acc : accList){
                 result.add(new AccountDataWrapper(acc));
             }
         }
         system.debug('>>> result ' + json.serialize(result));
        return result;
    }

    /**
     * @description 관리처 화면에 오늘날짜 Setting
     *
     * @return      `Date`
     */
    @AuraEnabled
    public static Date getFirstDayOfMonthDate() {
        system.debug('>>>getFirstDayOfMonthDate');
        Date result = System.today();

        return result;
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
        system.debug('>>>doSave ');
        SaveResult saveResult = new SaveResult();
        // aura  String 으로 넘어와서 JSON.des
        // ObjCustomer obj =  JSON.deserialize(objCustomer, 래퍼클래스명.class);
        system.debug('>>>doSave # objCustomer ' + JSON.serialize(objCustomer));
        system.debug('>>>doSave # contacts ' + contacts.size());
        //값을 나눠서 값이 없으면 안되는친구들
        //값이 없어도 되는친구들 
        try {
            if(objCustomer != null){    
                MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c();
                //변경불가 2
                mdmRequest.RecordTypeId                                         = String.isBlank(objCustomer?.RecordTypeId) ? null : objCustomer.RecordTypeId;
                mdmRequest.requestType__c                                       = String.isBlank(objCustomer?.requestType) ? null : objCustomer.requestType;
                //mdmRequest.PV_KUNNR__c                                            = String.isBlank(objCustomer?.PV_KUNNR) ? null : objCustomer.PV_KUNNR;    이건 나중에 승인받고 추가
                //기본정보
                mdmRequest.PV_OLDCD__c                                          = String.isBlank(objCustomer?.PV_OLDCD) ? null : objCustomer.PV_OLDCD;
                mdmRequest.PV_NAME1__c                                          = String.isBlank(objCustomer?.PV_NAME1) ? null : objCustomer.PV_NAME1;
                mdmRequest.PV_NAME_G__c                                         = String.isBlank(objCustomer?.PV_NAME_G) ? null : objCustomer.PV_NAME_G ;
                mdmRequest.PV_NAME2__c                                          = String.isBlank(objCustomer?.PV_NAME2) ? null : objCustomer.PV_NAME2;                                                                                 
                mdmRequest.PV_KTOKD__c                                          = String.isBlank(objCustomer?.PV_KTOKD) ? null : objCustomer.PV_KTOKD;                                                                                 
                mdmRequest.PV_CUSTTYPE__c                                       = String.isBlank(objCustomer?.PV_CUSTTYPE) ? null : objCustomer.PV_CUSTTYPE;                                                                                         
                mdmRequest.PV_STCD2__c                                          = String.isBlank(objCustomer?.PV_STCD2) ? null : objCustomer.PV_STCD2;                                                                                 
                mdmRequest.PV_STCD3__c                                          = String.isBlank(objCustomer?.PV_STCD3) ? null : objCustomer.PV_STCD3;                                                                                 
                mdmRequest.PV_STCD4__c                                          = String.isBlank(objCustomer?.PV_STCD4) ? null : objCustomer.PV_STCD4;                                                                                 
                mdmRequest.PV_GFORM__c                                          = String.isBlank(objCustomer?.PV_GFORM) ? null : objCustomer.PV_GFORM;                                                                                 
                mdmRequest.PV_J_1KFREPRE__c                                     = String.isBlank(objCustomer?.PV_J_1KFREPRE) ? null : objCustomer.PV_J_1KFREPRE;                                                                                             
                mdmRequest.PV_STCD1__c                                          = String.isBlank(objCustomer?.PV_STCD1) ? null : objCustomer.PV_STCD1;                                                                                 
                mdmRequest.PV_J_1KFTBUS__c                                      = String.isBlank(objCustomer?.PV_J_1KFTBUS) ? null : objCustomer.PV_J_1KFTBUS;                                                                                         
                mdmRequest.PV_J_1KFTIND__c                                      = String.isBlank(objCustomer?.PV_J_1KFTIND) ? null : objCustomer.PV_J_1KFTIND;                                                                                         
                mdmRequest.PV_TELF1__c                                          = String.isBlank(objCustomer?.PV_TELF1) ? null : objCustomer.PV_TELF1;                                                                                 
                mdmRequest.PV_TELFX__c                                          = String.isBlank(objCustomer?.PV_TELFX) ? null : objCustomer.PV_TELFX;                                                                                 
                mdmRequest.PV_VKGRP__c                                          = String.isBlank(objCustomer?.PV_VKGRP) ? null : objCustomer.PV_VKGRP;     
                mdmRequest.PVRA_VKGRP__c                                        = objCustomer?.PVRA_VKGRP != null ? objCustomer.PVRA_VKGRP : null; //Date.valueOf(objCustomer?.PVRA_VKGRP);
                mdmRequest.PV_PERNR_lu__c                                       = String.isBlank(objCustomer?.PV_PERNR_lu) ? null : objCustomer.PV_PERNR_lu;   //반영안되네 빈값임

                
                mdmRequest.PVRA_PERNR__c                                          = Date.valueOf(objCustomer?.PVRA_PERNR);                                                                       
                mdmRequest.PV_ADMINMA_lu__c                                       = String.isBlank(objCustomer?.PV_ADMINMA_lu) ? null : objCustomer.PV_ADMINMA_lu;                                                                                             
                mdmRequest.PV_LOGISCENTER__c                                      = String.isBlank(objCustomer?.PV_LOGISCENTER) ? null : objCustomer.PV_LOGISCENTER;                                                                                                 
                mdmRequest.PVRA_LOGISCENTER__c                                    = Date.valueOf(objCustomer?.PVRA_LOGISCENTER);    
                //회계정보

                //영업정보

                /*
                //여기부터 ~~~~~~~~~~~~~~
                mdmRequest.PV_CUSTTYPE__c	                                   = String.isBlank(objCustomer?.PV_CUSTTYPE) ? null : objCustomer.PV_CUSTTYPE;
                mdmRequest.PV_LOGISCENTER_lu__c	                                = String.isBlank(objCustomer?.PV_LOGISCENTER_lu) ? null : objCustomer.PV_LOGISCENTER_lu;
                mdmRequest.PV_VKGRP_lu__c                                       = String.isBlank(objCustomer?.PV_VKGRP_lu) ? null : objCustomer.PV_VKGRP_lu;
                mdmRequest.PV_STCDT_lu__c                                       = String.isBlank(objCustomer?.PV_STCDT_lu) ? null : objCustomer.PV_STCDT_lu;
                mdmRequest.PV_VBUND_lu__c                                       = String.isBlank(objCustomer?.PV_VBUND_lu) ? null : objCustomer.PV_VBUND_lu;
                
                mdmRequest.PV_LAND1_lu__c                                       = String.isBlank(objCustomer?.PV_LAND1_lu) ? null : objCustomer.PV_LAND1_lu;
                mdmRequest.PV_REGIO_lu__c                                       = String.isBlank(objCustomer?.PV_REGIO_lu) ? null : objCustomer.PV_REGIO_lu;
                mdmRequest.PV_ZUAWA_lu__c                                       = String.isBlank(objCustomer?.PV_ZUAWA_lu) ? null : objCustomer.PV_ZUAWA_lu;
                mdmRequest.PV_CUHR1_lu__c                                       = String.isBlank(objCustomer?.PV_CUHR1_lu) ? null : objCustomer.PV_CUHR1_lu;
                mdmRequest.PV_KONDA_lu__c                                       = String.isBlank(objCustomer?.PV_KONDA_lu) ? null : objCustomer.PV_KONDA_lu;
                mdmRequest.PV_KVGR1_lu__c                                       = String.isBlank(objCustomer?.PV_KVGR1_lu) ? null : objCustomer.PV_KVGR1_lu;
                mdmRequest.PV_WAERS_lu__c                                       = String.isBlank(objCustomer?.PV_WAERS_lu) ? null : objCustomer.PV_WAERS_lu;
                mdmRequest.PV_ZTERM_VV_lu__c                                    = String.isBlank(objCustomer?.PV_ZTERM_VV_lu) ? null : objCustomer.PV_ZTERM_VV_lu;
                mdmRequest.PV_OLD_BIZPLACE_NEW_lu__c                            = String.isBlank(objCustomer?.PV_OLD_BIZPLACE_NEW_lu) ? null : objCustomer.PV_OLD_BIZPLACE_NEW_lu;
                mdmRequest.PV_DELIGROUP_lu__c                                   = String.isBlank(objCustomer?.PV_DELIGROUP_lu) ? null : objCustomer.PV_DELIGROUP_lu;
                mdmRequest.PV_KATR10_lu__c                                      = String.isBlank(objCustomer?.PV_KATR10_lu) ? null : objCustomer.PV_KATR10_lu;
                

                mdmRequest.PV_SELLER_lu__c                                      = String.isBlank(objCustomer?.PV_SELLER_lu) ? null : objCustomer.PV_SELLER_lu;                
               
                mdmRequest.PVRA_VKGRP__c                                        = Date.valueOf(objCustomer?.PVRA_VKGRP);
                mdmRequest.PVRA_PERNR__c                                        = Date.valueOf(objCustomer?.PVRA_PERNR);
                mdmRequest.PVRA_LOGISCENTER__c                                  = Date.valueOf(objCustomer?.PVRA_LOGISCENTER);               
                mdmRequest.PV_NAME2__c                                          = String.isBlank(objCustomer?.PV_NAME2) ? null : objCustomer.PV_NAME2;
                mdmRequest.PV_STCD3__c                                          = String.isBlank(objCustomer?.PV_STCD3) ? null : objCustomer.PV_STCD3;
                mdmRequest.PV_GFORM__c                                          = String.isBlank(objCustomer?.PV_GFORM) ? null : objCustomer.PV_GFORM;
                mdmRequest.PV_STCD1__c                                          = String.isBlank(objCustomer?.PV_STCD1) ? null : objCustomer.PV_STCD1;
                mdmRequest.PV_J_1KFTIND__c                                      = String.isBlank(objCustomer?.PV_J_1KFTIND) ? null : objCustomer.PV_J_1KFTIND;
                mdmRequest.PV_TELFX__c                                          = String.isBlank(objCustomer?.PV_TELFX) ? null : objCustomer.PV_TELFX;
                mdmRequest.PV_VKGRP__c                                          = String.isBlank(objCustomer?.PV_VKGRP) ? null : objCustomer.PV_VKGRP; // 참조코드 Id 넣어줘야함
                
                mdmRequest.PV_PERNR_lu__c                                       = String.isBlank(objCustomer?.PV_PERNR_lu) ? null : objCustomer.PV_PERNR_lu;     // user lookup
                //mdmRequest.PV_ADMINMA_lu__c                                     = objCustomer?.PV_ADMINMA_lu; 
                mdmRequest.PV_LOGISCENTER__c                                    = String.isBlank(objCustomer?.PV_LOGISCENTER) ? null : objCustomer.PV_LOGISCENTER; // 참조코드 Id 넣어줘야함
                mdmRequest.PV_STCDT__c                                          = String.isBlank(objCustomer?.PV_STCDT) ? null : objCustomer.PV_STCDT;             // 참조코드 Id 넣어줘야함
                //mdmRequest.PV_HDOFFICEYN__c                                     = Boolean.valueOf(objCustomer?.PV_HDOFFICEYN);
                //mdmRequest.PV_HKUNNR_lu__c                                      = objCustomer?.PV_HKUNNR_lu; // user lookup
                //mdmRequest.PV_CLOSEDT__c                                        = Date.valueOf(objCustomer?.PV_CLOSEDT);
                mdmRequest.PV_ADRES_ZIPCODE__c                                  = objCustomer?.PV_ADRES_ZIPCODE;
                mdmRequest.PV_ADRES_ROADADDR1__c                                = objCustomer?.PV_ADRES_ROADADDR1;
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
                */
                system.debug('>>> 찍혀요? 1');
                insert mdmRequest;
                //여기까지 ~~~~~~~~~~~~~~

                //Account도 추가
                // Account accRequest = new Account();
                // accRequest.Name                                                     = String.isBlank(objCustomer?.PV_NAME1) ? null : objCustomer.PV_NAME1;
                // insert accRequest;

                for (CustomContacts contact : contacts) {
                    if (String.isBlank(contact.id)) {
                        System.debug('contact ' + JSON.serialize(contact));
                        System.debug('contact.id 빈값 ' + JSON.serialize(contact.id));

                        Contact conRequest = new Contact();
                        conRequest.LastName                                  = String.isBlank(contact.Name) ? null : contact.Name;
                        conRequest.Email                                     = String.isBlank(contact.Email) ? null : contact.Email; 
                        conRequest.MobilePhone                               = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
                        conRequest.MDMRegRequestCustomer__c                  = mdmRequest.id;
                        
                            
                        insert conRequest;

                        MDMRegRequestContact__c mdmConRequest = new MDMRegRequestContact__c();
                        mdmConRequest.PV_NAME1_VK__c                                      = String.isBlank(contact.Name) ? null : contact.Name;
                        mdmConRequest.PV_EMAIL_VK__c                                      = String.isBlank(contact.Email) ? null : contact.Email; 
                        mdmConRequest.PV_TELF1_VK__c                                      = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
                        mdmConRequest.MDMRegRequestCustomer__c                            = mdmRequest.id;
                        mdmConRequest.Contact__c                                          = conRequest.id;  
                        insert mdmConRequest;                    
                        
                    }else{
                        System.debug('contact ' + JSON.serialize(contact));
                        System.debug('contact.id ????? ' + JSON.serialize(contact.id));
                        MDMRegRequestContact__c mdmConRequest = new MDMRegRequestContact__c();
                        mdmConRequest.PV_NAME1_VK__c                                     = String.isBlank(contact.Name) ? null : contact.Name;
                        mdmConRequest.PV_EMAIL_VK__c                                     = String.isBlank(contact.Email) ? null : contact.Email; 
                        mdmConRequest.PV_TELF1_VK__c                                     = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
                        mdmConRequest.MDMRegRequestCustomer__c                           = mdmRequest.id;
                        mdmConRequest.Contact__c                                         = contact.id;    
                        insert mdmConRequest;

                    }
                }

                
                
                //MDMRegRequestContact__c mdmConRequest = new MDMRegRequestContact__c();
            }
            
            //가져온 selectedItems여부 따져서, 
            //Id O Contact 추가
            //Id X Contact && MDMContact 추가

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

        /**
     * MDMRequest 공통
     */
    public class MDMRequest{

        //기존 2
        @AuraEnabled public String RecordTypeId {get;set;}
        @AuraEnabled public String requestType {get;set;}
        //기본 41
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
        @AuraEnabled public String PV_STCD1 {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS {get;set;}
        @AuraEnabled public String PV_J_1KFTIND {get;set;}
        @AuraEnabled public String PV_TELF1 {get;set;}
        @AuraEnabled public String PV_TELFX {get;set;}
        @AuraEnabled public String PV_VKGRP {get;set;}
        @AuraEnabled public Date PVRA_VKGRP {get;set;}
        @AuraEnabled public String PV_PERNR_lu {get;set;}
        @AuraEnabled public Date PVRA_PERNR {get;set;}
        @AuraEnabled public String PV_ADMINMA_lu {get;set;}
        @AuraEnabled public String PV_LOGISCENTER {get;set;}
        @AuraEnabled public Date PVRA_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_STCDT {get;set;}
        @AuraEnabled public String PV_FITYP {get;set;}
        @AuraEnabled public String PV_HDOFFICEYN {get;set;}
        @AuraEnabled public String PV_HKUNNR_lu {get;set;}
        @AuraEnabled public String PV_HKUNNR {get;set;}
        @AuraEnabled public String PV_VBUND {get;set;}
        @AuraEnabled public String PV_LAND1 {get;set;}
        @AuraEnabled public String PV_KNVKTYPE {get;set;}
        @AuraEnabled public Date PV_CLOSEDT {get;set;}
        @AuraEnabled public String PV_REGIO {get;set;}
        @AuraEnabled public String PV_ADRES_ZIPCODE {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR2 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR2 {get;set;}
        @AuraEnabled public String PV_SELLER_lu {get;set;}
        @AuraEnabled public String PV_BIZPLCODE {get;set;}

        //회계정보 7
        @AuraEnabled public String PV_BUSAB {get;set;}
        @AuraEnabled public String PV_CESSION_KZ {get;set;}
        @AuraEnabled public String PV_ZUAWA {get;set;}
        @AuraEnabled public String PV_AKONT {get;set;}
        @AuraEnabled public String PV_FDGRV {get;set;}
        @AuraEnabled public String PV_TAXKDD {get;set;}
        @AuraEnabled public String PV_KATR5 {get;set;}

        //영업정보 37
        @AuraEnabled public String PV_CUHR1 {get;set;}
        @AuraEnabled public String PVRA_CUHR1 {get;set;}
        @AuraEnabled public String PV_KONDA {get;set;}
        @AuraEnabled public String PVRA_KONDA {get;set;}
        @AuraEnabled public String PV_KVGR1 {get;set;}
        @AuraEnabled public String PVRA_KVGR1 {get;set;}
        @AuraEnabled public String PV_WAERS {get;set;}
        @AuraEnabled public String PV_KVGR3 {get;set;}
        @AuraEnabled public String PV_KVGR2 {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT {get;set;}
        @AuraEnabled public String PV_ODCLOSEGB {get;set;}
        @AuraEnabled public String PV_VACCPRTEXCYN {get;set;}
        @AuraEnabled public String PV_ZTERM_VV {get;set;}
        @AuraEnabled public String PV_DSTRHISTREGYN {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PVRA_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_EXAMYN {get;set;}
        @AuraEnabled public String PV_SHIPREQTIME {get;set;}
        @AuraEnabled public String PV_PRODLOADCOND {get;set;}
        @AuraEnabled public String PV_RETURNLOC {get;set;}
        @AuraEnabled public String PV_ENTERCOND1 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND1 {get;set;}
        @AuraEnabled public String PV_UNLOADCOND2 {get;set;}
        @AuraEnabled public String PV_DELIGROUP {get;set;}
        @AuraEnabled public String PV_KATR10 {get;set;}
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
         
        //참조모달
        @AuraEnabled public String PV_VKGRP_lu {get;set;}
        @AuraEnabled public String PV_LOGISCENTER_lu {get;set;}
        @AuraEnabled public String PV_STCDT_lu {get;set;}
        @AuraEnabled public String PV_VBUND_lu {get;set;}
        @AuraEnabled public String PV_LAND1_lu {get;set;}
        @AuraEnabled public String PV_REGIO_lu {get;set;}
        @AuraEnabled public String PV_ZUAWA_lu {get;set;}
        @AuraEnabled public String PV_AKONT_lu {get;set;}
        @AuraEnabled public String PV_CUHR1_lu {get;set;}
        @AuraEnabled public String PV_KONDA_lu {get;set;}
        @AuraEnabled public String PV_KVGR1_lu {get;set;}
        @AuraEnabled public String PV_WAERS_lu {get;set;}
        @AuraEnabled public String PV_ZTERM_VV_lu {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW_lu {get;set;}
        @AuraEnabled public String PV_DELIGROUP_lu {get;set;}
        @AuraEnabled public String PV_KATR10_lu {get;set;}



        //작업끝.



        // @AuraEnabled public String PV_CUSTTYPE {get;set;}
        // @AuraEnabled public String PV_LOGISCENTER_lu {get;set;}
        // @AuraEnabled public String PV_VKGRP_lu {get;set;}
        // @AuraEnabled public String PV_SELLER_lu {get;set;}
        // @AuraEnabled public String PV_STCDT_lu {get;set;}
        // @AuraEnabled public String PV_VBUND_lu {get;set;}
        // @AuraEnabled public String PV_AKONT_lu {get;set;}

        // @AuraEnabled public String PV_LAND1_lu {get;set;}
        // @AuraEnabled public String PV_REGIO_lu {get;set;}
        // @AuraEnabled public String PV_ZUAWA_lu {get;set;}
        // @AuraEnabled public String PV_CUHR1_lu {get;set;}
        // @AuraEnabled public String PV_KONDA_lu {get;set;}
        // @AuraEnabled public String PV_KVGR1_lu {get;set;}
        // @AuraEnabled public String PV_WAERS_lu {get;set;}
        // @AuraEnabled public String PV_ZTERM_VV_lu {get;set;}
        // @AuraEnabled public String PV_OLD_BIZPLACE_NEW_lu {get;set;}
        // @AuraEnabled public String PV_DELIGROUP_lu {get;set;}
        // @AuraEnabled public String PV_KATR10_lu {get;set;}

        // //기존
        // @AuraEnabled public String RecordTypeId {get;set;}
        // @AuraEnabled public String requestType {get;set;}
        // @AuraEnabled public String PVRA_VKGRP {get;set;}
        // @AuraEnabled public String PVRA_PERNR {get;set;}
        // @AuraEnabled public String PVRA_LOGISCENTER {get;set;}
        // @AuraEnabled public String PV_NAME1 {get;set;}
        // @AuraEnabled public String PV_NAME2 {get;set;}
        // @AuraEnabled public String PV_STCD3 {get;set;}
        // @AuraEnabled public String PV_GFORM {get;set;}
        // @AuraEnabled public String PV_STCD1 {get;set;}
        // @AuraEnabled public String PV_J_1KFTIND {get;set;}
        // @AuraEnabled public String PV_TELFX {get;set;}
        // @AuraEnabled public String PV_VKGRP {get;set;}
        // @AuraEnabled public String PV_PERNR_lu {get;set;}
        // @AuraEnabled public String PV_ADMINMA_lu {get;set;}
        // @AuraEnabled public String PV_LOGISCENTER {get;set;}
        // @AuraEnabled public String PV_STCDT {get;set;}
        // @AuraEnabled public String PV_HDOFFICEYN {get;set;}
        // @AuraEnabled public String PV_HKUNNR_lu {get;set;}
        // @AuraEnabled public String PV_CLOSEDT {get;set;}
        // @AuraEnabled public String PV_ADRES_ZIPCODE {get;set;}
        // @AuraEnabled public String PV_ADRES_ROADADDR1 {get;set;}
        // @AuraEnabled public String PV_OLDCD {get;set;}
        // @AuraEnabled public String PV_NAME_G {get;set;}
        // @AuraEnabled public String PV_STCD2 {get;set;}
        // @AuraEnabled public String PV_STCD4 {get;set;}
        // @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        // @AuraEnabled public String PV_J_1KFTBUS {get;set;}
        // @AuraEnabled public String PV_TELF1 {get;set;}
        // @AuraEnabled public String PV_FITYP {get;set;}
        // // @AuraEnabled public String PV_HKUNNR_lu {get;set;}
        // @AuraEnabled public String PV_VBUND {get;set;}
        // @AuraEnabled public String PV_KNVKTYPE {get;set;}
        // @AuraEnabled public String PV_REGIO {get;set;}
        // @AuraEnabled public String PV_BIZPLCODE {get;set;}
        // @AuraEnabled public String PV_BUSAB {get;set;}
        // @AuraEnabled public String PV_CESSION_KZ {get;set;}
        // @AuraEnabled public String PV_ZUAWA {get;set;}
        // @AuraEnabled public String PV_AKONT {get;set;}
        // @AuraEnabled public String PV_FDGRV {get;set;}
        // @AuraEnabled public String PV_TAXKDD {get;set;}
        // @AuraEnabled public String PV_KATR5 {get;set;}
        // @AuraEnabled public String PV_WAERS {get;set;}
        // @AuraEnabled public String PV_SHIPTYPE {get;set;}
        // @AuraEnabled public String PVRA_CUHR1 {get;set;}
        // @AuraEnabled public String PV_KONDA {get;set;}
        // @AuraEnabled public String PVRA_KVGR1 {get;set;}
        // @AuraEnabled public String PVRA_OLD_BIZPLACE_NEW {get;set;}
        // @AuraEnabled public String PV_DELIGROUP {get;set;}
        // @AuraEnabled public String PV_CUHR1 {get;set;}
        // // @AuraEnabled public String PV_KONDA {get;set;}
        // @AuraEnabled public String PV_KVGR1 {get;set;}
        // @AuraEnabled public String PV_KVGR2 {get;set;}
        // @AuraEnabled public String PV_ODCLOSEGB {get;set;}
        // @AuraEnabled public String PV_ZTERM_VV {get;set;}
        // @AuraEnabled public String PV_OLD_BIZPLACE_NEW {get;set;}
        // @AuraEnabled public String PV_EXAMYN {get;set;}
        // @AuraEnabled public String PV_PRODLOADCOND {get;set;}
        // @AuraEnabled public String PV_ENTERCOND1 {get;set;}
        // @AuraEnabled public String PV_UNLOADCOND2 {get;set;}
        // @AuraEnabled public String PV_KATR10 {get;set;}
        // @AuraEnabled public String PV_KEYINFO {get;set;}
        // @AuraEnabled public String PV_KXOTD {get;set;}
        // @AuraEnabled public String PV_FDINFO {get;set;}
        // @AuraEnabled public String PV_FDREQT {get;set;}
        // @AuraEnabled public String PV_FDCTINFO {get;set;}
        // @AuraEnabled public String PV_FDNOTICE {get;set;}
        // @AuraEnabled public String PV_KVGR3 {get;set;}
        // @AuraEnabled public String PV_KVGR3_BOT {get;set;}
        // @AuraEnabled public String PV_VACCPRTEXCYN {get;set;}
        // @AuraEnabled public String PV_DSTRHISTREGYN {get;set;}
        // @AuraEnabled public String PV_SHIPREQTIME {get;set;}
        // @AuraEnabled public String PV_RETURNLOC {get;set;}
        // @AuraEnabled public String PV_UNLOADCOND1 {get;set;}
        // @AuraEnabled public String PV_KEYYN {get;set;}
        // @AuraEnabled public String PV_KXOTDTIME {get;set;}
        // @AuraEnabled public String PV_FDREQD {get;set;}
        // @AuraEnabled public String PV_ISFDFTF {get;set;}
        // @AuraEnabled public String PV_TEMPTARGET {get;set;}
    }


    public class CustomContacts{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String AccountId {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String Phone {get;set;}
        @AuraEnabled public String MobilePhone {get;set;}
        @AuraEnabled public String Department {get;set;}
        @AuraEnabled public String PV_PAFKT_VK {get;set;}
        @AuraEnabled public String Gender {get;set;}
        @AuraEnabled public String Fax {get;set;}
        @AuraEnabled public String OtherInfo {get;set;}
        @AuraEnabled public String OwnerId {get;set;}
        @AuraEnabled public String PV_TALKT_VK {get;set;}

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
        @AuraEnabled public String PV_SELLER_lu{get;set;}               // 판매처
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
        @AuraEnabled public List<ContactWrapper> contactList {get;set;}



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
            this.PV_SELLER_lu                         = acc.Id;     //판매처
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
            this.contactList = new List<ContactWrapper>();
            //Id, Lastname, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c
            for(Contact con : acc.Contacts){
                String LastName = con.LastName;
                contactList.add(new ContactWrapper(LastName, acc.id));
                system.debug('contactList ' + JSON.serialize(contactList));
            }


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
    public class ContactWrapper {
        @AuraEnabled public String lastName {get; set;}
        @AuraEnabled public String id {get; set;}
        public ContactWrapper(String lastName, String id){
            this.lastName = lastName;
            this.id = id;
        }
    }


}