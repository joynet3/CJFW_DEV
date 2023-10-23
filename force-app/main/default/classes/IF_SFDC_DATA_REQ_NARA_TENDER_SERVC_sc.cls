/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-05-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class IF_SFDC_DATA_REQ_NARA_TENDER_SERVC_sc implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<NaramarketKeyword__mdt> keywordList = [
            SELECT Keyword__c
            FROM NaramarketKeyword__mdt
            WHERE Keyword_Lv__c = 1
        ];
        Set<Id> nextBatchLeadSet = new Set<Id>();
        // 용역조회
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba b2 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(keywordList, 'getBidPblancListInfoServcPPSSrch01', 0, nextBatchLeadSet, null, null);
        
        // Database.executeBatch(b1, 1);
        Database.executeBatch(b2, 1);
    }
}