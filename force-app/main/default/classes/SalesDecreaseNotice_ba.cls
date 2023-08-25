/**
 * @description       :
 * @author            : JeonKwanWoo(kwanwoo.jeon@daeunextier.com)
 * @group             :
 * @last modified on  : 01-02-2023
 * @last modified by  : JeonKwanWoo(kwanwoo.jeon@daeunextier.com)
**/
global with sharing class SalesDecreaseNotice_ba implements Database.Batchable<SObject>, Database.Stateful {
    global Date targetDate;

    global SalesDecreaseNotice_ba() {
        if (targetDate == null) {
            this.targetDate = Date.today();
        } else {
            this.targetDate = targetDate;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = 'SELECT Id FROM User WHERE IsActive = TRUE';
        strQuery += Test.isRunningTest()?' and id = \'' : '';
        strQuery += Test.isRunningTest()? UserInfo.getUserId(): '';
        strQuery += Test.isRunningTest()?'\' LIMIT 10' : '';
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext bc, List<User> scope) {
        Set<Id> setUserId = new Set<Id>();
        for (User obj: scope){
            setUserId.add(obj.Id);
        }
        Map<Id, Decimal> mapAccIdToTwoWeekAgo = new Map<Id, Decimal>();
        Id recordIdEx = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();
        Map<Id, Account> mapIdToAcc = new Map<Id, Account>([SELECT Name, OwnerId FROM Account WHERE RecordTypeId = :recordIdEx]);

        CustomNotificationType objCustomNotification = [
                SELECT Id, DeveloperName
                FROM CustomNotificationType
                WHERE DeveloperName = 'CustomNotification'
        ];

        String strQueryOneWeek = '';
        String strQueryTwoWeek = '';
        strQueryOneWeek += '    SELECT  SLST__c AccountId, SUM(SALES_AT__c) totalSalesAmount';
        strQueryOneWeek += '    FROM    SalesLedgerInformation__c';
        strQueryOneWeek += '    WHERE   SLST__r.OwnerId IN : setUserId';
        strQueryOneWeek += '    AND   SLST__c != null';
        strQueryTwoWeek += strQueryOneWeek;
        if (this.targetDate <> null) {
            Date oneWeekAgo = Date.newInstance(this.targetDate.year(), this.targetDate.month(), this.targetDate.day() - 7);
            Date twoWeekAgo = Date.newInstance(this.targetDate.year(), this.targetDate.month(), this.targetDate.day() - 14);
            Date endDate = Date.newInstance(this.targetDate.year(), this.targetDate.month(), this.targetDate.day());

            strQueryOneWeek += '   AND      SALES_YMD__c >=:oneWeekAgo';
            strQueryOneWeek += '   AND      SALES_YMD__c <:endDate';

            strQueryTwoWeek += '   AND      SALES_YMD__c >=:twoWeekAgo';
            strQueryTwoWeek += '   AND      SALES_YMD__c <:oneWeekAgo';
        }

        strQueryOneWeek += '    GROUP BY    SLST__c';
        strQueryTwoWeek += '    GROUP BY    SLST__c';

        for (AggregateResult ar : Database.query(strQueryTwoWeek)) {
            mapAccIdToTwoWeekAgo.put(String.valueOf(ar.get('AccountId')), Decimal.valueOf(String.valueOf(ar.get('totalSalesAmount'))));
        }

        for (AggregateResult ar : Database.query(strQueryOneWeek)) {
            String accId = String.valueOf(ar.get('AccountId'));
            Decimal totalSalesAmount = Decimal.valueOf(String.valueOf(ar.get('totalSalesAmount')));
            if (mapAccIdToTwoWeekAgo.get(accId) != null && totalSalesAmount < mapAccIdToTwoWeekAgo.get(accId) * 0.7) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('고객 매출 감소 알림');
                notification.setBody(mapIdToAcc.get(accId).Name + ' 고객의 매출이 30% 감소되었습니다.');
                notification.setNotificationTypeId(objCustomNotification.Id);
                notification.setTargetId(accId);
                notification.send(new Set<String>{mapIdToAcc.get(accId).OwnerId});
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
    }


}