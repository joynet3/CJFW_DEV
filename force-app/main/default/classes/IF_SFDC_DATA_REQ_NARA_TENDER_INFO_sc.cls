/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 02-05-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<NaramarketKeyword__mdt> keywordList = [
            SELECT Keyword__c
            FROM NaramarketKeyword__mdt
            WHERE Keyword_Lv__c = 1
        ];
        Set<Id> nextBatchLeadSet = new Set<Id>();
        // 기타조회
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba b5 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(keywordList, 'getBidPblancListInfoEtcPPSSrch01', 0, nextBatchLeadSet, null, null);
        
        Database.executeBatch(b5, 1);
    }

    global class Input{
        public Res response;
    }

    global class Res{
        public Body body;
    }

    global class Body{
        public String totalCount;
        public String pageNo;
        public String numOfRows;
        public List<Items> items;
    }

    global class Items{
        public String ntceKindNm;
        public String bidNtceNo;
        public String bidNtceNm;
        public String ntceInsttNm;
        public String ntceInsttOfclNm;
        public String ntceInsttOfclTelNo;
        public String ntceInsttOfclEmailAdrs;
        public String bidMethdNm;
        public String cntrctCnclsMthdNm;
        public String rbidPermsnYn;
        public String bidBeginDt;
        public String opengDt;
        public String bidClseDt;
        public String opengPlce;
        public String bidQlfctRgstDt;
        public String prearngPrceDcsnMthdNm;
        public String asignBdgtAmt;
        public String cmmnSpldmdCorpRgnLmtYn;
        public String indstrytyLmtYn;
        public String bidNtceDtlUrl;
        public String ntceInsttCd;
        public String dminsttNm;
        public String dminsttCd;
        public String bidNtceOrd;
        public string reNtceYn;
        public string rgstTyNm;
        public string intrbidYn;
        public string bidNtceDt;
        public string refNo;
        public string exctvNm;
        public string cmmnSpldmdAgrmntRcptdocMethd;
        public string cmmnSpldmdAgrmntClseDt;
        public string prdctClsfcLmtYn;
        public string mnfctYn;
        public string totPrdprcNum;
        public string drwtPrdprcNum;
        public string presmptPrce;
        public string bidPrtcptFeePaymntYn;
        public string bidPrtcptFee;
        public string bidGrntymnyPaymntYn;
        public string crdtrNm;
        public string dtilPrdctClsfcNo;
        public string dtilPrdctClsfcNoNm;
        public string prdctSpecNm;
        public string prdctQty;
        public string prdctUnit;
        public string prdctUprc;
        public string dlvrTmlmtDt;
        public string dlvrDaynum;
        public string dlvryCndtnNm;
        public string untyNtceNo;
        public string cmmnSpldmdMethdCd;
        public string cmmnSpldmdMethdNm;
        public string brffcBidprcPermsnYn;
        public string dsgntCmptYn;
        public string rsrvtnPrceReMkngMthdNm;
        public string arsltApplDocRcptMthdNm;
        public string arsltApplDocRcptDt;
        public string orderPlanUntyNo;
        public string sucsfbidLwltRate;
        public string rgstDt;
        public string bfSpecRgstNo;
        public string infoBizYn;
        public string sucsfbidMthdCd;
        public string sucsfbidMthdNm;
        public string chgDt;
        public string linkInsttNm;
        public string dminsttOfclEmailAdrs;
        public string d2bMngDcmtgOprtnDt;
        public string d2bMngDcmtgOprtnPlce;
        public string d2bMngRgnLmtYn;
        public string d2bMngPblctPlceNm;
        public string d2bMngCntrctKindNm;
        public string d2bMngCntrybndDedtBgnDate;
        public string d2bMngCntrybndDedtEndDate;
        public string d2bMngRsrvtnPrceBssOpenYn;
        public string d2bMngRrsrvtnPrceBssAplYn;
        public string d2bMngBssamt;
        public string d2bMngRgstEvalExmpYn;
        public string d2bMngCompCorpRsrchObjYn;
        public string d2bMngOrgnlbdgtDedtBgnDate;
        public string d2bMngOrgnlbdgtDedtEndDate;
        public string d2bMngAssmntUplmtRt;
        public string d2bMngAssmntLwstlmtRt;
        public string d2bMngPrdctnAbltySbmsnClseDt;
        public string d2bMngProgrsSttusNm;
        public string d2bMngExetTyNm;
        public string d2bMngExetTyCd;
        public string d2bMngPrdlstCd;
        public string d2bMngItemNo;
        public string d2bMngNgttnStleNm;
        public string d2bMngNgttnPlanDate;
        public string d2bMngDmndYear;
        public string d2bMngDcsnNo;
        public string rbidOpengDt;
        public string VAT;
        public string indutyVAT;
        public string ntceSpecDocUrl1;
        public string ntceSpecDocUrl2;
        public string ntceSpecDocUrl3;
        public string ntceSpecDocUrl4;
        public string ntceSpecDocUrl5;
        public string ntceSpecDocUrl6;
        public string ntceSpecDocUrl7;
        public string ntceSpecDocUrl8;
        public string ntceSpecDocUrl9;
        public string ntceSpecDocUrl10;
        public string ntceSpecFileNm1;
        public string ntceSpecFileNm2;
        public string ntceSpecFileNm3;
        public string ntceSpecFileNm4;
        public string ntceSpecFileNm5;
        public string ntceSpecFileNm6;
        public string ntceSpecFileNm7;
        public string ntceSpecFileNm8;
        public string ntceSpecFileNm9;
        public string ntceSpecFileNm10;
        public string bidNtceUrl;
        public string purchsObjPrdctList;
        public string stdNtceDocUrl;
        public string d2bMngStdIndstryClsfcCdList;
        public string chgNtceRsn;
        public string ntceNm;
        public string ntceDivNm;
        public string cntrctMthdNm;
        public string rbidDivNm;
        public string ofclNm;
        public string ofclTelNo;
        public string ofclEmail;
        public string bidWgrnteeRcptClseDt;
        public String bidNtceClsfc;
    }
}