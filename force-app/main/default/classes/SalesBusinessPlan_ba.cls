/**
 * @description       : 경영계획 매출정보 업데이트 Batch Class
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
/*
SalesBusinessPlan_ba b = new SalesBusinessPlan_ba(null, 2023, 2);
Database.executeBatch(b, 1000);
*/
global class SalesBusinessPlan_ba implements Database.Batchable<SObject>, Database.Stateful {        
    global String targetUserId;
    global Integer targetYear;
    global Integer targetMonth;

    global SalesBusinessPlan_ba(String targetUserId, Integer targetYear, Integer targetMonth) {
        if(targetUserId == null) {
            targetUserId = 'ALL';
        }
        
        if(Test.isRunningTest()) {
            targetUserId = UserInfo.getUserId();
        }

        this.targetUserId = targetUserId;

        if(targetYear == null) {
            targetYear = Date.today().year();
        }

        this.targetYear = targetYear;

        if(targetMonth == null) {
            targetMonth = Date.today().month();
        }

        this.targetMonth = targetMonth;
    }

    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 사용자정보 정보 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, Name, UserName, EmployeeNumber,';                
        strQuery += '   HeadOffice__c, SU__c, Team__c';
        strQuery += '   FROM    User';        
        strQuery += '   WHERE   EmployeeNumber != NULL';
        strQuery += '   AND     IsExtraServiceInstructor__c = false';


        if(!Test.isRunningTest()) {
            strQuery += '   AND     Profile.Name LIKE \'%CJFW_%\'';
        }

        if(this.targetUserId <> null && this.targetUserId <> '' && this.targetUserId != 'ALL') {
            strQuery += '   AND     Id=:targetUserId';
        }
        
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 경영계획 매출정보 업데이트
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<User> scope) {

        Set<String> setUserId = new Set<String>();
        Set<String> setUserEmployeeNumber = new Set<String>();

        Map<String, User> mapUser = new Map<String, User>();

        for(User obj : scope) {
            setUserId.add(obj.Id);
            setUserEmployeeNumber.add(obj.EmployeeNumber);
            mapUser.put(obj.Id, obj);
        }

        System.debug('===================> setUserEmployeeNumber : '+JSON.serialize(setUserEmployeeNumber));

        String strQuery = '';

        Date dtStart = Date.newInstance(this.targetYear, this.targetMonth, 1);
        Date dtEnd = Date.newInstance(this.targetYear, this.targetMonth, Date.today().day());

        strQuery += 'SELECT  OwnerId,';        
        strQuery += '   SUM(TotalNetAmount__c) TotalNetAmount, SUM(TotalSalesAmount__c) TotalSalesAmount, SUM(TotalSalesProfit__c) TotalSalesProfit';
        strQuery += '   FROM    SalesMonthOfMASummary__c';
        strQuery += '   WHERE   OwnerId IN:setUserId';
        strQuery += '   AND   SalesDate__c >=: dtStart';
        strQuery += '   AND   SalesDate__c <: dtEnd';

        strQuery += '   GROUP BY OwnerId';

        System.debug('=============> strQuery : '+strQuery);

        List<AggregateResult> listSalesMonthSummmary = Database.query(strQuery);

        List<BusinessPlan__c> listBP = new List<BusinessPlan__c>();

        if(listSalesMonthSummmary <> null && listSalesMonthSummmary.size() > 0) {            
            Map<String, String> mapSlbzOrgNm = CommonUtil.getMapPickListValuetoLabel('User', 'HeadOffice__c');
            Map<String, String> mapDivNm = CommonUtil.getMapPickListValuetoLabel('User', 'SU__c');
            Map<String, String> mapBrcNm = CommonUtil.getMapPickListValuetoLabel('User', 'Team__c');

            for(AggregateResult obj : listSalesMonthSummmary) {
                BusinessPlan__c objBP = new BusinessPlan__c();

                String strTargetOwnerId = String.valueOf(obj.get('OwnerId'));
                String strUserName = '';
                String strUserFullName = 'CJFWAdmin';
                String strTargetEmployeeNumber = '';

                if(mapUser <> null && mapUser.get(strTargetOwnerId) <> null) {
                    User objTargetUser = mapUser.get(strTargetOwnerId);

                    strUserName = objTargetUser.UserName;
                    strUserFullName = objTargetUser.Name;
                    strTargetEmployeeNumber = objTargetUser.EmployeeNumber;
                    objBP.OwnerId = objTargetUser.Id;

                    objBP.SLBZ_ORG_ID__c = String.valueOf(objTargetUser.HeadOffice__c);
                    objBP.SLBZ_ORG_NM__c = mapSlbzOrgNm.get(objBP.SLBZ_ORG_ID__c);
                    objBP.DIV_ID__c = String.valueOf(objTargetUser.SU__c);
                    objBP.DIV_NM__c = mapDivNm.get(objBP.DIV_ID__c);
                    objBP.BRC_ID__c = String.valueOf(objTargetUser.Team__c);
                    objBP.BRC_NM__c = mapBrcNm.get(objBP.BRC_ID__c);
                }

                objBP.Year__c = this.targetYear;
                objBP.Month__c = String.valueOf(this.targetMonth);
                objBP.YearMonth__c = objBP.Year__c+(objBP.Month__c.length() == 1 ? '0'+objBP.Month__c : objBP.Month__c);
                
                // 순매출
                objBP.NetAmount__c = (Decimal)obj.get('TotalNetAmount');

                /*
                if(objBP.NetAmount__c == null) {
                    objBP.NetAmount__c = 0;
                }
                */

                // 총매출
                objBP.SalesAmount__c = (Decimal)obj.get('TotalSalesAmount');

                /*
                if(objBP.SalesAmount__c == null) {
                    objBP.SalesAmount__c = 0;
                }
                */
                
                // 매출이익
                objBP.SalesProfit__c = (Decimal)obj.get('TotalSalesProfit');

                /*
                if(objBP.SalesProfit__c == null) {
                    objBP.SalesProfit__c = 0;
                }
                */

                objBP.Name = strUserFullName+'('+strTargetEmployeeNumber+')_'+objBP.YearMonth__c;
                objBP.ExtId__c = strTargetEmployeeNumber+'_'+objBP.Year__c+'_'+objBP.Month__c;

                listBP.add(objBP);
            }

            if(listBP <> null && listBP.size() > 0) {
                upsert listBP ExtId__c;
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