/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_PublicBidInformationTriggerHandler extends TriggerHandler{
    public CJFW_PublicBidInformationTriggerHandler() {
        System.debug('CJFW_PublicBidInformationTriggerHandler START');
        listNew = (List<CJFW_PublicBiddingInformation__c>) trigger.new;
        mapNew = (Map<Id, CJFW_PublicBiddingInformation__c>) trigger.newMap;
        listOld = (List<CJFW_PublicBiddingInformation__c>) trigger.old;
        mapOld = (Map<Id, CJFW_PublicBiddingInformation__c>) trigger.oldMap;
    }

    /*** TriggerHandler ***/
    private List<CJFW_PublicBiddingInformation__c> listNew { get; set; }
    private List<CJFW_PublicBiddingInformation__c> listOld { get; set; }
    private Map<Id, CJFW_PublicBiddingInformation__c> mapNew { get; set; }
    private Map<Id, CJFW_PublicBiddingInformation__c> mapOld { get; set; }

    public override void beforeUpdate() {
        changeNameChk();
    }

    private void changeNameChk(){
        for (CJFW_PublicBiddingInformation__c bi : listNew) {
            if (bi.Name != mapOld.get(bi.Id).Name) {
                bi.addError('기관명은 변경 불가합니다.');
            }
        }
    }

}