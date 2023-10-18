/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-16-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_DeliveryDstMgmtController_Test {
    @isTest
    static void test1() {

        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
        Id mailRecordTypeId = Schema.SObjectType.MailRecipientMaster__c.getRecordTypeInfosByName().get('물류센터 담당자 설정').getRecordTypeId();

        Account acc = new Account(
            Name = 'testAccount',
            RecordTypeId = accRecordTypeId
        );
        insert acc;

        MailRecipientMaster__c mailmaster = new MailRecipientMaster__c(
            RecordTypeId = mailRecordTypeId,
            MailAddress__c = 'test@test.com',
            LogisticsCenter__c = '장성센터'
        );
        insert mailmaster;

        CJFW_DeliveryDestinationMgmt__c mgmt = new CJFW_DeliveryDestinationMgmt__c(
            LogisticsCenter__c = '장성센터',
            Account__c = acc.Id,
            LoadingInfo__c = '적온적재',
            OrderForm__c = '당사 웹',
            ContactName__c = '릴리',
            Phone__c = '010-123-1234',
            InitialDate__c = System.today()
        );
        insert mgmt;

        Test.startTest();
            CJFW_DeliveryDstMgmtController.changeCompleted(mgmt.Id);
            CJFW_DeliveryDstMgmtController.sendEmail(mgmt.Id);
        Test.stopTest();
    }
}