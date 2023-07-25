/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 12-26-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
global with sharing class IF_SFDC_LOCAL_DATA_INFO_FOOD_sc implements Schedulable{
    global IF_SFDC_LOCAL_DATA_INFO_FOOD_sc() {
    }

    global void execute(SchedulableContext sc) {}

    global class Input {
        public Result result;
    }

    global class Result {
        public Header header;
        public Body body;
    }

    global class Header {
        public Paging paging;
        // public Proces process;
    }

    global class Paging {
        public String pageIndex;
        public String totalCount;
        public String pageSize;
    }

    global class Body {
        public List<Row> rows;
    }

    global class Row {
        public List<Item> row;
    }

    global class Item {
        public String rowNum;
        public String opnSfTeamCode;
        public String mgtNo;
        public String opnSvcId;
        public String updateGbn;
        public String updateDt;
        public String opnSvcNm;
        public String bplcNm;
        public String sitePostNo;
        public String siteWhlAddr;
        public String rdnPostNo;
        public String rdnWhlAddr;
        public String siteArea;
        public String apvPermYmd;
        public String apvCancelYmd;
        public String dcbYmd;
        public String clgStdt;
        public String clgEnddt;
        public String ropnYmd;
        public String trdStateGbn;
        public String trdStateNm;
        public String dtlStateGbn;
        public String dtlStateNm;
        public String x;
        public String y;
        public String lastModTs;
        public String uptaeNm;
        public String siteTel;
        public String bdngOwnSeNm;
        public String fctyOwkEpCnt;
        public String fctyPdtJobEpCnt;
        public String fctySilJobEpCnt;
        public String rgtMbdSno;
        public String wtrSplyFacilSeNm;
        public String manEipCnt;
        public String multUsnUpsoYn;
        public String lvSeNm;
        public String isreAm;
        public String hoffEpCnt;
        public String equSiz;
        public String facilTotScp;
        public String wmEipCnt;
        public String trdpJubnSeNm;
        public String monAm;
        public String sntUptaeNm;
        public String jtUpsoMainEdf;
        public String jtUpsoAsgnNo;
        public String totEpNum;
        public String lindPrcbGbnNm;
        public String lindJobGbnNm;
        public String lindSeqNo;
        public String homepage;
    }
}