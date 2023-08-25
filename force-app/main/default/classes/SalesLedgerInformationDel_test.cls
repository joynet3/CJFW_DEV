/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 11-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class SalesLedgerInformationDel_test {

    @TestSetup
    static void makeData(){
        SalesLedgerInformation__c obj = new SalesLedgerInformation__c();
        obj.SALES_YMD__c=Date.valueOf('2022-08-04');
        obj.SALES_LNKG_CL_CD__c='ZP05';
        obj.SALES_LNKG_CL_NM__c='자가소비 판촉 오더';
        obj.ORDR_NO__c='2172550485';
        obj.BILI_DOC_NO__c='Z000000000';
        obj.SLST_ID__c='468100';
        obj.BRC_ID__c='374';
        obj.MNGPLC_ID__c='468100';
        obj.CRG_MA_ID__c='253655';
        // obj.fm_OurHeadOffice__c=true;
        // obj.fm_OurSu__c=true;
        // obj.fm_OurTeam__c=true;
        obj.SLBZ_ORG_ID__c='3001';
        obj.GD_NO__c='246734';
        obj.BARCD_NO__c='8801111186247';
        obj.BCNR_ID__c='1001399';
        obj.DSTR_HIS_NO_RPT_OBJ_YN_NM__c='해당없음';
        obj.DSTR_HIS_MNG_YN_NM__c='대상아님';
        obj.TAXT_CL_CD_NM__c='과세';
        obj.RLSTK_UNIT_RLSTK_QTY__c=3;
        obj.RLSTK_UNIT_RLSTK_QTY_KG__c=0.426;
        obj.BOX_CTCNT_QTY__c=20;
        obj.REAL_BUY_UNPRC__c=1991;
        obj.OPT_UNPRC__c=3587;
        obj.ORDR_REAL_BUY_UNPRC__c=1991;
        obj.ORDR_OPT_UNPRC__c=3587;
        obj.SALE_UNPRC__c=3766;
        obj.SALES_AT__c=0;
        obj.SALES_TAT__c=0;
        obj.SALES_SUM_AT__c=0;
        obj.SALES_P_RT__c=4.990242542514636;
        obj.SAP_ERR_MSG__c='';
        obj.BAS_TKSTK_QTY__c=3;
        obj.DIV_ID__c='4705';
        // obj.fm_MyData__c=false;
        obj.ISLIQ__c=false;
        obj.RLSTK_UNIT__c='EA';
        obj.BAS_UNIT__c='EA';
        obj.SPLY_CTR_ID__c='2600';
        obj.SHIPLC_ID__c='2600';
        obj.ExtId__c='2172550485_Z000000000_246734';
        obj.CUST_NM__c='헬씨누리)헬씨누리전문점팀';
        obj.MNGPLC_NM__c='헬씨누리)헬씨누리전문점팀';
        // obj.CRG_MA__c='';
        obj.CRG_MA_NM__c='신승윤';
        obj.BCNR_NM__c='(주)명현유통';
        obj.PB_GD_CL__c='40';
        obj.GD_NM__c='크라운제과 화이트하임(142g/EA)';
        // obj.GD__c='';
        // obj.fm_SalesProfit__c='5325';
        // obj.fm_SalesCost__c='5973';

        insert obj;
    }

    @isTest
    static void testSalesLedgerInformationDel_test() {
        Test.startTest();

        Date targetDate = Date.today();

        SalesLedgerInformationDel_sc sc = new SalesLedgerInformationDel_sc();
        sc.execute(null);
        Test.stopTest();
    }
}