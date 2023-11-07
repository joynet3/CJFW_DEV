/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
trigger CJFW_BiddingInformation on CJFW_BiddingInformation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    new CJFW_BiddingInformationTriggerHandler().run();
}