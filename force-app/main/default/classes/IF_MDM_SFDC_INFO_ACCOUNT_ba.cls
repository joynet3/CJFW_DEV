/**
 * @description       : MDM 고객정보 Batch Class(사용안함)
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global with sharing class IF_MDM_SFDC_INFO_ACCOUNT_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{

    global String transactionId;

    global IF_MDM_SFDC_INFO_ACCOUNT_ba(String transactionId) {
        this.transactionId = transactionId;

        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, transactionId__c,INSTANCEID__c,PV_KUNNR__c,PV_OLDCD__c,PV_NAME1__c,PV_NAME_G__c,PV_NAME2__c,';
        strQuery += '   PV_KTOKD__c,PV_CUSTTYPE__c,PV_STCD2__c,PV_STCD3__c,PV_STCD4__c,PV_GFORM__c,PV_J_1KFREPRE__c,';
        strQuery += '   PV_STCD1__c,PV_J_1KFTBUS__c,PV_J_1KFTIND__c,PV_TELF1__c,PV_TELFX__c,PV_PAYCUST__c,PV_CHARGECUST__c,';
        strQuery += '   PV_VKGRP__c,PVVF_VKGRP__c,PVN_VKGRP__c,PVO_VKGRP__c,PVRA_VKGRP__c,PV_PERNR__c,PVVF_PERNR__c,PVN_PERNR__c,';
        strQuery += '   PVO_PERNR__c,PVRA_PERNR__c,PV_ADMINMA__c,PV_LOGISCENTER__c,PVVF_LOGISCENTER__c,PVN_LOGISCENTER__c,';
        strQuery += '   PVO_LOGISCENTER__c,PVRA_LOGISCENTER__c,PV_STCDT__c,PV_FITYP__c,PV_HDOFFICEYN__c,PV_HKUNNR__c,';
        strQuery += '   PV_SUBSIDIARYYN__c,PV_VBUND__c,PV_LIFNR__c,PV_LAND1__c,PV_KNVKTYPE__c,PV_CLOSEDT__c,PV_REGIO__c,';
        strQuery += '   PV_ADRES_ZIPCODE__c,PV_ADRES_SEQ__c,PV_ADRES_ADDR1__c,PV_ADRES_ADDR2__c,PV_ADRES_ROADADDR1__c,';
        strQuery += '   PV_ADRES_ROADADDR2__c,PV_ADRES_ROADMGMTNO__c,PV_BUSAB__c,PV_CESSION_KZ__c,PV_ZUAWA__c,PV_AKONT__c,';
        strQuery += '   PV_FDGRV__c,PV_VRSDG__c,PV_TAXKDD__c,PV_KATR5__c,PV_CUHR1__c,PVVF_CUHR1__c,PVN_CUHR1__c,PVO_CUHR1__c,';
        strQuery += '   PVRA_CUHR1__c,PV_KONDA__c,PVVF_KONDA__c,PVN_KONDA__c,PVO_KONDA__c,PVRA_KONDA__c,PV_KVGR1__c,PVVF_KVGR1__c,';
        strQuery += '   PVN_KVGR1__c,PVO_KVGR1__c,PVRA_KVGR1__c,PV_WAERS__c,PV_KDGRP__c,PV_KVGR3__c,PV_KVGR2__c,PV_KVGR3_BOT__c,';
        strQuery += '   PV_ODCLOSEGB__c,PV_VACCPRTEXCYN__c,PV_ZTERM_VV__c,PV_DSTRHISTREGYN__c,PV_KULTG__c,PV_OLD_BIZPLACE_NEW__c,';
        strQuery += '   PVVF_OLD_BIZPLACE_NEW__c,PVN_OLD_BIZPLACE_NEW__c,PVO_OLD_BIZPLACE_NEW__c,PVRA_OLD_BIZPLACE_NEW__c,PV_SHAPE__c,';
        strQuery += '   PV_EXAMYN__c,PV_SHIPREQTIME__c,PV_PRODLOADCOND__c,PV_RETURNLOC__c,PV_ENTERCOND1__c,PV_UNLOADCOND1__c,';
        strQuery += '   PV_UNLOADCOND2__c,PV_DELIGROUP__c,PV_KATR10__c,PV_KEYYN__c,PV_KEYINFO__c,PV_KXOTD__c,PV_KXOTDTIME__c,';
        strQuery += '   PV_FDINFO__c,PV_FDREQD__c,PV_FDREQT__c,PV_ISFDFTF__c,PV_FDCTINFO__c,PV_FDNOTICE__c,PV_SHIPTYPE__c,PV_TEMPTARGET__c,PV_ORDERMA__c,PV_CSHAPE__c,PV_STORECNT__c,';
        strQuery += '   PV_TERMF__c,PV_EXISTSUP__c,PV_TERMT__c,PV_ESALES__c,PV_EPROFIT__c,PV_ESALESFC__c,PV_EXSALESFC__c,';
        strQuery += '   PV_GSALESFC__c,PV_EXPROFITFC__c,PV_GPROFITFC__c,PV_SALESPERSTOREFC__c,PV_DROPSIZEFC__c,PV_SKUPERSALESFC__c,';
        strQuery += '   PV_EXSALESFEE__c,PV_GSALESFEE__c,PV_NUMSKU__c,PV_NUMPARTNER__c,PV_DELAVG__c,PV_ETCSALESFEE__c,PV_SALESMNG__c,';
        strQuery += '   PV_LOGISRATIO__c,PV_LRATE__c,PV_CGRRATE__c,PV_CARDFRATE__c,PV_ETCRATE__c,PV_SUPPOINT__c,PV_DEPRE__c,PV_SUBSIDY__c,';
        strQuery += '   PV_DONATION__c,PV_ETCSUP__c,PV_COMMRATE__c,PV_DEPOSITYN__c,PV_DEPOSIT__c,PV_DEPOSITF__c,PV_PROVCOL__c,PV_AMOUNTCOL__c,';
        strQuery += '   PV_ISCOLFEE__c,PV_SPECIALNOTE__c,PV_RESESALES__c,PV_RESEEARN__c,PV_RESEPROFIT__c,PV_ECPROFIT__c,PV_ECPROFITRATE__c,';
        strQuery += '   PV_SUPFEERATE__c,PV_ESALESPROFIT__c,PV_ESALESPROFITRATE__c,PV_BLCKYN__c,PV_STATUSTYPE__c';
        strQuery += '   FROM IF_MDM_SFDC_INFO_ACCOUNT__c';        
        strQuery += '   WHERE     IsUpdate__c = false' ;
        if(transactionId != 'ALL') {
            strQuery += '   AND transactionId__c = \'' + transactionId+'\'';
        }

        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<IF_MDM_SFDC_INFO_ACCOUNT__c> scope) {
        Set<String> setCustomerId = new Set<String>();
        for (IF_MDM_SFDC_INFO_ACCOUNT__c obj : scope) {
            if(obj.PV_PAYCUST__c <> null) {
                setCustomerId.add(obj.PV_PAYCUST__c);
            }

            if(obj.PV_CHARGECUST__c <> null) {
                setCustomerId.add(obj.PV_CHARGECUST__c);
            }
        }

        Map<String, Account> mapAccount = new Map<String, Account>();

        for(Account objAccount : [
            SELECT  Id, CustomerID__c, Name
            FROM    Account
            WHERE   CustomerID__c In:setCustomerId
        ]) {
            mapAccount.put(objAccount.CustomerID__c, objAccount);
        }


        List<Account> upsertAccountList = new List<Account>();
        List<Contact> upsertContactList = new List<Contact>();
        List<AccountBankInfo__c> upsertBankList = new List<AccountBankInfo__c>();
        List<IF_MDM_SFDC_INFO_ACCOUNT_CONTACT__c> contactDummyList = [
            SELECT Id, transactionId__c, INSTANCEID__c, PV_KUNNR__c, PV_NO__c, PV_NAME1_VK__c, PV_KNVKGB__c, PV_TELF1_VK__c, PV_ABTNR_VK__c, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_EMAIL_VK__c
            FROM IF_MDM_SFDC_INFO_ACCOUNT_CONTACT__c
            WHERE transactionId__c = :transactionId
        ];

        List<IF_MDM_SFDC_INFO_ACCOUNT_BANK__C> bankDummyList = [
            SELECT Id, transactionId__c,  INSTANCEID__c, PV_KUNNR__c, PV_NO__c, PV_BANKL__c, PV_BANKN__c, PV_KOINH__c, PV_BKONT__c, PV_BVTYP__c, PV_BKREF__c, PV_ACTCLOSEYN__c, PV_ACTCLOSED__c
            FROM IF_MDM_SFDC_INFO_ACCOUNT_BANK__C
            WHERE transactionId__c = :transactionId
        ];

        Id recordIdEx = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();

        List<IF_MDM_SFDC_INFO_ACCOUNT__c> listUpdate = new List<IF_MDM_SFDC_INFO_ACCOUNT__c>();        

        for (IF_MDM_SFDC_INFO_ACCOUNT__c obj : scope) {
            if(obj.PV_KUNNR__c <> null && (!(setCustomerID <> null && setCustomerID.contains(obj.PV_KUNNR__c)))) {
                setCustomerID.add(obj.PV_KUNNR__c);

                Account accountObj = new Account();

                accountObj.RecordTypeId = recordIdEx;

                accountObj.INSTANCEID__c = obj.INSTANCEID__c;
                accountObj.CustomerID__c = obj.PV_KUNNR__c;
                accountObj.CustomerIDASIS__c = obj.PV_OLDCD__c;
                accountObj.Name = obj.PV_NAME1__c;
                accountObj.NameKor__c = obj.PV_NAME_G__c;
                accountObj.NameAlias__c = obj.PV_NAME2__c;
                accountObj.AccountGroup__c = obj.PV_KTOKD__c;
                accountObj.CustomerType__c = obj.PV_CUSTTYPE__c;
                accountObj.CompanyRegisterNumber__c = obj.PV_STCD2__c;
                accountObj.CorporateCode__c = obj.PV_STCD3__c;
                accountObj.SubCompanyRegisterNumber__c = obj.PV_STCD4__c;
                accountObj.LegalStatus__c = obj.PV_GFORM__c;
                accountObj.RepresentativeName__c = obj.PV_J_1KFREPRE__c;
                accountObj.RepresentativeBirthDate__c = obj.PV_STCD1__c;
                accountObj.BusinessConditions__c = obj.PV_J_1KFTBUS__c;
                accountObj.BusinessCategory__c = obj.PV_J_1KFTIND__c;
                accountObj.Phone = obj.PV_TELF1__c;
                accountObj.Fax = obj.PV_TELFX__c;

                // 2022-11-10 Account 연결 확인필요(청구처)                
                if(obj.PV_KUNNR__c == obj.PV_PAYCUST__c) {
                    accountObj.PaymentAccountName__c = obj.PV_NAME1__c;
                }else if(mapAccount <> null && mapAccount.get(obj.PV_PAYCUST__c) <> null) {
                    accountObj.PaymentAccountName__c = mapAccount.get(obj.PV_PAYCUST__c).Name;
                }else {
                    accountObj.PaymentAccountName__c = obj.PV_PAYCUST__c;
                }
                
                accountObj.PaymentAccountCode__c = obj.PV_PAYCUST__c;

                // 2022-11-10 Account 연결 확인필요(지급처)
                if(obj.PV_KUNNR__c == obj.PV_CHARGECUST__c) {
                    accountObj.ShippingAccountName__c = obj.PV_NAME1__c;
                }else if(mapAccount <> null && mapAccount.get(obj.PV_CHARGECUST__c) <> null) {
                    accountObj.ShippingAccountName__c = mapAccount.get(obj.PV_CHARGECUST__c).Name;
                }else {
                    accountObj.ShippingAccountName__c = obj.PV_CHARGECUST__c;
                }
                
                accountObj.ShippingAccountCode__c = obj.PV_CHARGECUST__c;
                accountObj.PV_VKGRP__c = obj.PV_VKGRP__c;
                accountObj.PVVF_VKGRP__c = obj.PVVF_VKGRP__c <> null ? Date.valueOf(obj.PVVF_VKGRP__c) : null;
                // accountObj.PVN_VKGRP__c = obj.PVN_VKGRP__c;
                // accountObj.PVO_VKGRP__c = obj.PVO_VKGRP__c;
                accountObj.SalesGroupFromDate__c = obj.PVRA_VKGRP__c <> null ? Date.valueOf(obj.PVRA_VKGRP__c) : null;
                accountObj.PICCode__c = obj.PV_PERNR__c;
                accountObj.PVVF_PERNR__c = obj.PVVF_PERNR__c <> null ? Date.valueOf(obj.PVVF_PERNR__c) : null;
                // accountObj.PVN_PERNR__c = obj.PVN_PERNR__c;
                // accountObj.PVO_PERNR__c = obj.PVO_PERNR__c;
                accountObj.ResponsibilityMAFromDate__c = obj.PVRA_PERNR__c <> null ? Date.valueOf(obj.PVRA_PERNR__c) : null;
                accountObj.ResponsibilityAMA__c = obj.PV_ADMINMA__c;
                accountObj.FWReleaseCenter__c = obj.PV_LOGISCENTER__c;
                accountObj.PVVF_LOGISCENTER__c = obj.PVVF_LOGISCENTER__c <> null ? Date.valueOf(obj.PVVF_LOGISCENTER__c) : null;
                // accountObj.PVN_LOGISCENTER__c = obj.PVN_LOGISCENTER__c;
                // accountObj.PVO_LOGISCENTER__c = obj.PVO_LOGISCENTER__c;
                accountObj.FWReleaseCenterFromDate__c = obj.PVRA_LOGISCENTER__c <> null ? Date.valueOf(obj.PVRA_LOGISCENTER__c) : null;
                accountObj.TaxInvoiceType__c = obj.PV_STCDT__c;
                accountObj.TaxationType__c = obj.PV_FITYP__c;
                accountObj.IsHeadShopUseYN__c = obj.PV_HDOFFICEYN__c == 'Y' ? true : false;
                accountObj.HeadOfficeCode__c = obj.PV_HKUNNR__c;
                accountObj.IsAffiliatedcompanyYN__c = obj.PV_SUBSIDIARYYN__c == 'Y' ? true : false;
                //accountObj.AffiliatedCompanyCode__c = obj.PV_VBUND__c;
                accountObj.PV_LIFNRNM__c = obj.PV_LIFNR__c;
                accountObj.CountryKeyCode__c = obj.PV_LAND1__c;
                accountObj.PV_KNVKTYPE__c = obj.PV_KNVKTYPE__c;
                accountObj.ShutDownDate__c = obj.PV_CLOSEDT__c <> null ? Date.valueOf(obj.PV_CLOSEDT__c) : null;
                accountObj.LocationState__c = obj.PV_REGIO__c;
                //accountObj.LocationState__c = obj.PV_REGIO__c;
                //accountObj.LocationStateProvince__c = obj.__c;
                accountObj.PostalCode__c = obj.PV_ADRES_ZIPCODE__c;
                accountObj.PV_ADRES_SEQ__c = obj.PV_ADRES_SEQ__c;
                accountObj.Address2__c = obj.PV_ADRES_ADDR1__c;
                accountObj.AddressDetails2__c = obj.PV_ADRES_ADDR2__c;
                accountObj.Address__c = obj.PV_ADRES_ROADADDR1__c;
                accountObj.AddressDetails__c = obj.PV_ADRES_ROADADDR2__c;
                accountObj.PV_ADRES_ROADMGMTNO__c = obj.PV_ADRES_ROADMGMTNO__c;
                accountObj.SalesForm__c = obj.PV_BUSAB__c;
                accountObj.CustomerStatus__c = obj.PV_CESSION_KZ__c;
                accountObj.SortKey__c = obj.PV_ZUAWA__c;
                accountObj.MediateAccount__c = obj.PV_AKONT__c;
                accountObj.CashManagementGroup__c = obj.PV_FDGRV__c;
                accountObj.IsDeposit__c = obj.PV_VRSDG__c;
                accountObj.TaxClassification__c = obj.PV_TAXKDD__c;
                accountObj.TaxPaymentMethod__c = obj.PV_KATR5__c;
                accountObj.CustomerRoute__c = obj.PV_CUHR1__c;
                accountObj.PV_CUHR1__c = obj.PVVF_CUHR1__c <> null ? Date.valueOf(obj.PVVF_CUHR1__c) : null;
                // accountObj.PVN_CUHR1__c = obj.PVN_CUHR1__c;
                // accountObj.PVO_CUHR1__c = obj.PVO_CUHR1__c;
                accountObj.CustomerRouteFromDate__c = obj.PVRA_CUHR1__c <> null ? Date.valueOf(obj.PVRA_CUHR1__c) : null;
                accountObj.PriceGroup__c = obj.PV_KONDA__c;
                accountObj.PVVF_KONDA__c = obj.PVVF_KONDA__c <> null ? Date.valueOf(obj.PVVF_KONDA__c) : null;
                // accountObj.PVN_KONDA__c = obj.PVN_KONDA__c;
                // accountObj.PVO_KONDA__c = obj.PVO_KONDA__c;
                accountObj.PriceGroupFromDate__c = obj.PVRA_KONDA__c <> null ? Date.valueOf(obj.PVRA_KONDA__c) : null;
                accountObj.UnitPriceGroup__c = obj.PV_KVGR1__c;
                accountObj.PVVF_KVGR1__c = obj.PVVF_KVGR1__c <> null ? Date.valueOf(obj.PVVF_KVGR1__c) : null;
                // accountObj.PVN_KVGR1__c = obj.PVN_KVGR1__c;
                // accountObj.PVO_KVGR1__c = obj.PVO_KVGR1__c;
                accountObj.UnitPriceGroupFromDate__c = obj.PVRA_KVGR1__c <> null ? Date.valueOf(obj.PVRA_KVGR1__c) : null;
                accountObj.CurrencyIsoCode = obj.PV_WAERS__c;
                accountObj.CreditManagement__c = obj.PV_KDGRP__c;
                accountObj.StatementOfDeliveryType__c = obj.PV_KVGR3__c;
                accountObj.SubsidyType__c = obj.PV_KVGR2__c;
                accountObj.StatementOfDeliveryType2__c = obj.PV_KVGR3_BOT__c;
                accountObj.CustomerOrderDeadlineType__c = obj.PV_ODCLOSEGB__c;
                accountObj.IsPrintVirtualAccount__c = obj.PV_VACCPRTEXCYN__c == '1' ? true : false;
                accountObj.TermsOfPayment__c = obj.PV_ZTERM_VV__c;
                accountObj.DisHisRegType__c = obj.PV_DSTRHISTREGYN__c;
                accountObj.ContractRocationDate__c = obj.PV_KULTG__c;
                accountObj.CustomerPath__c = obj.PV_OLD_BIZPLACE_NEW__c;
                accountObj.PVVF_OLD_BIZPLACE_NEW__c = obj.PVVF_OLD_BIZPLACE_NEW__c <> null ?Date.valueOf(obj.PVVF_OLD_BIZPLACE_NEW__c) : null;
                /*
                accountObj.PVN_OLD_BIZPLACE_NEW__c = obj.PVN_OLD_BIZPLACE_NEW__c;
                accountObj.PVO_OLD_BIZPLACE_NEW__c = obj.PVO_OLD_BIZPLACE_NEW__c;
                */
                accountObj.CustomerPathFromDate__c = obj.PVRA_OLD_BIZPLACE_NEW__c <> null ?Date.valueOf(obj.PVRA_OLD_BIZPLACE_NEW__c) : null;
                accountObj.Shape__c = obj.PV_SHAPE__c;
                accountObj.IsFaceToFaceInspectionStatus__c = obj.PV_EXAMYN__c == '1' ? true : false;
                accountObj.OTD__c = obj.PV_SHIPREQTIME__c;
                accountObj.ProductLoadingCondition__c = obj.PV_PRODLOADCOND__c;
                accountObj.ReturnLocation__c = obj.PV_RETURNLOC__c;
                accountObj.VehicleEntryCondtions__c = obj.PV_ENTERCOND1__c;
                accountObj.UnloadConditions1__c = obj.PV_UNLOADCOND1__c;
                accountObj.UnloadConditions2__c = obj.PV_UNLOADCOND2__c;
                accountObj.DeliveryGroup__c = obj.PV_DELIGROUP__c;
                accountObj.ShipmentArea__c = obj.PV_KATR10__c;
                accountObj.IsBusinessPlaceKey__c = obj.PV_KEYYN__c == '1' ? true : false;
                accountObj.BusinessPlaceKeyInfo__c = obj.PV_KEYINFO__c;
                accountObj.KXOTD__c = obj.PV_KXOTD__c;
                accountObj.KXOTDRequestDate__c = obj.PV_KXOTDTIME__c;
                accountObj.InitialDeliveryShare__c = obj.PV_FDINFO__c;
                accountObj.InitialDeliveryRequestDate__c = obj.PV_FDREQD__c <> null ? Date.valueOf(obj.PV_FDREQD__c) : null;
                accountObj.InitialDeliveryRequestTime__c = obj.PV_FDREQT__c;
                accountObj.IsInitialDeliveryFTFInspection__c = obj.PV_ISFDFTF__c == 'Y' ? true : false;
                accountObj.InitialDeliveryContact__c = obj.PV_FDCTINFO__c;
                accountObj.InitialDeliveryDescription__c = obj.PV_FDNOTICE__c;
                accountObj.PV_SHIPTYPE__c = obj.PV_SHIPTYPE__c;
                accountObj.PV_TEMPTARGET__c = obj.PV_TEMPTARGET__c;
                accountObj.PV_ORDERMA__c = obj.PV_ORDERMA__c;
                accountObj.PV_CSHAPE__c = obj.PV_CSHAPE__c <> null ? Decimal.valueOf(obj.PV_CSHAPE__c) : null;
                accountObj.PV_STORECNT__c = obj.PV_STORECNT__c <> null ? Decimal.valueOf(obj.PV_STORECNT__c) : null;
                accountObj.PV_TERMF__c = obj.PV_TERMF__c <> null ? Date.valueOf(obj.PV_TERMF__c) : null;
                accountObj.PV_EXISTSUP__c = obj.PV_EXISTSUP__c;

                if(obj.PV_TERMT__c <> null && obj.PV_TERMT__c.contains('9999-')) {
                    obj.PV_TERMT__c = obj.PV_TERMT__c.replaceAll('9999-', '2099-');
                }

                accountObj.PV_TERMT__c = obj.PV_TERMT__c <> null ? Date.valueOf(obj.PV_TERMT__c) : null;

                accountObj.PV_ESALES__c = obj.PV_ESALES__c <> null ? Decimal.valueOf(obj.PV_ESALES__c) : null;
                accountObj.PV_EPROFIT__c = obj.PV_EPROFIT__c <> null ? Decimal.valueOf(obj.PV_EPROFIT__c) : null;
                accountObj.PV_ESALESFC__c = obj.PV_ESALESFC__c <> null ? Decimal.valueOf(obj.PV_ESALESFC__c) : null;
                accountObj.PV_EXSALESFC__c = obj.PV_EXSALESFC__c <> null ? Decimal.valueOf(obj.PV_EXSALESFC__c) : null;
                accountObj.PV_GSALESFC__c = obj.PV_GSALESFC__c <> null ? Decimal.valueOf(obj.PV_GSALESFC__c) : null;
                accountObj.PV_EXPROFITFC__c = obj.PV_EXPROFITFC__c <> null ? Decimal.valueOf(obj.PV_EXPROFITFC__c) : null;
                accountObj.PV_GPROFITFC__c = obj.PV_GPROFITFC__c <> null ? Decimal.valueOf(obj.PV_GPROFITFC__c) : null;
                accountObj.PV_SALESPERSTOREFC__c = obj.PV_SALESPERSTOREFC__c <> null ? Decimal.valueOf(obj.PV_SALESPERSTOREFC__c) : null;
                accountObj.PV_DROPSIZEFC__c = obj.PV_DROPSIZEFC__c <> null ? Decimal.valueOf(obj.PV_DROPSIZEFC__c) : null;
                accountObj.PV_SKUPERSALESFC__c = obj.PV_SKUPERSALESFC__c <> null ? Decimal.valueOf(obj.PV_SKUPERSALESFC__c) : null;
                accountObj.PV_EXSALESFEE__c = obj.PV_EXSALESFEE__c <> null ? Decimal.valueOf(obj.PV_EXSALESFEE__c) : null;
                accountObj.PV_GSALESFEE__c = obj.PV_GSALESFEE__c <> null ? Decimal.valueOf(obj.PV_GSALESFEE__c) : null;
                accountObj.PV_NUMSKU__c = obj.PV_NUMSKU__c <> null ? Decimal.valueOf(obj.PV_NUMSKU__c) : null;
                accountObj.PV_NUMPARTNER__c = obj.PV_NUMPARTNER__c <> null ? Decimal.valueOf(obj.PV_NUMPARTNER__c) : null;
                accountObj.PV_DELAVG__c = obj.PV_DELAVG__c <> null ? Decimal.valueOf(obj.PV_DELAVG__c) : null;
                accountObj.PV_ETCSALESFEE__c = obj.PV_ETCSALESFEE__c;
                accountObj.PV_SALESMNG__c = obj.PV_SALESMNG__c <> null ? Decimal.valueOf(obj.PV_SALESMNG__c) : null;
                accountObj.PV_LOGISRATIO__c = obj.PV_LOGISRATIO__c <> null ? Decimal.valueOf(obj.PV_LOGISRATIO__c) : null;
                accountObj.PV_LRATE__c = obj.PV_LRATE__c <> null ? Decimal.valueOf(obj.PV_LRATE__c) : null;
                accountObj.PV_CGRRATE__c = obj.PV_CGRRATE__c <> null ? Decimal.valueOf(obj.PV_CGRRATE__c) : null;
                accountObj.PV_CARDFRATE__c = obj.PV_CARDFRATE__c <> null ? Decimal.valueOf(obj.PV_CARDFRATE__c) : null;
                accountObj.PV_ETCRATE__c = obj.PV_ETCRATE__c <> null ? Decimal.valueOf(obj.PV_ETCRATE__c) : null;
                accountObj.PV_SUPPOINT__c = obj.PV_SUPPOINT__c <> null ? Decimal.valueOf(obj.PV_SUPPOINT__c) : null;
                accountObj.PV_DEPRE__c = obj.PV_DEPRE__c <> null ? Decimal.valueOf(obj.PV_DEPRE__c) : null;
                accountObj.PV_SUBSIDY__c = obj.PV_SUBSIDY__c <> null ? Decimal.valueOf(obj.PV_SUBSIDY__c) : null;
                accountObj.PV_DONATION__c = obj.PV_DONATION__c <> null ? Decimal.valueOf(obj.PV_DONATION__c) : null;
                accountObj.PV_ETCSUP__c = obj.PV_ETCSUP__c <> null ? Decimal.valueOf(obj.PV_ETCSUP__c) : null;
                accountObj.PV_COMMRATE__c = obj.PV_COMMRATE__c <> null ? Decimal.valueOf(obj.PV_COMMRATE__c) : null;
                accountObj.PV_DEPOSITYN__c = obj.PV_DEPOSITYN__c == 'Y' ? true : false;
                accountObj.PV_DEPOSIT__c = obj.PV_DEPOSIT__c <> null ? Decimal.valueOf(obj.PV_DEPOSIT__c) : null;
                accountObj.PV_DEPOSITF__c = obj.PV_DEPOSITF__c <> null ? Decimal.valueOf(obj.PV_DEPOSITF__c) : null;
                accountObj.PV_PROVCOL__c = obj.PV_PROVCOL__c;
                accountObj.PV_AMOUNTCOL__c = obj.PV_AMOUNTCOL__c <> null ? Decimal.valueOf(obj.PV_AMOUNTCOL__c) : null;
                accountObj.PV_ISCOLFEE__c = obj.PV_ISCOLFEE__c == 'Y' ? true : false;
                accountObj.PV_SPECIALNOTE__c = obj.PV_SPECIALNOTE__c;
                accountObj.PV_RESESALES__c = obj.PV_RESESALES__c <> null ? Decimal.valueOf(obj.PV_RESESALES__c) : null;
                accountObj.PV_RESEEARN__c = obj.PV_RESEEARN__c <> null ? Decimal.valueOf(obj.PV_RESEEARN__c) : null;
                accountObj.PV_RESEPROFIT__c = obj.PV_RESEPROFIT__c <> null ? Decimal.valueOf(obj.PV_RESEPROFIT__c) : null;
                accountObj.PV_ECPROFIT__c = obj.PV_ECPROFIT__c <> null ? Decimal.valueOf(obj.PV_ECPROFIT__c) : null;
                accountObj.PV_ECPROFITRATE__c = obj.PV_ECPROFITRATE__c <> null ? Decimal.valueOf(obj.PV_ECPROFITRATE__c) : null;
                accountObj.PV_SUPFEERATE__c = obj.PV_SUPFEERATE__c <> null ? Decimal.valueOf(obj.PV_SUPFEERATE__c) : null;
                accountObj.PV_ESALESPROFIT__c = obj.PV_ESALESPROFIT__c <> null ? Decimal.valueOf(obj.PV_ESALESPROFIT__c) : null;
                accountObj.PV_ESALESPROFITRATE__c = obj.PV_ESALESPROFITRATE__c <> null ? Decimal.valueOf(obj.PV_ESALESPROFITRATE__c) : null;
                accountObj.PV_BLCKYN__c = obj.PV_BLCKYN__c == 'Y' ? true : false;
                accountObj.PV_STATUSTYPE__c = obj.PV_STATUSTYPE__c;
                upsertAccountList.add(accountObj);

                IF_MDM_SFDC_INFO_ACCOUNT__c objTarget = new IF_MDM_SFDC_INFO_ACCOUNT__c();
                objTarget.Id = obj.Id;
                objTarget.IsUpdate__c = true;
                listUpdate.add(objTarget);
            }            
        }

        Savepoint sp = Database.setSavepoint();

        // try {
            if(upsertAccountList <> null && upsertAccountList.size() > 0) {
                upsert upsertAccountList CustomerID__c;

                if(listUpdate <> null && listUpdate.size() > 0) {
                    update listUpdate;
                }
            }
        // }catch(Exception e) {
        //     Database.rollback(sp);
        //     System.debug('=============================> Error Line '+e.getLineNumber());
        //     System.debug('=============================> Error '+e.getMessage());
        // }

        Map<String, Id> accountIdMap = new Map<String, Id>();
        for (Account obj : upsertAccountList) {
            accountIdMap.put(obj.CustomerID__c, obj.Id);
        }

        List<IF_MDM_SFDC_INFO_ACCOUNT_CONTACT__c> listUpdateContact = new List<IF_MDM_SFDC_INFO_ACCOUNT_CONTACT__c>();

        Set<String> setAccountContactKey = new Set<String>();

        for (IF_MDM_SFDC_INFO_ACCOUNT_CONTACT__c obj : contactDummyList) {
            if(obj.PV_KUNNR__c <> null && obj.PV_NO__c <> null) {
                String strKey = obj.PV_KUNNR__c+'_'+obj.PV_NO__c;

                if(!(setAccountContactKey <> null && setAccountContactKey.contains(strKey))) {
                    setAccountContactKey.add(strKey);

                    Contact contactObj = new Contact();
                    contactObj.AccountId = accountIdMap.get(obj.PV_KUNNR__c);
                    
                    contactObj.INSTANCEID__c = obj.INSTANCEID__c;
                    contactObj.PV_KUNNR__c = obj.PV_KUNNR__c;
                    contactObj.PV_NO__c = obj.PV_NO__c;
                    contactObj.LastName = obj.PV_NAME1_VK__c;
                    contactObj.PV_KNVKGB__c = obj.PV_KNVKGB__c;
                    contactObj.MobilePhone = obj.PV_TELF1_VK__c;
                    contactObj.Department = obj.PV_ABTNR_VK__c;
                    contactObj.PV_PAFKT_VK__c = obj.PV_PAFKT_VK__c;
                    contactObj.PV_TALKT_VK__c = obj.PV_TALKT_VK__c;
                    //contactObj.Email = obj.PV_EMAIL_VK__c;
                    contactObj.EmailBackUp__c = obj.PV_EMAIL_VK__c;

                    contactObj.ExtId__c = obj.PV_KUNNR__c+'_'+obj.PV_NO__c;
                    upsertContactList.add(contactObj);

                    IF_MDM_SFDC_INFO_ACCOUNT_CONTACT__c objTarget = new IF_MDM_SFDC_INFO_ACCOUNT_CONTACT__c();
                    objTarget.Id = obj.Id;
                    objTarget.IsUpdate__c = true;
                    listUpdateContact.add(objTarget);
                }
            }            
        }

        Map<String, String> mapBankPicklist = CommonUtil.getMapPickListValuetoLabel('AccountBankInfo__c', 'PV_BANKL__c');

        List<IF_MDM_SFDC_INFO_ACCOUNT_BANK__c> listUpdateBank = new List<IF_MDM_SFDC_INFO_ACCOUNT_BANK__c>();

        Set<String> setAccountBankKey = new Set<String>();

        for (IF_MDM_SFDC_INFO_ACCOUNT_BANK__c obj : bankDummyList) {
            if(obj.PV_KUNNR__c <> null && obj.PV_NO__c <> null) {
                String strKey = obj.PV_KUNNR__c+'_'+obj.PV_NO__c;

                if(!(setAccountBankKey <> null && setAccountBankKey.contains(strKey))) {
                    setAccountBankKey.add(strKey);

                    AccountBankInfo__c bankObj = new AccountBankInfo__c();
                    bankObj.Account__c = accountIdMap.get(obj.PV_KUNNR__c);
                    bankObj.Name = mapBankPicklist.get(obj.PV_BANKL__c);

                    bankObj.INSTANCEID__c = obj.INSTANCEID__c;            
                    bankObj.PV_KUNNR__c = obj.PV_KUNNR__c;
                    bankObj.PV_NO__c = obj.PV_NO__c;
                    bankObj.PV_BANKL__c = obj.PV_BANKL__c;
                    bankObj.PV_BANKN__c = obj.PV_BANKN__c;
                    bankObj.PV_KOINH__c = obj.PV_KOINH__c;
                    bankObj.PV_BKONT__c = obj.PV_BKONT__c;
                    bankObj.PV_BVTYP__c = obj.PV_BVTYP__c;
                    bankObj.PV_BKREF__c = obj.PV_BKREF__c;      
                    if(obj.PV_ACTCLOSED__c <> null) {
                        bankObj.PV_ACTCLOSEYN__c = obj.PV_ACTCLOSED__c == 'Y' ? true : false;
                    }
                    
                    bankObj.PV_ACTCLOSED__c = obj.PV_ACTCLOSED__c <> null ? Date.valueOf(obj.PV_ACTCLOSED__c) : null;

                    bankObj.ExtId__c = obj.PV_KUNNR__c+'_'+obj.PV_NO__c;
                    upsertBankList.add(bankObj);

                    IF_MDM_SFDC_INFO_ACCOUNT_BANK__c objTarget = new IF_MDM_SFDC_INFO_ACCOUNT_BANK__c();
                    objTarget.Id = obj.Id;
                    objTarget.IsUpdate__c = true;
                    listUpdateBank.add(objTarget);
                }
            }
        }


        // try {
            if(upsertContactList <> null && upsertContactList.size() > 0) {
                upsert upsertContactList ExtId__c;

                if(listUpdateContact <> null && listUpdateContact.size() > 0) {
                    update listUpdateContact;
                }
            }
            
            if(upsertBankList <> null && upsertBankList.size() > 0) {
                upsert upsertBankList ExtId__c;

                if(listUpdateBank <> null && listUpdateBank.size() > 0) {
                    update listUpdateBank;
                }
            }
			
        // }catch(Exception e) {
        //     Database.rollback(sp);

        //     System.debug('=============================> Error Line '+e.getLineNumber());
        //     System.debug('=============================> Error '+e.getMessage());
        // }
    }

    global void finish(Database.BatchableContext BC) {
        IF_DUMMY_DEL_ba del_account = new IF_DUMMY_DEL_ba('IF_MDM_SFDC_INFO_ACCOUNT__c', this.transactionId);
        Database.executeBatch(del_account, 200);

        IF_DUMMY_DEL_ba del_contact = new IF_DUMMY_DEL_ba('IF_MDM_SFDC_INFO_ACCOUNT_CONTACT__c', this.transactionId);
        Database.executeBatch(del_contact, 200);

        IF_DUMMY_DEL_ba del_bank = new IF_DUMMY_DEL_ba('IF_MDM_SFDC_INFO_ACCOUNT_BANK__c', this.transactionId);
        Database.executeBatch(del_bank, 200);
    }
}