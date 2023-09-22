/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 09-19-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_CommRelatedListController_Test {
    @isTest
    static void test1() {
        Account acc = new Account(
            Name = 'testAccount'
        );
        insert acc;

        Test.startTest();
        
        CJFW_CommRelatedListController.hasObejctAccess('Account');
        CJFW_CommRelatedListController.getRelatedParentInfo(acc.Id);

        String recordId = acc.Id;
        String targetObjectApiName = 'Contact';
        String addFieldString = '';
        String sqlCondition = 'AccountId = \'' + acc.Id +'\'';
        Integer recordLimit = 10;
        String sortBy = '';
        String sortDirection = '';
        CJFW_CommRelatedListController.getRecords(recordId, targetObjectApiName, addFieldString, sqlCondition, recordLimit, sortBy, sortDirection);
        
        Test.stopTest();
    }
}