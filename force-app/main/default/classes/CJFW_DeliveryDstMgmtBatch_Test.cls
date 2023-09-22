/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 09-20-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_DeliveryDstMgmtBatch_Test {
    @isTest
    static void test1() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

        Account acc = new Account(
            Name = 'testAccount',
            RecordTypeId = recordTypeId
        );
        insert acc;

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
        
            DataBase.executeBatch( new CJFW_DeliveryDstMgmtBatch(), 50);
        
        Test.stopTest();
    }
}