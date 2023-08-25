/**
 * @description       : MDM 고객정보 API(사용안함)
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
@RestResource(urlMapping='/mdm/customer/info_test')
global with sharing class IF_MDM_SFDC_INFO_ACCOUNT {
    global IF_MDM_SFDC_INFO_ACCOUNT() {}

    global class Input {
        public List<Item> data; 
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last;
    }

    global class Item {
        public String INSTANCEID;
        public String PV_KUNNR;
        public String PV_OLDCD;
        public String PV_NAME1;
        public String PV_NAME_G;
        public String PV_NAME2;
        public String PV_KTOKD;
        public String PV_CUSTTYPE;
        public String PV_STCD2;
        public String PV_STCD3;
        public String PV_STCD4;
        public String PV_GFORM;
        public String PV_J_1KFREPRE;
        public String PV_STCD1;
        public String PV_J_1KFTBUS;
        public String PV_J_1KFTIND;
        public String PV_TELF1;
        public String PV_TELFX;
        public String PV_PAYCUST;
        public String PV_CHARGECUST;
        public String PV_VKGRP;
        public String PVVF_VKGRP;
        public String PVN_VKGRP;
        public String PVO_VKGRP;
        public String PVRA_VKGRP;
        public String PV_PERNR;
        public String PVVF_PERNR;
        public String PVN_PERNR;
        public String PVO_PERNR;
        public String PVRA_PERNR;
        public String PV_ADMINMA;
        public String PV_LOGISCENTER;
        public String PVVF_LOGISCENTER;
        public String PVN_LOGISCENTER;
        public String PVO_LOGISCENTER;
        public String PVRA_LOGISCENTER;
        public String PV_STCDT;
        public String PV_FITYP;
        public String PV_HDOFFICEYN;
        public String PV_HKUNNR;
        public String PV_SUBSIDIARYYN;
        public String PV_VBUND;
        public String PV_LIFNR;
        public String PV_LAND1;
        public String PV_KNVKTYPE;
        public String PV_CLOSEDT;
        public String PV_REGIO;
        public String PV_ADRES_ZIPCODE;
        public String PV_ADRES_SEQ;
        public String PV_ADRES_ADDR1;
        public String PV_ADRES_ADDR2;
        public String PV_ADRES_ROADADDR1;
        public String PV_ADRES_ROADADDR2;
        public String PV_ADRES_ROADMGMTNO;
        public String PV_BUSAB;
        public String PV_CESSION_KZ;
        public String PV_ZUAWA;
        public String PV_AKONT;
        public String PV_FDGRV;
        public String PV_VRSDG;
        public String PV_TAXKDD;
        public String PV_KATR5;
        public String PV_CUHR1;
        public String PVVF_CUHR1;
        public String PVN_CUHR1;
        public String PVO_CUHR1;
        public String PVRA_CUHR1;
        public String PV_KONDA;
        public String PVVF_KONDA;
        public String PVN_KONDA;
        public String PVO_KONDA;
        public String PVRA_KONDA;
        public String PV_KVGR1;
        public String PVVF_KVGR1;
        public String PVN_KVGR1;
        public String PVO_KVGR1;
        public String PVRA_KVGR1;
        public String PV_WAERS;
        public String PV_KDGRP;
        public String PV_KVGR3;
        public String PV_KVGR2;
        public String PV_KVGR3_BOT;
        public String PV_ODCLOSEGB;
        public String PV_VACCPRTEXCYN;
        public String PV_ZTERM_VV;
        public String PV_DSTRHISTREGYN;
        public String PV_KULTG;
        public String PV_OLD_BIZPLACE_NEW;
        public String PVVF_OLD_BIZPLACE_NEW;
        public String PVN_OLD_BIZPLACE_NEW;
        public String PVO_OLD_BIZPLACE_NEW;
        public String PVRA_OLD_BIZPLACE_NEW;
        public String PV_SHAPE;
        public String PV_EXAMYN;
        public String PV_SHIPREQTIME;
        public String PV_PRODLOADCOND;
        public String PV_RETURNLOC;
        public String PV_ENTERCOND1;
        public String PV_UNLOADCOND1;
        public String PV_UNLOADCOND2;
        public String PV_DELIGROUP;
        public String PV_KATR10;
        public String PV_KEYYN;
        public String PV_KEYINFO;
        public String PV_KXOTD;
        public String PV_KXOTDTIME;
        public String PV_FDINFO;
        public String PV_FDREQD;
        public String PV_FDREQT;
        public String PV_ISFDFTF;
        public String PV_FDCTINFO;
        public String PV_FDNOTICE;
        public String PV_SHIPTYPE;
        public String PV_TEMPTARGET;
        public String PV_ORDERMA;
        public String PV_CSHAPE;
        public String PV_STORECNT;
        public String PV_TERMF;
        public String PV_EXISTSUP;
        public String PV_TERMT;
        public String PV_ESALES;
        public String PV_EPROFIT;
        public String PV_ESALESFC;
        public String PV_EXSALESFC;
        public String PV_GSALESFC;
        public String PV_EXPROFITFC;
        public String PV_GPROFITFC;
        public String PV_SALESPERSTOREFC;
        public String PV_DROPSIZEFC;
        public String PV_SKUPERSALESFC;
        public String PV_EXSALESFEE;
        public String PV_GSALESFEE;
        public String PV_NUMSKU;
        public String PV_NUMPARTNER;
        public String PV_DELAVG;
        public String PV_ETCSALESFEE;
        public String PV_SALESMNG;
        public String PV_LOGISRATIO;
        public String PV_LRATE;
        public String PV_CGRRATE;
        public String PV_CARDFRATE;
        public String PV_ETCRATE;
        public String PV_SUPPOINT;
        public String PV_DEPRE;
        public String PV_SUBSIDY;
        public String PV_DONATION;
        public String PV_ETCSUP;
        public String PV_COMMRATE;
        public String PV_DEPOSITYN;
        public String PV_DEPOSIT;
        public String PV_DEPOSITF;
        public String PV_PROVCOL;
        public String PV_AMOUNTCOL;
        public String PV_ISCOLFEE;
        public String PV_SPECIALNOTE;
        public String PV_RESESALES;
        public String PV_RESEEARN;
        public String PV_RESEPROFIT;
        public String PV_ECPROFIT;
        public String PV_ECPROFITRATE;
        public String PV_SUPFEERATE;
        public String PV_ESALESPROFIT;
        public String PV_ESALESPROFITRATE;
        public String PV_BLCKYN;
        public String PV_STATUSTYPE;
        public List<Manager> PV_MANAGER_INFO;
        public List<Bank> PV_BANK_INFO;
    }

    global class Manager {
        public String INSTANCEID;
        public String PV_NO;
        public String PV_NAME1_VK;
        public String PV_KNVKGB;
        public String PV_TELF1_VK;
        public String PV_ABTNR_VK;
        public String PV_PAFKT_VK;
        public String PV_TALKT_VK;
        public String PV_EMAIL_VK;
    }
    global class Bank {
        public String INSTANCEID;
        public String PV_NO;
        public String PV_BANKL;
        public String PV_BANKN;
        public String PV_KOINH;
        public String PV_BKONT;
        public String PV_BVTYP;
        public String PV_BKREF;
        public String PV_ACTCLOSEYN;
        public String PV_ACTCLOSED;
    }
    global class Output {
        public String err_cd;
        public String err_msg_ctt;
        /*
        public Result result;
        public ResultData resultData;
        */
    }

    global class Result {
        public String resultCode;
        public String resultMessage;
    }

    global class ResultData {
    }

    @HttpPost
    global static Output doPost() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Data has successfully upserted.';

        /*
        Result objResult = new Result();
        ResultData resultData = new ResultData();
        */

        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String requestBody = '';

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            LogWrapper.requestBody = requestBody;   
            if(requestBody == '' || requestBody == null) {
                strStatus = 'ERROR';
                strCode = '-1';
                strMessage = 'request body value does not exist';
            }else {
                Input input = (Input)JSON.deserialize(requestBody,  Input.class);
                List<IF_MDM_SFDC_INFO_ACCOUNT__c> accountDummyList = new List<IF_MDM_SFDC_INFO_ACCOUNT__c>();
                List<IF_MDM_SFDC_INFO_ACCOUNT_contact__c> contactDummyList = new List<IF_MDM_SFDC_INFO_ACCOUNT_contact__c>();
                List<IF_MDM_SFDC_INFO_ACCOUNT_Bank__c> bankDummyList = new List<IF_MDM_SFDC_INFO_ACCOUNT_Bank__c>();
                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'data list is empty';
                }else{ 

                    for (Item item : input.data) {
                        IF_MDM_SFDC_INFO_ACCOUNT__c objDummy = new IF_MDM_SFDC_INFO_ACCOUNT__c();
                        objDummy.transactionId__c = input.transaction_Id;
                        objDummy.INSTANCEID__c = item.INSTANCEID;
                        objDummy.PV_KUNNR__c = item.PV_KUNNR;
                        objDummy.PV_OLDCD__c = item.PV_OLDCD;
                        objDummy.PV_NAME1__c = item.PV_NAME1;
                        objDummy.PV_NAME_G__c = item.PV_NAME_G;
                        objDummy.PV_NAME2__c = item.PV_NAME2;
                        objDummy.PV_KTOKD__c = item.PV_KTOKD;
                        objDummy.PV_CUSTTYPE__c = item.PV_CUSTTYPE;
                        objDummy.PV_STCD2__c = item.PV_STCD2;
                        objDummy.PV_STCD3__c = item.PV_STCD3;
                        objDummy.PV_STCD4__c = item.PV_STCD4;
                        objDummy.PV_GFORM__c = item.PV_GFORM;
                        objDummy.PV_J_1KFREPRE__c = item.PV_J_1KFREPRE;
                        objDummy.PV_STCD1__c = item.PV_STCD1;
                        objDummy.PV_J_1KFTBUS__c = item.PV_J_1KFTBUS;
                        objDummy.PV_J_1KFTIND__c = item.PV_J_1KFTIND;
                        objDummy.PV_TELF1__c = item.PV_TELF1;
                        objDummy.PV_TELFX__c = item.PV_TELFX;
                        objDummy.PV_PAYCUST__c = item.PV_PAYCUST;
                        objDummy.PV_CHARGECUST__c = item.PV_CHARGECUST;
                        objDummy.PV_VKGRP__c = item.PV_VKGRP;
                        objDummy.PVVF_VKGRP__c = item.PVVF_VKGRP;
                        objDummy.PVN_VKGRP__c = item.PVN_VKGRP;
                        objDummy.PVO_VKGRP__c = item.PVO_VKGRP;
                        objDummy.PVRA_VKGRP__c = item.PVRA_VKGRP;
                        objDummy.PV_PERNR__c = item.PV_PERNR;
                        objDummy.PVVF_PERNR__c = item.PVVF_PERNR;
                        objDummy.PVN_PERNR__c = item.PVN_PERNR;
                        objDummy.PVO_PERNR__c = item.PVO_PERNR;
                        objDummy.PVRA_PERNR__c = item.PVRA_PERNR;
                        objDummy.PV_ADMINMA__c = item.PV_ADMINMA;
                        objDummy.PV_LOGISCENTER__c = item.PV_LOGISCENTER;
                        objDummy.PVVF_LOGISCENTER__c = item.PVVF_LOGISCENTER;
                        objDummy.PVN_LOGISCENTER__c = item.PVN_LOGISCENTER;
                        objDummy.PVO_LOGISCENTER__c = item.PVO_LOGISCENTER;
                        objDummy.PVRA_LOGISCENTER__c = item.PVRA_LOGISCENTER;
                        objDummy.PV_STCDT__c = item.PV_STCDT;
                        objDummy.PV_FITYP__c = item.PV_FITYP;
                        objDummy.PV_HDOFFICEYN__c = item.PV_HDOFFICEYN;
                        objDummy.PV_HKUNNR__c = item.PV_HKUNNR;
                        objDummy.PV_SUBSIDIARYYN__c = item.PV_SUBSIDIARYYN;
                        objDummy.PV_VBUND__c = item.PV_VBUND;
                        objDummy.PV_LIFNR__c = item.PV_LIFNR;
                        objDummy.PV_LAND1__c = item.PV_LAND1;
                        objDummy.PV_KNVKTYPE__c = item.PV_KNVKTYPE;
                        objDummy.PV_CLOSEDT__c = item.PV_CLOSEDT;
                        objDummy.PV_REGIO__c = item.PV_REGIO;
                        objDummy.PV_ADRES_ZIPCODE__c = item.PV_ADRES_ZIPCODE;
                        objDummy.PV_ADRES_SEQ__c = item.PV_ADRES_SEQ;
                        objDummy.PV_ADRES_ADDR1__c = item.PV_ADRES_ADDR1;
                        objDummy.PV_ADRES_ADDR2__c = item.PV_ADRES_ADDR2;
                        objDummy.PV_ADRES_ROADADDR1__c = item.PV_ADRES_ROADADDR1;
                        objDummy.PV_ADRES_ROADADDR2__c = item.PV_ADRES_ROADADDR2;
                        objDummy.PV_ADRES_ROADMGMTNO__c = item.PV_ADRES_ROADMGMTNO;
                        objDummy.PV_BUSAB__c = item.PV_BUSAB;
                        objDummy.PV_CESSION_KZ__c = item.PV_CESSION_KZ;
                        objDummy.PV_ZUAWA__c = item.PV_ZUAWA;
                        objDummy.PV_AKONT__c = item.PV_AKONT;
                        objDummy.PV_FDGRV__c = item.PV_FDGRV;
                        objDummy.PV_VRSDG__c = item.PV_VRSDG;
                        objDummy.PV_TAXKDD__c = item.PV_TAXKDD;
                        objDummy.PV_KATR5__c = item.PV_KATR5;
                        objDummy.PV_CUHR1__c = item.PV_CUHR1;
                        objDummy.PVVF_CUHR1__c = item.PVVF_CUHR1;
                        objDummy.PVN_CUHR1__c = item.PVN_CUHR1;
                        objDummy.PVO_CUHR1__c = item.PVO_CUHR1;
                        objDummy.PVRA_CUHR1__c = item.PVRA_CUHR1;
                        objDummy.PV_KONDA__c = item.PV_KONDA;
                        objDummy.PVVF_KONDA__c = item.PVVF_KONDA;
                        objDummy.PVN_KONDA__c = item.PVN_KONDA;
                        objDummy.PVO_KONDA__c = item.PVO_KONDA;
                        objDummy.PVRA_KONDA__c = item.PVRA_KONDA;
                        objDummy.PV_KVGR1__c = item.PV_KVGR1;
                        objDummy.PVVF_KVGR1__c = item.PVVF_KVGR1;
                        objDummy.PVN_KVGR1__c = item.PVN_KVGR1;
                        objDummy.PVO_KVGR1__c = item.PVO_KVGR1;
                        objDummy.PVRA_KVGR1__c = item.PVRA_KVGR1;
                        objDummy.PV_WAERS__c = item.PV_WAERS;
                        objDummy.PV_KDGRP__c = item.PV_KDGRP;
                        objDummy.PV_KVGR3__c = item.PV_KVGR3;
                        objDummy.PV_KVGR2__c = item.PV_KVGR2;
                        objDummy.PV_KVGR3_BOT__c = item.PV_KVGR3_BOT;
                        objDummy.PV_ODCLOSEGB__c = item.PV_ODCLOSEGB;
                        objDummy.PV_VACCPRTEXCYN__c = item.PV_VACCPRTEXCYN;
                        objDummy.PV_ZTERM_VV__c = item.PV_ZTERM_VV;
                        objDummy.PV_DSTRHISTREGYN__c = item.PV_DSTRHISTREGYN;
                        objDummy.PV_KULTG__c = item.PV_KULTG;
                        objDummy.PV_OLD_BIZPLACE_NEW__c = item.PV_OLD_BIZPLACE_NEW;
                        objDummy.PVVF_OLD_BIZPLACE_NEW__c = item.PVVF_OLD_BIZPLACE_NEW;
                        objDummy.PVN_OLD_BIZPLACE_NEW__c = item.PVN_OLD_BIZPLACE_NEW;
                        objDummy.PVO_OLD_BIZPLACE_NEW__c = item.PVO_OLD_BIZPLACE_NEW;
                        objDummy.PVRA_OLD_BIZPLACE_NEW__c = item.PVRA_OLD_BIZPLACE_NEW;
                        objDummy.PV_SHAPE__c = item.PV_SHAPE;
                        objDummy.PV_EXAMYN__c = item.PV_EXAMYN;
                        objDummy.PV_SHIPREQTIME__c = item.PV_SHIPREQTIME;
                        objDummy.PV_PRODLOADCOND__c = item.PV_PRODLOADCOND;
                        objDummy.PV_RETURNLOC__c = item.PV_RETURNLOC;
                        objDummy.PV_ENTERCOND1__c = item.PV_ENTERCOND1;
                        objDummy.PV_UNLOADCOND1__c = item.PV_UNLOADCOND1;
                        objDummy.PV_UNLOADCOND2__c = item.PV_UNLOADCOND2;
                        objDummy.PV_DELIGROUP__c = item.PV_DELIGROUP;
                        objDummy.PV_KATR10__c = item.PV_KATR10;
                        objDummy.PV_KEYYN__c = item.PV_KEYYN;
                        objDummy.PV_KEYINFO__c = item.PV_KEYINFO;
                        objDummy.PV_KXOTD__c = item.PV_KXOTD;
                        objDummy.PV_KXOTDTIME__c = item.PV_KXOTDTIME;
                        objDummy.PV_FDINFO__c = item.PV_FDINFO;
                        objDummy.PV_FDREQD__c = item.PV_FDREQD;
                        objDummy.PV_FDREQT__c = item.PV_FDREQT;
                        objDummy.PV_ISFDFTF__c = item.PV_ISFDFTF;
                        objDummy.PV_FDCTINFO__c = item.PV_FDCTINFO;
                        objDummy.PV_FDNOTICE__c = item.PV_FDNOTICE;
                        objDummy.PV_SHIPTYPE__c = item.PV_SHIPTYPE;
                        objDummy.PV_TEMPTARGET__c = item.PV_TEMPTARGET;
                        objDummy.PV_ORDERMA__c = item.PV_ORDERMA;
                        objDummy.PV_CSHAPE__c = item.PV_CSHAPE;
                        objDummy.PV_STORECNT__c = item.PV_STORECNT;
                        objDummy.PV_TERMF__c = item.PV_TERMF;
                        objDummy.PV_EXISTSUP__c = item.PV_EXISTSUP;
                        objDummy.PV_TERMT__c = item.PV_TERMT;
                        objDummy.PV_ESALES__c = item.PV_ESALES;
                        objDummy.PV_EPROFIT__c = item.PV_EPROFIT;
                        objDummy.PV_ESALESFC__c = item.PV_ESALESFC;
                        objDummy.PV_EXSALESFC__c = item.PV_EXSALESFC;
                        objDummy.PV_GSALESFC__c = item.PV_GSALESFC;
                        objDummy.PV_EXPROFITFC__c = item.PV_EXPROFITFC;
                        objDummy.PV_GPROFITFC__c = item.PV_GPROFITFC;
                        objDummy.PV_SALESPERSTOREFC__c = item.PV_SALESPERSTOREFC;
                        objDummy.PV_DROPSIZEFC__c = item.PV_DROPSIZEFC;
                        objDummy.PV_SKUPERSALESFC__c = item.PV_SKUPERSALESFC;
                        objDummy.PV_EXSALESFEE__c = item.PV_EXSALESFEE;
                        objDummy.PV_GSALESFEE__c = item.PV_GSALESFEE;
                        objDummy.PV_NUMSKU__c = item.PV_NUMSKU;
                        objDummy.PV_NUMPARTNER__c = item.PV_NUMPARTNER;
                        objDummy.PV_DELAVG__c = item.PV_DELAVG;
                        objDummy.PV_ETCSALESFEE__c = item.PV_ETCSALESFEE;
                        objDummy.PV_SALESMNG__c = item.PV_SALESMNG;
                        objDummy.PV_LOGISRATIO__c = item.PV_LOGISRATIO;
                        objDummy.PV_LRATE__c = item.PV_LRATE;
                        objDummy.PV_CGRRATE__c = item.PV_CGRRATE;
                        objDummy.PV_CARDFRATE__c = item.PV_CARDFRATE;
                        objDummy.PV_ETCRATE__c = item.PV_ETCRATE;
                        objDummy.PV_SUPPOINT__c = item.PV_SUPPOINT;
                        objDummy.PV_DEPRE__c = item.PV_DEPRE;
                        objDummy.PV_SUBSIDY__c = item.PV_SUBSIDY;
                        objDummy.PV_DONATION__c = item.PV_DONATION;
                        objDummy.PV_ETCSUP__c = item.PV_ETCSUP;
                        objDummy.PV_COMMRATE__c = item.PV_COMMRATE;
                        objDummy.PV_DEPOSITYN__c = item.PV_DEPOSITYN;
                        objDummy.PV_DEPOSIT__c = item.PV_DEPOSIT;
                        objDummy.PV_DEPOSITF__c = item.PV_DEPOSITF;
                        objDummy.PV_PROVCOL__c = item.PV_PROVCOL;
                        objDummy.PV_AMOUNTCOL__c = item.PV_AMOUNTCOL;
                        objDummy.PV_ISCOLFEE__c = item.PV_ISCOLFEE;
                        objDummy.PV_SPECIALNOTE__c = item.PV_SPECIALNOTE;
                        objDummy.PV_RESESALES__c = item.PV_RESESALES;
                        objDummy.PV_RESEEARN__c = item.PV_RESEEARN;
                        objDummy.PV_RESEPROFIT__c = item.PV_RESEPROFIT;
                        objDummy.PV_ECPROFIT__c = item.PV_ECPROFIT;
                        objDummy.PV_ECPROFITRATE__c = item.PV_ECPROFITRATE;
                        objDummy.PV_SUPFEERATE__c = item.PV_SUPFEERATE;
                        objDummy.PV_ESALESPROFIT__c = item.PV_ESALESPROFIT;
                        objDummy.PV_ESALESPROFITRATE__c = item.PV_ESALESPROFITRATE;
                        objDummy.PV_BLCKYN__c = item.PV_BLCKYN;
                        objDummy.PV_STATUSTYPE__c = item.PV_STATUSTYPE;
                        accountDummyList.add(objDummy);
                    }
                    for (Item item : input.data) {
                        if(item.PV_MANAGER_INFO <> null && item.PV_MANAGER_INFO.size() > 0){
                            for (Manager ManagerObj : item.PV_MANAGER_INFO) {
                                IF_MDM_SFDC_INFO_ACCOUNT_contact__c objDummy = new IF_MDM_SFDC_INFO_ACCOUNT_contact__c();
                                objDummy.transactionId__c = input.transaction_Id;
                                objDummy.INSTANCEID__c = item.INSTANCEID;
                                objDummy.PV_KUNNR__c = item.PV_KUNNR;
                                objDummy.PV_NO__c = ManagerObj.PV_NO;
                                objDummy.PV_NAME1_VK__c = ManagerObj.PV_NAME1_VK;
                                objDummy.PV_KNVKGB__c = ManagerObj.PV_KNVKGB;
                                objDummy.PV_TELF1_VK__c = ManagerObj.PV_TELF1_VK;
                                objDummy.PV_ABTNR_VK__c = ManagerObj.PV_ABTNR_VK;
                                objDummy.PV_PAFKT_VK__c = ManagerObj.PV_PAFKT_VK;
                                objDummy.PV_TALKT_VK__c = ManagerObj.PV_TALKT_VK;
                                objDummy.PV_EMAIL_VK__c = ManagerObj.PV_EMAIL_VK;
                                contactDummyList.add(objDummy);
                            }
                        }
                        if (item.PV_BANK_INFO <> null && item.PV_BANK_INFO.size() > 0) {
                            for (Bank BkObj : item.PV_BANK_INFO) {
                                IF_MDM_SFDC_INFO_ACCOUNT_Bank__c objDummy = new IF_MDM_SFDC_INFO_ACCOUNT_Bank__c();
                                objDummy.transactionId__c = input.transaction_Id;
                                objDummy.INSTANCEID__c = item.INSTANCEID;
                                objDummy.PV_KUNNR__c = item.PV_KUNNR;
                                objDummy.PV_NO__c = BkObj.PV_NO;
                                objDummy.PV_BANKL__c = BkObj.PV_BANKL;
                                objDummy.PV_BANKN__c = BkObj.PV_BANKN;
                                objDummy.PV_KOINH__c = BkObj.PV_KOINH;
                                objDummy.PV_BKONT__c = BkObj.PV_BKONT;
                                objDummy.PV_BVTYP__c = BkObj.PV_BVTYP;
                                objDummy.PV_BKREF__c = BkObj.PV_BKREF;
                                objDummy.PV_ACTCLOSEYN__c = BkObj.PV_ACTCLOSEYN;
                                objDummy.PV_ACTCLOSED__c = BkObj.PV_ACTCLOSED;
                                bankDummyList.add(objDummy);
                            }
                        }
                    }
                }

                if (accountDummyList <> null && accountDummyList.size() > 0) {
                    insert accountDummyList;
                    insert contactDummyList;
                    insert bankDummyList;
                    
                    if (Boolean.valueOf(input.is_last) == true) {
                        IF_MDM_SFDC_INFO_ACCOUNT_ba ba = new IF_MDM_SFDC_INFO_ACCOUNT_ba(input.transaction_Id);
                        Database.executeBatch(ba, 200);
                    }
                }
                
                // Map<String, Id> accountIdMap = new Map<String, Id>();
                // for (Account obj : upsertObjList) {
                //     accountIdMap.put(obj.CustomerID__c, obj.Id);
                // }
            }
        } catch(Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       

            System.debug('========================> strMessage : '+strMessage);
        }

        /*
        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        
        objOutput.resultData = resultData;
        objOutput.result = objResult;
        */

        // 2022-11-11 Response 변경
        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;        

        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = requestBody;
        LogWrapper.responseBody = JSON.serialize(objOutput);
        
        IFUtil objIF = new IFUtil('IF_MDM_SFDC_INFO_ACCOUNT');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}