/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 11-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class IF_MDM_SFDC_INFO_ACCOUNT_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_MDM_SFDC_INFO_ACCOUNT'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'POST';
            objIFMaster.ContentType__c = 'application/json';
            objIFMaster.Endpoint__c = 'test';
            
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;
    }

    @isTest
    static void testIF_MDM_SFDC_INFO_ACCOUNT() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{"transaction_id":"CR007_20221122152602075","is_last":"true","data":[{"INSTANCEID":"IT000000010020994588","PV_CRMNO":"","PV_KUNNR":"552311003","PV_OLDCD":"","PV_NAME1":"미담채(흰돌회)","PV_NAME_G":"미담채(흰돌회)","PV_NAME2":"미담채(흰돌회)","PV_KTOKD":"Z300","PV_CUSTTYPE":"C02","PV_STCD2":"5165000500","PV_STCD3":"","PV_STCD4":"","PV_GFORM":"A","PV_J_1KFREPRE":"이혜정","PV_STCD1":"761220","PV_J_1KFTBUS":"도매 및 소매업","PV_J_1KFTIND":"농수산물,식품","PV_TELF1":"010-3173-8600","PV_TELFX":"","PV_PAYCUST":"55231","PV_CHARGECUST":"55231","PV_VKGRP":"321-003","PVVF_VKGRP":"2022-11-22 12:11:00","PVN_VKGRP":"321-003","PVO_VKGRP":"","PVRA_VKGRP":"2022-11-22 12:11:00","PV_PERNR":"260956","PVVF_PERNR":"2022-11-22 12:11:00","PVN_PERNR":"260956","PVO_PERNR":"","PVRA_PERNR":"2022-11-22 12:11:00","PV_ADMINMA":"","PV_LOGISCENTER":"2600","PVVF_LOGISCENTER":"2022-11-22 12:11:00","PVN_LOGISCENTER":"2600","PVO_LOGISCENTER":"","PVRA_LOGISCENTER":"2022-11-22 12:11:00","PV_STCDT":"E2","PV_FITYP":"01","PV_HDOFFICEYN":"N","PV_HKUNNR":"55231","PV_SUBSIDIARYYN":"N","PV_VBUND":"","PV_LIFNR":"","PV_LAND1":"KR","PV_KNVKTYPE":"03","PV_CLOSEDT":"","PV_REGIO":"11380","PV_ADRES_ZIPCODE":"03481","PV_ADRES_SEQ":"","PV_ADRES_ADDR1":"서울 은평구 응암동 731-17","PV_ADRES_ADDR2":"","PV_ADRES_ROADADDR1":"서울 은평구 가좌로7가길 12","PV_ADRES_ROADADDR2":"","PV_ADRES_ROADMGMTNO":"","PV_BUSAB":"01","PV_CESSION_KZ":"01","PV_ZUAWA":"009","PV_AKONT":"11311010","PV_FDGRV":"C1","PV_VRSDG":"100","PV_TAXKDD":"1","PV_KATR5":"5B","PV_CUHR1":"3134-001","PVVF_CUHR1":"2022-11-22 12:11:00","PVN_CUHR1":"3134-001","PVO_CUHR1":"","PVRA_CUHR1":"2022-11-22 12:11:00","PV_KONDA":"5","PVVF_KONDA":"2022-11-22 12:11:00","PVN_KONDA":"5","PVO_KONDA":"","PVRA_KONDA":"2022-11-22 12:11:00","PV_KVGR1":"50J","PVVF_KVGR1":"2022-11-22 12:11:00","PVN_KVGR1":"50J","PVO_KVGR1":"","PVRA_KVGR1":"2022-11-22 12:11:00","PV_WAERS":"KRW","PV_KDGRP":"01","PV_KVGR3":"00","PV_KVGR2":"","PV_KVGR3_BOT":"02","PV_ODCLOSEGB":"20","PV_VACCPRTEXCYN":"N","PV_ZTERM_VV":"D730","PV_DSTRHISTREGYN":"3","PV_KULTG":"60","PV_OLD_BIZPLACE_NEW":"8002","PVVF_OLD_BIZPLACE_NEW":"2022-11-22 12:11:00","PVN_OLD_BIZPLACE_NEW":"8002","PVO_OLD_BIZPLACE_NEW":"","PVRA_OLD_BIZPLACE_NEW":"2022-11-22 12:11:00","PV_SHAPE":"","PV_EXAMYN":"N","PV_SHIPREQTIME":"","PV_PRODLOADCOND":"","PV_RETURNLOC":"","PV_ENTERCOND1":"","PV_UNLOADCOND1":"","PV_UNLOADCOND2":"","PV_DELIGROUP":"00","PV_KATR10":"","PV_KEYYN":"N","PV_KEYINFO":"","PV_KXOTD":"","PV_KXOTDTIME":"","PV_FDINFO":"","PV_FDREQD":"","PV_FDREQT":"","PV_ISFDFTF":"N","PV_FDCTINFO":"","PV_FDNOTICE":"","PV_SHIPTYPE":"01","PV_TEMPTARGET":"02","PV_ORDERMA":"","PV_CSHAPE":"","PV_STORECNT":"","PV_TERMF":"","PV_EXISTSUP":"","PV_TERMT":"","PV_ESALES":"","PV_EPROFIT":"","PV_ESALESFC":"","PV_EXSALESFC":"","PV_GSALESFC":"","PV_EXPROFITFC":"","PV_GPROFITFC":"","PV_SALESPERSTOREFC":"","PV_DROPSIZEFC":"","PV_SKUPERSALESFC":"","PV_EXSALESFEE":"","PV_GSALESFEE":"","PV_NUMSKU":"","PV_NUMPARTNER":"","PV_DELAVG":"","PV_ETCSALESFEE":"","PV_SALESMNG":"","PV_LOGISRATIO":"","PV_LRATE":"","PV_CGRRATE":"","PV_CARDFRATE":"","PV_ETCRATE":"","PV_SUPPOINT":"","PV_DEPRE":"","PV_SUBSIDY":"","PV_DONATION":"","PV_ETCSUP":"","PV_COMMRATE":"","PV_DEPOSITYN":"N","PV_DEPOSIT":"","PV_DEPOSITF":"","PV_PROVCOL":"","PV_AMOUNTCOL":"","PV_ISCOLFEE":"N","PV_SPECIALNOTE":"","PV_RESESALES":"","PV_RESEEARN":"","PV_RESEPROFIT":"","PV_ECPROFIT":"","PV_ECPROFITRATE":"","PV_SUPFEERATE":"","PV_ESALESPROFIT":"","PV_ESALESPROFITRATE":"","PV_BLCKYN":"N","PV_STATUSTYPE":"","PV_MANAGER_INFO":[{"PV_KUNNR":"552311003","INSTANCEID":"IT000000010020994588","PV_NO":"1","PV_NAME1_VK":"김흔중","PV_KNVKGB":"A03","PV_TELF1_VK":"01031738600","PV_ABTNR_VK":"","PV_PAFKT_VK":"","PV_TALKT_VK":"","PV_EMAIL_VK":""}],"PV_BANK_INFO":[]}],"total_page":"1","page_no":"1"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IF_MDM_SFDC_INFO_ACCOUNT.doPost();
        IF_MDM_SFDC_INFO_ACCOUNT_REALTIME.doPost();
        
        Test.stopTest();
    }
}