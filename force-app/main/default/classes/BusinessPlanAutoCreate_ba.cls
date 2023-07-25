/**
 * @description       : 사용자별 경영계획 생성 Batch Class
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
/*
BusinessPlanAutoCreate_ba b = new BusinessPlanAutoCreate_ba(2022, null);
Database.executeBatch(b, 1000);
*/
global class BusinessPlanAutoCreate_ba implements Database.Batchable<SObject>, Database.Stateful {
    global Integer targetYear;
    global String strUserId;
    global Set<String> setMonth;

    global BusinessPlanAutoCreate_ba(Integer targetYear, String strUserId) {
        if(targetYear == null) {
            targetYear = Date.today().year();
        }

        this.strUserId = strUserId;

        this.targetYear = targetYear;
        this.setMonth = new Set<String>{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'};
    }

    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 사용자 정보 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, Name, Username, EmployeeNumber,';                
        strQuery += '   HeadOffice__c, SU__c, Team__c';
        strQuery += '   FROM    User';
        strQuery += '   WHERE   EmployeeNumber != NULL';
        strQuery += '   AND     IsExtraServiceInstructor__c = false';
        strQuery += '   AND     IsActive = true';

        if(!Test.isRunningTest()) {
            strQuery += '   AND     Profile.Name LIKE \'%CJFW_%\'';
        }

        if(this.strUserId <> null) {
            strQuery += '   AND     Id =\''+this.strUserId+'\'';
        }
        
        if(Test.isRunningTest()) {
            strQuery += '   LIMIT 1';
        }

        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 사용자별 경영계획 자동생성
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<User> scope) {

        List<BusinessPlan__c> listBP = new List<BusinessPlan__c>();

        Map<String, String> mapSlbzOrgNm = CommonUtil.getMapPickListValuetoLabel('User', 'HeadOffice__c');
        Map<String, String> mapDivNm = CommonUtil.getMapPickListValuetoLabel('User', 'SU__c');
        Map<String, String> mapBrcNm = CommonUtil.getMapPickListValuetoLabel('User', 'Team__c');


        for(User obj : scope) {
            System.debug('=====================> HeadOffice__c : '+obj.HeadOffice__c);
            System.debug('=====================> SU__c : '+obj.SU__c);
            System.debug('=====================> Team__c : '+obj.Team__c);

            for(String strMonth : this.setMonth) {
                BusinessPlan__c objBP = new BusinessPlan__c();
                objBP.Name = obj.Name+'('+obj.EmployeeNumber+')_'+this.targetYear+(strMonth.length() == 1 ? '0'+strMonth : strMonth);

                objBP.OwnerId = obj.Id;
                objBP.Year__c = this.targetYear;
                objBP.Month__c = strMonth;
                objBP.SLBZ_ORG_ID__c = String.valueOf(obj.HeadOffice__c);
                objBP.SLBZ_ORG_NM__c = mapSlbzOrgNm.get(obj.HeadOffice__c);
                objBP.DIV_ID__c = String.valueOf(obj.SU__c);
                objBP.DIV_NM__c = mapDivNm.get(obj.SU__c);
                objBP.BRC_ID__c = String.valueOf(obj.Team__c);
                objBP.BRC_NM__c = mapBrcNm.get(obj.Team__c);

                objBP.ExtId__c = obj.EmployeeNumber+'_'+objBP.Year__c+'_'+objBP.Month__c;

                System.debug('==============> objBP.ExtId__c : '+objBP.ExtId__c);

                System.debug('==============> objBP : '+JSON.serialize(objBP));

                listBP.add(objBP);
            }
        }

        if(listBP <> null && listBP.size() > 0) {
            upsert listBP ExtId__c;
        }
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 내용 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
    }
}