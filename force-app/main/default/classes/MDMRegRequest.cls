/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-22-2023
 * @last modified by  : yeonji.lim@dkbmc.com
**/
public without sharing class MDMRegRequest {
    /**
     * MDM 고객정보 등록 Init
     * 
     * @params recordId MDMRegRequestCustomer Id     
     * @params mdmCustomerType MDM 고객 구분(MDMParent : 본점, MDMChild : 판매처)  
     * @return DataWrapper
     *
    **/
    @AuraEnabled
    public static DataWrapper doInit(Id recordId, String mdmCustomerType) {
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';
        String strMessage = '';
        String MDMRecordTypeId = '';
        try {
            String strObjectType = String.valueOf(recordId.getSobjectType());
            system.debug('1)정체가 뭘까 strObjectType : ' + strObjectType);
            objWrapper.strObjectType = strObjectType;

            User objUser = [
                SELECT Id, LastName, EmployeeNumber FROM User
                WHERE Id =:UserInfo.getUserId()
            ];

            objWrapper.objUser = objUser;
            system.debug('### objWrapper.objUser '+ objWrapper.objUser);

            // Opportunity에서 MDM 신규고객등록 버튼 클릭시
            if(strObjectType == 'Opportunity') {

                objWrapper.objOpportunity = [
                    SELECT  Id, AccountId, 
                            Account.Name, Account.OwnerId, Account.Owner.EmployeeNumber,
                            Account.CompanyRegisterNumber__c, Account.RepresentativeName__c, Account.Phone
                    FROM    Opportunity where Id =:recordId
                ];

                MDMRecordTypeId = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(mdmCustomerType).getRecordTypeId();

                objWrapper.listCustomerOrderType = CommonUtil.getPickListValues('MDMRegRequestCustomer__c', 'PV_ODCLOSEGB__c', true);
                system.debug('objWrapper.listCustomerOrderType ' + objWrapper.listCustomerOrderType);
                system.debug('objWrapper.listCustomerOrderType ' + Json.serialize(objWrapper.listCustomerOrderType));

            }
            // MDM 고객등록 요청에서 편집버튼 클릭시 
            else {

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
                            IsSelf_PV_CHARGECUST__c, Status__c, WF_DESCRIPTION__c
                    FROM    MDMRegRequestCustomer__c
                    WHERE   Id =:recordId
                ];

                MDMRecordTypeId = objMDMRegReqCustomer.RecordTypeId;
                objWrapper.objMDMRegReqCustomer = objMDMRegReqCustomer;

                List<MDMRegRequestContact__c> listMDMReqContact = [
                    SELECT  Id, MDMRegRequestCustomer__c,
                            INSTANCEID__c, PV_NO__c, PV_NAME1_VK__c, PV_KNVKGB__c, PV_TELF1_VK__c, PV_ABTNR_VK__c, PV_PAFKT_VK__c,
                            PV_TALKT_VK__c, PV_EMAIL_VK__c, PV_KNVKGB_lu__c, Contact__c
                    FROM    MDMRegRequestContact__c
                    WHERE   MDMRegRequestCustomer__c =:recordId
                ];

                objWrapper.listMDMReqContact = listMDMReqContact;
                objWrapper.listCustomerOrderType = doCheckOrderType('LOGIC', objMDMRegReqCustomer.PV_LOGISCENTER__c, objMDMRegReqCustomer.PV_CUHR1__c).listCustomerOrderType;
            }

        }catch(Exception e) {
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
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
            
            strStatus = 'ERROR';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();
        }
        
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    public class DataWrapper {
        @AuraEnabled
        public String strStatus {get;set;}      // 성공, 실패
        @AuraEnabled
        public String strMessage {get;set;}     // 에러메세지
        @AuraEnabled
        public String strObjectType {get;set;}
        @AuraEnabled
        public String MDMRecordTypeId {get;set;}

        @AuraEnabled
        public List<Map<String, String>> listCustomerOrderType {get;set;}

        @AuraEnabled
        public User objUser {get;set;}
        @AuraEnabled
        public Opportunity objOpportunity {get;set;}
        @AuraEnabled
        public MDMRegRequestCustomer__c objMDMRegReqCustomer {get;set;}
        @AuraEnabled
        public List<MDMRegRequestContact__c> listMDMReqContact {get;set;}
    }

    /**
     * MDM 고객정보 저장
     * 
     * @params customer : MDM고객등록요청 고객정보
     * @params contacts : MDM고객등록요청 담당자정보
     * @params contacts : MDM고객등록요청 은행정보(은행정보는 현재 사용하지 않음
     * @return String : 성공, 실패(error)
     *
    **/
    @AuraEnabled
    public static String saveRecords(MDMRegRequestCustomer__c customer, List<MDMRegRequestContact__c> contacts, List<MDMRegRequestBank__c> banks){
        Savepoint sp = Database.setSavepoint();

        try {
            upsert customer;

            List<MDMRegRequestContact__c> listCurContact = [
                SELECT Id FROM MDMRegRequestContact__c WHERE MDMRegRequestCustomer__c =:customer.Id
            ];

            if(listCurContact <> null && listCurContact.size() > 0) {
                delete listCurContact;
            }

            List<Contact> listUpdateContact = new List<Contact>();

            if (contacts != null && contacts.size() > 0) {
                for(MDMRegRequestContact__c con : contacts) {
                    con.Id = null;
                    con.MDMRegRequestCustomer__c = customer.Id;

                    Contact objUpdateContact = new Contact();
                    objUpdateContact.Id = con.Contact__c;
                    objUpdateContact.ExtId__c = customer.Account__c+'_'+con.PV_NO__c;
                    listUpdateContact.add(objUpdateContact);
                }

                upsert contacts;
            }

            if(listUpdateContact <> null && listUpdateContact.size() > 0) {
                update listUpdateContact;
            }
            
            /*
            if (banks != null && banks.size() > 0) {
                for (MDMRegRequestBank__c bank : banks) {
                    bank.MDMRegRequestCustomer__c = customer.Id;
                }
                upsert banks;
            }
            */

            Account objAccount = new Account();

            objAccount.Id = customer.Account__c;
            objAccount.IsRequestMDMReg__c = true;

            update objAccount;

            return customer.Id;
        }catch(Exception e) {
            Database.rollback(sp);
            System.debug('Error ==============> '+e.getMessage());
            return 'error';
            // return e.getMessage();
        //     System.debug('=============================> Error Line '+e.getLineNumber());
        //     System.debug('=============================> Error '+e.getMessage());
        }
    }
    
    /**
     * User 정보 조회
     * 
     * @params userId : User Id     
     * @return User Object
     *
    **/
    @AuraEnabled
    public static user pvadmChanged(String userId) {
        User uss = [select id, employeeNumber from user where id=:userId];
        
        return uss;
    }

    /**
     * Account MDM 고객Id 조회
     * 
     * @params accountId : Account Id     
     * @return String : MDM 고객Id
     *
    **/
    @AuraEnabled
    public static String getCustomerId(String accountId) {
        Account acc = [select id, CustomerID__c from account where id =:accountId];
        return acc.CustomerID__c;
    }

    /*
    @AuraEnabled
    public static user changedMA(String userId){
        User uss = [select id, employeeNumber from user where id=:userId];
        return uss;
    }
    */

    /**
     * User 사원번호 조회
     * 
     * @params userId : User Id     
     * @return String : 사원번호
     *
    **/
    @AuraEnabled
    public static String changedMA(String userId){
        System.debug('==============> changedMA Start');
        System.debug('==============> changedMA userId : '+userId);
        
        User objUser = [SELECT Id, EmployeeNumber FROM User where Id=:userId];

        System.debug('=============> objUser : '+objUser);
        
        return objUser.EmployeeNumber;
    }
    
    /**
     * 영업기회(Opportunity) 조회
     * 
     * @params opportunityId : Opportunity Id     
     * @return Opportunity Object
     *
    **/
    @AuraEnabled
    public static List<Opportunity> getAccountInfo(String opportunityId){

        List<Opportunity> opp = [select id, accountid, account.fm_empId__c, Account.AccountGroup__c, Account.Name ,account.ownerid from opportunity where id=:opportunityId];
		 
		System.debug(opp+'=====');        
        return opp;        
    }

    /*
    @AuraEnabled
    public static WrapperDefault getDefaultInfo(String opportunityId){
        WrapperDefault wrapper = new WrapperDefault();


        String userId = UserInfo.getUserId();
        User currentUser = [Select Id, EmployeeNumber from User where Id = :userId];
        wrapper.employeeNumber = currentUser.EmployeeNumber;
        // wrapper.employeeNumber = [Select Id, EmployeeNumber from User where Id = : userId].EmployeeNumber;
        
        Opportunity opp = [select id, accountid, account.fm_empId__c, Account.AccountGroup__c, Account.Name ,account.ownerid from opportunity where id=:opportunityId];
        if (opp != null) {
            wrapper.ownerNumber = [Select Id, EmployeeNumber from User where Id = : opp.Account.OwnerId].EmployeeNumber;
        }        
        return wrapper;
    }
    */
    
    //Addr 반영
    //private static String sConfirmKey = 'TESTJUSOGOKR';
    /*
    private static String sConfirmKey = 'U01TX0FVVEgyMDIyMTEzMDE5NTQzNzExMzI3NTQ='; //신규로받은키
    private static String sReturnType = 'json';
    */
   
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

    public class WrapperDefault {
        @AuraEnabled public String employeeNumber {get; set;}
        @AuraEnabled public String ownerNumber {get; set;}
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
    
    /**
     * 주소정보 조회
     * 
     * @params recordId : Object Record Id
     * @params objName : Object API Name
     * @params zipCodeField : 우편번호 Field
     * @params addressField : 주소 Field
     * @params addressDetailField : 상세주소 Field
     * @return Map<String, Object> : 조회된 결과
     *
    **/
    @AuraEnabled
    public static Map<String, Object> getInitData(String recordId
            , String objName
            , String zipCodeField
            , String addressField
            , String addressDetailField) {
        /*
         ACCOUNT listAcc = new ACCOUNT();
      		listAcc =[SELECT zipNo__c , RoadAddr__c, AddrDetail__c FROM ACCOUNT
				where id = :recordId] ;
        System.debug('aaaaa : '+listAcc.zipNo__c );
        */
          //String query = 'select   '+zipCodeField+','+addressField+','+addressDetailField+' from '+objName+' where Id=\'0010k00000ws5gVAAQ\'';
          String query = 'select   '+zipCodeField+','+addressField+','+addressDetailField+' from '+objName+' where Id=:recordId';
             
         sObject obj = Database.query(query);
            
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();

        List<String> listField = new List<String>{zipCodeField, addressField, addressDetailField};
        String labelPostalCode = '';
        String labelAddress = '';
        String labelAddressDetail = '';
        
        for (String fieldName: fieldMap.keySet()) {
            system.debug('fieldName :: ' + fieldName );
            if(fieldName == zipCodeField ){
                labelPostalCode = fieldMap.get(fieldName).getDescribe().getLabel();
            }
            else if(fieldName == addressField){
                labelAddress = fieldMap.get(fieldName).getDescribe().getLabel();
            }
            else if(fieldName == addressDetailField){
                labelAddressDetail = fieldMap.get(fieldName).getDescribe().getLabel();
            }
        }

         Map<String, Object> mapReturnValue = new Map<String, Object>{
            'listDesire' => obj,
            'labelPostalCode' => labelPostalCode,
            'labelAddress' => labelAddress,
            'labelAddressDetail' => labelAddressDetail
        };
        return mapReturnValue;
       
    }

    //get contact link with opportunity record
    /**
     * 연락처(Contact) 정보 조회
     * 
     * @params recordId : Opportunity Id     
     * @return List<Contact> : 조회된 결과
     *
    **/
    @AuraEnabled
    public static List<Contact> getContactsByOpportunity(Id recordId){
        Opportunity opp = [
            SELECT Id, AccountId
            FROM Opportunity
            WHERE Id = :recordId
        ];
        String accountId = opp.AccountId;
        if(String.isBlank(accountId)){
            return null;
        }else {
            return [
                SELECT Id, Lastname, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c
                FROM Contact
                WHERE AccountId = :accountId
            ];
        }
    }
    
    /**
     * 연락처(Contact) 정보 저장
     * 
     * @params List<Contact> : 대상 연락처
     *
    **/
    @AuraEnabled
    public static void doSaveContact(string contactTarget){
        try {
            system.debug('contactTarget :: ' + contactTarget);
            List<Contact> listContact = new List<contact>();
            listContact = (List<Contact>) JSON.deserialize(contactTarget, List<Contact>.class);
            if( !listContact.isEmpty()){
                update listContact;
            }


            // Map<String, Object> cObjMap = (Map<String, Object>) JSON.deserializeUntyped(contactTarget);
            // List<Object> listContact = (List<Object>) JSON.deserialize(contactTarget, Contact.class);
            // system.debug('contactTarget :: ' + (List<Contact>) JSON.deserialize(contactTarget, List<Contact>.class)) ;
            // for (Object objContact: listContact){

            //     system.debug('contactTarget :: ' + (Contact) ((Object) objContact)) ;
            // }
            // if( !contactTarget.isEmpty()){
            //     update contactTarget;
            // }
        } catch(Exception e){
            system.debug('MDMRegRequest doSaveContact error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

    //save contact request
    // @AuraEnabled
    // public static List<MDMRegRequestContact__c> saveMDMRegRequestContact(List<MDMRegRequestContact__c> listMDMRegRequestContact){
    //     if(listMDMRegRequestContact.size() > 0){
    //         insert listMDMRegRequestContact;
    //     }
    //     return listMDMRegRequestContact;
    // }

    // //save bank request
    // @AuraEnabled
    // public static List<MDMRegRequestBank__c> saveMDMRegRequestBank(List<MDMRegRequestBank__c> listMDMRegRequestBank){
    //     if(listMDMRegRequestBank.size() > 0){
    //         insert listMDMRegRequestBank;
    //     }
    //     return listMDMRegRequestBank;
    // }
}