/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_BiddingInfoTriggerHandler_Test {

	@isTest
	static void testUpdate() {
        CJFW_BiddingInformation__c bi = new CJFW_BiddingInformation__c(
            Name = 'test'
        );
        insert bi;

        try {
            bi.Name = 'update';
            update bi;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
}