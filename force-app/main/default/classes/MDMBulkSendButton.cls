public with sharing class MDMBulkSendButton {
 /**
     * MDM 고객정보 I/F
     * 
     * @param recordId MDMRegRequestCustomer Id     
     * @return DataWrapper
     *         
    **/

    @AuraEnabled
	public static DataWrapper doSendMDM(String recordId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {

            List<MDMRegRequestCustomer__c> listMDMCustomer = new List<MDMRegRequestCustomer__c>();

            // #1. 리스트로 변경해야함
            // Account objUpdateAccount = new Account();

            listMDMCustomer = [
                SELECT  Id, Account__c,
                        INSTANCEID__c, PROCID__c, REQACTORID__c, PV_CRMNO__c, PV_KUNNR__c, PV_OLDCD__c, PV_NAME1__c, 
                        PV_NAME_G__c, PV_NAME2__c, PV_KTOKD__c, PV_CUSTTYPE__c, PV_STCD2__c, PV_STCD3__c, PV_STCD4__c, 
                        PV_GFORM__c, PV_J_1KFREPRE__c, PV_STCD1__c, PV_J_1KFTBUS__c, PV_J_1KFTIND__c, PV_TELF1__c, PV_TELFX__c, 
                        PV_PAYCUST__c, PV_CHARGECUST__c, PV_VKGRP__c, PVRA_VKGRP__c, PV_PERNR__c, PVVF_PERNR__c, PVRA_PERNR__c, 
                        PV_ADMINMA__c, PV_LOGISCENTER__c, PVVF_LOGISCENTER__c, PV_STCDT__c, PV_FITYP__c, PV_HDOFFICEYN__c, 
                        PV_HKUNNR__c, PV_SUBSIDIARYYN__c, PV_VBUND__c, PV_LIFNR__c, PV_LAND1__c, PV_KNVKTYPE__c, PV_CLOSEDT__c, 
                        PV_REGIO__c, PV_ADRES_ZIPCODE__c, PV_ADRES_SEQ__c, PV_ADRES_ADDR1__c, PV_ADRES_ADDR2__c, 
                        PV_ADRES_ROADADDR1__c, PV_ADRES_ROADADDR2__c, PV_ADRES_ROADMGMTNO__c, PV_BUSAB__c, PV_CESSION_KZ__c, 
                        PV_ZUAWA__c, PV_AKONT__c, PV_FDGRV__c, PV_VRSDG__c, PV_TAXKDD__c, PV_KATR5__c, PV_CUHR1__c, PVVF_CUHR1__c, 
                        PVRA_CUHR1__c, PV_KONDA__c, PVVF_KONDA__c, PVRA_KONDA__c, PV_KVGR1__c, PVVF_KVGR1__c, PVRA_KVGR1__c, 
                        PV_WAERS__c, PV_KDGRP__c, PV_KVGR3__c, PV_KVGR2__c, PV_KVGR3_BOT__c, PV_ODCLOSEGB__c, PV_VACCPRTEXCYN__c, 
                        PV_ZTERM_VV__c, PV_DSTRHISTREGYN__c, PV_KULTG__c, PV_OLD_BIZPLACE_NEW__c, PVVF_OLD_BIZPLACE_NEW__c, 
                        PVRA_OLD_BIZPLACE_NEW__c, PV_SHAPE__c, PV_EXAMYN__c, PV_SHIPREQTIME__c, PV_PRODLOADCOND__c, PV_RETURNLOC__c, 
                        PV_ENTERCOND1__c, PV_UNLOADCOND1__c, PV_UNLOADCOND2__c, PV_DELIGROUP__c, PV_KATR10__c, PV_KEYYN__c, 
                        PV_KEYINFO__c, PV_KXOTD__c, PV_KXOTDTIME__c, PV_FDINFO__c, PV_FDREQD__c, PV_FDREQT__c, PV_ISFDFTF__c, 
                        PV_FDCTINFO__c, PV_FDNOTICE__c, PV_SHIPTYPE__c, PV_TEMPTARGET__c, PV_ORDERMA__c, PV_CSHAPE__c, PV_STORECNT__c, 
                        PV_TERMF__c, PV_EXISTSUP__c, PV_TERMT__c, PV_ESALES__c, PV_EPROFIT__c, PV_ESALESFC__c, PV_EXSALESFC__c, PV_GSALESFC__c, 
                        PV_EXPROFITFC__c, PV_GPROFITFC__c, PV_SALESPERSTOREFC__c, PV_DROPSIZEFC__c, PV_SKUPERSALESFC__c, PV_EXSALESFEE__c, 
                        PV_GSALESFEE__c, PV_NUMSKU__c, PV_NUMPARTNER__c, PV_DELAVG__c, PV_ETCSALESFEE__c, PV_SALESMNG__c, PV_LOGISRATIO__c, 
                        PV_LRATE__c, PV_CGRRATE__c, PV_CARDFRATE__c, PV_ETCRATE__c, PV_SUPPOINT__c, PV_DEPRE__c, PV_SUBSIDY__c, 
                        PV_DONATION__c, PV_ETCSUP__c, PV_COMMRATE__c, PV_DEPOSITYN__c, PV_DEPOSIT__c, PV_DEPOSITF__c, PV_PROVCOL__c, 
                        PV_AMOUNTCOL__c, PV_ISCOLFEE__c, PV_SPECIALNOTE__c, PV_RESESALES__c, PV_RESEEARN__c, PV_RESEPROFIT__c, 
                        PV_ECPROFIT__c, PV_ECPROFITRATE__c, PV_SUPFEERATE__c, PV_ESALESPROFIT__c, PV_ESALESPROFITRATE__c, PV_BLCKYN__c, 
                        PV_STATUSTYPE__c, PV_BIZPLCODE__c, PV_SALESCUST__c, PV_DELICUST__c, WF_DESCRIPTION__c,
                        PVVF_VKGRP__c, PVRA_LOGISCENTER__c, 
                        // MDMRegRequestCustomer__c을 바라보고 있는 하위 Contact SubQuery
                        (
                            SELECT  Id, Contact__c,
                                    INSTANCEID__c, PV_NO__c, PV_NAME1_VK__c, PV_KNVKGB__c, PV_TELF1_VK__c,
                                    PV_ABTNR_VK__c, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_EMAIL_VK__c
                            FROM    MDMRegRequestContact__r
                        )
                FROM    MDMRegRequestCustomer__c
                WHERE 	MDMRegRequestBulkCustomer__c = :recordId
            ];

            if(!listMDMCustomer.isEmpty())
            {
                // List<Account> objUpdateAccountList = new List<Account>();

                // 인터페이스 보낼 Wrapper 클래스 (다건이라고 가정)
                List<MDMCustomer> objInputList = new List<MDMCustomer>();

                for(MDMRegRequestCustomer__c mdmCustomer : listMDMCustomer){

                    // objUpdateAccountList.add(objTarget.Account__c);
                    // MDMCustomer
                    MDMCustomer objInput = new MDMCustomer();
                    objInput.PV_CRMNO       = CommonUtil.nullToBlank(mdmCustomer.Account__c);
                    objInput.PV_KUNNR       = CommonUtil.nullToBlank(mdmCustomer.PV_KUNNR__c);
                    objInput.PV_NAME1       = CommonUtil.nullToBlank(mdmCustomer.PV_NAME1__c);
                    objInput.PV_GFORM       = CommonUtil.nullToBlank(mdmCustomer.PV_GFORM__c);
                    objInput.PV_J_1KFREPRE  = CommonUtil.nullToBlank(mdmCustomer.PV_J_1KFREPRE__c);
                    objInput.PV_STCD1       = CommonUtil.nullToBlank(mdmCustomer.PV_STCD1__c);
                    objInput.PV_J_1KFTBUS   = CommonUtil.nullToBlank(mdmCustomer.PV_J_1KFTBUS__c);

                   
                    List<MDMContact> PV_MANAGER_INFO = new List<MDMContact>();
                    List<Contact> listUpdateContact = new List<Contact>();

                    // MDMContact정보
                    for(MDMRegRequestContact__c mdmcontact : mdmCustomer.MDMRegRequestContact__r )
                    {
                        Contact objUpdateContact   = new Contact();
                        objUpdateContact.Id        = mdmcontact.Contact__c;
                        objUpdateContact.ExtId__c  = objInput.PV_CRMNO+'_'+mdmcontact.PV_NO__c;
                        listUpdateContact.add(objUpdateContact);

                        MDMContact objMDMContact = new MDMContact();

                        objMDMContact.INSTANCEID   = CommonUtil.nullToBlank(mdmcontact.INSTANCEID__c);
                        objMDMContact.PV_NO        = CommonUtil.nullToBlank(mdmcontact.PV_NO__c);
                        objMDMContact.PV_NAME1_VK  = CommonUtil.nullToBlank(mdmcontact.PV_NAME1_VK__c);
                        objMDMContact.PV_KNVKGB    = CommonUtil.nullToBlank(mdmcontact.PV_KNVKGB__c);
                        objMDMContact.PV_TELF1_VK  = CommonUtil.nullToBlank(mdmcontact.PV_TELF1_VK__c);
                        objMDMContact.PV_ABTNR_VK  = CommonUtil.nullToBlank(mdmcontact.PV_ABTNR_VK__c);
                        objMDMContact.PV_PAFKT_VK  = CommonUtil.nullToBlank(mdmcontact.PV_PAFKT_VK__c);
                        objMDMContact.PV_TALKT_VK  = CommonUtil.nullToBlank(mdmcontact.PV_TALKT_VK__c);
                        objMDMContact.PV_EMAIL_VK  = CommonUtil.nullToBlank(mdmcontact.PV_EMAIL_VK__c);

                        PV_MANAGER_INFO.add(objMDMContact);
                    }
                    objInput.PV_MANAGER_INFO = PV_MANAGER_INFO;

                    objInputList.add(objInput);
                }
                    
                IFUtil ifutilWrapper      = new IFUtil('IF_SFDC_MDM_REG_ACCOUNT');
                String strJsonRequestBody  = JSON.serialize(objInputList);

                // 인터페이스 콜아웃 호출( 웹서비스 호출하여 데이터 전송 ) // 리턴으로 응답값이 옴
                HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);
                
                // 
                String responseBody = response.getBody();


                // if(response.getStatusCode() == 200) {
                //     IF_MDM_SFDC_RES_ACCOUNT.Item objResponse = (IF_MDM_SFDC_RES_ACCOUNT.Item)JSON.deserialize(responseBody,  IF_MDM_SFDC_RES_ACCOUNT.Item.class);
                //     if(objResponse.err_cd == 'S') {
                //         MDMRegRequestCustomer__c objUpdateTarget = new MDMRegRequestCustomer__c();
                //         objUpdateTarget.Id =  objTarget.Id;
                //         objUpdateTarget.Status__c = 'InProgress';

                //         MDMRegRequestResult__c objNewResult = new MDMRegRequestResult__c();

                //         objNewResult.ExtId__c                  = objResponse.PV_CRMNO+'_'+objResponse.INSTANCEID;
                //         objNewResult.MDMRegRequestCustomer__c  = objTarget.Id;
                //         objNewResult.INSTANCEID__c             = objResponse.INSTANCEID;
                //         objNewResult.PV_CRMNO__c               = objResponse.PV_CRMNO;
                //         // 2023-02-01 최초 승인요청시 검토(PROC)로 전송되어 혼란이 있어 요청완료로 변경 진행
                //         //objNewResult.WF_STATUS__c = objResponse.WF_STATUS;
                //         objNewResult.WF_STATUS__c = 'REQ';
                        
                //         if(objResponse.WF_ACTOR <> null && objResponse.WF_ACTOR.size() > 0) {
                //             String strWFActor = '';

                //             for(IF_MDM_SFDC_RES_ACCOUNT.Actor objA : objResponse.WF_ACTOR) {
                //                 strWFActor += objA.NAME+'('+objA.EMPLOYEE_NUM+')'+'|';
                //             }

                //             if(strWFActor.length() > 0) {
                //                 strWFActor = strWFActor.substring(0, (strWFActor.length()-1));
                //             }
                //             objNewResult.WF_ACTOR__c = strWFActor;
                //         }

                //         if(objResponse.WF_NEXTACTOR <> null && objResponse.WF_NEXTACTOR.size() > 0) {
                //             String strNEXTWFActor = '';

                //             for(IF_MDM_SFDC_RES_ACCOUNT.NextActor objA : objResponse.WF_NEXTACTOR) {
                //                 strNEXTWFActor += objA.NAME+'('+objA.EMPLOYEE_NUM+')'+'|';
                //             }

                //             if(strNEXTWFActor.length() > 0) {
                //                 strNEXTWFActor = strNEXTWFActor.substring(0, (strNEXTWFActor.length()-1));
                //             }

                //             objNewResult.WF_NEXTACTOR__c = strNEXTWFActor;
                //         }

                //         objNewResult.WF_DATE__c = objResponse.WF_DATE <> null ? Datetime.valueOf(objResponse.WF_DATE) : null;
                //         objNewResult.WF_DESCRIPTION__c = objResponse.WF_DESCRIPTION;

                //         update objUpdateTarget;
                //         insert objNewResult;

                //         if(listUpdateContact <> null && listUpdateContact.size() > 0) {
                //             update listUpdateContact;
                //         }

                //     } else {
                //         strStatus = 'ERROR';
                //         strMessage = '[I/F Error] '+objResponse.err_msg_ctt;
                //     }
                // } else {
                //     strStatus = 'ERROR';
                //     strMessage = '[I/F Error] 오류가 발생했습니다. 관리자에게 문의 부탁드립니다.\\\\n 오류코드 : '+response.getStatusCode()+' '+responseBody;
                // }
            }
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
    }

    public class MDMCustomer {

        @AuraEnabled public String PV_CRMNO {get;set;}
        @AuraEnabled public String PV_KUNNR {get;set;}
        @AuraEnabled public String PV_NAME1 {get;set;}
        @AuraEnabled public String PV_GFORM {get;set;}
        @AuraEnabled public String PV_J_1KFREPRE {get;set;}
        @AuraEnabled public String PV_STCD1 {get;set;}
        @AuraEnabled public String PV_J_1KFTBUS {get;set;}

        @AuraEnabled
        public List<MDMContact> PV_MANAGER_INFO {get;set;}

    }

    public class MDMContact {
        @AuraEnabled public String INSTANCEID {get;set;}
        @AuraEnabled public String PV_NO {get;set;}
        @AuraEnabled public String PV_NAME1_VK {get;set;}
        @AuraEnabled public String PV_KNVKGB {get;set;}
        @AuraEnabled public String PV_TELF1_VK {get;set;}
        @AuraEnabled public String PV_ABTNR_VK {get;set;}
        @AuraEnabled public String PV_PAFKT_VK {get;set;}
        @AuraEnabled public String PV_TALKT_VK {get;set;}
        @AuraEnabled public String PV_EMAIL_VK {get;set;}
    }
}