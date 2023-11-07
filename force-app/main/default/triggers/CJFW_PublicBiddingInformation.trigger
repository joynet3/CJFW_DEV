/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
trigger CJFW_PublicBiddingInformation on CJFW_PublicBiddingInformation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CJFW_PublicBidInformationTriggerHandler().run();
}