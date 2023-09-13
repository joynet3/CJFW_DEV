/**
 * @description       : MDM 고객정보 전송
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class MDMSendBtn {
    /** S
     * MDM 전송 버튼 Init
     * 
     * @param recordId MDMRegRequestCustomer Id
     * @return DataWrapper
     *
    **/
    @AuraEnabled
	public static DataWrapper doInit(String recordId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {

        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

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
                        PVVF_VKGRP__c, PVRA_LOGISCENTER__c
                FROM    MDMRegRequestCustomer__c
                WHERE Id =:recordId
            ];

            List<MDMRegRequestContact__c> listMDMContact = new List<MDMRegRequestContact__c>();

            listMDMContact = [
                SELECT  Id, Contact__c,
                        INSTANCEID__c, PV_NO__c, PV_NAME1_VK__c, PV_KNVKGB__c, PV_TELF1_VK__c,
                        PV_ABTNR_VK__c, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_EMAIL_VK__c
                FROM    MDMRegRequestContact__c
                WHERE   MDMRegRequestCustomer__c =:recordId
            ];

            /*
            List<MDMRegRequestBank__c> listMDMBank = new List<MDMRegRequestBank__c>();

            listMDMBank = [
                SELECT  Id, INSTANCEID__c, PV_NO__c, PV_BANKL__c, PV_BANKN__c, PV_KOINH__c, PV_BKONT__c,
                        PV_BVTYP__c, PV_BKREF__c, PV_ACTCLOSEYN__c, PV_ACTCLOSED__c
                FROM    MDMRegRequestBank__c
                WHERE   MDMRegRequestCustomer__c =:recordId
            ];
            */
            
            Account objUpdateAccount = new Account();

            if(listMDMCustomer <> null && listMDMCustomer.size() > 0) {
                MDMCustomer objInput = new MDMCustomer();

                MDMRegRequestCustomer__c objTarget = listMDMCustomer[0];

                objUpdateAccount.Id = objTarget.Account__c;
                //objUpdateAccount.ExtId__c = objTarget.Account__c;

                objInput.INSTANCEID = CommonUtil.nullToBlank(objTarget.INSTANCEID__c);
                objInput.PROCID = CommonUtil.nullToBlank(objTarget.PROCID__c);
                objInput.REQACTORID = CommonUtil.nullToBlank(objTarget.REQACTORID__c);
                objInput.PV_CRMNO = CommonUtil.nullToBlank(objTarget.Account__c);
                // 2022-12-13 빈값으로 변경                
                objInput.PV_KUNNR = '';
                objInput.PV_OLDCD = CommonUtil.nullToBlank(objTarget.PV_OLDCD__c);
                objInput.PV_NAME1 = CommonUtil.nullToBlank(objTarget.PV_NAME1__c);
                objInput.PV_NAME_G = CommonUtil.nullToBlank(objTarget.PV_NAME_G__c);
                objInput.PV_NAME2 = CommonUtil.nullToBlank(objTarget.PV_NAME2__c);
                objInput.PV_KTOKD = CommonUtil.nullToBlank(objTarget.PV_KTOKD__c);
                objInput.PV_CUSTTYPE = CommonUtil.nullToBlank(objTarget.PV_CUSTTYPE__c);
                objInput.PV_STCD2 = CommonUtil.nullToBlank(objTarget.PV_STCD2__c);
                objInput.PV_STCD3 = CommonUtil.nullToBlank(objTarget.PV_STCD3__c);
                objInput.PV_STCD4 = CommonUtil.nullToBlank(objTarget.PV_STCD4__c);
                objInput.PV_GFORM = CommonUtil.nullToBlank(objTarget.PV_GFORM__c);
                objInput.PV_J_1KFREPRE = CommonUtil.nullToBlank(objTarget.PV_J_1KFREPRE__c);
                objInput.PV_STCD1 = CommonUtil.nullToBlank(objTarget.PV_STCD1__c);
                objInput.PV_J_1KFTBUS = CommonUtil.nullToBlank(objTarget.PV_J_1KFTBUS__c);
                objInput.PV_J_1KFTIND = CommonUtil.nullToBlank(objTarget.PV_J_1KFTIND__c);
                objInput.PV_TELF1 = CommonUtil.nullToBlank(objTarget.PV_TELF1__c);
                objInput.PV_TELFX = CommonUtil.nullToBlank(objTarget.PV_TELFX__c);
                objInput.PV_PAYCUST = CommonUtil.nullToBlank(objTarget.PV_PAYCUST__c);                
                objInput.PV_CHARGECUST = CommonUtil.nullToBlank(objTarget.PV_CHARGECUST__c);

                objInput.PV_VKGRP = CommonUtil.nullToBlank(objTarget.PV_VKGRP__c);
                objInput.PVVF_VKGRP = CommonUtil.nullToBlank(objTarget.PVVF_VKGRP__c);
                objInput.PVN_VKGRP = CommonUtil.nullToBlank(objTarget.PV_VKGRP__c);
                //objInput.PVO_VKGRP = CommonUtil.nullToBlank(objTarget.PVO_VKGRP__c);
                objInput.PVRA_VKGRP = CommonUtil.nullToBlank(objTarget.PVRA_VKGRP__c);
                
                objInput.PV_PERNR = CommonUtil.nullToBlank(objTarget.PV_PERNR__c);
                objInput.PVVF_PERNR = CommonUtil.nullToBlank(objTarget.PVVF_PERNR__c);
                objInput.PVN_PERNR = CommonUtil.nullToBlank(objTarget.PV_PERNR__c);
                //objInput.PVO_PERNR = CommonUtil.nullToBlank(objTarget.PVO_PERNR__c);
                objInput.PVRA_PERNR = CommonUtil.nullToBlank(objTarget.PVRA_PERNR__c);

                objInput.PV_ADMINMA = CommonUtil.nullToBlank(objTarget.PV_ADMINMA__c);

                objInput.PV_LOGISCENTER = CommonUtil.nullToBlank(objTarget.PV_LOGISCENTER__c);
                objInput.PVVF_LOGISCENTER = CommonUtil.nullToBlank(objTarget.PVVF_LOGISCENTER__c);
                objInput.PVN_LOGISCENTER = CommonUtil.nullToBlank(objTarget.PV_LOGISCENTER__c);
                //objInput.PVO_LOGISCENTER = CommonUtil.nullToBlank(objTarget.PVO_LOGISCENTER__c);                
                objInput.PVRA_LOGISCENTER = CommonUtil.nullToBlank(objTarget.PVRA_LOGISCENTER__c);

                objInput.PV_STCDT = CommonUtil.nullToBlank(objTarget.PV_STCDT__c);
                objInput.PV_FITYP = CommonUtil.nullToBlank(objTarget.PV_FITYP__c);
                
                objInput.PV_HDOFFICEYN = objTarget.PV_HDOFFICEYN__c ? 'Y' : 'N';
                objInput.PV_HKUNNR = CommonUtil.nullToBlank(objTarget.PV_HKUNNR__c);
                objInput.PV_SUBSIDIARYYN = objTarget.PV_SUBSIDIARYYN__c ? 'Y' : 'N';
                objInput.PV_VBUND = CommonUtil.nullToBlank(objTarget.PV_VBUND__c);
                objInput.PV_LIFNR = CommonUtil.nullToBlank(objTarget.PV_LIFNR__c);
                objInput.PV_LAND1 = CommonUtil.nullToBlank(objTarget.PV_LAND1__c);
                objInput.PV_KNVKTYPE = CommonUtil.nullToBlank(objTarget.PV_KNVKTYPE__c);
                objInput.PV_CLOSEDT = CommonUtil.nullToBlank(objTarget.PV_CLOSEDT__c);
                objInput.PV_REGIO = CommonUtil.nullToBlank(objTarget.PV_REGIO__c);
                objInput.PV_ADRES_ZIPCODE = CommonUtil.nullToBlank(objTarget.PV_ADRES_ZIPCODE__c);
                objInput.PV_ADRES_SEQ = CommonUtil.nullToBlank(objTarget.PV_ADRES_SEQ__c);
                objInput.PV_ADRES_ADDR1 = CommonUtil.nullToBlank(objTarget.PV_ADRES_ADDR1__c);
                objInput.PV_ADRES_ADDR2 = CommonUtil.nullToBlank(objTarget.PV_ADRES_ADDR2__c);
                objInput.PV_ADRES_ROADADDR1 = CommonUtil.nullToBlank(objTarget.PV_ADRES_ROADADDR1__c);
                objInput.PV_ADRES_ROADADDR2 = CommonUtil.nullToBlank(objTarget.PV_ADRES_ROADADDR2__c);
                objInput.PV_ADRES_ROADMGMTNO = CommonUtil.nullToBlank(objTarget.PV_ADRES_ROADMGMTNO__c);
                objInput.PV_BUSAB = CommonUtil.nullToBlank(objTarget.PV_BUSAB__c);
                objInput.PV_CESSION_KZ = CommonUtil.nullToBlank(objTarget.PV_CESSION_KZ__c);
                objInput.PV_ZUAWA = CommonUtil.nullToBlank(objTarget.PV_ZUAWA__c);
                objInput.PV_AKONT = CommonUtil.nullToBlank(objTarget.PV_AKONT__c);
                objInput.PV_FDGRV = CommonUtil.nullToBlank(objTarget.PV_FDGRV__c);
                objInput.PV_VRSDG = CommonUtil.nullToBlank(objTarget.PV_VRSDG__c);
                objInput.PV_TAXKDD = CommonUtil.nullToBlank(objTarget.PV_TAXKDD__c);
                objInput.PV_KATR5 = CommonUtil.nullToBlank(objTarget.PV_KATR5__c);

                objInput.PV_CUHR1 = CommonUtil.nullToBlank(objTarget.PV_CUHR1__c);
                objInput.PVVF_CUHR1 = CommonUtil.nullToBlank(objTarget.PVVF_CUHR1__c);
                objInput.PVN_CUHR1 = CommonUtil.nullToBlank(objTarget.PV_CUHR1__c);
                //objInput.PVO_CUHR1 = CommonUtil.nullToBlank(objTarget.PVO_CUHR1__c);
                objInput.PVRA_CUHR1 = CommonUtil.nullToBlank(objTarget.PVRA_CUHR1__c);

                objInput.PV_KONDA = CommonUtil.nullToBlank(objTarget.PV_KONDA__c);
                objInput.PVVF_KONDA = CommonUtil.nullToBlank(objTarget.PVVF_KONDA__c);
                objInput.PVN_KONDA = CommonUtil.nullToBlank(objTarget.PV_KONDA__c);
                //objInput.PVO_KONDA = CommonUtil.nullToBlank(objTarget.PVO_KONDA__c);
                objInput.PVRA_KONDA = CommonUtil.nullToBlank(objTarget.PVRA_KONDA__c);

                objInput.PV_KVGR1 = CommonUtil.nullToBlank(objTarget.PV_KVGR1__c);
                objInput.PVVF_KVGR1 = CommonUtil.nullToBlank(objTarget.PVVF_KVGR1__c);
                objInput.PVN_KVGR1 = CommonUtil.nullToBlank(objTarget.PV_KVGR1__c);
                //objInput.PVO_KVGR1 = CommonUtil.nullToBlank(objTarget.PVO_KVGR1__c);
                objInput.PVRA_KVGR1 = CommonUtil.nullToBlank(objTarget.PVRA_KVGR1__c);

                objInput.PV_WAERS = CommonUtil.nullToBlank(objTarget.PV_WAERS__c);
                objInput.PV_KDGRP = CommonUtil.nullToBlank(objTarget.PV_KDGRP__c);
                objInput.PV_KVGR3 = CommonUtil.nullToBlank(objTarget.PV_KVGR3__c);
                objInput.PV_KVGR2 = CommonUtil.nullToBlank(objTarget.PV_KVGR2__c);
                objInput.PV_KVGR3_BOT = CommonUtil.nullToBlank(objTarget.PV_KVGR3_BOT__c);
                objInput.PV_ODCLOSEGB = CommonUtil.nullToBlank(objTarget.PV_ODCLOSEGB__c);
                objInput.PV_VACCPRTEXCYN = objTarget.PV_VACCPRTEXCYN__c ? 'Y' : 'N';
                objInput.PV_ZTERM_VV = CommonUtil.nullToBlank(objTarget.PV_ZTERM_VV__c);
                objInput.PV_DSTRHISTREGYN = CommonUtil.nullToBlank(objTarget.PV_DSTRHISTREGYN__c);
                objInput.PV_KULTG = CommonUtil.nullToBlank(objTarget.PV_KULTG__c);

                objInput.PV_OLD_BIZPLACE_NEW = CommonUtil.nullToBlank(objTarget.PV_OLD_BIZPLACE_NEW__c);
                objInput.PVVF_OLD_BIZPLACE_NEW = CommonUtil.nullToBlank(objTarget.PVVF_OLD_BIZPLACE_NEW__c);
                objInput.PVN_OLD_BIZPLACE_NEW = CommonUtil.nullToBlank(objTarget.PV_OLD_BIZPLACE_NEW__c);
                //objInput.PVO_OLD_BIZPLACE_NEW = CommonUtil.nullToBlank(objTarget.PVO_OLD_BIZPLACE_NEW__c);
                objInput.PVRA_OLD_BIZPLACE_NEW = CommonUtil.nullToBlank(objTarget.PVRA_OLD_BIZPLACE_NEW__c);

                objInput.PV_SHAPE = CommonUtil.nullToBlank(objTarget.PV_SHAPE__c);
                objInput.PV_EXAMYN = CommonUtil.nullToBlank(objTarget.PV_EXAMYN__c ? 'Y' : 'N');
                objInput.PV_SHIPREQTIME = CommonUtil.nullToBlank(objTarget.PV_SHIPREQTIME__c);
                objInput.PV_PRODLOADCOND = CommonUtil.nullToBlank(objTarget.PV_PRODLOADCOND__c);
                objInput.PV_RETURNLOC = CommonUtil.nullToBlank(objTarget.PV_RETURNLOC__c);
                objInput.PV_ENTERCOND1 = CommonUtil.nullToBlank(objTarget.PV_ENTERCOND1__c);
                objInput.PV_UNLOADCOND1 = CommonUtil.nullToBlank(objTarget.PV_UNLOADCOND1__c);
                objInput.PV_UNLOADCOND2 = CommonUtil.nullToBlank(objTarget.PV_UNLOADCOND2__c);
                objInput.PV_DELIGROUP = CommonUtil.nullToBlank(objTarget.PV_DELIGROUP__c);
                objInput.PV_KATR10 = CommonUtil.nullToBlank(objTarget.PV_KATR10__c);
                objInput.PV_KEYYN = objTarget.PV_KEYYN__c ? 'Y' : 'N';
                objInput.PV_KEYINFO = CommonUtil.nullToBlank(objTarget.PV_KEYINFO__c);
                objInput.PV_KXOTD = objTarget.PV_KXOTD__c ? 'Y' : 'N';
                objInput.PV_KXOTDTIME = CommonUtil.nullToBlank(objTarget.PV_KXOTDTIME__c);
                objInput.PV_FDINFO = objTarget.PV_FDINFO__c ? 'Y' : 'N';
                objInput.PV_FDREQD = CommonUtil.nullToBlank(objTarget.PV_FDREQD__c);
                objInput.PV_FDREQT = CommonUtil.nullToBlank(objTarget.PV_FDREQT__c);
                objInput.PV_ISFDFTF = objTarget.PV_ISFDFTF__c ? 'Y' : 'N';
                objInput.PV_FDCTINFO = CommonUtil.nullToBlank(objTarget.PV_FDCTINFO__c);
                objInput.PV_FDNOTICE = CommonUtil.nullToBlank(objTarget.PV_FDNOTICE__c);
                objInput.PV_SHIPTYPE = CommonUtil.nullToBlank(objTarget.PV_SHIPTYPE__c);
                objInput.PV_TEMPTARGET = CommonUtil.nullToBlank(objTarget.PV_TEMPTARGET__c);
                objInput.PV_ORDERMA = CommonUtil.nullToBlank(objTarget.PV_ORDERMA__c);
                objInput.PV_CSHAPE = CommonUtil.nullToBlank(objTarget.PV_CSHAPE__c);
                objInput.PV_STORECNT = CommonUtil.nullToBlank(objTarget.PV_STORECNT__c);
                objInput.PV_TERMF = CommonUtil.nullToBlank(objTarget.PV_TERMF__c);
                objInput.PV_EXISTSUP = CommonUtil.nullToBlank(objTarget.PV_EXISTSUP__c);
                objInput.PV_TERMT = CommonUtil.nullToBlank(objTarget.PV_TERMT__c);
                objInput.PV_ESALES = CommonUtil.nullToBlank(objTarget.PV_ESALES__c);
                objInput.PV_EPROFIT = CommonUtil.nullToBlank(objTarget.PV_EPROFIT__c);
                objInput.PV_ESALESFC = CommonUtil.nullToBlank(objTarget.PV_ESALESFC__c);
                objInput.PV_EXSALESFC = CommonUtil.nullToBlank(objTarget.PV_EXSALESFC__c);
                objInput.PV_GSALESFC = CommonUtil.nullToBlank(objTarget.PV_GSALESFC__c);
                objInput.PV_EXPROFITFC = CommonUtil.nullToBlank(objTarget.PV_EXPROFITFC__c);
                objInput.PV_GPROFITFC = CommonUtil.nullToBlank(objTarget.PV_GPROFITFC__c);
                objInput.PV_SALESPERSTOREFC = CommonUtil.nullToBlank(objTarget.PV_SALESPERSTOREFC__c);
                objInput.PV_DROPSIZEFC = CommonUtil.nullToBlank(objTarget.PV_DROPSIZEFC__c);
                objInput.PV_SKUPERSALESFC = CommonUtil.nullToBlank(objTarget.PV_SKUPERSALESFC__c);
                objInput.PV_EXSALESFEE = CommonUtil.nullToBlank(objTarget.PV_EXSALESFEE__c);
                objInput.PV_GSALESFEE = CommonUtil.nullToBlank(objTarget.PV_GSALESFEE__c);
                objInput.PV_NUMSKU = CommonUtil.nullToBlank(objTarget.PV_NUMSKU__c);
                objInput.PV_NUMPARTNER = CommonUtil.nullToBlank(objTarget.PV_NUMPARTNER__c);
                objInput.PV_DELAVG = CommonUtil.nullToBlank(objTarget.PV_DELAVG__c);
                objInput.PV_ETCSALESFEE = CommonUtil.nullToBlank(objTarget.PV_ETCSALESFEE__c);
                objInput.PV_SALESMNG = CommonUtil.nullToBlank(objTarget.PV_SALESMNG__c);
                objInput.PV_LOGISRATIO = CommonUtil.nullToBlank(objTarget.PV_LOGISRATIO__c);
                objInput.PV_LRATE = CommonUtil.nullToBlank(objTarget.PV_LRATE__c);
                objInput.PV_CGRRATE = CommonUtil.nullToBlank(objTarget.PV_CGRRATE__c);
                objInput.PV_CARDFRATE = CommonUtil.nullToBlank(objTarget.PV_CARDFRATE__c);
                objInput.PV_ETCRATE = CommonUtil.nullToBlank(objTarget.PV_ETCRATE__c);
                objInput.PV_SUPPOINT = CommonUtil.nullToBlank(objTarget.PV_SUPPOINT__c);
                objInput.PV_DEPRE = CommonUtil.nullToBlank(objTarget.PV_DEPRE__c);
                objInput.PV_SUBSIDY = CommonUtil.nullToBlank(objTarget.PV_SUBSIDY__c);
                objInput.PV_DONATION = CommonUtil.nullToBlank(objTarget.PV_DONATION__c);
                objInput.PV_ETCSUP = CommonUtil.nullToBlank(objTarget.PV_ETCSUP__c);
                objInput.PV_COMMRATE = CommonUtil.nullToBlank(objTarget.PV_COMMRATE__c);
                objInput.PV_DEPOSITYN = objTarget.PV_DEPOSITYN__c ? 'Y' : 'N';
                objInput.PV_DEPOSIT = CommonUtil.nullToBlank(objTarget.PV_DEPOSIT__c);
                objInput.PV_DEPOSITF = CommonUtil.nullToBlank(objTarget.PV_DEPOSITF__c);
                objInput.PV_PROVCOL = CommonUtil.nullToBlank(objTarget.PV_PROVCOL__c);
                objInput.PV_AMOUNTCOL = CommonUtil.nullToBlank(objTarget.PV_AMOUNTCOL__c);
                objInput.PV_ISCOLFEE = objTarget.PV_ISCOLFEE__c ? 'Y' : 'N';
                objInput.PV_SPECIALNOTE = CommonUtil.nullToBlank(objTarget.PV_SPECIALNOTE__c);
                objInput.PV_RESESALES = CommonUtil.nullToBlank(objTarget.PV_RESESALES__c);
                objInput.PV_RESEEARN = CommonUtil.nullToBlank(objTarget.PV_RESEEARN__c);
                objInput.PV_RESEPROFIT = CommonUtil.nullToBlank(objTarget.PV_RESEPROFIT__c);
                objInput.PV_ECPROFIT = CommonUtil.nullToBlank(objTarget.PV_ECPROFIT__c);
                objInput.PV_ECPROFITRATE = CommonUtil.nullToBlank(objTarget.PV_ECPROFITRATE__c);
                objInput.PV_SUPFEERATE = CommonUtil.nullToBlank(objTarget.PV_SUPFEERATE__c);
                objInput.PV_ESALESPROFIT = CommonUtil.nullToBlank(objTarget.PV_ESALESPROFIT__c);
                objInput.PV_ESALESPROFITRATE = CommonUtil.nullToBlank(objTarget.PV_ESALESPROFITRATE__c);
                objInput.PV_BLCKYN = objTarget.PV_BLCKYN__c ? 'Y' : 'N';
                objInput.PV_STATUSTYPE = CommonUtil.nullToBlank(objTarget.PV_STATUSTYPE__c);
                objInput.PV_BIZPLCODE = CommonUtil.nullToBlank(objTarget.PV_BIZPLCODE__c);
                objInput.PV_SALESCUST = CommonUtil.nullToBlank(objTarget.PV_SALESCUST__c);
                objInput.PV_DELICUST = CommonUtil.nullToBlank(objTarget.PV_DELICUST__c);
                objInput.WF_DESCRIPTION = CommonUtil.nullToBlank(objTarget.WF_DESCRIPTION__c);

                List<MDMContact> PV_MANAGER_INFO = new List<MDMContact>();

                List<Contact> listUpdateContact = new List<Contact>();

                if(listMDMContact <> null && listMDMContact.size() > 0) {
                    for(MDMRegRequestContact__c objMDMCon : listMDMContact) {

                        Contact objUpdateContact = new Contact();

                        objUpdateContact.Id = objMDMCon.Contact__c;
                        objUpdateContact.ExtId__c = objInput.PV_CRMNO+'_'+objMDMCon.PV_NO__c;

                        listUpdateContact.add(objUpdateContact);

                        MDMContact objMDMContact = new MDMContact();

                        objMDMContact.INSTANCEID = CommonUtil.nullToBlank(objMDMCon.INSTANCEID__c);
                        objMDMContact.PV_NO = CommonUtil.nullToBlank(objMDMCon.PV_NO__c);
                        objMDMContact.PV_NAME1_VK = CommonUtil.nullToBlank(objMDMCon.PV_NAME1_VK__c);
                        objMDMContact.PV_KNVKGB = CommonUtil.nullToBlank(objMDMCon.PV_KNVKGB__c);
                        objMDMContact.PV_TELF1_VK = CommonUtil.nullToBlank(objMDMCon.PV_TELF1_VK__c);
                        objMDMContact.PV_ABTNR_VK = CommonUtil.nullToBlank(objMDMCon.PV_ABTNR_VK__c);
                        objMDMContact.PV_PAFKT_VK = CommonUtil.nullToBlank(objMDMCon.PV_PAFKT_VK__c);
                        objMDMContact.PV_TALKT_VK = CommonUtil.nullToBlank(objMDMCon.PV_TALKT_VK__c);
                        objMDMContact.PV_EMAIL_VK = CommonUtil.nullToBlank(objMDMCon.PV_EMAIL_VK__c);

                        PV_MANAGER_INFO.add(objMDMContact);
                    }

                    objInput.PV_MANAGER_INFO = PV_MANAGER_INFO;
                }

                /*
                List<MDMBank> PV_BANK_INFO = new List<MDMBank>();

                if(listMDMBank <> null && listMDMBank.size() > 0) {
                    for(MDMRegRequestBank__c objMDMB : listMDMBank) {

                        MDMBank objMDMBank = new MDMBank();

                        objMDMBank.INSTANCEID = CommonUtil.nullToBlank(objMDMB.INSTANCEID__c);
                        objMDMBank.PV_NO = CommonUtil.nullToBlank(objMDMB.PV_NO__c);
                        objMDMBank.PV_BANKL = CommonUtil.nullToBlank(objMDMB.PV_BANKL__c);
                        objMDMBank.PV_BANKN = CommonUtil.nullToBlank(objMDMB.PV_BANKN__c);
                        objMDMBank.PV_KOINH = CommonUtil.nullToBlank(objMDMB.PV_KOINH__c);
                        objMDMBank.PV_BKONT = CommonUtil.nullToBlank(objMDMB.PV_BKONT__c);
                        objMDMBank.PV_BVTYP = CommonUtil.nullToBlank(objMDMB.PV_BVTYP__c);
                        objMDMBank.PV_BKREF = CommonUtil.nullToBlank(objMDMB.PV_BKREF__c);
                        objMDMBank.PV_ACTCLOSEYN = objMDMB.PV_ACTCLOSEYN__c ? 'Y' : 'N';
                        objMDMBank.PV_ACTCLOSED = CommonUtil.nullToBlank(objMDMB.PV_ACTCLOSED__c);

                        PV_BANK_INFO.add(objMDMBank);
                    }

                    objInput.PV_BANK_INFO = PV_BANK_INFO;
                }
                */

                IFUtil ifutilWrapper = new IFUtil('IF_SFDC_MDM_REG_ACCOUNT');

                String strJsonRequestBody = JSON.serialize(objInput);
                
                HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

                String responseBody = response.getBody();

                System.debug('===========> strJsonRequestBody : '+strJsonRequestBody);

                if(response.getStatusCode() == 200) {
                    IF_MDM_SFDC_RES_ACCOUNT.Item objResponse = (IF_MDM_SFDC_RES_ACCOUNT.Item)JSON.deserialize(responseBody,  IF_MDM_SFDC_RES_ACCOUNT.Item.class);

                    System.debug('=================> objResponse : '+JSON.serialize(objResponse));

                    if(objResponse.err_cd == 'S') {
                        MDMRegRequestCustomer__c objUpdateTarget = new MDMRegRequestCustomer__c();
                        objUpdateTarget.Id =  objTarget.Id;
                        objUpdateTarget.Status__c = 'InProgress';

                        MDMRegRequestResult__c objNewResult = new MDMRegRequestResult__c();

                        objNewResult.ExtId__c = objResponse.PV_CRMNO+'_'+objResponse.INSTANCEID;
                        objNewResult.MDMRegRequestCustomer__c = objTarget.Id;
                        objNewResult.INSTANCEID__c = objResponse.INSTANCEID;
                        objNewResult.PV_CRMNO__c = objResponse.PV_CRMNO;
                        // 2023-02-01 최초 승인요청시 검토(PROC)로 전송되어 혼란이 있어 요청완료로 변경 진행
                        //objNewResult.WF_STATUS__c = objResponse.WF_STATUS;
                        objNewResult.WF_STATUS__c = 'REQ';
                        
                        if(objResponse.WF_ACTOR <> null && objResponse.WF_ACTOR.size() > 0) {
                            String strWFActor = '';

                            for(IF_MDM_SFDC_RES_ACCOUNT.Actor objA : objResponse.WF_ACTOR) {
                                strWFActor += objA.NAME+'('+objA.EMPLOYEE_NUM+')'+'|';
                            }

                            if(strWFActor.length() > 0) {
                                strWFActor = strWFActor.substring(0, (strWFActor.length()-1));
                            }
                            objNewResult.WF_ACTOR__c = strWFActor;
                        }

                        if(objResponse.WF_NEXTACTOR <> null && objResponse.WF_NEXTACTOR.size() > 0) {
                            String strNEXTWFActor = '';

                            for(IF_MDM_SFDC_RES_ACCOUNT.NextActor objA : objResponse.WF_NEXTACTOR) {
                                strNEXTWFActor += objA.NAME+'('+objA.EMPLOYEE_NUM+')'+'|';
                            }

                            if(strNEXTWFActor.length() > 0) {
                                strNEXTWFActor = strNEXTWFActor.substring(0, (strNEXTWFActor.length()-1));
                            }

                            objNewResult.WF_NEXTACTOR__c = strNEXTWFActor;
                        }

                        objNewResult.WF_DATE__c = objResponse.WF_DATE <> null ? Datetime.valueOf(objResponse.WF_DATE) : null;
                        objNewResult.WF_DESCRIPTION__c = objResponse.WF_DESCRIPTION;

                        System.debug('==================> 1');

                        update objUpdateTarget;

                        System.debug('==================> 2');

                        insert objNewResult;

                        System.debug('==================> objUpdateAccount : '+JSON.serialize(objUpdateAccount));

                        /*
                        if(objUpdateAccount.Id <> null) {
                            System.debug('==================> objUpdateAccount Update');
                            update objUpdateAccount;
                        }
                        */

                        System.debug('==================> listUpdateContact : '+JSON.serialize(listUpdateContact));

                        if(listUpdateContact <> null && listUpdateContact.size() > 0) {
                            System.debug('==================> listUpdateContact Update');
                            update listUpdateContact;
                        }

                    }else {
                        strStatus = 'ERROR';
                        strMessage = '[I/F Error] '+objResponse.err_msg_ctt;
                    }
                }else {
                    strStatus = 'ERROR';
                    strMessage = '[I/F Error] 오류가 발생했습니다. 관리자에게 문의 부탁드립니다.\\\\n 오류코드 : '+response.getStatusCode()+' '+responseBody;
                }
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
        @AuraEnabled public String INSTANCEID {get;set;}
        @AuraEnabled public String PROCID {get;set;}
        @AuraEnabled public String REQACTORID {get;set;}
        @AuraEnabled public String PV_CRMNO {get;set;}
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
        @AuraEnabled public String PV_PAYCUST {get;set;}
        @AuraEnabled public String PV_CHARGECUST {get;set;}
        @AuraEnabled public String PV_VKGRP {get;set;}
        @AuraEnabled public String PVVF_VKGRP {get;set;}
        @AuraEnabled public String PVN_VKGRP {get;set;}
        @AuraEnabled public String PVO_VKGRP {get;set;}
        @AuraEnabled public String PVRA_VKGRP {get;set;}
        @AuraEnabled public String PV_PERNR {get;set;}
        @AuraEnabled public String PVVF_PERNR {get;set;}
        @AuraEnabled public String PVN_PERNR {get;set;}
        @AuraEnabled public String PVO_PERNR {get;set;}
        @AuraEnabled public String PVRA_PERNR {get;set;}
        @AuraEnabled public String PV_ADMINMA {get;set;}
        @AuraEnabled public String PV_LOGISCENTER {get;set;}
        @AuraEnabled public String PVVF_LOGISCENTER {get;set;}
        @AuraEnabled public String PVN_LOGISCENTER {get;set;}
        @AuraEnabled public String PVO_LOGISCENTER {get;set;}
        @AuraEnabled public String PVRA_LOGISCENTER {get;set;}
        @AuraEnabled public String PV_STCDT {get;set;}
        @AuraEnabled public String PV_FITYP {get;set;}
        @AuraEnabled public String PV_HDOFFICEYN {get;set;}
        @AuraEnabled public String PV_HKUNNR {get;set;}
        @AuraEnabled public String PV_SUBSIDIARYYN {get;set;}
        @AuraEnabled public String PV_VBUND {get;set;}
        @AuraEnabled public String PV_LIFNR {get;set;}
        @AuraEnabled public String PV_LAND1 {get;set;}
        @AuraEnabled public String PV_KNVKTYPE {get;set;}
        @AuraEnabled public String PV_CLOSEDT {get;set;}
        @AuraEnabled public String PV_REGIO {get;set;}
        @AuraEnabled public String PV_ADRES_ZIPCODE {get;set;}
        @AuraEnabled public String PV_ADRES_SEQ {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ADDR2 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR1 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADADDR2 {get;set;}
        @AuraEnabled public String PV_ADRES_ROADMGMTNO {get;set;}
        @AuraEnabled public String PV_BUSAB {get;set;}
        @AuraEnabled public String PV_CESSION_KZ {get;set;}
        @AuraEnabled public String PV_ZUAWA {get;set;}
        @AuraEnabled public String PV_AKONT {get;set;}
        @AuraEnabled public String PV_FDGRV {get;set;}
        @AuraEnabled public String PV_VRSDG {get;set;}
        @AuraEnabled public String PV_TAXKDD {get;set;}
        @AuraEnabled public String PV_KATR5 {get;set;}
        @AuraEnabled public String PV_CUHR1 {get;set;}
        @AuraEnabled public String PVVF_CUHR1 {get;set;}
        @AuraEnabled public String PVN_CUHR1 {get;set;}
        @AuraEnabled public String PVO_CUHR1 {get;set;}
        @AuraEnabled public String PVRA_CUHR1 {get;set;}
        @AuraEnabled public String PV_KONDA {get;set;}
        @AuraEnabled public String PVVF_KONDA {get;set;}
        @AuraEnabled public String PVN_KONDA {get;set;}
        @AuraEnabled public String PVO_KONDA {get;set;}
        @AuraEnabled public String PVRA_KONDA {get;set;}
        @AuraEnabled public String PV_KVGR1 {get;set;}
        @AuraEnabled public String PVVF_KVGR1 {get;set;}
        @AuraEnabled public String PVN_KVGR1 {get;set;}
        @AuraEnabled public String PVO_KVGR1 {get;set;}
        @AuraEnabled public String PVRA_KVGR1 {get;set;}
        @AuraEnabled public String PV_WAERS {get;set;}
        @AuraEnabled public String PV_KDGRP {get;set;}
        @AuraEnabled public String PV_KVGR3 {get;set;}
        @AuraEnabled public String PV_KVGR2 {get;set;}
        @AuraEnabled public String PV_KVGR3_BOT {get;set;}
        @AuraEnabled public String PV_ODCLOSEGB {get;set;}
        @AuraEnabled public String PV_VACCPRTEXCYN {get;set;}
        @AuraEnabled public String PV_ZTERM_VV {get;set;}
        @AuraEnabled public String PV_DSTRHISTREGYN {get;set;}
        @AuraEnabled public String PV_KULTG {get;set;}
        @AuraEnabled public String PV_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PVVF_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PVN_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PVO_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PVRA_OLD_BIZPLACE_NEW {get;set;}
        @AuraEnabled public String PV_SHAPE {get;set;}
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
        @AuraEnabled public String PV_ORDERMA {get;set;}
        @AuraEnabled public String PV_CSHAPE {get;set;}
        @AuraEnabled public String PV_STORECNT {get;set;}
        @AuraEnabled public String PV_TERMF {get;set;}
        @AuraEnabled public String PV_EXISTSUP {get;set;}
        @AuraEnabled public String PV_TERMT {get;set;}

        @AuraEnabled public String PV_ESALES {get;set;}
        @AuraEnabled public String PV_EPROFIT {get;set;}
        @AuraEnabled public String PV_ESALESFC {get;set;}
        @AuraEnabled public String PV_EXSALESFC {get;set;}
        @AuraEnabled public String PV_GSALESFC {get;set;}
        @AuraEnabled public String PV_EXPROFITFC {get;set;}
        @AuraEnabled public String PV_GPROFITFC {get;set;}

        @AuraEnabled public String PV_SALESPERSTOREFC {get;set;}
        @AuraEnabled public String PV_DROPSIZEFC {get;set;}
        @AuraEnabled public String PV_SKUPERSALESFC {get;set;}
        @AuraEnabled public String PV_EXSALESFEE {get;set;}
        @AuraEnabled public String PV_GSALESFEE {get;set;}
        @AuraEnabled public String PV_NUMSKU {get;set;}
        @AuraEnabled public String PV_NUMPARTNER {get;set;}
        @AuraEnabled public String PV_DELAVG {get;set;}
        @AuraEnabled public String PV_ETCSALESFEE {get;set;}
        @AuraEnabled public String PV_SALESMNG {get;set;}
        @AuraEnabled public String PV_LOGISRATIO {get;set;}
        @AuraEnabled public String PV_LRATE {get;set;}
        @AuraEnabled public String PV_CGRRATE {get;set;}
        @AuraEnabled public String PV_CARDFRATE {get;set;}
        @AuraEnabled public String PV_ETCRATE {get;set;}
        @AuraEnabled public String PV_SUPPOINT {get;set;}
        @AuraEnabled public String PV_DEPRE {get;set;}
        @AuraEnabled public String PV_SUBSIDY {get;set;}
        @AuraEnabled public String PV_DONATION {get;set;}
        @AuraEnabled public String PV_ETCSUP {get;set;}
        @AuraEnabled public String PV_COMMRATE {get;set;}
        @AuraEnabled public String PV_DEPOSITYN {get;set;}
        @AuraEnabled public String PV_DEPOSIT {get;set;}
        @AuraEnabled public String PV_DEPOSITF {get;set;}
        @AuraEnabled public String PV_PROVCOL {get;set;}
        @AuraEnabled public String PV_AMOUNTCOL {get;set;}
        @AuraEnabled public String PV_ISCOLFEE {get;set;}
        @AuraEnabled public String PV_SPECIALNOTE {get;set;}
        @AuraEnabled public String PV_RESESALES {get;set;}
        @AuraEnabled public String PV_RESEEARN {get;set;}
        @AuraEnabled public String PV_RESEPROFIT {get;set;}
        @AuraEnabled public String PV_ECPROFIT {get;set;}
        @AuraEnabled public String PV_ECPROFITRATE {get;set;}
        @AuraEnabled public String PV_SUPFEERATE {get;set;}
        @AuraEnabled public String PV_ESALESPROFIT {get;set;}
        @AuraEnabled public String PV_ESALESPROFITRATE {get;set;}
        @AuraEnabled public String PV_BLCKYN {get;set;}
        @AuraEnabled public String PV_STATUSTYPE {get;set;}
        @AuraEnabled public String PV_BIZPLCODE {get;set;}
        @AuraEnabled public String PV_SALESCUST {get;set;}
        @AuraEnabled public String PV_DELICUST {get;set;}
        @AuraEnabled public String WF_DESCRIPTION {get;set;}

        @AuraEnabled
        public List<MDMContact> PV_MANAGER_INFO {get;set;}
        /*
        @AuraEnabled
        public List<MDMBank> PV_BANK_INFO {get;set;}
        */
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

    /*
    public class MDMBank {
        @AuraEnabled public String INSTANCEID {get;set;}
        @AuraEnabled public String PV_NO {get;set;}
        @AuraEnabled public String PV_BANKL {get;set;}
        @AuraEnabled public String PV_BANKN {get;set;}
        @AuraEnabled public String PV_KOINH {get;set;}
        @AuraEnabled public String PV_BKONT {get;set;}
        @AuraEnabled public String PV_BVTYP {get;set;}
        @AuraEnabled public String PV_BKREF {get;set;}
        @AuraEnabled public String PV_ACTCLOSEYN {get;set;}
        @AuraEnabled public String PV_ACTCLOSED {get;set;}		
	}
    */
}