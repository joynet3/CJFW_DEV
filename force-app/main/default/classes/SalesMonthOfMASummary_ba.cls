/**
 * @description       : 매출원장정보 MA별 Summary Batch Class
 * @author            : youngmin.kim@daeunextier.com
 * @group             : 
 * @last modified on  : 03-15-2023
 * @last modified by  : admin
**/
/*
Date startDate = Date.newInstance(2022, 2, 1);
Date endDate = Date.newInstance(2022, 2, 28);
Integer batchSize = 20;

SalesMonthOfMASummary_ba ba = new SalesMonthOfMASummary_ba(startDate, endDate, null, true, batchSize);
Database.executeBatch(ba, batchSize);
*/

global class SalesMonthOfMASummary_ba implements Database.Batchable<SObject>, Database.Stateful {    
    global Date startDate;
    global Date endDate;
    global Integer batchSize;
    global String targetUserId;
    global Boolean isRecursion;
    //global Boolean isNextBatch;

    global SalesMonthOfMASummary_ba(Date startDate, Date endDate, String targetUserId, Boolean isRecursion, Integer batchSize) {
        this.startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);

        if(startDate <> null) {
            this.startDate = startDate;
        }
        
        this.endDate = Date.today().addDays(-1);

        if(endDate <> null) {
            this.endDate = endDate;
        }
        
        this.targetUserId = targetUserId;
        this.isRecursion = isRecursion;
        this.batchSize = batchSize;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 사용자정보 정보 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, Name, EmployeeNumber';                
        strQuery += '   FROM    User';        
        strQuery += '   WHERE   EmployeeNumber != NULL';

        if(!Test.isRunningTest()) {
            strQuery += '   AND     Profile.Name LIKE \'%CJFW_%\'';
        }

        System.debug('===================> targetUserId : '+targetUserId);

        if(this.targetUserId <> null && this.targetUserId <> '') {
            strQuery += '   AND     Id=\''+this.targetUserId+'\'';
        }
        
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 매출원장정보 MA별 Summary upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<User> scope) {

        Set<String> setUserId = new Set<String>();
        Set<String> setUserEmployeeNumber = new Set<String>();

        Map<String, User> mapUser = new Map<String, User>();

        for(User obj : scope) {
            setUserId.add(obj.Id);
            setUserEmployeeNumber.add(obj.EmployeeNumber);
            mapUser.put(obj.EmployeeNumber, obj);
        }

        System.debug('===================> setUserEmployeeNumber : '+JSON.serialize(setUserEmployeeNumber));

        String strQuery = '';

        Date targetStartDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);

        if(this.startDate <> null) {
            targetStartDate = this.startDate;
        }

        strQuery += 'SELECT  CRG_MA_ID__c,';
        strQuery += '   SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c,';
        strQuery += '   SUM(SALES_AT__c) TotalNetAmount, SUM(SALES_SUM_AT__c) TotalSalesAmount, SUM(fm_SalesProfit__c) TotalSalesProfit';
        strQuery += '   FROM    SalesLedgerInformation__c';
        strQuery += '   WHERE   CRG_MA_ID__c IN:setUserEmployeeNumber';
        strQuery += '   AND   SALES_YMD__c =: targetStartDate';

        strQuery += '   GROUP BY SALES_YMD__c, CRG_MA_ID__c, SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c';

        System.debug('=============> strQuery : '+strQuery);

        List<AggregateResult> listAccountSalesSummary = Database.query(strQuery);

        List<SalesMonthOfMASummary__c> listSalesSummary = new List<SalesMonthOfMASummary__c>();

        if(listAccountSalesSummary <> null && listAccountSalesSummary.size() > 0) {

            Map<String, String> mapSlbzOrgNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'SLBZ_ORG_ID__c');
            Map<String, String> mapDivNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'DIV_ID__c');
            Map<String, String> mapBrcNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'BRC_ID__c');

            for(AggregateResult obj : listAccountSalesSummary) {
                SalesMonthOfMASummary__c objSummary = new SalesMonthOfMASummary__c();

                String strTargetEmployeeNumber = String.valueOf(obj.get('CRG_MA_ID__c'));

                String strUserName = 'CJFWAdmin';

                if(mapUser <> null && mapUser.get(strTargetEmployeeNumber) <> null) {
                    User objTargetUser = mapUser.get(strTargetEmployeeNumber);

                    strUserName = objTargetUser.Name;

                    objSummary.OwnerId = objTargetUser.Id;
                }               

                String strDate = this.startDate.year()+'-'+this.startDate.month();

                objSummary.SalesDate__c = this.startDate;

                objSummary.SLBZ_ORG_ID__c = String.valueOf(obj.get('SLBZ_ORG_ID__c'));
                objSummary.SLBZ_ORG_NM__c = mapSlbzOrgNm.get(objSummary.SLBZ_ORG_ID__c);
                objSummary.DIV_ID__c = String.valueOf(obj.get('DIV_ID__c'));
                objSummary.DIV_NM__c = mapDivNm.get(objSummary.DIV_ID__c);
                objSummary.BRC_ID__c = String.valueOf(obj.get('BRC_ID__c'));
                objSummary.BRC_NM__c = mapBrcNm.get(objSummary.BRC_ID__c);
                // 순매출
                objSummary.TotalNetAmount__c = (Decimal)obj.get('TotalNetAmount');
                // 총매출
                objSummary.TotalSalesAmount__c = (Decimal)obj.get('TotalSalesAmount');
                // 매출이익
                objSummary.TotalSalesProfit__c = (Decimal)obj.get('TotalSalesProfit');

                //objSummary.Name = strUserName+'('+strTargetEmployeeNumber+')_'+strDate;
                objSummary.Name = objSummary.SLBZ_ORG_NM__c+'_'+objSummary.DIV_NM__c+'_'+objSummary.BRC_NM__c+'_'+strUserName+'('+strTargetEmployeeNumber+')'+'_'+strDate;
                // '본부코드'+'_'+'SU코드'+'_'+'팀코드'+'_'+'사원번호'+'_'+'청구일자'
                objSummary.ExtId__c = objSummary.SLBZ_ORG_ID__c+'_'+objSummary.DIV_ID__c+'_'+objSummary.BRC_ID__c+'_'+strTargetEmployeeNumber+'_'+objSummary.SalesDate__c;

                listSalesSummary.add(objSummary);
            }

            if(listSalesSummary <> null && listSalesSummary.size() > 0) {
                upsert listSalesSummary ExtId__c;
            }
        }
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 매출원장정보 MA별 Summary Batch 재호출 및 경영계획 매출원장정보 Batch Class 호출
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        if(this.isRecursion && this.startDate < this.endDate) {
            SalesMonthOfMASummary_ba b = new SalesMonthOfMASummary_ba(this.startDate.addDays(1), this.endDate, this.targetUserId, this.isRecursion, this.batchSize);
            Database.executeBatch(b, this.batchSize);
        }else {            
            SalesBusinessPlan_ba b = new SalesBusinessPlan_ba(null, this.startDate.year(), this.startDate.month());
            Database.executeBatch(b, 200);
        }
        /*
        else if(this.isNextBatch) {
            SalesBusinessPlan_ba b = new SalesBusinessPlan_ba(null, null, null);
            Database.executeBatch(b, 200);
        }
        */
    }
}