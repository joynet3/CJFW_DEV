/**
 * @description       : 매출원장 고객별 Summary Batch Class
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-15-2023
 * @last modified by  : admin
**/
/*
Date startDate = Date.newInstance(2022, 11, 1);
Date endDate = Date.newInstance(2022, 11, 30);
Integer batchSize = 50;

SalesAccountSummary_ba ba = new SalesAccountSummary_ba(startDate, endDate);
Database.executeBatch(ba, batchSize);
*/
global class SalesAccountSummary_ba implements Database.Batchable<SObject>, Database.Stateful {
    //global String targetAccount;
    global Date startDate;
    global Date endDate;

    global SalesAccountSummary_ba(Date startDate, Date endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : Account(기존고객) 정보 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {

        Id recordIdEx = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();


        String strQuery = '';
        strQuery += 'SELECT Id, OwnerId';        
        //strQuery += '   ShippingAccountName__c, ShippingAccountCode__c';
        strQuery += '   FROM    Account';
        strQuery += '   WHERE   RecordTypeId =:recordIdEx';

        /*
        if(this.targetAccount <> null && this.targetAccount <> '') {
            strQuery += '   AND     Id=:targetAccount';
        }
        */
        
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 매출원장정보 고객별 Summary upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<Account> scope) {

        Set<String> setAccountId = new Set<String>();

        for(Account obj : scope) {
            setAccountId.add(obj.Id);
        }

        Map<String, Account> mapAccount = new Map<String, Account>();

        mapAccount.putAll([
            SELECT  Id, Name, CustomerID__c, OwnerId
            FROM    Account
            WHERE Id IN:setAccountId
        ]);

        String strQuery = '';

        strQuery += 'SELECT  SLST__c AccountId,';
        strQuery += '   SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c,';
        strQuery += '   SALES_YMD__c SalesDate,';
        strQuery += '   SUM(SALES_AT__c) TotalNetAmount, SUM(SALES_SUM_AT__c) TotalSalesAmount, SUM(fm_SalesProfit__c) TotalSalesProfit';
        strQuery += '   FROM    SalesLedgerInformation__c';
        strQuery += '   WHERE   SLST__c IN:setAccountId';
        
        Date targetStartDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);

        if(this.startDate <> null) {
            targetStartDate = this.startDate;
        }

        Date targetEndDate = Date.today().addDays(-1);

        if(this.endDate <> null) {
            targetEndDate = this.endDate;
        }

        strQuery += '   AND   SALES_YMD__c >=:targetStartDate';
        strQuery += '   AND   SALES_YMD__c <=:targetEndDate';
        strQuery += '   GROUP BY SLST__c, SLBZ_ORG_ID__c, DIV_ID__c, BRC_ID__c, SALES_YMD__c';

        System.debug('=============> strQuery : '+strQuery);

        List<AggregateResult> listAccountSalesSummary = Database.query(strQuery);

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

        List<SalesAccountSummary__c> listSalesSummary = new List<SalesAccountSummary__c>();

        if(listAccountSalesSummary <> null && listAccountSalesSummary.size() > 0) {

            Map<String, String> mapSlbzOrgNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'SLBZ_ORG_ID__c');
            Map<String, String> mapDivNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'DIV_ID__c');
            Map<String, String> mapBrcNm = CommonUtil.getMapPickListValuetoLabel('SalesLedgerInformation__c', 'BRC_ID__c');

            for(AggregateResult obj : listAccountSalesSummary) {
                SalesAccountSummary__c objSummary = new SalesAccountSummary__c();

                objSummary.Account__c = String.valueOf(obj.get('AccountId'));

                Account objTargetAccount = mapAccount.get(objSummary.Account__c);
                objSummary.SalesDate__c = Date.valueOf(obj.get('SalesDate'));
                objSummary.OwnerId = objTargetAccount.OwnerId;

                String strDate = objSummary.SalesDate__c.year()+'-'+objSummary.SalesDate__c.month()+'-'+objSummary.SalesDate__c.day();

                objSummary.Name = objTargetAccount.Name+'('+objTargetAccount.CustomerID__c+')_'+strDate;
                // 본부 Id
                objSummary.SLBZ_ORG_ID__c = String.valueOf(obj.get('SLBZ_ORG_ID__c'));
                // 본부명
                objSummary.SLBZ_ORG_NM__c = mapSlbzOrgNm.get(objSummary.SLBZ_ORG_ID__c);
                // SU Id
                objSummary.DIV_ID__c = String.valueOf(obj.get('DIV_ID__c'));
                // SU명
                objSummary.DIV_NM__c = mapDivNm.get(objSummary.DIV_ID__c);
                // 팀Id
                objSummary.BRC_ID__c = String.valueOf(obj.get('BRC_ID__c'));
                // 팀명
                objSummary.BRC_NM__c = mapBrcNm.get(objSummary.BRC_ID__c);
                // 순매출
                objSummary.TotalNetAmount__c = (Decimal)obj.get('TotalNetAmount');
                // 총매출
                objSummary.TotalSalesAmount__c = (Decimal)obj.get('TotalSalesAmount');
                // 매출이익
                objSummary.TotalSalesProfit__c = (Decimal)obj.get('TotalSalesProfit');
                // 고객ID+'_'+청구일자+'_'+본부코드+'_'+'SU코드'+'팀코드'
                objSummary.ExtId__c = objSummary.Account__c+'_'+objSummary.SalesDate__c+'_'+objSummary.SLBZ_ORG_ID__c+'_'+objSummary.DIV_ID__c+'_'+objSummary.BRC_ID__c;

                listSalesSummary.add(objSummary);
            }

            if(listSalesSummary <> null && listSalesSummary.size() > 0) {
                upsert listSalesSummary ExtId__c;
            }
        }
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
    }
}