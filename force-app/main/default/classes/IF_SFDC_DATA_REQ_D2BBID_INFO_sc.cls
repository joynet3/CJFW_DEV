/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 01-17-2023
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
global with sharing class IF_SFDC_DATA_REQ_D2BBID_INFO_sc implements Schedulable{

    global void execute(SchedulableContext sc) {
        List<NaramarketKeyword__mdt> keywordList = new List<NaramarketKeyword__mdt>();
        if (Test.isRunningTest()) {
            keywordList = [
                SELECT Keyword__c
                FROM NaramarketKeyword__mdt
                WHERE Keyword__c IN ('식자재')
            ];
        }else {
            keywordList = [
                SELECT Keyword__c
                FROM NaramarketKeyword__mdt
                WHERE Keyword_Lv__c = 1
            ];
        }
        List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> inputItemsList = new List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items>();

        IF_SFDC_DATA_REQ_D2BBID_INFO_ba ba = new IF_SFDC_DATA_REQ_D2BBID_INFO_ba(keywordList, 0, inputItemsList);
        Database.executeBatch(ba, 1);
    }

    global class Input{
        public Res response;
    }

    global class otherInput{
        public otherRes response;
    }

    global class Res{
        public Body body;
    }

    global class otherRes{
        public otherBody body;
    }

    global class Body{
        public String totalCount;
        public String pageNo;
        public String numOfRows;
        public List<Items> items;
        public Item item;
    }
    global class otherBody{
        public String totalCount;
        public String pageNo;
        public String numOfRows;
        public otherItems items;
    }

    global class Items{
        public String demandYear;
        public String orntCode;
        public String dcsNo;
        public String pblancNo;
        public String pblancOdr;
        public String keyword;
        public String bsicExpt;
        public String bsisPrdprcOthbcAt;
        public Item item;
        
    }
    global class otherItems{
        public otherItem item;
        public String keyword;
    }
    
    global class otherItem{
        public String bsicExpt;
        public String demandYear;
        public String orntCode;
        public String dcsNo;
        public String pblancNo;
        public String pblancOdr;
        public String bsisPrdprcOthbcAt;
    }

    global class Item{
        public String pblancSe;
        public String pblancNo;
        public String pblancOdr;
        public String pblancDate;
        public String pblictInstt;
        public String bidNm;
        public String excutTy;
        public String dcsNo;
        public String ornt;
        public String bidStle;
        public String cntrctMth;
        public String bidMth;
        public String cntrctKnd;
        public String sucbidrDecsnMth;
        public String budgetAmount;
        public String bidPartcptRegistClosDt;
        public String biddocPresentnClosDt;
        public String opengDt;
        public String bidPlace;
        public String bsnsDcMeetngDt;
        public String bsnsDcMeetngPlace;
        public String registJdgmnPnttm;
        public String bsisPrdprcApplcAt;
        public String g2bPblancNo;
        public String g2bPblancOdr;
        public String copertnOutsrcFlflMthd;
        public String compnoEntrpsRsrchTrgetAt;
        public String orgnlbudgtDedt;
        public String ntndbtDedt;
        public String chargerNm;
        public String chargerCttpc;
        
    }
}