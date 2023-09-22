/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 09-21-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-18-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMManagementController {

    /**
     * @description RecordTypeName으로 RecordTypeId Return해주기
     * @params recordId MDMRegRequestCustomer Id     
     * @params mdmCustomerType MDM 고객 구분(MDMParent : 본점, MDMChild : 판매처, MDMManagement : 관리처)  
     * @return      `String`
     */
    @AuraEnabled
    public static DataWrapper doInit(id recordId){
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';                          // Success 메세지
        String strMessage = '';                                // Error 메세지 
        String MDMRecordTypeId = '';                           // MDMRegRequestCustomer__c의 recordTypeId
        String strObjectType = 'MDMRegRequestCustomer__c';     // ObjectName
        String mdmCustomerType = 'MDMManagement';              // recordTypeName

        /**
         * 1) 생성, 수정 + AccountDetail 수정  (X)
         * 2) 생성, 수정                       (O)         
         */
    try {
        
        User objUser = [
                SELECT Id, LastName, EmployeeNumber FROM User
                WHERE Id =:UserInfo.getUserId()
        ];
        system.debug('json.objUser ' + JSON.serialize(objUser));
            
            objWrapper.objUser = objUser;
            system.debug('objUser ' + JSON.serialize(objUser));
        
        if(strObjectType == 'MDMRegRequestCustomer__c'){
            MDMRecordTypeId = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(mdmCustomerType).getRecordTypeId();
            system.debug('>>> setDefaultInfo ' + MDMRecordTypeId);
            objWrapper.listCustomerOrderType = CommonUtil.getPickListValues('MDMRegRequestCustomer__c',  'PV_ODCLOSEGB__c',  true);
            system.debug('objWrapper.listCustomerOrderType ' + Json.serialize(objWrapper.listCustomerOrderType));
        }
        
    }catch(Exception e){
        strStatus = 'ERROR';
        strMessage = e.getMessage()+' Line : '+e.getLineNumber();
    
    }
        objWrapper.MDMRecordTypeId = MDMRecordTypeId;
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;
        return objWrapper;
    }

    /**
     * 출고센터, 고객분류 변경시 고객 주문마감 유형코드 SelectList 변경
     * 
     * @params strType : LOGIC(출고센터), CUHR(고객분류)
     * @params mdmCustomerType MDM 고객 구분(MDMParent : 본점, MDMChild : 판매처)  
     * @return DataWrapper
     *
    **/
    @AuraEnabled
    public static DataWrapper doCheckOrderType(String strType, String PV_LOGISCENTER, String PV_CUHR1) {
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';
        String strMessage = '';
        String PV_ODCLOSEGB = '';

        System.debug('==============> strType : '+strType);
        System.debug('==============> PV_LOGISCENTER : '+PV_LOGISCENTER);
        System.debug('==============> before PV_CUHR1 : '+PV_CUHR1);

        if(PV_CUHR1 <> null && PV_CUHR1.contains('-')) {
            PV_CUHR1 = PV_CUHR1.split('-')[0];
        }
        
        System.debug('==============> after PV_CUHR1 : '+PV_CUHR1);

        try {            
            Set<String> setCloseGB = new Set<String>();

            String strQuery = 'SELECT Id, CUHR1__c, LOGISCENTER__c, CLOSEGB__c';
            strQuery += '   FROM    MDMCustomerOrderType__c';
            
            if(strType == 'LOGIC') {
                strQuery += '   WHERE   LOGISCENTER__c LIKE \'%'+PV_LOGISCENTER+'%\'';
            }else {                
                strQuery += '   WHERE   CUHR1__c =\''+PV_CUHR1+'\'';
            }
            
            strQuery += '   ORDER BY CLOSEGB__c ASC';

            for(MDMCustomerOrderType__c obj : Database.query(strQuery)) {
                System.debug('=========> obj.CUHR1__c : '+obj.CUHR1__c);
                System.debug('=========> obj.PV_CUHR1 : '+PV_CUHR1);

                if(strType == 'LOGIC') {
                    if(obj.CUHR1__c == 'All') {
                        setCloseGB.add(obj.CLOSEGB__c);
                    }else if(obj.CUHR1__c == PV_CUHR1) {
                        setCloseGB.add(obj.CLOSEGB__c);
                    }
                }else {
                    if(obj.CUHR1__c == 'All') {
                        setCloseGB.add(obj.CLOSEGB__c);
                    }else if(obj.LOGISCENTER__c.contains(PV_LOGISCENTER)) {
                        setCloseGB.add(obj.CLOSEGB__c);
                    }
                }
                
            }

            System.debug('===========> setCloseGB : '+setCloseGB);

            List<Map<String, String>> listOrderType = CommonUtil.getPickListValues('MDMRegRequestCustomer__c', 'PV_ODCLOSEGB__c', true);

            List<Map<String, String>> listCustomerOrderType = new List<Map<String, String>>();

            listCustomerOrderType.add(new Map<String, String>{
                'label' => '--없음--',
                'value' => 'none'
            });

            if(!setCloseGB.isEmpty()) {
                for(Map<String, String> mapTarget : listOrderType) {
                    System.debug('listOrderType[mapTarget]  =>' + mapTarget);
                    if(setCloseGB.contains(mapTarget.get('value'))) {
                        listCustomerOrderType.add(mapTarget);
                    }
                }
            }else {
                listCustomerOrderType = listOrderType;
            }
            
            objWrapper.listCustomerOrderType = listCustomerOrderType;
            System.debug('listOrderType =>' + listCustomerOrderType);

        }catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();
        }
        
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

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
        
        //SELECT Name,  (SELECT LastName FROM Contacts)  FROM Account
        //List<Account>    accList = getAccountRecord(customerId,  customerName,  managerMA);
        List<Account> accList = [SELECT  Id
                                        ,   Name                            
                                        ,  NameAlias__c                    
                                        ,  CustomerType__c                 
                                        ,  LegalStatus__c                  
                                        ,  BusinessCategory__c             
                                        ,  TaxInvoiceType__c               
                                        ,  PostalCode__c                   
                                        ,  Address__c                      
                                        ,  NameKor__c                      
                                        ,  AccountGroup__c                 
                                        ,  CompanyRegisterNumber__c        
                                        ,  RepresentativeName__c           
                                        ,  BusinessConditions__c           
                                        ,  Phone                           
                                        ,  HeadOfficeCode__c               
                                        ,  LocationState__c                
                                        ,  SubsidyType__c                  
                                        ,  CustomerOrderDeadlineType__c    
                                        ,  TermsOfPayment__c               
                                        ,  CustomerPath__c                 
                                        ,  ShipmentArea__c                 
                                        ,  StatementOfDeliveryType__c      
                                        ,  StatementOfDeliveryType2__c     
                                        ,  DisHisRegType__c                
                                        ,  DeliveryGroup__c                
                                        ,  (SELECT Id,  Lastname,  Firstname,  Email,  Phone,  MobilePhone,  Department,  PV_PAFKT_VK__c,  PV_TALKT_VK__c,  PV_KNVKGB__c FROM Contacts) 
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
     * @description 본점 조회
     *
     * @return      `List<Account>`
     */
    @AuraEnabled
    public static Account getHKUNNR(String accountId) {
        system.debug(' ### getHKUNNR ' + accountId);
        Account getAccHKUNNR = [SELECT Id,  ParentId, HeadOfficeCode__c FROM Account WHERE Id =: accountId];

        return getAccHKUNNR;
    }

    /**
     * User 정보 조회
     * 
     * @params userId : User Id     
     * @return `User` 
     *
    **/
    @AuraEnabled
    public static User getUserEmployeeNumber(String userId) {
        User us = [SELECT Id, EmployeeNumber FROM User WHERE Id=: userId];
        
        return us;
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
    public static SaveResult doSave(MDMRequest objCustomer,  List<CustomContacts> contacts, Boolean isEdit)
    {
        
        system.debug(' ### CJFW_MDMManagementController > doSave ');
        system.debug(' >>> doSave > objCustomer.Account ' + objCustomer.Account);
        system.debug(' >>> doSave > json.serialize(objCustomer) ' + json.serialize(objCustomer));
        SaveResult saveResult = new SaveResult();
        // aura  String 으로 넘어와서 JSON.des
        // ObjCustomer obj =  JSON.deserialize(objCustomer,  래퍼클래스명.class);
        Id recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMManagement').getRecordTypeId();


        /**
         * 1 관리처 생성 MDM에 id가 없음
         * 2 관리처 수정 1) MDM에서 온 경우 MDM에 id가 없음
         *              2) sfdc에서 승인 난 경우 MDM id 가 있음
         */
        try {
            
            // ================ MDM 요청 =============
            // 생성 인 경우

            String mdmRequestId = '';

            if(!isEdit){ 
                system.debug(' >>> doSave > isEdit = false ' );
                system.debug(' json.serialize(objCustomer) ' + json.serialize(objCustomer));
                MDMRegRequestCustomer__c mdmRequest = convertMdmRequest(objCustomer, null);

                insert mdmRequest;
                mdmRequestId = mdmRequest.id;
            // 수정 인 경우
            }else{
                system.debug(' >>> doSave > isEdit = true ' );
                system.debug(' json.serialize(objCustomer) ' + json.serialize(objCustomer));
                List<Account> accountList = [SELECT Id, recordTypeId, Name, CustomerID__c FROM Account WHERE Id =: objCustomer.Account LIMIT 1 ];
                List<MDMRegRequestCustomer__c> mdmRegRequestCustomerList = [
                    SELECT id
                    FROM MDMRegRequestCustomer__c  
                    WHERE PV_KUNNR__c =: accountList[0].CustomerId__c]; 
                
                // 없을 경우 1. MDM에서 온 경우
                if(mdmRegRequestCustomerList.isEmpty()){ 

                    system.debug('여기 찍히나요 mdm에서 온 경우');
                    //메서드 만들어서 데이터 보내고, 받은다음 
                    MDMRegRequestCustomer__c mdmRequest = convertMdmRequest(objCustomer, null);
                    insert mdmRequest;
                    mdmRequestId = mdmRequest.id;
                 //2. 있을 경우 sfdc 출신 MDM
                }else{
                    // CustomerId__c로 찾은 MDMRegRequestCustomer__c를 넣어줌
                    MDMRegRequestCustomer__c originalCustomer = mdmRegRequestCustomerList[0];
                    MDMRegRequestCustomer__c mdmRequest = convertMdmRequest(objCustomer, originalCustomer);

                    update mdmRequest;
                    mdmRequestId = mdmRequest.id;
                }
            }

            /** =============== 담당자 정보 ============ **/
            // contactId가 있으면 usert/ 없으면 inert
            List<Contact> insertContactList = new List<Contact>();
            List<Contact> updateContactList = new List<Contact>();

            List<MDMRegRequestContact__c> conMdmRequestList = new List<MDMRegRequestContact__c>();

            for (CustomContacts contact : contacts) {
                // 없음 = insert
                if (String.isBlank(contact.id)) {
                    //// 공통적인 부분은 메소드에 contact보내서 처리함
                    system.debug('컨택이 없는 이름 => ' + contact.Name);
                    insertContactList.add(convertContact(contact, mdmRequestId));
                // 있음 = update
                }else{

                    // Contact conRequest = new Contact();
                    // conRequest.id                                         = contact.id; // 아이디 특정
                    // conRequest.LastName                                  = String.isBlank(contact.Name) ? null : contact.Name;
                    // conRequest.Email                                     = String.isBlank(contact.Email) ? null : contact.Email; 
                    // conRequest.MobilePhone                               = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
                    // conRequest.MDMRegRequestCustomer__c                  = mdmRequest.id;
                    // updateContactList.add(conRequest);

                    // contact Convert 부분은 메소드에 contact보내서 처리함 (공통사용)
                    updateContactList.add(convertContact(contact, mdmRequestId));
                    
                    // MDMRegRequestContact__c mdmConRequest = new MDMRegRequestContact__c();
                    // mdmConRequest.PV_NAME1_VK__c                                     = String.isBlank(contact.Name) ? null : contact.Name;
                    // mdmConRequest.PV_EMAIL_VK__c                                     = String.isBlank(contact.Email) ? null : contact.Email; 
                    // mdmConRequest.PV_TELF1_VK__c                                     = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
                    // mdmConRequest.MDMRegRequestCustomer__c                           = mdmRequestId;
                    // mdmConRequest.Contact__c                                         = contact.id;    

                    // mdm contact Convert 부분은 메소드에 contact보내서 처리함 (공통사용)
                    system.debug('컨택이 있는 이름 => ' + contact.name);
                    conMdmRequestList.add(convertMdmContact(contact, mdmRequestId, contact.Id));
                }
            }
            
            if(!insertContactList.isEmpty()){
                insert insertContactList;
                
                Map<String, String> insertConRequestMap = new Map<String, String>(); 

                // 새로 생성한 Contact의 경우 Id값이 없으니까 insert하고나서 맵에 키 넣어두고 Id값 가져옴
                for(Contact insertContact : insertContactList)
                {
                    insertConRequestMap.put(insertContact.LastName +'-'+insertContact.Email +'-'+insertContact.MobilePhone, insertContact.id);
                }

                for (CustomContacts contact : contacts) {
                    String name        = String.isBlank(contact.Name) ? null : contact.Name;
                    String email       = String.isBlank(contact.Email) ? null : contact.Email; 
                    String mobilePhone = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 

                    // 위에서 넣어준 Map에 key넣어주어 Insert된 ContactId가져옴
                    String conRequestid = insertConRequestMap.get(Name+'-'+Email+'-'+MobilePhone);

                    // mdm contact Convert 부분은 메소드에 contact보내서 처리함 (공통사용)
                    if(conRequestid!= null)
                    {
                        conMdmRequestList.add(convertMdmContact(contact, mdmRequestId, conRequestid));
                    }
                }

                //여기에 MDMRegRequestContact__c 추가해주면 안되는건가?
            }
            if(!updateContactList.isEmpty()){
                update updateContactList;
            }
            if(!conMdmRequestList.isEmpty()){
                system.debug(conMdmRequestList.size());
                List<MDMRegRequestContact__c> delConMDMRequestList = [SELECT Id FROM MDMRegRequestContact__c WHERE MDMRegRequestCustomer__c =:mdmRequestId];
                if(!delConMDMRequestList.isEmpty()){
                    delete delConMDMRequestList;
                }
                upsert conMdmRequestList;
            }
        } catch (Exception e) {
            saveResult = new SaveResult('F',  e.getMessage() + e.getLineNumber());
        }

        return saveResult;
    } 
     /**
      * @param  : objCustomer => 화면에서 보내준 래퍼클래스
      * @param  : mdmRegRequestRecordId    => 수정 일 경우 originalCustomer
      * @return : 래퍼클래스를 MDMRegRequestCustomer__c 오브젝트에 매핑해서 변환
      */
    public static MDMRegRequestCustomer__c convertMdmRequest(MDMRequest objCustomer, MDMRegRequestCustomer__c originalCustomer){
            system.debug(' ### CJFW_MDMManagementController > convertMdmRequest ');
            system.debug(' >>> objCustomer ' + json.serialize(objCustomer));
            Id recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get('MDMManagement').getRecordTypeId();

            // 뉴 해가지고 그냥 새로만든 MDMRegRequestCustomer__c
            MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c();
            
            // 기존 데이터 업데이트 시 넘어옴
            if(originalCustomer != null){
                // originalCustomer라고 조회한 MDMRegRequestCustomer__c 이걸로 엎어쳐줌
                mdmRequest = originalCustomer;
            }

            mdmRequest.Account__c                                           = String.isBlank(objCustomer?.Account) ? null : objCustomer.Account;
            mdmRequest.RecordTypeId                                         = recordIdEx;
            mdmRequest.RequestType__c                                       = String.isBlank(objCustomer?.RequestType) ? null : objCustomer.RequestType;
            //기본정보 42
            mdmRequest.PV_KUNNR__c                                            = String.isBlank(objCustomer?.PV_KUNNR) ? null : objCustomer.PV_KUNNR;   
            mdmRequest.PV_OLDCD__c                                            = String.isBlank(objCustomer?.PV_OLDCD) ? null : objCustomer.PV_OLDCD;
            mdmRequest.PV_NAME1__c                                            = String.isBlank(objCustomer?.PV_NAME1) ? null : objCustomer.PV_NAME1;
            mdmRequest.PV_NAME_G__c                                           = String.isBlank(objCustomer?.PV_NAME_G) ? null : objCustomer.PV_NAME_G ;
            mdmRequest.PV_NAME2__c                                            = String.isBlank(objCustomer?.PV_NAME2) ? null : objCustomer.PV_NAME2;                                                                                 
            mdmRequest.PV_KTOKD__c                                            = String.isBlank(objCustomer?.PV_KTOKD) ? null : objCustomer.PV_KTOKD;                                                                                 
            mdmRequest.PV_CUSTTYPE__c                                         = String.isBlank(objCustomer?.PV_CUSTTYPE) ? null : objCustomer.PV_CUSTTYPE;                                                                                         
            mdmRequest.PV_STCD2__c                                            = String.isBlank(objCustomer?.PV_STCD2) ? null : objCustomer.PV_STCD2;                                                                                 
            mdmRequest.PV_STCD3__c                                            = String.isBlank(objCustomer?.PV_STCD3) ? null : objCustomer.PV_STCD3;                                                                                 
            mdmRequest.PV_STCD4__c                                            = String.isBlank(objCustomer?.PV_STCD4) ? null : objCustomer.PV_STCD4;                                                                                 
            mdmRequest.PV_GFORM__c                                            = String.isBlank(objCustomer?.PV_GFORM) ? null : objCustomer.PV_GFORM;                                                                                 
            mdmRequest.PV_J_1KFREPRE__c                                       = String.isBlank(objCustomer?.PV_J_1KFREPRE) ? null : objCustomer.PV_J_1KFREPRE;                                                                                             
            mdmRequest.PV_STCD1__c                                            = String.isBlank(objCustomer?.PV_STCD1) ? null : objCustomer.PV_STCD1;                                                                                 
            mdmRequest.PV_J_1KFTBUS__c                                        = String.isBlank(objCustomer?.PV_J_1KFTBUS) ? null : objCustomer.PV_J_1KFTBUS;                                                                                         
            mdmRequest.PV_J_1KFTIND__c                                        = String.isBlank(objCustomer?.PV_J_1KFTIND) ? null : objCustomer.PV_J_1KFTIND;                                                                                         
            mdmRequest.PV_TELF1__c                                            = String.isBlank(objCustomer?.PV_TELF1) ? null : objCustomer.PV_TELF1;                                                                                 
            mdmRequest.PV_TELFX__c                                            = String.isBlank(objCustomer?.PV_TELFX) ? null : objCustomer.PV_TELFX;                                                                                 
            mdmRequest.PV_VKGRP__c                                            = String.isBlank(objCustomer?.PV_VKGRP) ? null : objCustomer.PV_VKGRP;     
            mdmRequest.PVRA_VKGRP__c                                          = objCustomer?.PVRA_VKGRP != null ? objCustomer.PVRA_VKGRP : null; 
            mdmRequest.PV_PERNR__c                                            = String.isBlank(objCustomer?.PV_PERNR) ? null : objCustomer.PV_PERNR;   //반영안되네 ma사번
            mdmRequest.PV_PERNR_lu__c                                         = String.isBlank(objCustomer?.PV_PERNR_lu) ? null : objCustomer.PV_PERNR_lu;   //반영안되네 maid
            mdmRequest.PVRA_PERNR__c                                          = objCustomer?.PVRA_PERNR != null ? objCustomer.PVRA_PERNR : null; 
            mdmRequest.PV_ADMINMA__c                                          = String.isBlank(objCustomer?.PV_ADMINMA) ? null : objCustomer.PV_ADMINMA;          
            mdmRequest.PV_ADMINMA_lu__c                                       = String.isBlank(objCustomer?.PV_ADMINMA_lu) ? null : objCustomer.PV_ADMINMA_lu;
            mdmRequest.PV_LOGISCENTER__c                                      = String.isBlank(objCustomer?.PV_LOGISCENTER) ? null : objCustomer.PV_LOGISCENTER;                                                                                                 
            mdmRequest.PVRA_LOGISCENTER__c                                    = objCustomer?.PVRA_LOGISCENTER != null ? objCustomer.PVRA_LOGISCENTER : null;        
            mdmRequest.PV_STCDT__c                                            = String.isBlank(objCustomer?.PV_STCDT) ? null : objCustomer.PV_STCDT;                                                                                 
            mdmRequest.PV_FITYP__c                                            = String.isBlank(objCustomer?.PV_FITYP) ? null : objCustomer.PV_FITYP;              
            mdmRequest.PV_HDOFFICEYN__c                                       = objCustomer?.PV_HDOFFICEYN ? true : false;
            mdmRequest.PV_HKUNNR_lu__c                                        = String.isBlank(objCustomer?.PV_HKUNNR_lu) ? null : objCustomer.PV_HKUNNR_lu;                                                                                         
            mdmRequest.PV_HKUNNR__c                                           = String.isBlank(objCustomer?.PV_HKUNNR) ? null : objCustomer.PV_HKUNNR;                                                                                     
            mdmRequest.PV_VBUND__c                                            = String.isBlank(objCustomer?.PV_VBUND) ? null : objCustomer.PV_VBUND;                                                                                 
            mdmRequest.PV_LAND1__c                                            = String.isBlank(objCustomer?.PV_LAND1) ? null : objCustomer.PV_LAND1;
            mdmRequest.PV_LAND1_lu__c                                         = String.isBlank(objCustomer?.PV_LAND1_lu) ? null : objCustomer.PV_LAND1_lu;
            mdmRequest.PV_KNVKTYPE__c                                         = String.isBlank(objCustomer?.PV_KNVKTYPE) ? null : objCustomer.PV_KNVKTYPE;     
            //'' -> Null로 변경
            mdmRequest.PV_CLOSEDT__c                                          = objCustomer?.PV_CLOSEDT != null ? objCustomer.PV_CLOSEDT : null;  
            mdmRequest.PV_REGIO__c                                            = String.isBlank(objCustomer?.PV_REGIO) ? null : objCustomer.PV_REGIO;                                                                                 
            mdmRequest.PV_ADRES_ZIPCODE__c                                    = String.isBlank(objCustomer?.PV_ADRES_ZIPCODE) ? null : objCustomer.PV_ADRES_ZIPCODE;  
            mdmRequest.PV_ADRES_ROADADDR1__c                                  = String.isBlank(objCustomer?.PV_ADRES_ROADADDR1) ? null : objCustomer.PV_ADRES_ROADADDR1;                                                                                                         
            mdmRequest.PV_ADRES_ROADADDR2__c                                  = String.isBlank(objCustomer?.PV_ADRES_ROADADDR2) ? null : objCustomer.PV_ADRES_ROADADDR2;                                                                                                         
            mdmRequest.PV_ADRES_ADDR1__c                                      = String.isBlank(objCustomer?.PV_ADRES_ADDR1) ? null : objCustomer.PV_ADRES_ADDR1;                                                                                                 
            mdmRequest.PV_ADRES_ADDR2__c                                      = String.isBlank(objCustomer?.PV_ADRES_ADDR2) ? null : objCustomer.PV_ADRES_ADDR2;                                                                                                 
            mdmRequest.PV_SELLER_lu__c                                        = String.isBlank(objCustomer?.PV_SELLER_lu) ? null : objCustomer.PV_SELLER_lu;                                                                                         
            mdmRequest.PV_BIZPLCODE__c                                        = String.isBlank(objCustomer?.PV_BIZPLCODE) ? null : objCustomer.PV_BIZPLCODE;
            //기본정보 완료
            //회계정보 7
            mdmRequest.PV_BUSAB__c                                            = String.isBlank(objCustomer?.PV_BUSAB) ? null : objCustomer.PV_BUSAB;                                                                                 
            mdmRequest.PV_CESSION_KZ__c                                       = String.isBlank(objCustomer?.PV_CESSION_KZ) ? null : objCustomer.PV_CESSION_KZ;                                                                                             
            mdmRequest.PV_ZUAWA__c                                            = String.isBlank(objCustomer?.PV_ZUAWA) ? null : objCustomer.PV_ZUAWA;                                                                                 
            mdmRequest.PV_AKONT__c                                            = String.isBlank(objCustomer?.PV_AKONT) ? null : objCustomer.PV_AKONT;                                                                                 
            mdmRequest.PV_FDGRV__c                                            = String.isBlank(objCustomer?.PV_FDGRV) ? null : objCustomer.PV_FDGRV;                                                                                 
            mdmRequest.PV_TAXKDD__c                                           = String.isBlank(objCustomer?.PV_TAXKDD) ? null : objCustomer.PV_TAXKDD;                                                                                     
            mdmRequest.PV_KATR5__c                                            = String.isBlank(objCustomer?.PV_KATR5) ? null : objCustomer.PV_KATR5; 
            //회계정보 완료
            //영업정보 53
            mdmRequest.PV_CUHR1__c                                            = String.isBlank(objCustomer?.PV_CUHR1) ? null : objCustomer.PV_CUHR1;                                                                                 
            mdmRequest.PVRA_CUHR1__c                                          = objCustomer?.PVRA_CUHR1 != null ? objCustomer.PVRA_CUHR1 : null;                                                                                          
            mdmRequest.PV_KONDA__c                                            = String.isBlank(objCustomer?.PV_KONDA) ? null : objCustomer.PV_KONDA;                                                                                 
            mdmRequest.PVRA_KONDA__c                                          = objCustomer?.PVRA_KONDA != null ? objCustomer.PVRA_KONDA : null;                                                                                          
            mdmRequest.PV_KVGR1__c                                            = String.isBlank(objCustomer?.PV_KVGR1) ? null : objCustomer.PV_KVGR1;                                                                                 
            mdmRequest.PVRA_KVGR1__c                                          = objCustomer?.PVRA_KVGR1 != null ? objCustomer.PVRA_KVGR1: null;                                                                                         
            mdmRequest.PV_WAERS__c                                            = String.isBlank(objCustomer?.PV_WAERS) ? null : objCustomer.PV_WAERS;                                                                                 
            mdmRequest.PV_KVGR3__c                                            = String.isBlank(objCustomer?.PV_KVGR3) ? null : objCustomer.PV_KVGR3;                                                                                 
            mdmRequest.PV_KVGR2__c                                            = String.isBlank(objCustomer?.PV_KVGR2) ? null : objCustomer.PV_KVGR2;                                                                                 
            mdmRequest.PV_KVGR3_BOT__c                                        = String.isBlank(objCustomer?.PV_KVGR3_BOT) ? null : objCustomer.PV_KVGR3_BOT;                                                                                         
            mdmRequest.PV_ODCLOSEGB__c                                        = String.isBlank(objCustomer?.PV_ODCLOSEGB) ? null : objCustomer.PV_ODCLOSEGB;                                                                                         
            mdmRequest.PV_VACCPRTEXCYN__c                                     = objCustomer?.PV_VACCPRTEXCYN;                                                                                   
            mdmRequest.PV_ZTERM_VV__c                                         = String.isBlank(objCustomer?.PV_ZTERM_VV) ? null : objCustomer.PV_ZTERM_VV;                                                                                         
            mdmRequest.PV_DSTRHISTREGYN__c                                    = String.isBlank(objCustomer?.PV_DSTRHISTREGYN) ? null : objCustomer.PV_DSTRHISTREGYN;                                                                                                 
            mdmRequest.PV_OLD_BIZPLACE_NEW__c                                 = String.isBlank(objCustomer?.PV_OLD_BIZPLACE_NEW) ? null : objCustomer.PV_OLD_BIZPLACE_NEW;                                                                                                         
            mdmRequest.PVRA_OLD_BIZPLACE_NEW__c                               = objCustomer?.PVRA_OLD_BIZPLACE_NEW != null ? objCustomer.PVRA_OLD_BIZPLACE_NEW: null; 
            mdmRequest.PV_EXAMYN__c                                           = objCustomer?.PV_EXAMYN; //Boolean.valueOf(objCustomer?.PV_EXAMYN);                                                                                 
            mdmRequest.PV_SHIPREQTIME__c                                      = String.isBlank(objCustomer?.PV_SHIPREQTIME) ? null : objCustomer.PV_SHIPREQTIME;                                                                                                 
            mdmRequest.PV_PRODLOADCOND__c                                     = String.isBlank(objCustomer?.PV_PRODLOADCOND) ? null : objCustomer.PV_PRODLOADCOND;                                                                                                 
            mdmRequest.PV_RETURNLOC__c                                        = String.isBlank(objCustomer?.PV_RETURNLOC) ? null : objCustomer.PV_RETURNLOC;                                                                                         
            mdmRequest.PV_ENTERCOND1__c                                       = String.isBlank(objCustomer?.PV_ENTERCOND1) ? null : objCustomer.PV_ENTERCOND1;                                                                                             
            mdmRequest.PV_UNLOADCOND1__c                                      = String.isBlank(objCustomer?.PV_UNLOADCOND1) ? null : objCustomer.PV_UNLOADCOND1;                                                                                                 
            mdmRequest.PV_UNLOADCOND2__c                                      = String.isBlank(objCustomer?.PV_UNLOADCOND2) ? null : objCustomer.PV_UNLOADCOND2;                                                                                                 
            mdmRequest.PV_DELIGROUP__c                                        = String.isBlank(objCustomer?.PV_DELIGROUP) ? null : objCustomer.PV_DELIGROUP;                                                                                         
            mdmRequest.PV_KATR10__c                                           = String.isBlank(objCustomer?.PV_KATR10) ? null : objCustomer.PV_KATR10;                                                                                     
            mdmRequest.PV_KEYYN__c                                            = objCustomer?.PV_KEYYN; //Boolean.valueOf(objCustomer?.PV_KEYYN);                                                                                 
            mdmRequest.PV_KEYINFO__c                                          = String.isBlank(objCustomer?.PV_KEYINFO) ? null : objCustomer.PV_KEYINFO;                                                                                         
            mdmRequest.PV_KXOTD__c                                            = Boolean.valueOf(objCustomer?.PV_KXOTD);                                                                         
            mdmRequest.PV_KXOTDTIME__c                                        = String.isBlank(objCustomer?.PV_KXOTDTIME) ? null : objCustomer.PV_KXOTDTIME;                                                                                         
            mdmRequest.PV_FDINFO__c                                           = objCustomer?.PV_EXAMYN; //Boolean.valueOf(objCustomer?.PV_FDINFO);                                                                                     
            mdmRequest.PV_FDREQD__c                                           = objCustomer?.PV_FDREQD != null ? objCustomer.PV_FDREQD: null;
            mdmRequest.PV_FDREQT__c                                           = String.isBlank(objCustomer?.PV_FDREQT) ? null : objCustomer.PV_FDREQT;                                                                                     
            mdmRequest.PV_ISFDFTF__c                                          = objCustomer?.PV_ISFDFTF; //Boolean.valueOf(objCustomer?.PV_ISFDFTF);                                                                    
            mdmRequest.PV_FDCTINFO__c                                         = String.isBlank(objCustomer?.PV_FDCTINFO) ? null : objCustomer.PV_FDCTINFO;                                                                                         
            mdmRequest.PV_FDNOTICE__c                                         = String.isBlank(objCustomer?.PV_FDNOTICE) ? null : objCustomer.PV_FDNOTICE;                                                                                         
            mdmRequest.PV_SHIPTYPE__c                                         = String.isBlank(objCustomer?.PV_SHIPTYPE) ? null : objCustomer.PV_SHIPTYPE;                                                                                         
            mdmRequest.PV_TEMPTARGET__c                                       = String.isBlank(objCustomer?.PV_TEMPTARGET) ? null : objCustomer.PV_TEMPTARGET;                                                                                             
            mdmRequest.PV_VKGRP_lu__c                                         = String.isBlank(objCustomer?.PV_VKGRP_lu) ? null : objCustomer.PV_VKGRP_lu;                                                                                         
            mdmRequest.PV_LOGISCENTER_lu__c                                   = String.isBlank(objCustomer?.PV_LOGISCENTER_lu) ? null : objCustomer.PV_LOGISCENTER_lu;                                                                                                     
            mdmRequest.PV_STCDT_lu__c                                         = String.isBlank(objCustomer?.PV_STCDT_lu) ? null : objCustomer.PV_STCDT_lu;                                                                                         
            mdmRequest.PV_VBUND_lu__c                                         = String.isBlank(objCustomer?.PV_VBUND_lu) ? null : objCustomer.PV_VBUND_lu;                                                                                         
            mdmRequest.PV_LAND1_lu__c                                         = String.isBlank(objCustomer?.PV_LAND1_lu) ? null : objCustomer.PV_LAND1_lu;                                                                                         
            mdmRequest.PV_REGIO_lu__c                                         = String.isBlank(objCustomer?.PV_REGIO_lu) ? null : objCustomer.PV_REGIO_lu;                                                                                         
            mdmRequest.PV_ZUAWA_lu__c                                         = String.isBlank(objCustomer?.PV_ZUAWA_lu) ? null : objCustomer.PV_ZUAWA_lu;                                                                                         
            mdmRequest.PV_AKONT_lu__c                                         = String.isBlank(objCustomer?.PV_AKONT_lu) ? null : objCustomer.PV_AKONT_lu;                                                                                         
            mdmRequest.PV_CUHR1_lu__c                                         = String.isBlank(objCustomer?.PV_CUHR1_lu) ? null : objCustomer.PV_CUHR1_lu;                                                                                         
            mdmRequest.PV_KONDA_lu__c                                         = String.isBlank(objCustomer?.PV_KONDA_lu) ? null : objCustomer.PV_KONDA_lu;                                                                                         
            mdmRequest.PV_KVGR1_lu__c                                         = String.isBlank(objCustomer?.PV_KVGR1_lu) ? null : objCustomer.PV_KVGR1_lu;                                                                                         
            mdmRequest.PV_WAERS_lu__c                                         = String.isBlank(objCustomer?.PV_WAERS_lu) ? null : objCustomer.PV_WAERS_lu;                                                                                         
            mdmRequest.PV_ZTERM_VV_lu__c                                      = String.isBlank(objCustomer?.PV_ZTERM_VV_lu) ? null : objCustomer.PV_ZTERM_VV_lu;                                                                                                 
            mdmRequest.PV_OLD_BIZPLACE_NEW_lu__c                              = String.isBlank(objCustomer?.PV_OLD_BIZPLACE_NEW_lu) ? null : objCustomer.PV_OLD_BIZPLACE_NEW_lu;                                                                                                                 
            mdmRequest.PV_DELIGROUP_lu__c                                     = String.isBlank(objCustomer?.PV_DELIGROUP_lu) ? null : objCustomer.PV_DELIGROUP_lu;                                                                                                 
            mdmRequest.PV_KATR10_lu__c                                        = String.isBlank(objCustomer?.PV_KATR10_lu) ? null : objCustomer.PV_KATR10_lu;                                                         
            
            return mdmRequest;


                //담당자 정보 contactId가 있으면 usert/ 없으면 inert
                // for (CustomContacts contact : contacts) {
                //     if (String.isBlank(contact.id)) {
                //         System.debug('contact ' + JSON.serialize(contact));
                //         System.debug('contact.id 빈값 ' + JSON.serialize(contact.id));

                //         Contact conRequest = new Contact();
                //         conRequest.LastName                                  = String.isBlank(contact.Name) ? null : contact.Name;
                //         conRequest.Email                                     = String.isBlank(contact.Email) ? null : contact.Email; 
                //         conRequest.MobilePhone                               = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
                //         conRequest.MDMRegRequestCustomer__c                  = mdmRequest.id;
                        
                            
                //         insert conRequest;

                //         MDMRegRequestContact__c mdmConRequest = new MDMRegRequestContact__c();
                //         mdmConRequest.PV_NAME1_VK__c                                      = String.isBlank(contact.Name) ? null : contact.Name;
                //         mdmConRequest.PV_EMAIL_VK__c                                      = String.isBlank(contact.Email) ? null : contact.Email; 
                //         mdmConRequest.PV_TELF1_VK__c                                      = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
                //         mdmConRequest.MDMRegRequestCustomer__c                            = mdmRequest.id;
                //         mdmConRequest.Contact__c                                          = conRequest.id;  
                //         insert mdmConRequest;                    
                        
                //     }else{
                //         System.debug('contact ' + JSON.serialize(contact));
                //         System.debug('contact.id ????? ' + JSON.serialize(contact.id));
                //         MDMRegRequestContact__c mdmConRequest = new MDMRegRequestContact__c();
                //         mdmConRequest.PV_NAME1_VK__c                                     = String.isBlank(contact.Name) ? null : contact.Name;
                //         mdmConRequest.PV_EMAIL_VK__c                                     = String.isBlank(contact.Email) ? null : contact.Email; 
                //         mdmConRequest.PV_TELF1_VK__c                                     = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
                //         mdmConRequest.MDMRegRequestCustomer__c                           = mdmRequest.id;
                //         mdmConRequest.Contact__c                                         = contact.id;    
                //         insert mdmConRequest;

                //     }
                // }
    }  
    /**
     * @param  : objCustomer => 화면에서 보내준 래퍼클래스
     * @param  : contact
     * @return : 래퍼클래스를 Contact 오브젝트에 매핑해서 변환
    */
    public static Contact convertContact(CustomContacts contact, String mdmRequestId){
        Contact conRequest = new Contact();

        if(!String.isBlank(contact.id))
        {
            conRequest.id = contact.id;
        }

        conRequest.LastName                                  = String.isBlank(contact.Name) ? null : contact.Name;
        conRequest.Email                                     = String.isBlank(contact.Email) ? null : contact.Email; 
        conRequest.MobilePhone                               = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
        conRequest.MDMRegRequestCustomer__c                  = mdmRequestId;

        return conRequest;
    }

    /**
     * @param  : objCustomer => 화면에서 보내준 래퍼클래스
     * @param  : 
     * @return : 래퍼클래스를 MDMRegRequestContact__c 오브젝트에 매핑해서 변환
    */
    public static MDMRegRequestContact__c convertMdmContact(CustomContacts contact, String mdmRequestId, String contactId ){

        MDMRegRequestContact__c mdmConRequest = new MDMRegRequestContact__c();
        mdmConRequest.PV_NAME1_VK__c                                     = String.isBlank(contact.Name) ? null : contact.Name;
        mdmConRequest.PV_EMAIL_VK__c                                     = String.isBlank(contact.Email) ? null : contact.Email; 
        mdmConRequest.PV_TELF1_VK__c                                     = String.isBlank(contact.MobilePhone) ? null : contact.MobilePhone; 
        mdmConRequest.MDMRegRequestCustomer__c                           = mdmRequestId; //customer.id
        mdmConRequest.Contact__c                                         = contactId;  

        return mdmConRequest;
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

        public SaveResult(String status,  String massage){
            this.status  = status;
            this.massage = massage;
        }
    }

    public class EditMDMRequest{
        @AuraEnabled public Boolean isCRM{get;set;}
        @AuraEnabled public Boolean isEdit{get;set;}
        @AuraEnabled public MDMRequest mdmRequest{get;set;}
        @AuraEnabled public List<CustomContacts> CustomContacts{get;set;}
    }

    /**
     * @description [코드정리해야함 공통화 해]
     *              수정 일 경우(AccountId가 존재) 
     *              AccountId로 MDM오브젝트 조회하여 저장되어 있는 필드와 값을 래퍼클래스에 매핑하여 화면에 리턴
     * 
     * @return      `EditMDMRequest`
     */
    @AuraEnabled 
    public static EditMDMRequest getAccountToMdm(String accountId){

        system.debug('#CJFW_MDMManagementController > getAccountToMdm()');
        system.debug('>>> accountId ' + accountId);
        Id recordIdEx = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();

        EditMDMRequest result = new EditMDMRequest();
        //code -> Name 변환 코드
        Set<String> accountCodeSet = new Set<String>();

        List<Account> accountList = [SELECT Id
                                            ,ParentId
                                            ,Owner.EmployeeNumber
                                            ,ownerId
                                            ,recordTypeId
                                            ,Name
                                            ,CustomerID__c //CustomerId가 왜 두개니..
                                            ,custID__c
                                            ,CustomerIDASIS__c
                                            ,NameKor__c
                                            ,NameAlias__c
                                            ,AccountGroup__c
                                            ,CustomerType__c
                                            ,CompanyRegisterNumber__c
                                            ,CorporateCode__c
                                            ,SubCompanyRegisterNumber__c
                                            ,LegalStatus__c
                                            ,RepresentativeName__c
                                            ,RepresentativeBirthDate__c
                                            ,BusinessConditions__c
                                            ,BusinessCategory__c
                                            ,Phone
                                            ,Fax
                                            ,PV_VKGRP__c
                                            ,SalesGroupFromDate__c
                                            ,PICCode__c
                                            ,ResponsibilityMAFromDate__c
                                            ,ResponsibilityAMA__c
                                            ,FWReleaseCenter__c
                                            ,FWReleaseCenterFromDate__c
                                            ,TaxInvoiceType__c
                                            ,TaxationType__c
                                            ,IsHeadShopUseYN__c
                                            ,HeadOfficeCode__c
                                            ,IsAffiliatedcompanyYN__c
                                            ,CountryKeyCode__c
                                            ,PV_KNVKTYPE__c
                                            ,ShutDownDate__c
                                            ,LocationState__c
                                            ,PostalCode__c
                                            ,Address__c
                                            ,AddressDetails__c
                                            ,Address2__c
                                            ,AffiliatedCompany__c
                                            ,AddressDetails2__c //여기까지 기본정보, AffiliatedCompanyCode__c(주석되어있음)
                                            ,SalesForm__c
                                            ,CustomerStatus__c
                                            ,SortKey__c
                                            ,MediateAccount__c
                                            ,CashManagementGroup__c
                                            ,TaxClassification__c
                                            ,TaxPaymentMethod__c //여기까지 회계정보
                                            ,CustomerRoute__c
                                            ,CustomerRouteFromDate__c
                                            ,PriceGroup__c
                                            ,PriceGroupFromDate__c
                                            ,UnitPriceGroup__c
                                            ,UnitPriceGroupFromDate__c
                                            ,CurrencyIsoCode
                                            ,StatementOfDeliveryType__c
                                            ,SubsidyType__c
                                            ,StatementOfDeliveryType2__c
                                            ,CustomerOrderDeadlineType__c
                                            ,IsPrintVirtualAccount__c
                                            ,TermsOfPayment__c
                                            ,DisHisRegType__c
                                            ,CustomerPath__c
                                            ,CustomerPathFromDate__c
                                            ,IsFaceToFaceInspectionStatus__c
                                            ,OTD__c
                                            ,ProductLoadingCondition__c
                                            ,ReturnLocation__c
                                            ,VehicleEntryCondtions__c
                                            ,UnloadConditions1__c
                                            ,UnloadConditions2__c
                                            ,DeliveryGroup__c
                                            ,ShipmentArea__c
                                            ,IsBusinessPlaceKey__c
                                            ,BusinessPlaceKeyInfo__c
                                            ,KXOTD__c
                                            ,KXOTDRequestDate__c
                                            ,InitialDeliveryShare__c
                                            ,InitialDeliveryRequestDate__c
                                            ,InitialDeliveryRequestTime__c
                                            ,IsInitialDeliveryFTFInspection__c
                                            ,InitialDeliveryContact__c
                                            ,InitialDeliveryDescription__c
                                            ,PV_SHIPTYPE__c
                                            ,PV_TEMPTARGET__c //여기까지 영업기회
                                            ,(SELECT id, Name, AccountId, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, Gender__c, Fax, OtherInfo__c, OwnerId, PV_TALKT_VK__c FROM Contacts)
                                        FROM Account WHERE Id =: accountId LIMIT 1];
        
        // system.debug('accountList[0].CustomerId__c' + json.serialize(accountList[0].CustomerId__c));
        // system.debug('String.isNotBlank(accountList[0].CustomerId__c)' + json.serialize(String.isNotBlank(accountList[0].CustomerId__c)));
        // system.debug('String.isNotBlank(accountList[0].CustomerId__c)' + String.isNotBlank(accountList[0].CustomerId__c));
        // system.debug('accountList[0].PV_VKGRP__c' + accountList[0].PV_VKGRP__c);
        system.debug('TEST 중');
        

        /**
         * 1. AccountList for문돌려서 key뽑아냄
         * 2. Reference코드 셀렉해서 key넣고 map만듬
         */
        Set<String> accCodeSet = new Set<String>();
        for(Account acc :AccountList){
                accCodeSet.add(acc.PV_VKGRP__c);
        }

         List<MDMReferenceCode__c> mdmReferenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c =: accCodeSet];

        Map<String, String> codeToNameMap = new Map<String, String>();
        for(MDMReferenceCode__c mdmCode :mdmReferenceCodeList){ 
            codeToNameMap.put(mdmCode.Code__c, mdmCode.Name);
        }

        // 이거를 하는 이유는 MDM등록수정obj에 데이터가 있는지 확인하기 위해서임
        // CustomerId__c 자체가 Null값이면 에러 남.(key이기때문에)
        if(String.isNotBlank(accountList[0].CustomerId__c)){
           List<MDMRegRequestCustomer__c> mdmRegRequestCustomerList = [
                SELECT Id, RecordTypeId, RequestType__c, PV_OLDCD__c, PV_NAME1__c, PV_NAME_G__c, PV_NAME2__c, PV_KTOKD__c, PV_CUSTTYPE__c, PV_STCD2__c, PV_STCD3__c, PV_STCD4__c, PV_GFORM__c, PV_J_1KFREPRE__c, PV_STCD1__c, 
                        PV_J_1KFTBUS__c, PV_J_1KFTIND__c, PV_TELF1__c, PV_TELFX__c, PV_VKGRP__c, PVRA_VKGRP__c, PV_PERNR__c, PV_PERNR_lu__c, PVRA_PERNR__c, PV_ADMINMA__c, PV_ADMINMA_lu__c, PV_LOGISCENTER__c, PVRA_LOGISCENTER__c, 
                        PV_STCDT__c, PV_FITYP__c, PV_HDOFFICEYN__c, PV_HKUNNR_lu__c, PV_HKUNNR__c, PV_VBUND__c, PV_LAND1__c, PV_KNVKTYPE__c, PV_CLOSEDT__c, PV_REGIO__c, PV_ADRES_ZIPCODE__c, PV_ADRES_ROADADDR1__c, 
                        PV_ADRES_ROADADDR2__c, PV_ADRES_ADDR1__c, PV_ADRES_ADDR2__c, PV_SELLER_lu__c, PV_BIZPLCODE__c, PV_BUSAB__c, PV_CESSION_KZ__c, PV_ZUAWA__c, PV_AKONT__c, PV_FDGRV__c, PV_TAXKDD__c, PV_KATR5__c, PV_CUHR1__c, 
                        PVRA_CUHR1__c, PV_KONDA__c, PVRA_KONDA__c, PV_KVGR1__c, PVRA_KVGR1__c, PV_WAERS__c, PV_KVGR3__c, PV_KVGR2__c, PV_KVGR3_BOT__c, PV_ODCLOSEGB__c, PV_VACCPRTEXCYN__c, PV_ZTERM_VV__c, PV_DSTRHISTREGYN__c, 
                        PV_OLD_BIZPLACE_NEW__c, PVRA_OLD_BIZPLACE_NEW__c, PV_EXAMYN__c, PV_SHIPREQTIME__c, PV_PRODLOADCOND__c, PV_RETURNLOC__c, PV_ENTERCOND1__c, PV_UNLOADCOND1__c, PV_UNLOADCOND2__c, PV_DELIGROUP__c, PV_KATR10__c, 
                        PV_KEYYN__c, PV_KEYINFO__c, PV_KXOTD__c, PV_KXOTDTIME__c, PV_FDINFO__c, PV_FDREQD__c, PV_FDREQT__c, PV_ISFDFTF__c, PV_FDCTINFO__c, PV_FDNOTICE__c, PV_SHIPTYPE__c, PV_TEMPTARGET__c, PV_VKGRP_lu__c, 
                        PV_LOGISCENTER_lu__c, PV_STCDT_lu__c, PV_VBUND_lu__c, PV_LAND1_lu__c, PV_REGIO_lu__c, PV_ZUAWA_lu__c, PV_AKONT_lu__c, PV_CUHR1_lu__c, PV_KONDA_lu__c, PV_KVGR1_lu__c, PV_WAERS_lu__c, PV_ZTERM_VV_lu__c, 
                        PV_OLD_BIZPLACE_NEW_lu__c, PV_DELIGROUP_lu__c, PV_KATR10_lu__c
                FROM MDMRegRequestCustomer__c
                WHERE PV_KUNNR__c =: accountList[0].CustomerId__c];

            system.debug('mdmRegRequestCustomerList[0].PV_VKGRP__c' + json.serialize(mdmRegRequestCustomerList[0].PV_VKGRP__c));
            system.debug('mdmRegRequestCustomerList[0].PV_VKGRP_lu__c' + json.serialize(mdmRegRequestCustomerList[0].PV_VKGRP_lu__c));
            


            Account account = accountList[0];
            
            List<Contact> contacts = account.Contacts;
            for (Contact contact : contacts) {
                System.debug('Contact Id: ' + contact.Id);
                System.debug('Contact Name: ' + contact.Name);
                System.debug('Contact Email: ' + contact.Email);
                // 원하는 다른 Contact 필드를 추가로 디버그할 수 있습니다.
            }
             // MDM에서 온 친구(MDMRegRequestCustomer__c 추가 + Account 편집 화면에 Account 값이 떠야 함 되어야 함 RequestType:편집으로..)
            /**
             * 1. mdmRegRequestCustomerList.isEmpty() = true : MDM등록수정요청에 ID값이 없다. MDM에서 왔다.
             */
            if(mdmRegRequestCustomerList.isEmpty()){
                system.debug('>>> MDM에서 온 데이터');
                system.debug('>>> mdmRegRequestCustomerList[0].PV_VKGRP__c ' + mdmRegRequestCustomerList[0].PV_VKGRP__c);
                /**
                 * isCRM  = true  : sfdc에서 생성 된 acocunt 
                 * isCRM  = false : MDM에서 꽂힌 데이터
                 * isEdit = true  :  Account의 Detail에서 모달 호출 한 경우
                 * isEdit = false : MDM 등록 수정 요청에서 모달 호출 한 경우 
                 */
                result.isCRM = false;
                result.isEdit = true;
            // 승인으로 온 친구 upsert
            }else{
                system.debug('>>> 승인으로 온 친구');
                system.debug('>>> mdmRegRequestCustomerList[0].PV_VKGRP__c ' + mdmRegRequestCustomerList[0].PV_VKGRP__c);
                /**
                * isCRM  = true  : sfdc에서 생성 된 acocunt 
                * isCRM  = false : MDM에서 꽂힌 데이터
                * isEdit = true  : Account의 Detail에서 모달 호출 한 경우
                * isEdit = false : MDM 등록 수정 요청에서 모달 호출 한 경우 
                */
                result.isCRM = true;
                result.isEdit = true;
                for(Account acc : accountList){
                    MDMRequest wrapperRequest = new MDMRequest();
                        // [2] : sfdc에서 생성 된 데이터로, MDMRegRequstCustomer__c에 id가 있음.
                        // objectName : MDMRegRequestCustomer__c 
                        // requestType : update
                        wrapperRequest.Account                              =       acc?.Id;
                        wrapperRequest.RecordTypeId                         =       recordIdEx;                                          
                        wrapperRequest.RequestType                          =       'Edit';                         
                        //기본정보 [S] : 주석처리 되어있으면 account에 필드 없는것임. 
                        wrapperRequest.PV_KUNNR								=       acc?.CustomerID__c;				
                        wrapperRequest.PV_OLDCD								=       acc?.CustomerIDASIS__c;				
                        wrapperRequest.PV_NAME1								=       acc?.Name;				
                        wrapperRequest.PV_NAME_G							=       acc?.NameKor__c;					
                        wrapperRequest.PV_NAME2								=       acc?.NameAlias__c;				
                        wrapperRequest.PV_KTOKD								=       acc?.AccountGroup__c;				
                        wrapperRequest.PV_CUSTTYPE							=       acc?.CustomerType__c;					
                        wrapperRequest.PV_STCD2								=       acc?.CompanyRegisterNumber__c;				
                        wrapperRequest.PV_STCD3								=       acc?.CorporateCode__c;				
                        wrapperRequest.PV_STCD4								=       acc?.SubCompanyRegisterNumber__c;				
                        wrapperRequest.PV_GFORM								=       acc?.LegalStatus__c;				
                        wrapperRequest.PV_J_1KFREPRE						=       acc?.RepresentativeName__c;						
                        wrapperRequest.PV_STCD1								=       acc?.RepresentativeBirthDate__c;				
                        wrapperRequest.PV_J_1KFTBUS							=       acc?.BusinessConditions__c;					
                        wrapperRequest.PV_J_1KFTIND							=       acc?.BusinessCategory__c;					
                        wrapperRequest.PV_TELF1								=       acc?.Phone;				
                        wrapperRequest.PV_TELFX								=       acc?.Fax;				
                        wrapperRequest.inputpv_vkgrp       					=       acc?.PV_VKGRP__c;	                                    // 영업그룹 코드 -> Name으로 변경해야함
                        wrapperRequest.PV_VKGRP           					=       acc?.PV_VKGRP__c;	                                    // 영업그룹 코드
                        wrapperRequest.PV_VKGRP_lu       				    =       mdmRegRequestCustomerList[0].PV_VKGRP_lu__c;	        // 영업그룹 id
                        //wrapperRequest.PV_VKGRP_lu						=       acc?.X;					
                        wrapperRequest.PVRA_VKGRP							=       acc?.SalesGroupFromDate__c;					
                        wrapperRequest.PV_PERNR								=       acc?.Owner.EmployeeNumber;				
                        wrapperRequest.PV_PERNR_lu						    =       acc?.OwnerId;	 				
                        wrapperRequest.PVRA_PERNR							=       acc?.ResponsibilityMAFromDate__c;					
                        wrapperRequest.PV_ADMINMA							=       acc?.ResponsibilityAMA__c;					
                        //wrapperRequest.PV_ADMINMA_lu						=       acc?.X;						
                        wrapperRequest.inputpv_LOGISCENTER				    =       acc?.FWReleaseCenter__c;                                // FW 출고센터 코드	-> Name으로 변경해야함					
                        wrapperRequest.PV_LOGISCENTER   				    =       acc?.FWReleaseCenter__c;                                // FW 출고센터 코드					
                        wrapperRequest.PV_LOGISCENTER_lu					=       mdmRegRequestCustomerList[0].PV_LOGISCENTER_lu__c;	    // FW 출고센터 id	
                        wrapperRequest.PVRA_LOGISCENTER						=       acc?.FWReleaseCenterFromDate__c;						
                        wrapperRequest.inputpv_stcdt						=       acc?.TaxInvoiceType__c;	                                // 세금계산서발행유형 코드	-> Name으로 변경해야함					
                        wrapperRequest.PV_STCDT     						=       acc?.TaxInvoiceType__c;	                                // 세금계산서발행유형 코드					
                        wrapperRequest.PV_STCDT_lu						    =       mdmRegRequestCustomerList[0].PV_STCDT_lu__c;	        // 세금계산서발행유형 id	
                        wrapperRequest.PV_FITYP								=       acc?.TaxationType__c;				
                        wrapperRequest.PV_HDOFFICEYN						=       acc?.IsHeadShopUseYN__c;						
                        wrapperRequest.PV_HKUNNR							=       acc?.HeadOfficeCode__c;                                 // [Prod확인] 실제Prod에는 headOfficeCode OR ##SELFID## 두개가 들어가네 (확인 필요)
                        wrapperRequest.PV_HKUNNR_lu						    =       acc?.ParentId; 			                             	
                        wrapperRequest.PV_SUBSIDIARYYN						=       acc?.IsAffiliatedcompanyYN__c;						
                        wrapperRequest.inputpv_vbund		    			=       acc?.AffiliatedCompany__c;                              // [Prod확인] 값이 있는게 없음(필수값아님)	
                        wrapperRequest.PV_VBUND     		    			=       acc?.AffiliatedCompany__c;                              // [Prod확인] 값이 있는게 없음(필수값아님)	
                        wrapperRequest.PV_VBUND_lu	    	    			=       mdmRegRequestCustomerList[0].PV_VBUND_lu__c;            // [Prod확인] 값이 있는게 없음(필수값아님)	
                        wrapperRequest.inputpv_land1						=       acc?.CountryKeyCode__c;                                 //국가키 코드	-> Name으로 변경해야함					
                        wrapperRequest.PV_LAND1     						=       acc?.CountryKeyCode__c;                                 //국가키 코드					
                        wrapperRequest.PV_LAND1_lu							=       mdmRegRequestCustomerList[0].PV_LAND1_lu__c;   			//국가키 id	
                        wrapperRequest.PV_KNVKTYPE							=       acc?.PV_KNVKTYPE__c;					
                        wrapperRequest.PV_CLOSEDT							=       acc?.ShutDownDate__c;					
                        wrapperRequest.inputpv_land1						=       acc?.LocationState__c;                                   // 지역 코드	-> Name으로 변경해야함					
                        wrapperRequest.PV_REGIO							    =       acc?.LocationState__c;				                     // 지역 코드					
                        wrapperRequest.PV_REGIO_lu							=       mdmRegRequestCustomerList[0].PV_REGIO_lu__c; 	         // 지역 id	
                        wrapperRequest.PV_ADRES_ZIPCODE						=       acc?.PostalCode__c;						
                        wrapperRequest.PV_ADRES_ROADADDR1					=       acc?.Address__c;							
                        wrapperRequest.PV_ADRES_ROADADDR2					=       acc?.AddressDetails__c;							
                        wrapperRequest.PV_ADRES_ADDR1						=       acc?.Address2__c;						
                        wrapperRequest.PV_ADRES_ADDR2						=       acc?.AddressDetails2__c;		                 
                        // wrapperRequest.PV_SELLER_lu                      =       acc?.X;                                                 //[수정] 판매처는 잠시,,               
                        // wrapperRequest.PV_BIZPLCODE                      =       acc?.X;                          
                        //기본정보 [E]
                        
                        //회계정보 [S]
                        wrapperRequest.PV_BUSAB                             =       acc?.SalesForm__c;                
                        wrapperRequest.PV_CESSION_KZ                        =       acc?.CustomerStatus__c;                        
                        wrapperRequest.inputpv_zuawa                        =       acc?.SortKey__c; // 정렬키 :  Account의 코드를 inputField에 넣어줌               
                        wrapperRequest.PV_ZUAWA                             =       acc?.SortKey__c;
                        wrapperRequest.PV_ZUAWA_lu                          =       mdmRegRequestCustomerList[0].PV_ZUAWA_lu__c; 
                        wrapperRequest.inputpv_akont                        =       acc?.MediateAccount__c; //조정계정 : Account의 코드를 inputField에 넣어줌           
                        wrapperRequest.PV_AKONT                             =       acc?.MediateAccount__c;                
                        wrapperRequest.PV_AKONT_lu                          =       mdmRegRequestCustomerList[0].PV_AKONT_lu__c;               
                        wrapperRequest.PV_FDGRV                             =       acc?.CashManagementGroup__c;                
                        wrapperRequest.PV_TAXKDD                            =       acc?.TaxClassification__c;                    
                        wrapperRequest.PV_KATR5                             =       acc?.TaxPaymentMethod__c;                
                        //회계정보 [E]

                        //영업정보 [E]
                        wrapperRequest.inputpv_cuhr1                            =    acc?.CustomerRoute__c;  // 고객분류 : Account의 코드를 inputField에 넣어줌     
                        wrapperRequest.PV_CUHR1                                 =    acc?.CustomerRoute__c;
                        wrapperRequest.PV_CUHR1_lu                              =    mdmRegRequestCustomerList[0].PV_CUHR1_lu__c;
                        wrapperRequest.PVRA_CUHR1                               =    acc?.CustomerRouteFromDate__c;   
                        wrapperRequest.inputpv_konda                            =    acc?.PriceGroup__c; // 가격그룹 :  Account의 코드를 inputField에 넣어줌  
                        wrapperRequest.PV_KONDA                                 =    acc?.PriceGroup__c;
                        wrapperRequest.PV_KONDA_lu                              =    mdmRegRequestCustomerList[0].PV_KONDA_lu__c;  
                        wrapperRequest.PVRA_KONDA                               =    acc?.PriceGroupFromDate__c;   
                        wrapperRequest.inputpv_kvgr1                            =    acc?.UnitPriceGroup__c; // 단가그룹(pageLayout에 빠져있음) :  Account의 코드를 inputField에 넣어줌  
                        wrapperRequest.PV_KVGR1_lu                              =    acc?.UnitPriceGroup__c;    
                        wrapperRequest.PV_KVGR1_lu                              =    mdmRegRequestCustomerList[0].PV_KVGR1_lu__c;      
                        wrapperRequest.PVRA_KVGR1                               =    acc?.UnitPriceGroupFromDate__c;   
                        wrapperRequest.inputpv_waers                            =    acc?.CurrencyIsoCode; //통화 : Account의 코드를 inputField에 넣어줌   
                        wrapperRequest.PV_WAERS                                 =    acc?.CurrencyIsoCode;
                        wrapperRequest.PV_WAERS_lu                              =    mdmRegRequestCustomerList[0].PV_WAERS_lu__c;
                        wrapperRequest.PV_KVGR3                                 =    acc?.StatementOfDeliveryType__c;   
                        wrapperRequest.PV_KVGR2                                 =    acc?.SubsidyType__c;   
                        wrapperRequest.PV_KVGR3_BOT                             =    acc?.StatementOfDeliveryType2__c;   
                        wrapperRequest.PV_ODCLOSEGB                             =    acc?.CustomerOrderDeadlineType__c;   
                        wrapperRequest.PV_VACCPRTEXCYN                          =    acc?.IsPrintVirtualAccount__c;   
                        wrapperRequest.inputpv_zterm_vv                         =    acc?.TermsOfPayment__c; //지급조건 :  Account의 코드를 inputField에 넣어줌  
                        wrapperRequest.PV_ZTERM_VV                              =    acc?.TermsOfPayment__c;
                        wrapperRequest.PV_ZTERM_VV_lu                           =    mdmRegRequestCustomerList[0].PV_ZTERM_VV_lu__c;
                        wrapperRequest.PV_DSTRHISTREGYN                         =    acc?.DisHisRegType__c;   
                        wrapperRequest.inputpv_old_bizplace_new                 =    acc?.CustomerPath__c; // 경로(사업부) : Account의 코드를 inputField에 넣어줌    
                        wrapperRequest.PV_OLD_BIZPLACE_NEW                      =    acc?.CustomerPath__c;
                        wrapperRequest.PV_OLD_BIZPLACE_NEW_lu                   =    mdmRegRequestCustomerList[0].PV_OLD_BIZPLACE_NEW_lu__c;
                        wrapperRequest.PVRA_OLD_BIZPLACE_NEW                    =    acc?.CustomerPathFromDate__c;   
                        wrapperRequest.PV_EXAMYN                                =    acc?.IsFaceToFaceInspectionStatus__c;   
                        wrapperRequest.PV_SHIPREQTIME                           =    acc?.OTD__c;   
                        wrapperRequest.PV_PRODLOADCOND                          =    acc?.ProductLoadingCondition__c;   
                        wrapperRequest.PV_RETURNLOC                             =    acc?.ReturnLocation__c;   
                        wrapperRequest.PV_ENTERCOND1                            =    acc?.VehicleEntryCondtions__c;   
                        wrapperRequest.PV_UNLOADCOND1                           =    acc?.UnloadConditions1__c;   
                        wrapperRequest.PV_UNLOADCOND2                           =    acc?.UnloadConditions2__c;   
                        wrapperRequest.inputpv_deligroup                        =    acc?.DeliveryGroup__c; // 배송그룹 : Account의 코드를 inputField에 넣어줌  
                        wrapperRequest.PV_DELIGROUP                             =    acc?.DeliveryGroup__c;   
                        wrapperRequest.PV_DELIGROUP_lu                          =    mdmRegRequestCustomerList[0].PV_DELIGROUP_lu__c;   
                        wrapperRequest.inputPV_KATR10                           =    acc?.ShipmentArea__c;  //출하권역 : Account의 코드를 inputField에 넣어줌
                        wrapperRequest.PV_KATR10                                =    acc?.ShipmentArea__c; 
                        wrapperRequest.PV_KATR10_lu                             =    mdmRegRequestCustomerList[0].PV_KATR10_lu__c;  
                        wrapperRequest.PV_KEYYN                                 =    acc?.IsBusinessPlaceKey__c;   
                        wrapperRequest.PV_KEYINFO                               =    acc?.BusinessPlaceKeyInfo__c;   
                        wrapperRequest.PV_KXOTD                                 =    acc?.KXOTD__c;   
                        wrapperRequest.PV_KXOTDTIME                             =    acc?.KXOTDRequestDate__c;   
                        wrapperRequest.PV_FDINFO                                =    acc.InitialDeliveryShare__c == 'Y' ? true : false; //acc?.InitialDeliveryShare__c;   
                        wrapperRequest.PV_FDREQD                                =    acc?.InitialDeliveryRequestDate__c;   
                        wrapperRequest.PV_FDREQT                                =    acc?.InitialDeliveryRequestTime__c;   
                        wrapperRequest.PV_ISFDFTF                               =    acc?.IsInitialDeliveryFTFInspection__c;   
                        wrapperRequest.PV_FDCTINFO                              =    acc?.InitialDeliveryContact__c;   
                        wrapperRequest.PV_FDNOTICE                              =    acc?.InitialDeliveryDescription__c;   
                        wrapperRequest.PV_SHIPTYPE                              =    acc?.PV_SHIPTYPE__c;   
                        wrapperRequest.PV_TEMPTARGET                            =    acc?.PV_TEMPTARGET__c;   

                        result.mdmRequest = wrapperRequest;
                        List<CustomContacts> customContactsList = new List<CustomContacts>(); // CustomContacts 객체를 저장할 리스트

                        for (Contact con : acc.Contacts) {
                            CustomContacts wrapperConRequest = new CustomContacts();
                            wrapperConRequest.id = con.Id;
                            wrapperConRequest.Name = con.Name;
                            wrapperConRequest.AccountId = con.AccountId;
                            wrapperConRequest.Email = con.Email;
                            wrapperConRequest.Phone = con.Phone;
                            wrapperConRequest.MobilePhone = con.MobilePhone;
                            wrapperConRequest.Department = con.Department;
                            wrapperConRequest.PV_PAFKT_VK = con.PV_PAFKT_VK__c;
                            wrapperConRequest.Gender = con.Gender__c;
                            wrapperConRequest.Fax = con.Fax;
                            wrapperConRequest.OtherInfo = con.OtherInfo__c;
                            wrapperConRequest.OwnerId = con.OwnerId;
                            wrapperConRequest.PV_TALKT_VK = con.PV_TALKT_VK__c;
                            
                            customContactsList.add(wrapperConRequest); // CustomContacts 객체를 리스트에 추가
                            result.CustomContacts = customContactsList;
                            System.debug('AccountId를 룩업하고 있는 ContactId2 ' + result.CustomContacts);
                            System.debug('wrapperConRequest ' + JSON.serialize(customContactsList));
                        }
                        system.debug('wrapperRequest ' + JSON.serialize(wrapperRequest));
                    result.mdmRequest = wrapperRequest;
                }
            }
        }else{
            
        }
      
        return result;
    }

    /**
     * MDMRequest 공통
     */
    public class MDMRequest{
        //필드 총 3 + 49 + 9 + 45
        //기존 3
        @AuraEnabled public String Account {get;set;}
        @AuraEnabled public String RecordTypeId {get;set;}
        @AuraEnabled public String RequestType {get;set;}
        //기본 49
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
        @AuraEnabled public String PV_VKGRP_lu {get;set;}
        @AuraEnabled public Date   PVRA_VKGRP {get;set;}
        @AuraEnabled public String PV_PERNR {get;set;}
        @AuraEnabled public String PV_PERNR_lu {get;set;}
        @AuraEnabled public Date   PVRA_PERNR {get;set;}
        @AuraEnabled public String PV_ADMINMA {get;set;}
        @AuraEnabled public String PV_ADMINMA_lu {get;set;}
        @AuraEnabled public String PV_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_LOGISCENTER_lu {get;set;}
        @AuraEnabled public Date   PVRA_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_STCDT {get;set;}
        @AuraEnabled public String PV_STCDT_lu {get;set;}
        @AuraEnabled public String PV_FITYP {get;set;}
        @AuraEnabled public Boolean PV_HDOFFICEYN {get;set;}
        @AuraEnabled public String PV_HKUNNR {get;set;}
        @AuraEnabled public String PV_HKUNNR_lu {get;set;}
        @AuraEnabled public Boolean PV_SUBSIDIARYYN {get;set;} //0913추가
        @AuraEnabled public String PV_VBUND {get;set;}
        @AuraEnabled public String PV_VBUND_lu {get;set;}
        @AuraEnabled public String PV_LAND1 {get;set;}
        @AuraEnabled public String PV_LAND1_lu {get;set;}
        @AuraEnabled public String PV_KNVKTYPE {get;set;}
        @AuraEnabled public Date   PV_CLOSEDT {get;set;}
        @AuraEnabled public String PV_REGIO {get;set;}
        @AuraEnabled public String PV_REGIO_lu {get;set;}
        @AuraEnabled public String PV_ADRES_ZIPCODE {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR2 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR2 {get;set;}
        @AuraEnabled public String PV_SELLER_lu {get;set;}
        @AuraEnabled public String PV_BIZPLCODE {get;set;}
        //기준정보 완료


        //회계정보 9
        @AuraEnabled public String PV_BUSAB {get;set;}
        @AuraEnabled public String PV_CESSION_KZ {get;set;}
        @AuraEnabled public String PV_ZUAWA {get;set;}
        @AuraEnabled public String PV_ZUAWA_lu {get;set;}
        @AuraEnabled public String PV_AKONT {get;set;}
        @AuraEnabled public String PV_AKONT_lu {get;set;}
        @AuraEnabled public String PV_FDGRV {get;set;}
        @AuraEnabled public String PV_TAXKDD {get;set;}
        @AuraEnabled public String PV_KATR5 {get;set;}

        //영업정보 45
        @AuraEnabled public String PV_CUHR1 {get;set;}
        @AuraEnabled public String PV_CUHR1_lu {get;set;}
        @AuraEnabled public Date   PVRA_CUHR1 {get;set;}
        @AuraEnabled public String PV_KONDA {get;set;}
        @AuraEnabled public String PV_KONDA_lu {get;set;}
        @AuraEnabled public Date   PVRA_KONDA {get;set;}
        @AuraEnabled public String PV_KVGR1 {get;set;}
        @AuraEnabled public String PV_KVGR1_lu {get;set;}
        @AuraEnabled public Date   PVRA_KVGR1 {get;set;}
        @AuraEnabled public String PV_WAERS {get;set;}
        @AuraEnabled public String PV_WAERS_lu {get;set;}
        @AuraEnabled public String PV_KVGR3 {get;set;}
        @AuraEnabled public String PV_KVGR2 {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT {get;set;}
        @AuraEnabled public String PV_ODCLOSEGB {get;set;}
        @AuraEnabled public Boolean PV_VACCPRTEXCYN {get;set;}
        @AuraEnabled public String PV_ZTERM_VV {get;set;}
        @AuraEnabled public String PV_ZTERM_VV_lu {get;set;}
        @AuraEnabled public String PV_DSTRHISTREGYN {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW_lu {get;set;}
        @AuraEnabled public Date   PVRA_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public Boolean PV_EXAMYN {get;set;}
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
        @AuraEnabled public Boolean PV_KEYYN {get;set;}
        @AuraEnabled public String PV_KEYINFO {get;set;}
        @AuraEnabled public String PV_KXOTD {get;set;}
        @AuraEnabled public String PV_KXOTDTIME {get;set;}
        @AuraEnabled public Boolean PV_FDINFO {get;set;}
        @AuraEnabled public Date   PV_FDREQD {get;set;}
        @AuraEnabled public String PV_FDREQT {get;set;}
        @AuraEnabled public Boolean PV_ISFDFTF {get;set;}
        @AuraEnabled public String PV_FDCTINFO {get;set;}
        @AuraEnabled public String PV_FDNOTICE {get;set;}
        @AuraEnabled public String PV_SHIPTYPE {get;set;}
        @AuraEnabled public String PV_TEMPTARGET {get;set;}

        //inputField
        @AuraEnabled public String inputpv_vkgrp {get;set;}
        @AuraEnabled public String inputpv_vbund {get;set;}
        @AuraEnabled public String inputpv_land1 {get;set;}
        @AuraEnabled public String inputpv_stcdt {get;set;}
        @AuraEnabled public String inputpv_zuawa {get;set;}
        @AuraEnabled public String inputpv_akont {get;set;}
        @AuraEnabled public String inputpv_cuhr1 {get;set;}
        @AuraEnabled public String inputpv_konda {get;set;}
        @AuraEnabled public String inputpv_kvgr1 {get;set;}
        @AuraEnabled public String inputpv_waers {get;set;}
        @AuraEnabled public String inputpv_zterm_vv {get;set;}
        @AuraEnabled public String inputpv_old_bizplace_new {get;set;}
        @AuraEnabled public String inputpv_deligroup {get;set;}
        @AuraEnabled public String inputPV_KATR10 {get;set;}
        @AuraEnabled public String inputpv_LOGISCENTER {get;set;}
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
    public class CustomBanks{
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String PV_BANKL {get;set;}
        @AuraEnabled public String PV_BANKN {get;set;}
        @AuraEnabled public String PV_KOINH {get;set;}
        @AuraEnabled public String PV_BKONT {get;set;}
        @AuraEnabled public String PV_BVTYP {get;set;}
        @AuraEnabled public String PV_BKREF {get;set;}
        @AuraEnabled public Boolean PV_ACTCLOSEYN {get;set;}
        @AuraEnabled public Date PV_ACTCLOSED {get;set;}
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
        @AuraEnabled public List<Map<String,  String>> listCustomerOrderType {get;set;}
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
        @AuraEnabled public String RequestType {get;set;}
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
            //Id,  Lastname,  Firstname,  Email,  Phone,  MobilePhone,  Department,  PV_PAFKT_VK__c,  PV_TALKT_VK__c,  PV_KNVKGB__c
            for(Contact con : acc.Contacts){
                String LastName = con.LastName;
                contactList.add(new ContactWrapper(LastName,  acc.id));
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
            this.RequestType = '';
            this.RecordTypeId = '';

            
        }
    }

    public class ContactWrapper {
        @AuraEnabled public String lastName {get; set;}
        @AuraEnabled public String id {get; set;}
        public ContactWrapper(String lastName,  String id){
            this.lastName = lastName;
            this.id = id;
        }
    }

    /** 관리처 생성 시 저장되는 데이터 API
     * RecordTypeId
       requestType__c
       PV_OLDCD__c
       PV_NAME1__c
       PV_NAME_G__c
       PV_NAME2__c
       PV_KTOKD__c
       PV_CUSTTYPE__c
       PV_STCD2__c
       PV_STCD3__c
       PV_STCD4__c
       PV_GFORM__c
       PV_J_1KFREPRE__c
       PV_STCD1__c
       PV_J_1KFTBUS__c
       PV_J_1KFTIND__c
       PV_TELF1__c
       PV_TELFX__c
       PV_VKGRP__c
       PVRA_VKGRP__c
       PV_PERNR__c
       PV_PERNR_lu__c
       PVRA_PERNR__c
       PV_ADMINMA__c
       PV_ADMINMA_lu__c
       PV_LOGISCENTER__c
       PVRA_LOGISCENTER__c
       PV_STCDT__c
       PV_FITYP__c
       PV_HDOFFICEYN__c
       PV_HKUNNR_lu__c
       PV_HKUNNR__c
       PV_VBUND__c
       PV_LAND1__c
       PV_LAND1_lu__c
       PV_KNVKTYPE__c
       PV_CLOSEDT__c
       PV_REGIO__c
       PV_ADRES_ZIPCODE__c
       PV_ADRES_ROADADDR1__c
       PV_ADRES_ROADADDR2__c
       PV_ADRES_ADDR1__c
       PV_ADRES_ADDR2__c
       PV_SELLER_lu__c
       PV_BIZPLCODE__c
       PV_BUSAB__c
       PV_CESSION_KZ__c
       PV_ZUAWA__c
       PV_AKONT__c
       PV_FDGRV__c
       PV_TAXKDD__c
       PV_KATR5__c
       PV_CUHR1__c
       PVRA_CUHR1__c
       PV_KONDA__c
       PVRA_KONDA__c
       PV_KVGR1__c
       PVRA_KVGR1__c
       PV_WAERS__c
       PV_KVGR3__c
       PV_KVGR2__c
       PV_KVGR3_BOT__c
       PV_ODCLOSEGB__c
       PV_VACCPRTEXCYN__c
       PV_ZTERM_VV__c
       PV_DSTRHISTREGYN__c
       PV_OLD_BIZPLACE_NEW__c
       PVRA_OLD_BIZPLACE_NEW__c
       PV_EXAMYN__c
       PV_SHIPREQTIME__c
       PV_PRODLOADCOND__c
       PV_RETURNLOC__c
       PV_ENTERCOND1__c
       PV_UNLOADCOND1__c
       PV_UNLOADCOND2__c
       PV_DELIGROUP__c
       PV_KATR10__c
       PV_KEYYN__c
       PV_KEYINFO__c
       PV_KXOTD__c
       PV_KXOTDTIME__c
       PV_FDINFO__c
       PV_FDREQD__c
       PV_FDREQT__c
       PV_ISFDFTF__c
       PV_ISFDFTF__c
       PV_FDCTINFO__c
       PV_FDNOTICE__c
       PV_SHIPTYPE__c
       PV_TEMPTARGET__c
       PV_VKGRP_lu__c
       PV_LOGISCENTER_lu__c
       PV_STCDT_lu__c
       PV_VBUND_lu__c
       PV_LAND1_lu__c
       PV_REGIO_lu__c
       PV_ZUAWA_lu__c
       PV_AKONT_lu__c
       PV_CUHR1_lu__c
       PV_KONDA_lu__c
       PV_KVGR1_lu__c
       PV_WAERS_lu__c
       PV_ZTERM_VV_lu__c
       PV_OLD_BIZPLACE_NEW_lu__c
       PV_DELIGROUP_lu__c
       PV_KATR10_lu__c
     */


}