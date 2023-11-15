/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class NotificationMgmtTriggerHandler_Test {
    @isTest
	static void testUpdate() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

        Account acc = new Account(
            Name = 'testAccount',
            RecordTypeId = recordTypeId
        );
        insert acc;

        NotificationManagement__c noti = new NotificationManagement__c(
            Name = 'test',
            IsUpdated__c = true,
            Account__c = acc.Id
        );
        insert noti;

        try {
            noti.Name = 'update';
            update noti;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
}