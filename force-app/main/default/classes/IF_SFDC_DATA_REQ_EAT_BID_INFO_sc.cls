/**
 * @description       :
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             :
 * @last modified on  : 01-17-2023
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
 **/
global with sharing class IF_SFDC_DATA_REQ_EAT_BID_INFO_sc implements Schedulable {
    global IF_SFDC_DATA_REQ_EAT_BID_INFO_sc() {
    }

    global void execute(SchedulableContext sc) {
        List<NaramarketKeyword__mdt> keywordList = new List<NaramarketKeyword__mdt>();
        if (Test.isRunningTest()) {
            keywordList = [
                SELECT Keyword__c
                FROM NaramarketKeyword__mdt
                WHERE Keyword__c IN ('식자재')
            ];
        } else {
            keywordList = [
                SELECT Keyword__c
                FROM NaramarketKeyword__mdt
                WHERE Keyword_Lv__c = 1
            ];
        }
        List<String> failPageList = new List<String>();
        IF_SFDC_DATA_REQ_EAT_BID_INFO_ba ba = new IF_SFDC_DATA_REQ_EAT_BID_INFO_ba(keywordList, 'eaTBidList', failPageList);
        Database.executeBatch(ba, 1);
    }

    global class Input {
        public Res response;
    }

    global class Res {
        public Header header;
        public Body body;
    }

    global class Header {
        public String resultCode;
        public String resultMsg;
        public String supOrganNm;
        public String supOrgancd;
        public String svcNm;
        public String supDt;
    }

    global class Body {
        public List<Item> items;
        public String numOfRows;
        public String pageNo;
        public String totalCount;
    }

    global class Item {
        public String etnBidNo;
        public String g2bYn;
        public String bidNm;
        public String etnBidSttNm;
        public String ancmDt;
        public String ancmHh;
        public String bizSortNm;
        public String etnBidYn;
        public String cntrctFormNm;
        public String limitConditionNm;
        public String purrNm;
        public String dmdOrganNm;
        public String bidOpenDt;
        public String bidOpenHh;
        public String bidOpenPlc;
        public String dmRegDt;
    }

    global class otherInput {
        public otherRes response;
    }

    global class otherRes {
        public otherHeader header;
        public otherBody body;
    }

    global class otherHeader {
        public String resultCode;
        public String resultMsg;
        public String supOrganNm;
        public String supOrgancd;
        public String svcNm;
        public String supDt;
    }

    global class otherBody {
        public otherItem items;
        public String numOfRows;
        public String pageNo;
        public String totalCount;
    }

    global class otherItem {
        public String etnBidNo;
        public String g2bYn;
        public String bidNm;
        public String etnBidSttNm;
        public String ancmDt;
        public String ancmHh;
        public String bizSortNm;
        public String etnBidYn;
        public String cntrctFormNm;
        public String limitConditionNm;
        public String purrNm;
        public String dmdOrganNm;
        public String bidOpenDt;
        public String bidOpenHh;
        public String bidOpenPlc;
        public String dmRegDt;
    }
}