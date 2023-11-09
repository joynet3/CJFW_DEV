/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_NotificationMgmtAutoBatch_Test {
    @isTest
    static void test1() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

        Account acc = new Account(
            Name = 'testAccount',
            RecordTypeId = recordTypeId
        );
        insert acc;

        NotificationManagement__c n = new NotificationManagement__c(
            Account__c = acc.Id,
            Name = 'test',
            AutoUpdate__c = true,
            IsUpdated__c = false,
            StartDate__c = Date.today().addMonths(-12).addDays(30),
            Period__c = '3M'
        );
        insert n;

        Test.startTest();
            DataBase.executeBatch( new CJFW_NotificationMgmtAutoBatch(), 50);
        Test.stopTest();
    }
}