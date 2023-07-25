/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
/*
Date startDate = Date.newInstance(2022, 11, 1);
Date endDate = Date.newInstance(2022, 11, 30);
Integer batchSize = 20;

FSOpportunitySalesSummary_ba ba = new FSOpportunitySalesSummary_ba(startDate, endDate, null, true, batchSize);
Database.executeBatch(ba, batchSize);
*/

global class FSOpportunitySalesSummary_ba implements Database.Batchable<SObject>, Database.Stateful {    
    global String targetUserId;
    global Date targetDate;

    global FSOpportunitySalesSummary_ba(Date targetDate, String targetUserId) {
        this.targetDate = targetDate;
        this.targetUserId = targetUserId;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, Owner.Name, Owner.Profile.Name, Year__c, Month__c, ';
        strQuery += '   NetAmount__c, SalesAmount__c, SalesProfit__c';
        strQuery += '   FROM    BusinessPlan__c';        
        // 2022-02-03 FS개발사업부 코드값(3100)으로 조회
        // 추후 코드값이 변경된다면 수정 필수!
        strQuery += '   WHERE   fm_SU__c =\'3100\'';

        if(this.targetUserId <> null && this.targetUserId <> '') {
            strQuery += '   AND     OwnerId =:targetUserId';
        }

        if(Test.isRunningTest()) {
            strQuery += '   ORDER BY Owner.Name, Year__c, Month__c asc';
        }
        
        return  Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<BusinessPlan__c> scope) {
        // BatchSize 무조건 1개로 진행해야함
        
    }

    global void finish(Database.BatchableContext BC) {
    }
}