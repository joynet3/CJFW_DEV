/**
 * @description       : 매출원장정보 Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class IF_IFRESH_SFDC_INFO_ORDER_0001_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global String transactionId;

    global IF_IFRESH_SFDC_INFO_ORDER_0001_ba(String transactionId) {
        this.transactionId = transactionId;
    }

    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : IF Dummy Object 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, transactionId__c, IsUpdate__c,';
        strQuery += '   SALES_YMD__c, slbz_org_id__c, SALES_LNKG_CL_CD__c, SALES_LNKG_CL_NM__c, ORDR_NO__c,';
        strQuery += '   BILI_DOC_NO__c, SLST_ID__c, CUST_NM__c, MNGPLC_ID__c, MNGPLC_NM__c, DIV_ID__c, DIV_NM__c, BRC_ID__c, BRC_NM__c,';
        strQuery += '   CRG_MA_ID__c, CRG_MA_NM__c, CRG_SMA_ID__c, CRG_SMA_NM__c, SCHL_CD__c, SCHL_NM__c, SPLY_CTR_ID__c, SPLY_CTR_NM__c,';
        strQuery += '   SHIPLC_ID__c, SHIPLC_NM__c, LAR_GD_CLS_ID__c, MID_GD_CLS_ID__c, SML_GD_CLS_ID__c, ISLIQ__c, GD_NO__c, GD_NM__c,';
        strQuery += '   GD_CLS_ID__c, pb_gd_cl_cd__c, PB_GD_CL_CD_NM__c, BARCD_NO__c, BCNR_ID__c, BCNR_NM__c, DSTR_HIS_NO_RPT_OBJ_YN_NM__c, DSTR_HIS_MNG_YN_NM__c,';
        strQuery += '   DSTR_HIS_NO__c, BL_NO__c, TAXT_CL_CD_NM__c, RLSTK_UNIT_RLSTK_QTY__c, RLSTK_UNIT_RLSTK_QTY_KG__c, BOX_CTCNT_QTY__c,';
        strQuery += '   RLSTK_UNIT_CD_NM__c, REAL_BUY_UNPRC__c, OPT_UNPRC__c, ORDR_REAL_BUY_UNPRC__c, ORDR_OPT_UNPRC__c, SALE_UNPRC__c,';
        strQuery += '   SALES_AT__c, SALES_TAT__c, SALES_SUM_AT__c, SALES_P_RT__c, SAP_ERR_MSG__c, BAS_UNIT_CD__c, BAS_TKSTK_QTY__c,';
        strQuery += '   REG_DT__c, UPD_DT__c, ORDR_DTL_NO__c, sales_seq__c, sales_vat_seq__c';
        strQuery += '   FROM IF_IFRESH_SFDC_INFO_ORDER_0001__c';
        strQuery += '   WHERE     IsUpdate__c = false' ;

        if(transactionId != 'ALL') {
            strQuery += '   AND transactionId__c =\'' + transactionId + '\'';
        }        

        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 매출원장정보 upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<IF_IFRESH_SFDC_INFO_ORDER_0001__c> scope) {
        Map<String,String> pbPicklistMap = new Map<String,String>();
        
        pbPicklistMap = CommonUtil.getMapPickListLabeltoValue('SalesLedgerInformation__c', 'PB_GD_CL__c');

        Set<String> setCustomerId = new Set<String>();
        Set<String> setSchoolCustId = new Set<String>();
        Set<String> setUserEmployeeNumber = new Set<String>();
        Set<String> setGdClsId = new Set<String>();
        Set<String> setProductCode = new Set<String>();

        Set<String> setPK = new Set<String>();

        for(IF_IFRESH_SFDC_INFO_ORDER_0001__c objDummy : scope) {
            if(objDummy.ORDR_NO__c <> null && objDummy.ORDR_DTL_NO__c <> null) {
                setPK.add(objDummy.ORDR_NO__c+'_'+objDummy.ORDR_DTL_NO__c);
            }

            if(objDummy.CRG_MA_ID__c <> null) {
                setUserEmployeeNumber.add(objDummy.CRG_MA_ID__c);
            }

            if(objDummy.SLST_ID__c <> null) {
                setCustomerId.add(objDummy.SLST_ID__c);
            }

            if(objDummy.MNGPLC_ID__c <> null) {
                setCustomerId.add(objDummy.MNGPLC_ID__c);
            }
            
            if(objDummy.SCHL_CD__c <> null){
                setSchoolCustId.add(objDummy.SCHL_CD__c);
            }

            if(objDummy.GD_CLS_ID__c <> null) {
                setGdClsId.add(objDummy.GD_CLS_ID__c);
            }

            if(objDummy.SPLY_CTR_ID__c <> null && objDummy.GD_NO__c <> null) {
                setProductCode.add(objDummy.SPLY_CTR_ID__c+'_'+objDummy.GD_NO__c);
            }
        }

        Map<String, SalesLedgerInformation__c> mapNewSalesL = new Map<String, SalesLedgerInformation__c>();

        for(SalesLedgerInformation__c obj : [
            SELECT  Id, ExtId__c, SALES_YMD__c, ORDR_NO__c, ORDR_DTL_NO__c, sales_seq__c, sales_seq_changeTxt__c
            FROM    SalesLedgerInformation__c
            WHERE   ExtId__c In:setPK
        ]) {
            mapNewSalesL.put(obj.ExtId__c, obj);
        }

        Map<String, String> mapUserId = new Map<String, String>();

        if(!setUserEmployeeNumber.isEmpty()) {

            for(User objUser : [
                SELECT Id, EmployeeNumber FROM User
                WHERE EmployeeNumber In:setUserEmployeeNumber
            ]) {
                mapUserId.put(objUser.EmployeeNumber, objUser.Id);
            }
        }

        Map<String, String> mapAccountId = new Map<String, String>();

        if(!setCustomerId.isEmpty()) {
            for(Account obj : [
                SELECT  Id, CustomerID__c
                FROM    Account
                WHERE   CustomerID__c In:setCustomerId       
            ]) {
                mapAccountId.put(obj.CustomerID__c, obj.Id);
            }
        }

        Map<String, String> mapSchoolAccountId = new Map<String, String>();

        if(!setSchoolCustId.isEmpty()) {
            for(Account obj : [
                SELECT  Id, custID__c
                FROM    Account
                WHERE   custID__c In:setSchoolCustId       
            ]) {
                mapSchoolAccountId.put(obj.custID__c, obj.Id);
            }
        }

        Map<String, String> mapProductCategoryId = new Map<String, String>();

        if(!setGdClsId.isEmpty()) {
            for(ProductCategory__c obj : [
                SELECT  Id, gd_cls_id__c
                FROM    ProductCategory__c
                WHERE   gd_cls_id__c In:setGdClsId            
            ]) {
                mapProductCategoryId.put(obj.gd_cls_id__c, obj.Id);
            }
        }

        Map<String, String> mapProductId = new Map<String, String>();

        if(!setGdClsId.isEmpty()) {
            for(Product2 obj : [
                SELECT  Id, ProductCode
                FROM    Product2
                WHERE   ProductCode In:setProductCode            
            ]) {
                mapProductId.put(obj.ProductCode, obj.Id);
            }
        }

        List<IF_IFRESH_SFDC_INFO_ORDER_0001__c> listUpdate = new List<IF_IFRESH_SFDC_INFO_ORDER_0001__c>();

        for(IF_IFRESH_SFDC_INFO_ORDER_0001__c objDummy : scope) {
            SalesLedgerInformation__c obj = new SalesLedgerInformation__c();

            String strPK = objDummy.ORDR_NO__c+'_'+objDummy.ORDR_DTL_NO__c;

            // 기존 매출원장정보(주문번호_항목번호)의 sales_seq보다 크거나 같은 경우 update
            if((mapNewSalesL == null) || (mapNewSalesL <> null && mapNewSalesL.get(strPK) == null) || (mapNewSalesL <> null && mapNewSalesL.get(strPK) <> null && mapNewSalesL.get(strPK).sales_seq__c <= objDummy.sales_seq__c)) {
                obj.ExtId__c = strPK;

                //obj.ExtId__c = objDummy.ORDR_NO__c+'_'+objDummy.BILI_DOC_NO__c+'_'+objDummy.ORDR_DTL_NO__c;

                Date dt = Date.newInstance( 
                    Integer.valueOf(objDummy.SALES_YMD__c.substring(0,4))
                    ,Integer.valueOf(objDummy.SALES_YMD__c.substring(4,6))
                    ,Integer.valueOf(objDummy.SALES_YMD__c.substring(6,8))
                );
                obj.SALES_YMD__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                obj.SALES_LNKG_CL_CD__c = objDummy.SALES_LNKG_CL_CD__c;
                obj.SALES_LNKG_CL_NM__c = objDummy.SALES_LNKG_CL_NM__c;
                obj.ORDR_NO__c = objDummy.ORDR_NO__c;            
                obj.BILI_DOC_NO__c = objDummy.BILI_DOC_NO__c;

                // 판매처
                if(objDummy.SLST_ID__c <> null && mapAccountId <> null && mapAccountId.get(objDummy.SLST_ID__c) <> null) {
                    obj.SLST__c = mapAccountId.get(objDummy.SLST_ID__c);
                }
                
                obj.SLST_ID__c = objDummy.SLST_ID__c;
                obj.CUST_NM__c = objDummy.CUST_NM__c;

                // 관리처(추후 관리처 정보 I/F 할경우 주석해제, MNGPLC__c 필드생성)
                /*
                if(objDummy.MNGPLC_ID__c <> null && mapAccountId.get(objDummy.MNGPLC_ID__c) <> null) {
                    obj.MNGPLC__c = mapAccountId.get(objDummy.MNGPLC_ID__c);
                }
                */

                obj.MNGPLC_ID__c = objDummy.MNGPLC_ID__c;
                obj.MNGPLC_NM__c = objDummy.MNGPLC_NM__c;
                obj.SLBZ_ORG_ID__c  = objDummy.SLBZ_ORG_ID__c; 
                obj.DIV_ID__c = objDummy.DIV_ID__c;
                // obj.DIV_NM__c = objDummy.DIV_NM__c;
                obj.BRC_ID__c = objDummy.BRC_ID__c;
                // obj.BRC_NM__c = objDummy.BRC_NM__c;
                if(objDummy.CRG_MA_ID__c <> null && mapUserId <> null && mapUserId.get(objDummy.CRG_MA_ID__c) <> null) {
                    obj.OwnerId = mapUserId.get(objDummy.CRG_MA_ID__c);
                    obj.CRG_MA__c = mapUserId.get(objDummy.CRG_MA_ID__c);
                }

                obj.CRG_MA_ID__c = objDummy.CRG_MA_ID__c;
                obj.CRG_MA_NM__c = objDummy.CRG_MA_NM__c;
                obj.CRG_SMA_ID__c = objDummy.CRG_SMA_ID__c;
                obj.CRG_SMA_NM__c = objDummy.CRG_SMA_NM__c;

                obj.SCHL_CD__c = objDummy.SCHL_CD__c;
                obj.SCHL_NM__c = objDummy.SCHL_NM__c;
                
                if(objDummy.SCHL_CD__c <> null && mapSchoolAccountId <> null && mapSchoolAccountId.get(objDummy.SCHL_CD__c) <> null) {
                    obj.SCHL__c = mapSchoolAccountId.get(objDummy.SCHL_CD__c);
                }
                
                obj.SPLY_CTR_ID__c = objDummy.SPLY_CTR_ID__c;
                // obj.SPLY_CTR_NM__c = objDummy.SPLY_CTR_NM__c;
                obj.SHIPLC_ID__c = objDummy.SHIPLC_ID__c;
                // obj.SHIPLC_NM__c = objDummy.SHIPLC_NM__c;
                
                obj.LAR_GD_CLS_ID__c = objDummy.LAR_GD_CLS_ID__c;
                obj.MID_GD_CLS_ID__c = objDummy.MID_GD_CLS_ID__c;
                obj.SML_GD_CLS_ID__c = objDummy.SML_GD_CLS_ID__c;
                obj.ISLIQ__c = objDummy.ISLIQ__c == '1' ? true : false;

                if(objDummy.SPLY_CTR_ID__c <> null && objDummy.GD_NO__c <> null) {
                    String strProductKey = objDummy.SPLY_CTR_ID__c+'_'+objDummy.GD_NO__c;

                    if(mapProductId <> null && mapProductId.get(strProductKey) <> null) {
                        obj.GD__c = mapProductId.get(strProductKey);
                    }
                }

                obj.GD_NO__c = objDummy.GD_NO__c;
                obj.GD_NM__c = objDummy.GD_NM__c;

                if(objDummy.GD_CLS_ID__c <> null && mapProductCategoryId <> null && mapProductCategoryId.get(objDummy.GD_CLS_ID__c) <> null) {
                    obj.ProductCategory__c = mapProductCategoryId.get(objDummy.GD_CLS_ID__c);
                }
                
                obj.GD_CLS_ID__c = objDummy.GD_CLS_ID__c;
                obj.PB_GD_CL__c = objDummy.PB_GD_CL_CD__c;
                obj.pb_gd_cl_cd_nm__c = objDummy.PB_GD_CL_CD_NM__c;
                obj.BARCD_NO__c = objDummy.BARCD_NO__c;
                obj.BCNR_ID__c = objDummy.BCNR_ID__c;
                obj.BCNR_NM__c = objDummy.BCNR_NM__c;
                obj.DSTR_HIS_NO_RPT_OBJ_YN_NM__c = objDummy.DSTR_HIS_NO_RPT_OBJ_YN_NM__c;
                obj.DSTR_HIS_MNG_YN_NM__c = objDummy.DSTR_HIS_MNG_YN_NM__c;
                obj.DSTR_HIS_NO__c = objDummy.DSTR_HIS_NO__c;
                obj.BL_NO__c = objDummy.BL_NO__c;
                obj.TAXT_CL_CD_NM__c = objDummy.TAXT_CL_CD_NM__c;
                obj.RLSTK_UNIT_RLSTK_QTY__c = objDummy.RLSTK_UNIT_RLSTK_QTY__c <> null ? Decimal.valueOf(objDummy.RLSTK_UNIT_RLSTK_QTY__c) : null;
                obj.RLSTK_UNIT_RLSTK_QTY_KG__c = objDummy.RLSTK_UNIT_RLSTK_QTY_KG__c <> null ? Decimal.valueOf(objDummy.RLSTK_UNIT_RLSTK_QTY_KG__c) : null;
                obj.BOX_CTCNT_QTY__c = objDummy.BOX_CTCNT_QTY__c <> null ? Integer.valueOf(objDummy.BOX_CTCNT_QTY__c) : null;
                obj.RLSTK_UNIT__c = objDummy.RLSTK_UNIT_CD_NM__c;
                obj.REAL_BUY_UNPRC__c = objDummy.REAL_BUY_UNPRC__c <> null ? Decimal.valueOf(objDummy.REAL_BUY_UNPRC__c) : null;
                obj.OPT_UNPRC__c = objDummy.OPT_UNPRC__c <> null ? Decimal.valueOf(objDummy.OPT_UNPRC__c) : null;
                obj.ORDR_REAL_BUY_UNPRC__c = objDummy.ORDR_REAL_BUY_UNPRC__c <> null ? Decimal.valueOf(objDummy.ORDR_REAL_BUY_UNPRC__c) : null;
                obj.ORDR_OPT_UNPRC__c = objDummy.ORDR_OPT_UNPRC__c <> null ? Decimal.valueOf(objDummy.ORDR_OPT_UNPRC__c) : null;
                obj.SALE_UNPRC__c = objDummy.SALE_UNPRC__c <> null ? Decimal.valueOf(objDummy.SALE_UNPRC__c) : null;
                obj.SALES_AT__c = objDummy.SALES_AT__c <> null ? Decimal.valueOf(objDummy.SALES_AT__c) : null;
                obj.SALES_TAT__c = objDummy.SALES_TAT__c <> null ? Decimal.valueOf(objDummy.SALES_TAT__c) : null;
                obj.SALES_SUM_AT__c = objDummy.SALES_SUM_AT__c <> null ? Decimal.valueOf(objDummy.SALES_SUM_AT__c) : null;
                obj.SALES_P_RT__c = objDummy.SALES_P_RT__c <> null ? Decimal.valueOf(objDummy.SALES_P_RT__c) : null;
                obj.SAP_ERR_MSG__c = objDummy.SAP_ERR_MSG__c;
                obj.BAS_UNIT__c = objDummy.BAS_UNIT_CD__c;
                obj.BAS_TKSTK_QTY__c = objDummy.BAS_TKSTK_QTY__c <> null ? Decimal.valueOf(objDummy.BAS_TKSTK_QTY__c) : null;

                obj.REG_DT__c = objDummy.REG_DT__c <> null ? Datetime.valueOf(objDummy.REG_DT__c) : null;
                obj.UPD_DT__c = objDummy.UPD_DT__c <> null ? Datetime.valueOf(objDummy.UPD_DT__c) : null;
                obj.ORDR_DTL_NO__c = objDummy.ORDR_DTL_NO__c;
                obj.sales_seq__c = objDummy.sales_seq__c;
                obj.sales_vat_seq__c = objDummy.sales_vat_seq__c;

                if(mapNewSalesL <> null && mapNewSalesL.get(strPK) <> null && mapNewSalesL.get(strPK).sales_seq__c < objDummy.sales_seq__c)  {
                    obj.sales_seq_changeTxt__c = mapNewSalesL.get(strPK).sales_seq_changeTxt__c+'->'+objDummy.sales_seq__c;
                }else {
                    obj.sales_seq_changeTxt__c = objDummy.sales_seq__c;
                }

                mapNewSalesL.put(strPK, obj);
            }

            IF_IFRESH_SFDC_INFO_ORDER_0001__c objTarget = new IF_IFRESH_SFDC_INFO_ORDER_0001__c();
            objTarget.Id = objDummy.Id;
            objTarget.IsUpdate__c = true;
            listUpdate.add(objTarget);
        }

        List<SalesLedgerInformation__c > upsertLegerList = new List<SalesLedgerInformation__c >();

        for(SalesLedgerInformation__c obj : mapNewSalesL.values()) {
            upsertLegerList.add(obj);
        }

        //Savepoint sp = Database.setSavepoint();

        // try {
            if(upsertLegerList <> null && upsertLegerList.size() > 0) {
                upsert upsertLegerList ExtId__c;
            }

            if(listUpdate <> null && listUpdate.size() > 0) {
                update listUpdate;
            }
        // }catch(Exception e) {
        //     Database.rollback(sp);

        //     System.debug('=============================> Error Line '+e.getLineNumber());
        //     System.debug('=============================> Error '+e.getMessage());
        // }
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        /*
        IF_DUMMY_DEL_ba order_ba = new IF_DUMMY_DEL_ba('IF_IFRESH_SFDC_INFO_ORDER_0001__c', this.transactionId);
        Database.executeBatch(order_ba, 1000);
        */
    }
}