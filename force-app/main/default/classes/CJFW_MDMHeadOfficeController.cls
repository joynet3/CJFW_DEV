/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 10-10-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   10-06-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMHeadOfficeController{
    /**
    * =======================================================================================================================
    * @description : [1. MDMRegRequestCustomer__c 생성 시]기본값 셋팅(레코드Id, 고객 주문마감 유형코드, 요청자 사원번호 세팅)
    * 
    * @params      : X
    * @return      : `DataWrapper`
    * =======================================================================================================================
    */
    @AuraEnabled
    public static DataWrapper setCreateDefaultInfo(){
        system.debug(' ### CJFW_MDMManagementController.setCreateDefaultInfo ');
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';                       // Sccess 시 
        String strMessage = '';                             // Error 시 메세지
        String MDMRecordTypeId = '';                        // MDMRegRequestCustomer__c의 '관리처' RecordId
        String strObjectType = 'MDMRegRequestCustomer__c';  // object api명
        String recordTypeName = 'MDMParent';            // recordType api명
        try{
            // 요청자 사원번호 세팅위해 조회 함 
            User objUser =[
                SELECT Id,  LastName,  EmployeeNumber FROM User
                WHERE Id =:UserInfo.getUserId() //현재 로그인한 사용자의 ID를 반환하는 Apex 내장 함수
                ];
            
            objWrapper.strObjectType = strObjectType;    
            objWrapper.objUser = objUser;
            MDMRecordTypeId = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            // 고객 주문마감 유형코드
            objWrapper.listCustomerOrderType = CommonUtil.getPickListValues('MDMRegRequestCustomer__c', 'PV_ODCLOSEGB__c', true);
            
            
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
    * =======================================================================================================================
    * @description : 출고센터, 고객분류 변경시 고객 주문마감 유형코드 SelectList 변경
    * 
    * @params      : strType : LOGIC(출고센터), CUHR(고객분류)
    * @params      : mdmCustomerType MDM 고객 구분(MDMParent : 본점, MDMChild : 판매처)  
    * @return      : `DataWrapper`
    * =======================================================================================================================
    */
    @AuraEnabled
    public static DataWrapper doCheckOrderType(String strType, String PV_LOGISCENTER, String PV_CUHR1) {
        try {
            DataWrapper objWrapper = new DataWrapper();
            String strStatus = 'SUCCESS';
            String strMessage = '';
            String PV_ODCLOSEGB = '';
            System.debug('==============> strType : '+strType);
            System.debug('==============> PV_LOGISCENTER : '+PV_LOGISCENTER);
            // 고객분류 코드 앞에 숫자4자리만 가져오기
            System.debug('==============> before PV_CUHR1 : '+PV_CUHR1);
            if(PV_CUHR1 <> null && PV_CUHR1.contains('-')) {
                PV_CUHR1 = PV_CUHR1.split('-')[0];
            }
            System.debug('==============> after PV_CUHR1 : '+PV_CUHR1);

            // MDMCustomerOrderType__c obj에서 선택된 Fw출고센터&고객분류에 맞는 고객주문마감 유형코드 리스트 가져오기
            Set<String> setCloseGB = new Set<String>();
            String strQuery = 'SELECT Id, CUHR1__c, LOGISCENTER__c, CLOSEGB__c';
            strQuery += ' FROM  MDMCustomerOrderType__c';
            
            if(strType == 'LOGIC') {
                strQuery += ' WHERE LOGISCENTER__c LIKE \'%'+PV_LOGISCENTER+'%\'';
            }else {                
                strQuery += ' WHERE CUHR1__c =\''+PV_CUHR1+'\'';
            }
            
            strQuery += '   ORDER BY CLOSEGB__c ASC';
            System.debug('Database.query(strQuery)' + Database.query(strQuery));
            // 고객주문마감 유형코드 리스트에서 중복된 코드들 제외
            for(MDMCustomerOrderType__c obj : Database.query(strQuery)) {
                // System.debug('=========> obj.CUHR1__c : '+obj.CUHR1__c);
                // System.debug('=========> obj.PV_CUHR1 : '+PV_CUHR1);
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
            // 고객주문마감 유형코드 pickList 가져오기
            List<Map<String, String>> listOrderType = CommonUtil.getPickListValues('MDMRegRequestCustomer__c', 'PV_ODCLOSEGB__c', false);
            
            List<Map<String, String>> listCustomerOrderType = new List<Map<String, String>>();
            // setCloseGB에 값이 있다면 pickList중 코드가 일치한 pickList value 값 가져오기
            if(!setCloseGB.isEmpty()) {
                for(Map<String, String> mapTarget : listOrderType) {
                    if(setCloseGB.contains(mapTarget.get('value'))) {
                        listCustomerOrderType.add(mapTarget);
                    }
                }
            }else {
                listCustomerOrderType = listOrderType;
            }
            objWrapper.listCustomerOrderType = listCustomerOrderType;
            System.debug('listOrderType =>' + listCustomerOrderType);
            objWrapper.strStatus = strStatus;
            return objWrapper;
        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
            
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * =======================================================================================================================
    * @description : [2. MDMRegRequestCustomer__c에서 수정 시]
    * 
    * @params      : mdmCustomerId(MDMReqRequestCustomer__c의 Id)
    * @return      : `DataWrapper`
    * =======================================================================================================================
    */
    @AuraEnabled 
    public static DataWrapper setEditMDMInfo(String mdmCustomerId ){
        system.debug(' ### CJFW_MDMManagementController.getMDMInfo ');
        system.debug(' >>> mdmCustomerId ' + mdmCustomerId);
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';                       // Sccess 시 
        String strMessage = '';                             // Error 시 메세지
        String MDMRecordTypeId = '';                        // MDMRegRequestCustomer__c의 '관리처' RecordId
        String strObjectType = 'MDMRegRequestCustomer__c';  // object api명
        try{
            // 요청자 사원번호 세팅위해 조회 함 
            User objUser =[
                SELECT Id,  LastName,  EmployeeNumber FROM User
                WHERE Id =:UserInfo.getUserId()
                ];
            objWrapper.strObjectType = strObjectType;    
            objWrapper.objUser = objUser;
            
            MDMRegRequestCustomer__c objMDMRegReqCustomer = [
                SELECT  Id, Name, RecordTypeId, Account__c, Opportunity__c, opcode__c, INSTANCEID__c, PROCID__c, REQACTORID__c,
                        PV_CRMNO__c, PV_KUNNR__c, PV_OLDCD__c, PV_NAME1__c, PV_NAME_G__c, PV_NAME2__c, PV_KTOKD__c, PV_CUSTTYPE__c,
                        PV_STCD2__c, PV_STCD3__c, PV_STCD4__c, PV_GFORM__c, PV_J_1KFREPRE__c, PV_BLCKYN__c, PV_STCD1__c,
                        PV_ESALESPROFITRATE__c, PV_J_1KFTBUS__c, PV_ESALESPROFIT__c, PV_J_1KFTIND__c, PV_SUPFEERATE__c,
                        PV_ECPROFITRATE__c, PV_ECPROFIT__c, PV_TELF1__c, PV_TELFX__c, PV_RESEPROFIT__c, PV_PAYCUST__c,
                        PV_CHARGECUST__c, PV_RESEEARN__c, PV_RESESALES__c, PV_SPECIALNOTE__c, PV_ISCOLFEE__c, PV_VKGRP__c,
                        PV_AMOUNTCOL__c, PV_PROVCOL__c, PV_DEPOSITF__c, PV_DEPOSIT__c, PV_DEPOSITYN__c, PV_COMMRATE__c,
                        PVVF_VKGRP__c, PV_ETCSUP__c, PVRA_VKGRP__c, PV_DONATION__c, PV_SUBSIDY__c, PV_PERNR__c, PV_DEPRE__c,
                        PVVF_PERNR__c, PV_SUPPOINT__c, PVRA_PERNR__c, PV_ETCRATE__c, PV_ADMINMA__c, PV_CARDFRATE__c, PV_CGRRATE__c,
                        PV_LOGISCENTER__c, PV_LRATE__c, PV_LOGISRATIO__c, PV_SALESMNG__c, PV_ETCSALESFEE__c, PV_DELAVG__c,
                        PV_NUMPARTNER__c, PV_NUMSKU__c, PV_GSALESFEE__c, PV_EXSALESFEE__c, PV_SKUPERSALESFC__c, PV_DROPSIZEFC__c,
                        PV_SALESPERSTOREFC__c, PV_GPROFITFC__c, PV_EXPROFITFC__c, PV_GSALESFC__c, PV_EXSALESFC__c, PV_ESALESFC__c,
                        PV_EPROFIT__c, PV_ESALES__c, PV_TERMT__c, PV_EXISTSUP__c, PV_TERMF__c, PV_STORECNT__c, PV_CSHAPE__c,
                        PVVF_LOGISCENTER__c, PVRA_LOGISCENTER__c, PV_STCDT__c, PV_BIZPLCODE__c, PV_STATUSTYPE__c, PV_FITYP__c, PV_HDOFFICEYN__c,
                        PV_HKUNNR__c, PV_SUBSIDIARYYN__c, PV_ORDERMA__c, PV_LIFNR__c, PV_TEMPTARGET__c, PV_SHIPTYPE__c, PV_FDNOTICE__c,
                        PV_LAND1__c, PV_FDCTINFO__c, PV_ISFDFTF__c, PV_FDREQT__c, PV_KNVKTYPE__c, PV_FDREQD__c, PV_CLOSEDT__c, PV_KXOTDTIME__c,
                        PV_KEYINFO__c, PV_KEYYN__c, PV_KATR10__c, PV_REGIO__c, PV_ADRES_ZIPCODE__c, PV_ADRES_SEQ__c, PV_DELIGROUP__c,
                        PV_ADRES_ADDR1__c, PV_ADRES_ADDR2__c, PV_UNLOADCOND2__c, PV_ADRES_ROADADDR1__c, PV_ADRES_ROADADDR2__c,
                        PV_UNLOADCOND1__c, PV_ADRES_ROADMGMTNO__c, PV_BUSAB__c, PV_ENTERCOND1__c, PV_CESSION_KZ__c, PV_RETURNLOC__c,
                        PV_PRODLOADCOND__c, PV_SHIPREQTIME__c, PV_EXAMYN__c, PV_SHAPE__c, PVRA_OLD_BIZPLACE_NEW__c, PVVF_OLD_BIZPLACE_NEW__c,
                        PV_ZUAWA__c, PV_OLD_BIZPLACE_NEW__c, PV_KULTG__c, PV_DSTRHISTREGYN__c, PV_ZTERM_VV__c, PV_VACCPRTEXCYN__c,
                        PV_AKONT__c, PV_ODCLOSEGB__c, PV_KVGR3_BOT__c, PV_KVGR2__c, PV_FDGRV__c, PV_KVGR3__c, PV_VRSDG__c, PVRA_KVGR1__c,
                        PV_TAXKDD__c, PVVF_KVGR1__c, PV_KATR5__c, PV_KVGR1__c, PVRA_KONDA__c, PV_CUHR1__c, PVVF_KONDA__c, PV_KONDA__c,
                        PVRA_CUHR1__c, PVVF_CUHR1__c, PV_SALESCUST__c, PV_DELICUST__c, PV_FDINFO__c, PV_KXOTD__c, PV_KDGRP__c, PV_VBUND__c,
                        PV_VKGRP_lu__c, PV_LOGISCENTER_lu__c, PV_STCDT_lu__c, PV_VBUND_lu__c, PV_LIFNR_lu__c, PV_LAND1_lu__c, PV_REGIO_lu__c,
                        PV_ZUAWA_lu__c, PV_AKONT_lu__c, PV_CUHR1_lu__c, PV_KONDA_lu__c, PV_KVGR1_lu__c, PV_WAERS_lu__c, PV_KVGR3_lu__c,
                        PV_KVGR3_BOT_lu__c, PV_ZTERM_VV_lu__c, PV_OLD_BIZPLACE_NEW_lu__c, PV_DELIGROUP_lu__c, PV_KATR10_lu__c, PV_WAERS__c,
                        PV_PERNR_lu__c, PV_ADMINMA_lu__c, PV_HKUNNR_lu__c, PV_PAYCUST_lu__c, IsSelf_PV_PAYCUST__c, PV_CHARGECUST_lu__c,
                        IsSelf_PV_CHARGECUST__c, Status__c, WF_DESCRIPTION__c, PV_SELLER_lu__c
                FROM    MDMRegRequestCustomer__c
                WHERE   Id =:mdmCustomerId];
            MDMRecordTypeId = objMDMRegReqCustomer.RecordTypeId;
            objWrapper.objMDMRegReqCustomer = objMDMRegReqCustomer;
            // mdmCustomerId로 MDMRegRequestContact__c 조회
            List<MDMRegRequestContact__c> listMDMReqContact = [
                SELECT  Id, MDMRegRequestCustomer__c,
                        INSTANCEID__c, PV_NO__c, PV_NAME1_VK__c, PV_KNVKGB__c, PV_TELF1_VK__c, PV_ABTNR_VK__c, PV_PAFKT_VK__c,
                        PV_TALKT_VK__c, PV_EMAIL_VK__c, PV_KNVKGB_lu__c, Contact__c
                FROM    MDMRegRequestContact__c
                WHERE   MDMRegRequestCustomer__c =:mdmCustomerId
            ];
            
            objWrapper.listMDMReqContact = listMDMReqContact;
            // 고객 주문마감 유형코드
            objWrapper.listCustomerOrderType = doCheckOrderType('LOGIC', objMDMRegReqCustomer.PV_LOGISCENTER__c, objMDMRegReqCustomer.PV_CUHR1__c).listCustomerOrderType;
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
    * =======================================================================================================================
    * @description : [3. Account Detail에서 수정 시]
    * 
    * @params      : accountId(Accout의 Id)
    * @return      : `DataWrapper`
    * =======================================================================================================================
    */
    @AuraEnabled 
    public static DataWrapper getAccountInfo(String accountId){
        String strStatus = 'SUCCESS';                       // Sccess 시 
        String strMessage = '';                             // Error 시 메세지
        String MDMRecordTypeId = '';                        // MDMRegRequestCustomer__c의 '관리처' RecordId
        String strObjectType = 'Account';                   // object api명
        String recordTypeName = 'MDMParent';                // recordType api명
        system.debug(' ### CJFW_MDMManagementController > getAccountInfo() ');
        system.debug(' >>> accountId ' + accountId);
        Id recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
       
        DataWrapper objWrapper = new DataWrapper();
        try{
            // 요청자 사원번호 세팅위해 조회 함 
            User objUser =[
                SELECT Id,  LastName,  EmployeeNumber FROM User
                WHERE Id =:UserInfo.getUserId()
                ];
            objWrapper.objUser = objUser;
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
                                                ,(SELECT id, Name, AccountId, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, Gender__c, Fax, OtherInfo__c, OwnerId, PV_KNVKGB__c FROM Contacts)
                                            FROM Account WHERE Id =: accountId LIMIT 1];
            // accountId로 Contact조회
            List<Contact> listReqContactList = [SELECT  Id, AccountId, Name, PV_NO__c, PV_KNVKGB__c, MobilePhone, Department, PV_PAFKT_VK__c, Email, PV_TALKT_VK__c
                                                FROM    Contact
                                                WHERE   AccountId =:accountId];
            // Contact의 코드(PV_KNVKGB__c)로 MDMReferenceCode__c 조회해서 Id값 알아내기
            Set<String> conCodeSet = new Set<String>();
            for(Contact con :listReqContactList){
                conCodeSet.add(con.PV_KNVKGB__c);
            }
            
            List<MDMReferenceCode__c> conReferenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c =: conCodeSet];
            
            // Key :code , value :Id
            Map<String, String> codeToConIdMap = new Map<String, String>();
            for(MDMReferenceCode__c conCode :conReferenceCodeList){ 
                codeToConIdMap.put(conCode.Code__c, conCode.id);
            }
            // Contact을 MDMRegRequestContact__c 매핑하여 리턴
            List<MDMRegRequestContact__c> mdmReqContactList = new List<MDMRegRequestContact__c>();
            
            // listReqContactList : accountId로 Contact조회
            for(Contact con : listReqContactList){
                MDMRegRequestContact__c mdmReqContact = new MDMRegRequestContact__c();
                    mdmReqContact.PV_NAME1_VK__c  = con.Name;
                    mdmReqContact.PV_KNVKGB__c    = con.PV_KNVKGB__c;        
                    mdmReqContact.PV_KNVKGB_lu__c = codeToConIdMap.get(con?.PV_KNVKGB__c);
                    mdmReqContact.PV_TELF1_VK__c  = con.MobilePhone;
                    mdmReqContact.PV_ABTNR_VK__c  = con.Department; 
                    mdmReqContact.PV_PAFKT_VK__c  = con.PV_PAFKT_VK__c;
                    mdmReqContact.PV_EMAIL_VK__c  = con.Email;
                    mdmReqContact.PV_TALKT_VK__c  = con.PV_TALKT_VK__c;
                    mdmReqContact.Contact__c      = con.id;
                    mdmReqContactList.add(mdmReqContact);
                
            }
            objWrapper.listMDMReqContact = mdmReqContactList;
            // 고객 주문마감 유형코드
            objWrapper.listCustomerOrderType = doCheckOrderType('LOGIC', accountList[0].FWReleaseCenter__c, accountList[0].CustomerRoute__c).listCustomerOrderType;
            // Account 코드필드들 MDMReferenceCode__c 조회해서 Id값 알아내기
            Set<String> accCodeSet = new Set<String>();
            for(Account acc :accountList){
                    accCodeSet.add(acc.PV_VKGRP__c);
                    accCodeSet.add(acc.FWReleaseCenter__c);
                    accCodeSet.add(acc.TaxInvoiceType__c);
                    accCodeSet.add(acc.CountryKeyCode__c);
                    accCodeSet.add(acc.LocationState__c);
                    accCodeSet.add(acc.SortKey__c);
                    accCodeSet.add(acc.MediateAccount__c);
                    accCodeSet.add(acc.CustomerRoute__c);
                    accCodeSet.add(acc.PriceGroup__c);
                    accCodeSet.add(acc.UnitPriceGroup__c);
                    accCodeSet.add(acc.CurrencyIsoCode);
                    accCodeSet.add(acc.TermsOfPayment__c);
                    accCodeSet.add(acc.CustomerPath__c);
                    accCodeSet.add(acc.DeliveryGroup__c);
                    accCodeSet.add(acc.ShipmentArea__c);
            }
            List<MDMReferenceCode__c> mdmReferenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c =: accCodeSet];
            // Key :code , value :Id
            Map<String, String> codeToIdMap = new Map<String, String>();
                for(MDMReferenceCode__c mdmCode :mdmReferenceCodeList){ 
                    codeToIdMap.put(mdmCode.Code__c, mdmCode.id);
                }
                
            // User의 사번필드(ResponsibilityAMA__c)로 User 조회해서 Id값 알아내기
            Set<String> accUserSet = new Set<String>();
            for(Account acc :accountList){
                accUserSet.add(acc.ResponsibilityAMA__c);
            }
            List<User> userList = [SELECT Id,EmployeeNumber FROM User WHERE EmployeeNumber =: accUserSet];
            
            // Key :code , value :Id
            Map<String, String> codeToUserIdMap = new Map<String, String>();
            for(User us :userList){ 
                codeToUserIdMap.put(us.EmployeeNumber, us.Id);
            }
            // Account를 MDMRegRequestContact__c 매핑하여 리턴
            for(Account acc : accountList){
                MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c    ();
                
                // Default
                mdmRequest.Account__c                                  = acc?.Id;   
                mdmRequest.recordTypeId                                = recordIdEx;
                mdmRequest.RequestType__c                              = 'Edit';
                // 기본정보 [S] 
                mdmRequest.PV_OLDCD__c                                 = acc?.CustomerIDASIS__c;                
                mdmRequest.PV_KUNNR__c                                 = acc?.CustomerID__c;                                                                       
                mdmRequest.PV_NAME1__c                                 = acc?.Name;                                                                    
                mdmRequest.PV_NAME_G__c                                = acc?.NameKor__c;                                                                              
                mdmRequest.PV_NAME2__c                                 = acc?.NameAlias__c;                                                                    
                mdmRequest.PV_KTOKD__c                                 = acc?.AccountGroup__c;                                                                     
                mdmRequest.PV_CUSTTYPE__c                              = acc?.CustomerType__c;                                                                             
                mdmRequest.PV_STCD2__c                                 = acc?.CompanyRegisterNumber__c;                                                                    
                mdmRequest.PV_STCD3__c                                 = acc?.CorporateCode__c;                                                                    
                mdmRequest.PV_STCD4__c                                 = acc?.SubCompanyRegisterNumber__c;                                                                     
                mdmRequest.PV_GFORM__c                                 = acc?.LegalStatus__c;                                                                      
                mdmRequest.PV_J_1KFREPRE__c                            = acc?.RepresentativeName__c;                                                                                       
                mdmRequest.PV_STCD1__c                                 = acc?.RepresentativeBirthDate__c;                                                                      
                mdmRequest.PV_J_1KFTBUS__c                             = acc?.BusinessConditions__c;                                                                               
                mdmRequest.PV_J_1KFTIND__c                             = acc?.BusinessCategory__c;                                                                             
                mdmRequest.PV_TELF1__c                                 = acc?.Phone;                                                                       
                mdmRequest.PV_TELFX__c                                 = acc?.Fax;                                                                     
                mdmRequest.PV_VKGRP__c                                 = acc?.PV_VKGRP__c;                                        // 영업그룹 코드                                                       
                mdmRequest.PV_VKGRP_lu__c                              = codeToIdMap.get(acc?.PV_VKGRP__c);                       // 영업그룹 id 
                mdmRequest.PVRA_VKGRP__c                               = acc?.SalesGroupFromDate__c;                    
                mdmRequest.PV_PERNR__c                                 = acc?.Owner.EmployeeNumber;             
                mdmRequest.PV_PERNR_lu__c                              = acc?.OwnerId;                  
                mdmRequest.PVRA_PERNR__c                               = acc?.ResponsibilityMAFromDate__c;                  
                mdmRequest.PV_ADMINMA__c                               = acc?.ResponsibilityAMA__c;                 
                mdmRequest.PV_ADMINMA_lu__c                            = codeToUserIdMap.get(acc?.ResponsibilityAMA__c);         // ResponsibilityAMA__c(사번)으로 User의 Id값 넣어주기
                mdmRequest.PV_LOGISCENTER__c                           = acc?.FWReleaseCenter__c;                                // FW 출고센터 코드                  
                mdmRequest.PV_LOGISCENTER_lu__c                        = codeToIdMap.get(acc?.FWReleaseCenter__c);               // FW 출고센터 id  
                mdmRequest.PVRA_LOGISCENTER__c                         = acc?.FWReleaseCenterFromDate__c;                       
                mdmRequest.PV_STCDT__c                                 = acc?.TaxInvoiceType__c;                                 // 세금계산서발행유형 코드                    
                mdmRequest.PV_STCDT_lu__c                              = codeToIdMap.get(acc?.TaxInvoiceType__c);                // 세금계산서발행유형 id    
                mdmRequest.PV_FITYP__c                                 = acc?.TaxationType__c;              
                mdmRequest.PV_HDOFFICEYN__c                            = acc?.IsHeadShopUseYN__c;                                // ==============================> IsUseHeadOffice__c 랑 무슨차이?                  
                mdmRequest.PV_HKUNNR__c                                = acc?.HeadOfficeCode__c;                                 // [Prod확인] 실제Prod에는 headOfficeCode OR ##SELFID## 두개가 들어가네 (확인 필요)
                mdmRequest.PV_HKUNNR_lu__c                             = acc?.ParentId;                                             
                mdmRequest.PV_SUBSIDIARYYN__c                          = acc?.IsAffiliatedcompanyYN__c;                     
                mdmRequest.PV_VBUND__c                                 = acc?.AffiliatedCompany__c;                              // [Prod확인] 값이 있는게 없음(필수값아님)   
                mdmRequest.PV_VBUND_lu__c                              = codeToIdMap.get(acc?.AffiliatedCompany__c);             // [Prod확인] 값이 있는게 없음(필수값아님)   
                mdmRequest.PV_LAND1__c                                 = acc?.CountryKeyCode__c;                                 //국가키 코드                   
                mdmRequest.PV_LAND1_lu__c                              = codeToIdMap.get(acc?.CountryKeyCode__c);                //국가키 id   
                mdmRequest.PV_KNVKTYPE__c                              = acc?.PV_KNVKTYPE__c;                   
                mdmRequest.PV_CLOSEDT__c                               = acc?.ShutDownDate__c;                  
                mdmRequest.PV_REGIO__c                                 = acc?.LocationState__c;                                   // 지역 코드(11140 : 서울 중구)                   
                mdmRequest.PV_REGIO_lu__c                              = codeToIdMap.get(acc?.LocationState__c);                  // 지역 id  
                mdmRequest.PV_ADRES_ZIPCODE__c                         = acc?.PostalCode__c;                        
                mdmRequest.PV_ADRES_ROADADDR1__c                       = acc?.Address__c;                           
                mdmRequest.PV_ADRES_ROADADDR2__c                       = acc?.AddressDetails__c;                            
                mdmRequest.PV_ADRES_ADDR1__c                           = acc?.Address2__c;                      
                mdmRequest.PV_ADRES_ADDR2__c                           = acc?.AddressDetails2__c;                        
                // wrapperRequest.PV_SELLER_lu__c                      = acc?.X;                                                  //[수정] 판매처는 잠시,,               
                // wrapperRequest.CreateReferenceId__c                 = acc?.X;                                                  //[수정] 판매처는 잠시,,               
                // wrapperRequest.PV_BIZPLCODE                         = acc?.X;                                                  //[수정] OnlyOneFoodNet사업장ID는 잠시,,
                 // 기본정보 [E]      
                //회계정보 [S]
                mdmRequest.PV_BUSAB__c                                 = acc?.SalesForm__c;                
                mdmRequest.PV_CESSION_KZ__c                            = acc?.CustomerStatus__c;                        
                mdmRequest.PV_ZUAWA__c                                 = acc?.SortKey__c;
                mdmRequest.PV_ZUAWA_lu__c                              = codeToIdMap.get(acc?.SortKey__c); 
                mdmRequest.PV_AKONT__c                                 = acc?.MediateAccount__c;                
                mdmRequest.PV_AKONT_lu__c                              = codeToIdMap.get(acc?.MediateAccount__c);          
                mdmRequest.PV_FDGRV__c                                 = acc?.CashManagementGroup__c;                
                mdmRequest.PV_TAXKDD__c                                = acc?.TaxClassification__c;                    
                mdmRequest.PV_KATR5__c                                 = acc?.TaxPaymentMethod__c;                
                //회계정보 [E]
                //영업정보 [E]
                mdmRequest.PV_CUHR1__c                                 = acc?.CustomerRoute__c;
                mdmRequest.PV_CUHR1_lu__c                              = codeToIdMap.get(acc?.CustomerRoute__c);  
                mdmRequest.PVRA_CUHR1__c                               = acc?.CustomerRouteFromDate__c;   
                mdmRequest.PV_KONDA__c                                 = acc?.PriceGroup__c;
                mdmRequest.PV_KONDA_lu__c                              = codeToIdMap.get(acc?.PriceGroup__c);    
                mdmRequest.PVRA_KONDA__c                               = acc?.PriceGroupFromDate__c;   
                mdmRequest.PV_KVGR1__c                                 = acc?.UnitPriceGroup__c;    
                mdmRequest.PV_KVGR1_lu__c                              = codeToIdMap.get(acc?.UnitPriceGroup__c);        
                mdmRequest.PVRA_KVGR1__c                               = acc?.UnitPriceGroupFromDate__c;   
                mdmRequest.PV_WAERS__c                                 = acc?.CurrencyIsoCode;
                mdmRequest.PV_WAERS_lu__c                              = codeToIdMap.get(acc?.CurrencyIsoCode);  
                mdmRequest.PV_KVGR3__c                                 = acc?.StatementOfDeliveryType__c;   
                mdmRequest.PV_KVGR2__c                                 = acc?.SubsidyType__c;   
                mdmRequest.PV_KVGR3_BOT__c                             = acc?.StatementOfDeliveryType2__c;   
                mdmRequest.PV_ODCLOSEGB__c                             = acc?.CustomerOrderDeadlineType__c;   
                mdmRequest.PV_VACCPRTEXCYN__c                          = acc?.IsPrintVirtualAccount__c;   
                mdmRequest.PV_ZTERM_VV__c                              = acc?.TermsOfPayment__c;
                mdmRequest.PV_ZTERM_VV_lu__c                           = codeToIdMap.get(acc?.TermsOfPayment__c);  
                mdmRequest.PV_DSTRHISTREGYN__c                         = acc?.DisHisRegType__c;   
                mdmRequest.PV_OLD_BIZPLACE_NEW__c                      = acc?.CustomerPath__c;
                mdmRequest.PV_OLD_BIZPLACE_NEW_lu__c                   = codeToIdMap.get(acc?.CustomerPath__c);  
                mdmRequest.PVRA_OLD_BIZPLACE_NEW__c                    = acc?.CustomerPathFromDate__c;   
                mdmRequest.PV_EXAMYN__c                                = acc?.IsFaceToFaceInspectionStatus__c;   
                mdmRequest.PV_SHIPREQTIME__c                           = acc?.OTD__c;   
                mdmRequest.PV_PRODLOADCOND__c                          = acc?.ProductLoadingCondition__c;   
                mdmRequest.PV_RETURNLOC__c                             = acc?.ReturnLocation__c;   
                mdmRequest.PV_ENTERCOND1__c                            = acc?.VehicleEntryCondtions__c;   
                mdmRequest.PV_UNLOADCOND1__c                           = acc?.UnloadConditions1__c;   
                mdmRequest.PV_UNLOADCOND2__c                           = acc?.UnloadConditions2__c;   
                mdmRequest.PV_DELIGROUP__c                             = acc?.DeliveryGroup__c;   
                mdmRequest.PV_DELIGROUP_lu__c                          = codeToIdMap.get(acc?.DeliveryGroup__c);  
                mdmRequest.PV_KATR10__c                                = acc?.ShipmentArea__c; 
                mdmRequest.PV_KATR10_lu__c                             = codeToIdMap.get(acc?.ShipmentArea__c);  
                mdmRequest.PV_KEYYN__c                                 = acc?.IsBusinessPlaceKey__c;   
                mdmRequest.PV_KEYINFO__c                               = acc?.BusinessPlaceKeyInfo__c;   
                mdmRequest.PV_KXOTD__c                                 = acc?.KXOTD__c == 'Y' ? true : false;   
                mdmRequest.PV_KXOTDTIME__c                             = acc?.KXOTDRequestDate__c;   
                mdmRequest.PV_FDINFO__c                                = acc.InitialDeliveryShare__c == 'Y' ? true : false; //acc?.InitialDeliveryShare__c;   
                mdmRequest.PV_FDREQD__c                                = acc?.InitialDeliveryRequestDate__c;   
                mdmRequest.PV_FDREQT__c                                = acc?.InitialDeliveryRequestTime__c;   
                mdmRequest.PV_ISFDFTF__c                               = acc?.IsInitialDeliveryFTFInspection__c;   
                mdmRequest.PV_FDCTINFO__c                              = acc?.InitialDeliveryContact__c;   
                mdmRequest.PV_FDNOTICE__c                              = acc?.InitialDeliveryDescription__c;   
                mdmRequest.PV_SHIPTYPE__c                              = acc?.PV_SHIPTYPE__c;   
                mdmRequest.PV_TEMPTARGET__c                            = acc?.PV_TEMPTARGET__c;   
                mdmRequest.EditRequestDate__c                          = Date.today();
                objWrapper.objMDMRegReqCustomer = mdmRequest;
            }
        }catch(Exception e){
            strStatus = 'ERROR';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();
        }
       
        return objWrapper;
    }
    /**
    * =======================================================================================================================
    * @description : [참조생성] 에서 가져온 AccountId로 참조 할 데이터 가져오기
    * 
    * @params      : accountId(Accout의 Id)
    * @return      : `DataWrapper`
    * =======================================================================================================================
    */
    @AuraEnabled
    public static DataWrapper getAccountReferenceInfo(String accountId){
        String strStatus = 'SUCCESS';                       // Sccess 시 
        String strMessage = '';                             // Error 시 메세지
        String MDMRecordTypeId = '';                        // MDMRegRequestCustomer__c의 '관리처' RecordId
        String strObjectType = 'Account';  // object api명
        String recordTypeName = 'MDMParent';            // recordType api명
        Id recordIdEx = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        system.debug('### CJFW_MDMManagementController.getAccountReferenceInfo())');
        system.debug('>>> accountId ' + accountId);
        DataWrapper objWrapper = new DataWrapper();
        try{
            List<Account> accountList = [SELECT    Id
                                                ,  Name                                         // 고객명(영문명 포함)                        
                                                ,  NameAlias__c                                 // 고객약칭명(변경)
                                                ,  CustomerType__c                              // 고객유형
                                                ,  LegalStatus__c                               // 법적상태
                                                ,  BusinessCategory__c                          // 업종
                                                ,  TaxInvoiceType__c                            // 세금계산서발행유형
                                                ,  PostalCode__c                                // 우편번호 
                                                ,  Address__c                                   // 주소>도로명주소(TAB)>도로명주소 =========================> 주소모두가져와야할듯
                                                ,  AddressDetails__c
                                                ,  Address2__c
                                                ,  AddressDetails2__c
                                                ,  NameKor__c                                   // 고객명(G) / 자국명   
                                                ,  AccountGroup__c                              // 고객계정그룹
                                                ,  CompanyRegisterNumber__c                     // 사업자등록번호
                                                ,  RepresentativeName__c                        // 대표자이름
                                                ,  BusinessConditions__c                        // 업태
                                                ,  Phone                                        // 전화번호
                                                ,  HeadOfficeCode__c                            // 본점코드
                                                ,  LocationState__c                             // 지역
                                                ,  SubsidyType__c                               // 장려금유형
                                                ,  CustomerOrderDeadlineType__c                 // 고객 주문마감 유형코드
                                                ,  TermsOfPayment__c                            // 지급조건
                                                ,  CustomerPath__c                              // 경로(사업부)
                                                ,  ShipmentArea__c                              // 출하권역
                                                ,  StatementOfDeliveryType__c                   // 납품서유형
                                                ,  StatementOfDeliveryType2__c                  // 납품서 하단유형
                                                ,  DisHisRegType__c                             // 유통이력 신고대상 유형
                                                ,  DeliveryGroup__c                             // 배송그룹
                                                ,  FWReleaseCenter__c
                                                ,  CustomerRoute__c
                                                ,  PV_VKGRP__c
                                                ,  ParentId
                                                //, tolabel(DisHisRegType__c) DisHisRegType
                                                ,  (SELECT Id,  Lastname,  Firstname,  Email,  Phone,  MobilePhone,  Department,  PV_PAFKT_VK__c,  PV_TALKT_VK__c,  PV_KNVKGB__c FROM Contacts) 
                                            FROM Account 
                                        WHERE Id =: accountId 
                                        LIMIT 1];
            // 고객 주문마감 유형코드
            objWrapper.listCustomerOrderType = CommonUtil.getPickListValues('MDMRegRequestCustomer__c', 'PV_ODCLOSEGB__c', true);
            // accountId로 Contact조회
            List<Contact> listReqContactList = [SELECT  Id, AccountId, Name, PV_NO__c, PV_KNVKGB__c, MobilePhone, Department, PV_PAFKT_VK__c, Email, PV_TALKT_VK__c
                                                FROM    Contact
                                                WHERE   AccountId =:accountId];
            // Contact의 코드(PV_KNVKGB__c)로 MDMReferenceCode__c 조회해서 Id값 알아내기
            Set<String> conCodeSet = new Set<String>();
            for(Contact con :listReqContactList){
                conCodeSet.add(con.PV_KNVKGB__c);
            }
            
            List<MDMReferenceCode__c> conReferenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c =: conCodeSet];
            
            // Key :code , value :Id
            Map<String, String> codeToConIdMap = new Map<String, String>();
            for(MDMReferenceCode__c conCode :conReferenceCodeList){ 
                codeToConIdMap.put(conCode.Code__c, conCode.id);
            }
            // Contact을 MDMRegRequestContact__c 매핑하여 리턴
            List<MDMRegRequestContact__c> mdmReqContactList = new List<MDMRegRequestContact__c>();
            
            // listReqContactList : accountId로 Contact조회
            for(Contact con : listReqContactList){
                MDMRegRequestContact__c mdmReqContact = new MDMRegRequestContact__c();
                    mdmReqContact.PV_NAME1_VK__c  = con.Name;
                    mdmReqContact.PV_KNVKGB__c    = con.PV_KNVKGB__c;        
                    mdmReqContact.PV_KNVKGB_lu__c = codeToConIdMap.get(con?.PV_KNVKGB__c);
                    mdmReqContact.PV_TELF1_VK__c  = con.MobilePhone;
                    mdmReqContact.PV_ABTNR_VK__c  = con.Department; 
                    mdmReqContact.PV_PAFKT_VK__c  = con.PV_PAFKT_VK__c;
                    mdmReqContact.PV_EMAIL_VK__c  = con.Email;
                    mdmReqContact.PV_TALKT_VK__c  = con.PV_TALKT_VK__c;
                    mdmReqContact.Contact__c      = con.id;
                    mdmReqContactList.add(mdmReqContact);
            }
            objWrapper.listMDMReqContact = mdmReqContactList;
            
            // Account 코드필드들 MDMReferenceCode__c 조회해서 Id값 알아내기
            Set<String> accCodeSet = new Set<String>();
            for(Account acc :accountList){
                    accCodeSet.add(acc.TaxInvoiceType__c);
                    accCodeSet.add(acc.LocationState__c);
                    accCodeSet.add(acc.TermsOfPayment__c);
                    accCodeSet.add(acc.CustomerPath__c);
                    accCodeSet.add(acc.DeliveryGroup__c);
                    accCodeSet.add(acc.ShipmentArea__c);
            }
            List<MDMReferenceCode__c> mdmReferenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c =: accCodeSet];
            // Key :code , value :Id
            Map<String, String> codeToIdMap = new Map<String, String>();
                for(MDMReferenceCode__c mdmCode :mdmReferenceCodeList){ 
                    codeToIdMap.put(mdmCode.Code__c, mdmCode.id);
                }
            /** 필요한지 모름
            // User의 사번필드(ResponsibilityAMA__c)로 User 조회해서 Id값 알아내기
            Set<String> accUserSet = new Set<String>();
            for(Account acc :accountList){
                accUserSet.add(acc.ResponsibilityAMA__c);
            }
            List<User> userList = [SELECT Id,EmployeeNumber FROM User WHERE EmployeeNumber =: accUserSet];
            
            // Key :code , value :Id
            Map<String, String> codeToUserIdMap = new Map<String, String>();
            for(User us :userList){ 
                codeToUserIdMap.put(us.EmployeeNumber, us.Id);
            }
             */
            // Account를 MDMRegRequestContact__c 매핑하여 리턴
            for(Account acc : accountList){
                MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c    ();
                
                // Default
                mdmRequest.Account__c                                  = acc?.Id;   
                mdmRequest.recordTypeId                                = recordIdEx;
                mdmRequest.RequestType__c                              = 'Edit';
                mdmRequest.CreateReferenceId__c                        = acc?.Id;                                               // 참조생성
                // 기본정보 [S] 
                mdmRequest.PV_NAME1__c                                 = acc?.Name;                                                                    
                mdmRequest.PV_NAME_G__c                                = acc?.NameKor__c;                                                                              
                mdmRequest.PV_NAME2__c                                 = acc?.NameAlias__c;                                                                    
                mdmRequest.PV_KTOKD__c                                 = acc?.AccountGroup__c;                                                                     
                mdmRequest.PV_CUSTTYPE__c                              = acc?.CustomerType__c;                                                                             
                mdmRequest.PV_STCD2__c                                 = acc?.CompanyRegisterNumber__c;                                                                    
                mdmRequest.PV_GFORM__c                                 = acc?.LegalStatus__c;                                                                      
                mdmRequest.PV_J_1KFREPRE__c                            = acc?.RepresentativeName__c;                                                                                       
                mdmRequest.PV_J_1KFTBUS__c                             = acc?.BusinessConditions__c;                                                                               
                mdmRequest.PV_J_1KFTIND__c                             = acc?.BusinessCategory__c;                                                                             
                mdmRequest.PV_TELF1__c                                 = acc?.Phone;                                                                       
                mdmRequest.PV_STCDT__c                                 = acc?.TaxInvoiceType__c;                                 // 세금계산서발행유형 코드                    
                mdmRequest.PV_STCDT_lu__c                              = codeToIdMap.get(acc?.TaxInvoiceType__c);                // 세금계산서발행유형 id    
                mdmRequest.PV_HKUNNR__c                                = acc?.HeadOfficeCode__c;                                 // [Prod확인] 실제Prod에는 headOfficeCode OR ##SELFID## 두개가 들어가네 (확인 필요)
                mdmRequest.PV_HKUNNR_lu__c                             = acc?.ParentId;                                             
                mdmRequest.PV_REGIO__c                                 = acc?.LocationState__c;                                   // 지역 코드(11140 : 서울 중구)                   
                mdmRequest.PV_REGIO_lu__c                              = codeToIdMap.get(acc?.LocationState__c);                  // 지역 id  
                mdmRequest.PV_ADRES_ZIPCODE__c                         = acc?.PostalCode__c;                        
                mdmRequest.PV_ADRES_ROADADDR1__c                       = acc?.Address__c;                           
                mdmRequest.PV_ADRES_ROADADDR2__c                       = acc?.AddressDetails__c;                            
                mdmRequest.PV_ADRES_ADDR1__c                           = acc?.Address2__c;                      
                mdmRequest.PV_ADRES_ADDR2__c                           = acc?.AddressDetails2__c;                        
                // 기본정보 [E]      
                //회계정보 [S]
                /**
                mdmRequest.PV_BUSAB__c                                 = acc?.SalesForm__c;                
                mdmRequest.PV_CESSION_KZ__c                            = acc?.CustomerStatus__c;                        
                mdmRequest.PV_ZUAWA__c                                 = acc?.SortKey__c;
                mdmRequest.PV_ZUAWA_lu__c                              = codeToIdMap.get(acc?.SortKey__c); 
                mdmRequest.PV_AKONT__c                                 = acc?.MediateAccount__c;                
                mdmRequest.PV_AKONT_lu__c                              = codeToIdMap.get(acc?.MediateAccount__c);          
                mdmRequest.PV_FDGRV__c                                 = acc?.CashManagementGroup__c;                
                mdmRequest.PV_TAXKDD__c                                = acc?.TaxClassification__c;                    
                mdmRequest.PV_KATR5__c                                 = acc?.TaxPaymentMethod__c;
                 */                
                //회계정보 [E]
                //영업정보 [E]
                mdmRequest.PV_KVGR3__c                                 = acc?.StatementOfDeliveryType__c;   
                mdmRequest.PV_KVGR2__c                                 = acc?.SubsidyType__c;   
                mdmRequest.PV_KVGR3_BOT__c                             = acc?.StatementOfDeliveryType2__c;   
                mdmRequest.PV_ODCLOSEGB__c                             = acc?.CustomerOrderDeadlineType__c;  
                mdmRequest.PV_ZTERM_VV__c                              = acc?.TermsOfPayment__c;
                mdmRequest.PV_ZTERM_VV_lu__c                           = codeToIdMap.get(acc?.TermsOfPayment__c);  
                mdmRequest.PV_DSTRHISTREGYN__c                         = acc?.DisHisRegType__c;   
                mdmRequest.PV_OLD_BIZPLACE_NEW__c                      = acc?.CustomerPath__c;
                mdmRequest.PV_OLD_BIZPLACE_NEW_lu__c                   = codeToIdMap.get(acc?.CustomerPath__c);  
                mdmRequest.PV_DELIGROUP__c                             = acc?.DeliveryGroup__c;   
                mdmRequest.PV_DELIGROUP_lu__c                          = codeToIdMap.get(acc?.DeliveryGroup__c);  
                mdmRequest.PV_KATR10__c                                = acc?.ShipmentArea__c; 
                mdmRequest.PV_KATR10_lu__c                             = codeToIdMap.get(acc?.ShipmentArea__c);  
                mdmRequest.EditRequestDate__c                          = Date.today();
                objWrapper.objMDMRegReqCustomer = mdmRequest;
            }    
        }catch(Exception e){
            strStatus = 'ERROR';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();
            system.debug(strMessage);
        }
        return objWrapper;
    }
    /**
    * =======================================================================================================================
    * @description : 관리처 화면에 오늘날짜 Setting
    * 
    * @params      : X
    * @return      : `Date`
    * =======================================================================================================================
    */
    @AuraEnabled
    public static Date getTodayDate() {
        system.debug('>>>getFirstDayOfMonthDate');
        Date result = System.today();
        return result;
    }
    /**
    * =======================================================================================================================
    * @description : 본점 자동생성 Btn > 본점 조회
    * 
    * @params      : 1) CreateReferenceId__c (MDMRegRequest 편집 -> 본점) OR 2) Account__c (AccountDetail 편집)
    * @return      : `Account`
    * =======================================================================================================================
    */
    @AuraEnabled
    public static Account getHKUNNR(String accountId) {
        system.debug(' ### getHKUNNR ' + accountId);
        Account getAccHKUNNR = [SELECT Id,  ParentId, HeadOfficeCode__c FROM Account WHERE Id =: accountId];
        return getAccHKUNNR;
    }
    /**
    * =======================================================================================================================
    * @description : AMA 정보 변경 이벤트 || MA 정보 변경 이벤트
    * 
    * @params      : userId
    * @return      : `User`
    * =======================================================================================================================
    */
    @AuraEnabled
    public static User getUserEmployeeNumber(String userId) {
        User us = [SELECT Id, EmployeeNumber FROM User WHERE Id=: userId];
        
        return us;
    }
    /**
    * =======================================================================================================================
    * @description : code만 알고있는 필드들을 이용해 Name을 가져오기 (inputv__Field 에 넣어줘야 함, 이 필드는 object의 필드가X) 
    * 
    * @params      : List<String> codes
    * @return      : `List<MDMReferenceCode__c>`
    * =======================================================================================================================
    */
    @AuraEnabled 
    public static List<MDMReferenceCode__c> getReferenceNamesByCodes(List<String> codes){
        return [SELECT Id, Name, CODE__c  FROM MDMReferenceCode__c WHERE CODE__c IN :codes];
    }
    /**
    * =======================================================================================================================
    * @description : code만 알고있는 필드를 이용해 Name을 가져오기 (PV_KNVKGB__c) 에 넣어줘야 함 
    * 
    * @params      : List<String> codes
    * @return      : `List<MDMReferenceCode__c>`
    * =======================================================================================================================
    */
    @AuraEnabled 
    public static List<MDMReferenceCode__c> getManagerNameByCodes(List<String> codes){
        return [SELECT Id, Name, CODE__c  FROM MDMReferenceCode__c WHERE CODE__c IN :codes AND GROUPID__c = 'KNVKGB'];
    }
    /**
    * =======================================================================================================================
    * @description : Account MDM 고객Id 조회
    * 
    * @params      : Account Id     
    * @return      : `Account`
    * =======================================================================================================================
    */
    @AuraEnabled
    public static String getCustomerId(String accountId) {
        Account acc = [SELECT Id, CustomerID__c FROM account WHERE Id =:accountId];

        return acc.Id;
    }
    /**
    * =======================================================================================================================
    * @description : Save 버튼을 클릭 했을 때 호출
    * 
    * @params      : objCustomer : 화면 objCustomer 데이터
    * @params      : 화면 contacts (List)데이터 > 왜 리스트가 나올까? 데이터가 다건인가?
    * @params      : 화면 banks (List) 데이터 (현재는 사용하지않음!)
    * @return      : `List<MDMReferenceCode__c>`
    * =======================================================================================================================
    */
    @AuraEnabled                                // List<CustomContacts> contacts, Boolean isMDMEdit
    public static String saveRecords(MDMRegRequestCustomer__c customer, List<MDMRegRequestContact__c> contacts, Boolean isMDMEdit){
        system.debug(' ### CJFW_MDMManagementController > doSave ');
        system.debug(' >>> doSave > json.serialize(customer) ' + json.serialize(customer));
        system.debug(' >>> doSave > json.serialize(contacts) ' + json.serialize(contacts));
        Savepoint sp = Database.setSavepoint();
        // aura  String 으로 넘어와서 JSON.des
        // ObjCustomer obj =  JSON.deserialize(objCustomer,  래퍼클래스명.class);
        try {
            upsert customer;
            List<MDMRegRequestContact__c> listCurContact = [
                SELECT Id FROM MDMRegRequestContact__c WHERE MDMRegRequestCustomer__c =:customer.Id
            ];
            if(listCurContact <> null && listCurContact.size() > 0) {
                delete listCurContact;
            }
            List<MDMRegRequestContact__c> listInsertMDMContact = new List<MDMRegRequestContact__c>();
            List<Contact> listUpdateContact = new List<Contact>();
            integer i = 1;
            if (contacts != null && contacts.size() > 0) {
                for(MDMRegRequestContact__c con : contacts) {
                    // 원본
                    // con.Id = null;
                    // con.MDMRegRequestCustomer__c = customer.Id;
                    // Insert MDM Contact
                    MDMRegRequestContact__c insertMDMCon = con.clone(false, true, false, false);
                    insertMDMCon.Id = null;  // 신규 추가에 경우 Name값이 ""으로 들어와서 널 값처리(AutoNumber)
                    
                    insertMDMCon.MDMRegRequestCustomer__c = customer.Id;
                    listInsertMDMContact.add(insertMDMCon);      
                    // Update Contact
                    if(String.isNotBlank(con.Contact__c))
                    {
                        Contact objUpdateContact = new Contact();
                        objUpdateContact.Id = con.Contact__c;
                        objUpdateContact.ExtId__c = customer.Account__c+'_'+ i++;
                        listUpdateContact.add(objUpdateContact);
                    }
                }
                // 원본
                //insert contacts;
                if(!listInsertMDMContact.isEmpty()) 
                {
                    system.debug(JSON.serialize(listInsertMDMContact));
                    insert listInsertMDMContact;
                }
            }
            if(listUpdateContact <> null && listUpdateContact.size() > 0) {
                update listUpdateContact;
            }
            if(customer.Id != null && customer.Account__c != null){
                Account objAccount = new Account();
                objAccount.Id = customer.Account__c;
                objAccount.IsRequestMDMReg__c = true;
                update objAccount;
            }
            return customer.Id;
        }catch(Exception e) {
            Database.rollback(sp);
            System.debug('Error ==============> '+e.getMessage());
            System.debug('=============================> Error Line '+e.getLineNumber());
            return 'error';
        }
     
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
        /** @description 고객 주문마감 유형코드*/
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
}