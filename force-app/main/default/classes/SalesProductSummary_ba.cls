/**
 * @description       : 매출원장 상품별(소분류) Summary Batch Class
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-15-2023
 * @last modified by  : admin
**/
/*
Date startDate = Date.newInstance(2022, 12, 1);
Date endDate = Date.newInstance(2022, 12, 31);
Integer batchSize = 5;

SalesProductSummary_ba ba = new SalesProductSummary_ba(startDate, endDate, true, batchSize);
Database.executeBatch(ba, batchSize);
*/

global class SalesProductSummary_ba implements Database.Batchable<String>, Database.Stateful {    
    global Date startDate;
    global Date endDate;    
    global Boolean isRecursion;
    global Integer batchSize;
    global Map<String, String> mapProductSmlGd;

    global SalesProductSummary_ba(Date startDate, Date endDate, Boolean isRecursion, Integer batchSize) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.isRecursion = isRecursion;
        this.batchSize = batchSize;

        mapProductSmlGd = CommonUtil.getMapPickListActive('SalesLedgerInformation__c', 'SML_GD_CLS_ID__c');
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 상품 소분류 정보 조회
    ************************************************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {
        List<String> listReturn = new List<String>();
        if(mapProductSmlGd <> null && mapProductSmlGd.keySet().size() > 0) {

            if(Test.isRunningTest()) {
                listReturn.add('100405');
            }else {
                for(String str : mapProductSmlGd.keySet()) {
                    listReturn.add(str);
                }
            }
        }
        
        return listReturn;
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 매출원장 상품별(소분류) Summary Upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<String> scope) {
        String strQuery = '';

        strQuery += 'SELECT  SALES_YMD__c SalesDate, SLST__r.CustomerPath__c CustomerPathCode,';
        strQuery += '   LAR_GD_CLS_ID__c, MID_GD_CLS_ID__c, SML_GD_CLS_ID__c,';
        strQuery += '   SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c,';
        //strQuery += '   GD_NO__c ProductCode,';
        strQuery += '   SUM(SALES_AT__c) TotalNetAmount, SUM(SALES_SUM_AT__c) TotalSalesAmount, SUM(fm_SalesProfit__c) TotalSalesProfit';
        strQuery += '   FROM    SalesLedgerInformation__c';
        //strQuery += '   WHERE   SML_GD_CLS_ID__c != NULL';
        strQuery += '   WHERE   SML_GD_CLS_ID__c IN:scope';

        Date salesYmd = this.startDate;

        if(salesYmd == null) {
            salesYmd = Date.today();
        }

        strQuery += '   AND   SALES_YMD__c =:salesYmd';
        //strQuery += '   GROUP BY SALES_YMD__c, SLST__r.CustomerPath__c, GD_NO__c, LAR_GD_CLS_ID__c, MID_GD_CLS_ID__c, SML_GD_CLS_ID__c';
        strQuery += '   GROUP BY SALES_YMD__c, SLST__r.CustomerPath__c, LAR_GD_CLS_ID__c, MID_GD_CLS_ID__c, SML_GD_CLS_ID__c';
        strQuery += '   ,SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c';

        System.debug('==============> strQuery : '+strQuery);

        /*
        strQuery += 'SELECT  SLST__c AccountId,';
        strQuery += '   SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c,';
        strQuery += '   SALES_YMD__c SalesDate, SUM(fm_SalesProfit__c) TotalSalesProfit, SUM(SALES_AT__c) totalSalesAmount';
        strQuery += '   FROM    SalesLedgerInformation__c';
        strQuery += '   WHERE   SLST__c IN:setAccountId';

        if(this.targetDate <> null) {
            Date startDate = Date.newInstance(this.targetDate.year(), this.targetDate.month(), 1);
            Date endDate = Date.newInstance(this.targetDate.year(), this.targetDate.month(), Date.daysInMonth(this.targetDate.year(), this.targetDate.month()));

            strQuery += '   AND   SALES_YMD__c >=:startDate';
            strQuery += '   AND   SALES_YMD__c <=:endDate';
        }

        strQuery += '   GROUP BY SLST__c, SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c, SALES_YMD__c';
        */

        System.debug('=============> strQuery : '+strQuery);

        List<AggregateResult> listProductSalesSummary = Database.query(strQuery);

        /*
        List<AggregateResult> listAccountSalesSummary = new List<AggregateResult> ([
            SELECT  SLST__c AccountId,
                    SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c,
                    SALES_YMD__c SalesDate, SUM(fm_SalesProfit__c) TotalSalesProfit, SUM(SALES_AT__c) totalSalesAmount
            FROM    SalesLedgerInformation__c
            WHERE   SLST__c IN:setAccountId
            GROUP BY SLST__c, SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c, SALES_YMD__c
        ]);
        */

        List<SalesProductSummary__c> listSalesSummary = new List<SalesProductSummary__c>();

        if(listProductSalesSummary <> null && listProductSalesSummary.size() > 0) {
            /*
            // 2023-01-05 상품코드 -> 상품소분류로 변경으로 인한 주석처리
            Set<String> setProductCode = new Set<String>();

            for(AggregateResult obj : listProductSalesSummary) {
                setProductCode.add(String.valueOf(obj.get('ProductCode')));
            }

            Map<String, String> mapProduct = new Map<String, String>();

            if(!setProductCode.isEmpty()) {
                for(Product2 objProduct : [
                    SELECT  Id, Name, gd_no__c, gd_nm__c, gd_bd__c
                    FROM    Product2 WHERE gd_no__c In:setProductCode
                    AND     lgs_ctr_id__c = '1000'
                ]) {
                    mapProduct.put(objProduct.gd_no__c, objProduct.Id);
                }
            }
            */

            Map<String, String> mapLarGdNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'LAR_GD_CLS_ID__c');
            Map<String, String> mapMidGdNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'MID_GD_CLS_ID__c');
            Map<String, String> mapSmlGdNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'SML_GD_CLS_ID__c');
            Map<String, String> mapAccountCustomerPath = CommonUtil.getMapPickListValuetoLabel('Account', 'CustomerPath__c');

            Map<String, String> mapSlbzOrgNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'SLBZ_ORG_ID__c');
            Map<String, String> mapDivNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'DIV_ID__c');
            Map<String, String> mapBrcNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'BRC_ID__c');

            for(AggregateResult obj : listProductSalesSummary) {
                SalesProductSummary__c objSummary = new SalesProductSummary__c();

                objSummary.CustomerPathCode__c = String.valueOf(obj.get('CustomerPathCode'));
                objSummary.CustomerPathNm__c = mapAccountCustomerPath.get(String.valueOf(objSummary.CustomerPathCode__c));
                
                objSummary.SLBZ_ORG_ID__c = String.valueOf(obj.get('SLBZ_ORG_ID__c'));
                objSummary.SLBZ_ORG_NM__c = mapSlbzOrgNm.get(objSummary.SLBZ_ORG_ID__c);
                objSummary.DIV_ID__c = String.valueOf(obj.get('DIV_ID__c'));
                objSummary.DIV_NM__c = mapDivNm.get(objSummary.DIV_ID__c);
                objSummary.BRC_ID__c = String.valueOf(obj.get('BRC_ID__c'));
                objSummary.BRC_NM__c = mapBrcNm.get(objSummary.BRC_ID__c);

                objSummary.SalesDate__c = Date.valueOf(obj.get('SalesDate'));

                objSummary.LAR_GD_CLS_ID__c = String.valueOf(obj.get('LAR_GD_CLS_ID__c'));
                objSummary.LAR_GD_CLS_NM__c = mapLarGdNm.get(String.valueOf(objSummary.LAR_GD_CLS_ID__c));

                objSummary.MID_GD_CLS_ID__c = String.valueOf(obj.get('MID_GD_CLS_ID__c'));
                objSummary.MID_GD_CLS_NM__c = mapMidGdNm.get(String.valueOf(objSummary.MID_GD_CLS_ID__c));
                objSummary.SML_GD_CLS_ID__c = String.valueOf(obj.get('SML_GD_CLS_ID__c'));
                objSummary.SML_GD_CLS_NM__c = mapSmlGdNm.get(String.valueOf(objSummary.SML_GD_CLS_ID__c));                

                /*
                objSummary.Product__c = mapProduct.get(String.valueOf(obj.get('ProductCode')));
                objSummary.ProductCode__c = String.valueOf(obj.get('ProductCode'));
                objSummary.ProductName__c = String.valueOf(obj.get('ProductName'));
                */
                // 순매출
                objSummary.TotalNetAmount__c = (Decimal)obj.get('TotalNetAmount');                
                // 총매출
                objSummary.TotalSalesAmount__c = (Decimal)obj.get('TotalSalesAmount');
                // 매출이익
                objSummary.TotalSalesProfit__c = (Decimal)obj.get('TotalSalesProfit');
                String strDate = String.valueOf(objSummary.SalesDate__c.year())+String.valueOf(objSummary.SalesDate__c.month()).leftPad(2, '0')+String.valueOf(objSummary.SalesDate__c.day()).leftPad(2, '0');

                String strName = objSummary.CustomerPathNm__c+'_'+objSummary.SLBZ_ORG_NM__c+'_'+objSummary.DIV_NM__c+'_'+objSummary.BRC_NM__c+'_'+objSummary.SML_GD_CLS_NM__c;

                /*
                if(strName.length() > 72) {
                    strName = strName.substring(0, 69);
                    strName += '...';
                }
                */

                objSummary.Name = objSummary.CustomerPathNm__c+'_'+objSummary.SLBZ_ORG_NM__c+'_'+objSummary.DIV_NM__c+'_'+objSummary.BRC_NM__c+'_'+objSummary.SML_GD_CLS_NM__c+'_'+strDate;                
                // ExtId : '경로(사업부)코드'+'_'+'본부코드+'_'+'SU코드'+'팀코드'+'상품 대분류코드'+'_'+'상품중분류코드'+'_'+'상품소분류코드'+'_'+'청구일자'
                objSummary.ExtId__c = objSummary.CustomerPathCode__c+'_'+objSummary.SLBZ_ORG_ID__c+'_'+objSummary.DIV_ID__c+'_'+objSummary.BRC_ID__c+'_'+objSummary.LAR_GD_CLS_ID__c+'_'+objSummary.MID_GD_CLS_ID__c+'_'+objSummary.SML_GD_CLS_ID__c+'_'+strDate;
                listSalesSummary.add(objSummary);
            }

            if(listSalesSummary <> null && listSalesSummary.size() > 0) {
                upsert listSalesSummary ExtId__c;
            }
        }
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 매출원장 상품별(소분류) Summary Batch Class 재호출
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        if(this.isRecursion && this.startDate < this.endDate) {
            SalesProductSummary_ba b = new SalesProductSummary_ba(this.startDate.addDays(1), this.endDate, this.isRecursion, this.batchSize);
            Database.executeBatch(b, this.batchSize);
        }
    }
}