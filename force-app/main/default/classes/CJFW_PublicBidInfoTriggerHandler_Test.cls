/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_PublicBidInfoTriggerHandler_Test {

    @isTest
	static void testUpdate() {
        CJFW_PublicBiddingInformation__c pi = new CJFW_PublicBiddingInformation__c(
            Name = 'test'
        );
        insert pi;

        try {
            pi.Name = 'update';
            update pi;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
}