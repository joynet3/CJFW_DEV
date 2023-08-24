/**
 * @description       : MDM 고객정보 API
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
@RestResource(urlMapping='/mdm/customer/info')
global with sharing class IF_MDM_SFDC_INFO_ACCOUNT_REALTIME {
    global IF_MDM_SFDC_INFO_ACCOUNT_REALTIME() {

    }

    global class Input {
        public List<Item> data; 
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last;
    }

    global class Item {
        public String INSTANCEID;
        public String PV_CRMNO;
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
        String strErrorMessage = '오류가 발생했습니다. CRM에 문의해주시기 바랍니다.';
        

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
                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'data list is empty';
                }else{

                    Boolean isCRMRegExAccount = false;


                    Id recordIdEx = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();
                    List<Account> upsertAccountList = new List<Account>();
                    List<Account> updateAccountList = new List<Account>();
                    List<Contact> upsertContactList = new List<Contact>();
                    List<AccountBankInfo__c> upsertBankList = new List<AccountBankInfo__c>();

                    Set<String> setCustomerId = new Set<String>();
                    Set<String> setParentCustomerId = new Set<String>();

                    for(Item item : input.data) {
                        if(item.PV_PAYCUST <> null && item.PV_PAYCUST <> '') {
                            setCustomerId.add(item.PV_PAYCUST);
                        }
            
                        if(item.PV_CHARGECUST <> null && item.PV_PAYCUST <> '') {
                            setCustomerId.add(item.PV_CHARGECUST);
                        }

                        if(item.PV_HKUNNR <> null && item.PV_HKUNNR <> '') {
                            setParentCustomerId.add(item.PV_HKUNNR);
                        }
                    }

                    Map<String, Account> mapParentAccount = new Map<String, Account>();

                    for(Account objAccount : [
                        SELECT  Id, CustomerID__c, Name
                        FROM    Account
                        WHERE   CustomerID__c In:setParentCustomerId
                    ]) {
                        mapParentAccount.put(objAccount.CustomerID__c, objAccount);
                    }

                    Map<String, Account> mapAccount = new Map<String, Account>();

                    for(Account objAccount : [
                        SELECT  Id, CustomerID__c, Name
                        FROM    Account
                        WHERE   CustomerID__c In:setCustomerId
                    ]) {
                        mapAccount.put(objAccount.CustomerID__c, objAccount);
                    }

                    for(Item item : input.data) {
                        Account accountObj = new Account();

                        accountObj.RecordTypeId = recordIdEx;
                        accountObj.INSTANCEID__c = item.INSTANCEID;
                        accountObj.CustomerID__c = item.PV_KUNNR;
                        accountObj.CustomerIDASIS__c = item.PV_OLDCD;
                        accountObj.Name = item.PV_NAME1;
                        accountObj.NameKor__c = item.PV_NAME_G;
                        accountObj.NameAlias__c = item.PV_NAME2;
                        accountObj.AccountGroup__c = item.PV_KTOKD;
                        accountObj.CustomerType__c = item.PV_CUSTTYPE;
                        accountObj.CompanyRegisterNumber__c = item.PV_STCD2;
                        accountObj.CorporateCode__c = item.PV_STCD3;
                        accountObj.SubCompanyRegisterNumber__c = item.PV_STCD4;
                        accountObj.LegalStatus__c = item.PV_GFORM;
                        accountObj.RepresentativeName__c = item.PV_J_1KFREPRE;
                        accountObj.RepresentativeBirthDate__c = item.PV_STCD1;
                        accountObj.BusinessConditions__c = item.PV_J_1KFTBUS;
                        accountObj.BusinessCategory__c = item.PV_J_1KFTIND;
                        accountObj.Phone = item.PV_TELF1;
                        accountObj.Fax = item.PV_TELFX;
                        // 2022-11-10 Account 연결 확인필요(지급처)
                        //accountObj.PaymentAccountName__c = item.PV_PAYCUST;

                        if(item.PV_KUNNR == item.PV_PAYCUST) {
                            accountObj.PaymentAccountName__c = item.PV_NAME1;
                        }else if(mapAccount <> null && mapAccount.get(item.PV_PAYCUST) <> null) {
                            accountObj.PaymentAccountName__c = mapAccount.get(item.PV_PAYCUST).Name;
                        }else {
                            accountObj.PaymentAccountName__c = item.PV_PAYCUST;
                        }

                        accountObj.PaymentAccountCode__c = item.PV_PAYCUST;
                        // 2022-11-10 Account 연결 확인필요(청구처)
                        //accountObj.ShippingAccountName__c = item.PV_CHARGECUST;

                        if(item.PV_KUNNR == item.PV_CHARGECUST) {
                            accountObj.ShippingAccountName__c = item.PV_NAME1;
                        }else if(mapAccount <> null && mapAccount.get(item.PV_CHARGECUST) <> null) {
                            accountObj.ShippingAccountName__c = mapAccount.get(item.PV_CHARGECUST).Name;
                        }else {
                            accountObj.ShippingAccountName__c = item.PV_CHARGECUST;
                        }
                        
                        accountObj.ShippingAccountCode__c = item.PV_CHARGECUST;
                        accountObj.PV_VKGRP__c = item.PV_VKGRP;
                        accountObj.PVVF_VKGRP__c = item.PVVF_VKGRP <> null && item.PVVF_VKGRP <> '' ? Date.valueOf(item.PVVF_VKGRP) : null;
                        // accountObj.PVN_VKGRP__c = item.PVN_VKGRP;
                        // accountObj.PVO_VKGRP__c = item.PVO_VKGRP;
                        accountObj.SalesGroupFromDate__c = item.PVRA_VKGRP <> null && item.PVRA_VKGRP <> '' ? Date.valueOf(item.PVRA_VKGRP) : null;
                        accountObj.PICCode__c = item.PV_PERNR;
                        accountObj.PVVF_PERNR__c = item.PVVF_PERNR <> null && item.PVVF_PERNR <> '' ? Date.valueOf(item.PVVF_PERNR) : null;
                        // accountObj.PVN_PERNR__c = item.PVN_PERNR;
                        // accountObj.PVO_PERNR__c = item.PVO_PERNR;
                        accountObj.ResponsibilityMAFromDate__c = item.PVRA_PERNR <> null && item.PVRA_PERNR <> '' ? Date.valueOf(item.PVRA_PERNR) : null;
                        accountObj.ResponsibilityAMA__c = item.PV_ADMINMA;
                        accountObj.FWReleaseCenter__c = item.PV_LOGISCENTER;
                        accountObj.PVVF_LOGISCENTER__c = item.PVVF_LOGISCENTER <> null && item.PVVF_LOGISCENTER <> '' ? Date.valueOf(item.PVVF_LOGISCENTER) : null;
                        // accountObj.PVN_LOGISCENTER__c = item.PVN_LOGISCENTER;
                        // accountObj.PVO_LOGISCENTER__c = item.PVO_LOGISCENTER;
                        accountObj.FWReleaseCenterFromDate__c = item.PVRA_LOGISCENTER <> null && item.PVRA_LOGISCENTER <> '' ? Date.valueOf(item.PVRA_LOGISCENTER) : null;
                        accountObj.TaxInvoiceType__c = item.PV_STCDT;
                        accountObj.TaxationType__c = item.PV_FITYP;
                        accountObj.IsHeadShopUseYN__c = item.PV_HDOFFICEYN == 'Y' ? true : false;

                        accountObj.HeadOfficeCode__c = item.PV_HKUNNR;

                        if((item.PV_HKUNNR <> null && item.PV_HKUNNR <> '') && (item.PV_KUNNR != item.PV_HKUNNR) && (mapParentAccount <> null && mapParentAccount.get(item.PV_HKUNNR) <> null)) {
                            accountObj.ParentId = mapParentAccount.get(item.PV_HKUNNR).Id;
                        }
                        
                        accountObj.IsAffiliatedcompanyYN__c = item.PV_SUBSIDIARYYN == 'Y' ? true : false;
                        accountObj.AffiliatedCompany__c = item.PV_VBUND;
                        accountObj.PV_LIFNRNM__c = item.PV_LIFNR;
                        accountObj.CountryKeyCode__c = item.PV_LAND1;
                        accountObj.PV_KNVKTYPE__c = item.PV_KNVKTYPE;
                        accountObj.ShutDownDate__c = item.PV_CLOSEDT <> null && item.PV_CLOSEDT <> '' ? Date.valueOf(item.PV_CLOSEDT) : null;
                        accountObj.LocationState__c = item.PV_REGIO;
                        //accountObj.LocationState__c = item.PV_REGIO;
                        //accountObj.LocationStateProvince__c = item.;
                        accountObj.PostalCode__c = item.PV_ADRES_ZIPCODE;
                        accountObj.PV_ADRES_SEQ__c = item.PV_ADRES_SEQ;
                        accountObj.Address2__c = item.PV_ADRES_ADDR1;
                        accountObj.AddressDetails2__c = item.PV_ADRES_ADDR2;
                        accountObj.Address__c = item.PV_ADRES_ROADADDR1;
                        accountObj.AddressDetails__c = item.PV_ADRES_ROADADDR2;
                        accountObj.PV_ADRES_ROADMGMTNO__c = item.PV_ADRES_ROADMGMTNO;
                        accountObj.SalesForm__c = item.PV_BUSAB;
                        accountObj.CustomerStatus__c = item.PV_CESSION_KZ;
                        accountObj.SortKey__c = item.PV_ZUAWA;
                        accountObj.MediateAccount__c = item.PV_AKONT;
                        accountObj.CashManagementGroup__c = item.PV_FDGRV;
                        accountObj.IsDeposit__c = item.PV_VRSDG;
                        accountObj.TaxClassification__c = item.PV_TAXKDD;
                        accountObj.TaxPaymentMethod__c = item.PV_KATR5;
                        accountObj.CustomerRoute__c = item.PV_CUHR1;
                        accountObj.PV_CUHR1__c = item.PVVF_CUHR1 <> null && item.PVVF_CUHR1 <> '' ? Date.valueOf(item.PVVF_CUHR1) : null;
                        // accountObj.PVN_CUHR1__c = item.PVN_CUHR1;
                        // accountObj.PVO_CUHR1__c = item.PVO_CUHR1;
                        accountObj.CustomerRouteFromDate__c = item.PVRA_CUHR1 <> null && item.PVRA_CUHR1 <> '' ? Date.valueOf(item.PVRA_CUHR1) : null;
                        accountObj.PriceGroup__c = item.PV_KONDA;
                        accountObj.PVVF_KONDA__c = item.PVVF_KONDA <> null && item.PVVF_KONDA <> '' ? Date.valueOf(item.PVVF_KONDA) : null;
                        // accountObj.PVN_KONDA__c = item.PVN_KONDA;
                        // accountObj.PVO_KONDA__c = item.PVO_KONDA;
                        accountObj.PriceGroupFromDate__c = item.PVRA_KONDA <> null && item.PVRA_KONDA <> '' ? Date.valueOf(item.PVRA_KONDA) : null;
                        accountObj.UnitPriceGroup__c = item.PV_KVGR1;
                        accountObj.PVVF_KVGR1__c = item.PVVF_KVGR1 <> null && item.PVVF_KVGR1 <> '' ? Date.valueOf(item.PVVF_KVGR1) : null;
                        // accountObj.PVN_KVGR1__c = item.PVN_KVGR1;
                        // accountObj.PVO_KVGR1__c = item.PVO_KVGR1;
                        accountObj.UnitPriceGroupFromDate__c = item.PVRA_KVGR1 <> null && item.PVRA_KVGR1 <> '' ? Date.valueOf(item.PVRA_KVGR1) : null;
                        accountObj.CurrencyIsoCode = item.PV_WAERS;
                        accountObj.CreditManagement__c = item.PV_KDGRP;
                        accountObj.StatementOfDeliveryType__c = item.PV_KVGR3;
                        accountObj.SubsidyType__c = item.PV_KVGR2;
                        accountObj.StatementOfDeliveryType2__c = item.PV_KVGR3_BOT;
                        accountObj.CustomerOrderDeadlineType__c = item.PV_ODCLOSEGB;
                        accountObj.IsPrintVirtualAccount__c = item.PV_VACCPRTEXCYN == '1' ? true : false;
                        accountObj.TermsOfPayment__c = item.PV_ZTERM_VV;
                        accountObj.DisHisRegType__c = item.PV_DSTRHISTREGYN;
                        accountObj.ContractRocationDate__c = item.PV_KULTG;
                        accountObj.CustomerPath__c = item.PV_OLD_BIZPLACE_NEW;
                        accountObj.PVVF_OLD_BIZPLACE_NEW__c = item.PVVF_OLD_BIZPLACE_NEW <> null && item.PVVF_OLD_BIZPLACE_NEW <> '' ? Date.valueOf(item.PVVF_OLD_BIZPLACE_NEW) : null;
                        /*
                        accountObj.PVN_OLD_BIZPLACE_NEW__c = item.PVN_OLD_BIZPLACE_NEW;
                        accountObj.PVO_OLD_BIZPLACE_NEW__c = item.PVO_OLD_BIZPLACE_NEW;
                        */
                        accountObj.CustomerPathFromDate__c = item.PVRA_OLD_BIZPLACE_NEW <> null && item.PVRA_OLD_BIZPLACE_NEW <> '' ? Date.valueOf(item.PVRA_OLD_BIZPLACE_NEW) : null;
                        accountObj.Shape__c = item.PV_SHAPE;
                        accountObj.IsFaceToFaceInspectionStatus__c = item.PV_EXAMYN == '1' ? true : false;
                        accountObj.OTD__c = item.PV_SHIPREQTIME;
                        accountObj.ProductLoadingCondition__c = item.PV_PRODLOADCOND;
                        accountObj.ReturnLocation__c = item.PV_RETURNLOC;
                        accountObj.VehicleEntryCondtions__c = item.PV_ENTERCOND1;
                        accountObj.UnloadConditions1__c = item.PV_UNLOADCOND1;
                        accountObj.UnloadConditions2__c = item.PV_UNLOADCOND2;
                        accountObj.DeliveryGroup__c = item.PV_DELIGROUP;
                        accountObj.ShipmentArea__c = item.PV_KATR10;
                        accountObj.IsBusinessPlaceKey__c = item.PV_KEYYN == '1' ? true : false;
                        accountObj.BusinessPlaceKeyInfo__c = item.PV_KEYINFO;
                        accountObj.KXOTD__c = item.PV_KXOTD;
                        accountObj.KXOTDRequestDate__c = item.PV_KXOTDTIME;
                        accountObj.InitialDeliveryShare__c = item.PV_FDINFO;
                        accountObj.InitialDeliveryRequestDate__c = item.PV_FDREQD <> null && item.PV_FDREQD <> '' ? Date.valueOf(item.PV_FDREQD) : null;
                        accountObj.InitialDeliveryRequestTime__c = item.PV_FDREQT;
                        accountObj.IsInitialDeliveryFTFInspection__c = item.PV_ISFDFTF == 'Y' ? true : false;
                        accountObj.InitialDeliveryContact__c = item.PV_FDCTINFO;
                        accountObj.InitialDeliveryDescription__c = item.PV_FDNOTICE;
                        accountObj.PV_SHIPTYPE__c = item.PV_SHIPTYPE;
                        accountObj.PV_TEMPTARGET__c = item.PV_TEMPTARGET;
                        accountObj.PV_ORDERMA__c = item.PV_ORDERMA;
                        accountObj.PV_CSHAPE__c = item.PV_CSHAPE <> null && item.PV_CSHAPE <> '' ? Decimal.valueOf(item.PV_CSHAPE) : null;
                        accountObj.PV_STORECNT__c = item.PV_STORECNT <> null && item.PV_STORECNT <> '' ? Decimal.valueOf(item.PV_STORECNT) : null;
                        accountObj.PV_TERMF__c = item.PV_TERMF <> null && item.PV_TERMF <> '' ? Date.valueOf(item.PV_TERMF) : null;
                        accountObj.PV_EXISTSUP__c = item.PV_EXISTSUP;

                        if(item.PV_TERMT <> null && item.PV_TERMT <> '' && item.PV_TERMT.contains('9999-')) {
                            item.PV_TERMT = item.PV_TERMT.replaceAll('9999-', '2099-');
                        }
        
                        accountObj.PV_TERMT__c = item.PV_TERMT <> null && item.PV_TERMT <> '' ? Date.valueOf(item.PV_TERMT) : null;
                        accountObj.PV_ESALES__c = item.PV_ESALES <> null && item.PV_ESALES <> '' ? Decimal.valueOf(item.PV_ESALES) : null;
                        accountObj.PV_EPROFIT__c = item.PV_EPROFIT <> null && item.PV_EPROFIT <> '' ? Decimal.valueOf(item.PV_EPROFIT) : null;
                        accountObj.PV_ESALESFC__c = item.PV_ESALESFC <> null && item.PV_ESALESFC <> '' ? Decimal.valueOf(item.PV_ESALESFC) : null;
                        accountObj.PV_EXSALESFC__c = item.PV_EXSALESFC <> null && item.PV_EXSALESFC <> '' ? Decimal.valueOf(item.PV_EXSALESFC) : null;
                        accountObj.PV_GSALESFC__c = item.PV_GSALESFC <> null && item.PV_GSALESFC <> '' ? Decimal.valueOf(item.PV_GSALESFC) : null;
                        accountObj.PV_EXPROFITFC__c = item.PV_EXPROFITFC <> null && item.PV_EXPROFITFC <> '' ? Decimal.valueOf(item.PV_EXPROFITFC) : null;
                        accountObj.PV_GPROFITFC__c = item.PV_GPROFITFC <> null && item.PV_GPROFITFC <> '' ? Decimal.valueOf(item.PV_GPROFITFC) : null;
                        accountObj.PV_SALESPERSTOREFC__c = item.PV_SALESPERSTOREFC <> null && item.PV_SALESPERSTOREFC <> '' ? Decimal.valueOf(item.PV_SALESPERSTOREFC) : null;
                        accountObj.PV_DROPSIZEFC__c = item.PV_DROPSIZEFC <> null && item.PV_DROPSIZEFC <> '' ? Decimal.valueOf(item.PV_DROPSIZEFC) : null;
                        accountObj.PV_SKUPERSALESFC__c = item.PV_SKUPERSALESFC <> null && item.PV_SKUPERSALESFC <> '' ? Decimal.valueOf(item.PV_SKUPERSALESFC) : null;
                        accountObj.PV_EXSALESFEE__c = item.PV_EXSALESFEE <> null && item.PV_EXSALESFEE <> '' ? Decimal.valueOf(item.PV_EXSALESFEE) : null;
                        accountObj.PV_GSALESFEE__c = item.PV_GSALESFEE <> null && item.PV_GSALESFEE <> '' ? Decimal.valueOf(item.PV_GSALESFEE) : null;
                        accountObj.PV_NUMSKU__c = item.PV_NUMSKU <> null && item.PV_NUMSKU <> '' ? Decimal.valueOf(item.PV_NUMSKU) : null;
                        accountObj.PV_NUMPARTNER__c = item.PV_NUMPARTNER <> null && item.PV_NUMPARTNER <> '' ? Decimal.valueOf(item.PV_NUMPARTNER) : null;
                        accountObj.PV_DELAVG__c = item.PV_DELAVG <> null && item.PV_DELAVG <> '' ? Decimal.valueOf(item.PV_DELAVG) : null;
                        accountObj.PV_ETCSALESFEE__c = item.PV_ETCSALESFEE;
                        accountObj.PV_SALESMNG__c = item.PV_SALESMNG <> null && item.PV_SALESMNG <> '' ? Decimal.valueOf(item.PV_SALESMNG) : null;
                        accountObj.PV_LOGISRATIO__c = item.PV_LOGISRATIO <> null && item.PV_LOGISRATIO <> '' ? Decimal.valueOf(item.PV_LOGISRATIO) : null;
                        accountObj.PV_LRATE__c = item.PV_LRATE <> null && item.PV_LRATE <> '' ? Decimal.valueOf(item.PV_LRATE) : null;
                        accountObj.PV_CGRRATE__c = item.PV_CGRRATE <> null && item.PV_CGRRATE <> '' ? Decimal.valueOf(item.PV_CGRRATE) : null;
                        accountObj.PV_CARDFRATE__c = item.PV_CARDFRATE <> null && item.PV_CARDFRATE <> '' ? Decimal.valueOf(item.PV_CARDFRATE) : null;
                        accountObj.PV_ETCRATE__c = item.PV_ETCRATE <> null && item.PV_ETCRATE <> '' ? Decimal.valueOf(item.PV_ETCRATE) : null;
                        accountObj.PV_SUPPOINT__c = item.PV_SUPPOINT <> null && item.PV_SUPPOINT <> '' ? Decimal.valueOf(item.PV_SUPPOINT) : null;
                        accountObj.PV_DEPRE__c = item.PV_DEPRE <> null && item.PV_DEPRE <> '' ? Decimal.valueOf(item.PV_DEPRE) : null;
                        accountObj.PV_SUBSIDY__c = item.PV_SUBSIDY <> null && item.PV_SUBSIDY <> '' ? Decimal.valueOf(item.PV_SUBSIDY) : null;
                        accountObj.PV_DONATION__c = item.PV_DONATION <> null && item.PV_DONATION <> '' ? Decimal.valueOf(item.PV_DONATION) : null;
                        accountObj.PV_ETCSUP__c = item.PV_ETCSUP <> null && item.PV_ETCSUP <> '' ? Decimal.valueOf(item.PV_ETCSUP) : null;
                        accountObj.PV_COMMRATE__c = item.PV_COMMRATE <> null && item.PV_COMMRATE <> '' ? Decimal.valueOf(item.PV_COMMRATE) : null;
                        accountObj.PV_DEPOSITYN__c = item.PV_DEPOSITYN == 'Y' ? true : false;
                        accountObj.PV_DEPOSIT__c = item.PV_DEPOSIT <> null && item.PV_DEPOSIT <> '' ? Decimal.valueOf(item.PV_DEPOSIT) : null;
                        accountObj.PV_DEPOSITF__c = item.PV_DEPOSITF <> null && item.PV_DEPOSITF <> '' ? Decimal.valueOf(item.PV_DEPOSITF) : null;
                        accountObj.PV_PROVCOL__c = item.PV_PROVCOL;
                        accountObj.PV_AMOUNTCOL__c = item.PV_AMOUNTCOL <> null && item.PV_AMOUNTCOL <> '' ? Decimal.valueOf(item.PV_AMOUNTCOL) : null;
                        accountObj.PV_ISCOLFEE__c = item.PV_ISCOLFEE == 'Y' ? true : false;
                        accountObj.PV_SPECIALNOTE__c = item.PV_SPECIALNOTE;
                        accountObj.PV_RESESALES__c = item.PV_RESESALES <> null && item.PV_RESESALES <> '' ? Decimal.valueOf(item.PV_RESESALES) : null;
                        accountObj.PV_RESEEARN__c = item.PV_RESEEARN <> null && item.PV_RESEEARN <> '' ? Decimal.valueOf(item.PV_RESEEARN) : null;
                        accountObj.PV_RESEPROFIT__c = item.PV_RESEPROFIT <> null && item.PV_RESEPROFIT <> '' ? Decimal.valueOf(item.PV_RESEPROFIT) : null;
                        accountObj.PV_ECPROFIT__c = item.PV_ECPROFIT <> null && item.PV_ECPROFIT <> '' ? Decimal.valueOf(item.PV_ECPROFIT) : null;
                        accountObj.PV_ECPROFITRATE__c = item.PV_ECPROFITRATE <> null && item.PV_ECPROFITRATE <> '' ? Decimal.valueOf(item.PV_ECPROFITRATE) : null;
                        accountObj.PV_SUPFEERATE__c = item.PV_SUPFEERATE <> null && item.PV_SUPFEERATE <> '' ? Decimal.valueOf(item.PV_SUPFEERATE) : null;
                        accountObj.PV_ESALESPROFIT__c = item.PV_ESALESPROFIT <> null && item.PV_ESALESPROFIT <> '' ? Decimal.valueOf(item.PV_ESALESPROFIT) : null;
                        accountObj.PV_ESALESPROFITRATE__c = item.PV_ESALESPROFITRATE <> null && item.PV_ESALESPROFITRATE <> '' ? Decimal.valueOf(item.PV_ESALESPROFITRATE) : null;
                        accountObj.PV_BLCKYN__c = item.PV_BLCKYN == 'Y' ? true : false;
                        accountObj.PV_STATUSTYPE__c = item.PV_STATUSTYPE;
                        
                        if(item.PV_CRMNO <> null && item.PV_CRMNO <> '') {
                            isCRMRegExAccount = true;
                            accountObj.Id = item.PV_CRMNO;
                            updateAccountList.add(accountObj);
                        }else {
                            upsertAccountList.add(accountObj);
                        }
                    }

                    Savepoint sp = Database.setSavepoint();

                    try {
                        if(upsertAccountList <> null && upsertAccountList.size() > 0) {
                            upsert upsertAccountList CustomerID__c;
                        }
                        
                        if(updateAccountList <> null && updateAccountList.size() > 0) {
                            Database.DMLOptions dml = new Database.DMLOptions();
                            dml.DuplicateRuleHeader.allowSave = true;
                            
                            Database.SaveResult[] srList = Database.update(updateAccountList, dml);

                            for(Database.SaveResult sr : srList) {
                                if (sr.isSuccess()) {
                                }
                                else {
                                    // Operation failed, so get all errors
                                    for(Database.Error err : sr.getErrors()) {
                                        strCode = '-1';
                                        strMessage = err.getStatusCode() + ': ' + err.getMessage();
                                        System.debug('The following error has occurred.');
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    }
                                }
                            }

                            //update updateAccountList;
                        }
                    } catch(Exception e) {
                        Database.rollback(sp);
                        
                        strStatus = 'ERROR';
                        strCode = '-1';
                        strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       

                        System.debug('========================> strMessage : '+strMessage);
                    }


                    Map<String, Id> accountIdMap = new Map<String, Id>();
                    for (Account obj : upsertAccountList) {
                        accountIdMap.put(obj.CustomerID__c, obj.Id);
                    }

                    for (Account obj : updateAccountList) {
                        accountIdMap.put(obj.CustomerID__c, obj.Id);
                    }

                    Set<String> setAccountContactKey = new Set<String>();

                    for (Item item : input.data) {
                        if(item.PV_MANAGER_INFO <> null && item.PV_MANAGER_INFO.size() > 0){
                            for (Manager ManagerObj : item.PV_MANAGER_INFO) {
                                if(item.PV_KUNNR <> null && ManagerObj.PV_NO <> null) {
                                    String strKey = item.PV_KUNNR+'_'+ManagerObj.PV_NO;

                                    if(item.PV_CRMNO <> null && item.PV_CRMNO != '') {
                                        strKey = item.PV_CRMNO+'_'+ManagerObj.PV_NO;
                                    }

                                    Contact contactObj = new Contact();
                                    contactObj.AccountId = accountIdMap.get(item.PV_KUNNR);
                                    
                                    contactObj.INSTANCEID__c = item.INSTANCEID;
                                    contactObj.PV_KUNNR__c = item.PV_KUNNR;
                                    contactObj.PV_NO__c = ManagerObj.PV_NO;
                                    contactObj.LastName = ManagerObj.PV_NAME1_VK;
                                    contactObj.PV_KNVKGB__c = ManagerObj.PV_KNVKGB;
                                    contactObj.MobilePhone = ManagerObj.PV_TELF1_VK;
                                    contactObj.Department = ManagerObj.PV_ABTNR_VK;
                                    contactObj.PV_PAFKT_VK__c = ManagerObj.PV_PAFKT_VK;
                                    contactObj.PV_TALKT_VK__c = ManagerObj.PV_TALKT_VK;
                                    //contactObj.Email__c = ManagerObj.PV_EMAIL_VK;
                                    contactObj.EmailBackUp__c = ManagerObj.PV_EMAIL_VK;
                
                                    contactObj.ExtId__c = strKey;
                                    contactObj.IsAdminUpdate__c = true;

                                    upsertContactList.add(contactObj);   
                                }
                            }
                        }

                        Map<String, String> mapBankPicklist = CommonUtil.getMapPickListValuetoLabel('AccountBankInfo__c', 'PV_BANKL__c');
    
                        List<IF_MDM_SFDC_INFO_ACCOUNT_BANK__c> listUpdateBank = new List<IF_MDM_SFDC_INFO_ACCOUNT_BANK__c>();
                
                        Set<String> setAccountBankKey = new Set<String>();
    
                        if (item.PV_BANK_INFO <> null && item.PV_BANK_INFO.size() > 0) {
                            for (Bank objBank : item.PV_BANK_INFO) {
                                if(item.PV_KUNNR <> null && objBank.PV_NO <> null) {
                                    String strKey = item.PV_KUNNR+'_'+objBank.PV_NO;
                                
                                    if(!(setAccountBankKey <> null && setAccountBankKey.contains(strKey))) {
                                        setAccountBankKey.add(strKey);
                                
                                        AccountBankInfo__c bankObj = new AccountBankInfo__c();
                                        bankObj.Account__c = accountIdMap.get(item.PV_KUNNR);
                                        bankObj.Name = mapBankPicklist.get(objBank.PV_BANKL);
                                
                                        bankObj.INSTANCEID__c = item.INSTANCEID;            
                                        bankObj.PV_KUNNR__c = item.PV_KUNNR;
                                        bankObj.PV_NO__c = objBank.PV_NO;
                                        bankObj.PV_BANKL__c = objBank.PV_BANKL;
                                        bankObj.PV_BANKN__c = objBank.PV_BANKN;
                                        bankObj.PV_KOINH__c = objBank.PV_KOINH;
                                        bankObj.PV_BKONT__c = objBank.PV_BKONT;
                                        bankObj.PV_BVTYP__c = objBank.PV_BVTYP;
                                        bankObj.PV_BKREF__c = objBank.PV_BKREF;      
                                        if(objBank.PV_ACTCLOSED <> null) {
                                            bankObj.PV_ACTCLOSEYN__c = objBank.PV_ACTCLOSED == 'Y' ? true : false;
                                        }
                                        
                                        bankObj.PV_ACTCLOSED__c = objBank.PV_ACTCLOSED <> null && objBank.PV_ACTCLOSED <> '' ? Date.valueOf(objBank.PV_ACTCLOSED) : null;
                                
                                        bankObj.ExtId__c = item.PV_KUNNR+'_'+objBank.PV_NO;
                                        upsertBankList.add(bankObj);
                                    }
                                }
                            }
                        }
                    }

                    sp = Database.setSavepoint();

                    try {
                        if(upsertBankList <> null && upsertContactList <> null && upsertBankList.size() > 0 && upsertContactList.size() > 0) {
                            upsert upsertContactList ExtId__c;
                            upsert upsertBankList ExtId__c;                            
                        }
                    } catch(Exception e) {
                        Database.rollback(sp);

                        strStatus = 'ERROR';
                        strCode = '-1';
                        strMessage = e.getMessage()+' Line : '+e.getLineNumber();                    
            
                        System.debug('========================> strMessage : '+strMessage);
                    }
                }
            }
        } catch(Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                    

            System.debug('========================> strMessage : '+strMessage);
        }

        // 2022-11-11 Response 변경
        objOutput.err_cd = strCode;
        if(strStatus == 'ERROR') {
            objOutput.err_msg_ctt = strErrorMessage;
        }else {
            objOutput.err_msg_ctt = strMessage;
        }

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