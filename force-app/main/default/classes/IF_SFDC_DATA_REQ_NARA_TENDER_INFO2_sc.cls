/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 01-17-2023
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
global class IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_sc implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<NaramarketKeyword__mdt> keywordList = [
            SELECT Keyword__c
            FROM NaramarketKeyword__mdt
            WHERE Keyword_Lv__c = 1
        ];
        Set<Id> nextBatchLeadSet = new Set<Id>();
        // 민간조회
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba b6 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba(keywordList, 'getPrvtBidPblancListInfoServcPPSSrch', 0, nextBatchLeadSet);
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba b7 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba(keywordList, 'getPrvtBidPblancListInfoThngPPSSrch', 0, nextBatchLeadSet);
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba b8 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba(keywordList, 'getPrvtBidPblancListInfoEtcPPSSrch', 0, nextBatchLeadSet);
    
        Database.executeBatch(b6, 1);
        Database.executeBatch(b7, 1);
        Database.executeBatch(b8, 1);
    }

}