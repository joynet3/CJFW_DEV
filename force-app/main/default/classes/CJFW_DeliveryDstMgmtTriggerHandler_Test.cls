/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_DeliveryDstMgmtTriggerHandler_Test {
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
            // OrderForm__c = '당사 웹',
            ContactName__c = '릴리',
            Phone__c = '010-123-1234',
            InitialDate__c = System.today(),
            Completed__c = true
        );
        
        Profile pf = [SELECT Id, Name FROM Profile WHERE Name = 'CJFW_외식남부사업부' LIMIT 1];
        User user = COMM_TestDataFactory.createUser(pf.Id);
        
        Test.startTest();
        System.runAs(user){

            insert mgmt;
            mgmt.Phone__c = '000';
            try {
                update mgmt;
            } catch (Exception e) {
                System.debug('update fail');
            }
            try {
                delete mgmt;
            }
            catch (Exception e) {
                System.debug('delete fail');
            }
        }
        Test.stopTest();

    }

    // public static User createUser(String profileId){
    //     User user = new User(
    //         ProfileId = profileId
    //         , Alias = 'Alias'
    //         , Username = 'Test@test.com' + System.currentTimeMillis()
    //         , EmployeeNumber = '998877'
    //         , Email = 'Test@test.com'
    //         , FirstName = 'Test'
    //         , LastName = 'Test'
    //         , LocaleSidKey = 'en_US'
    //         , LanguageLocaleKey = 'en_US'
    //         , EmailEncodingKey = 'UTF-8'
    //         , TimeZoneSidKey = 'America/Los_Angeles'
    //         , IsActive = true
    //         , FederationIdentifier = 'Test' + System.currentTimeMillis()
    //     );
    //     return user;
    // }
}