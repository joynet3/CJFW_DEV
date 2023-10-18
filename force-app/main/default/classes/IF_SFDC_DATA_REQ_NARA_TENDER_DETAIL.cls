/**
 * @description       : 공고번호 기준으로 디테일 조회하는 api
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
global without sharing class IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL {

    global IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL() {
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

    public class Output {
        public Result result;
    }

    public class Result {
        public String resultCode;
        public String resultMessage;
        //2023.09.11 - sancho 
        public CJFW_BiddingInformation__c resultLead;         //Lead -> CJFW_BiddingInformation__c

    }
    // inputstr => 공고번호
    public Output callOut(String inputStr, String sourceSiteChk, String workDivision) {

        Result objResult = new Result();
        Output objOutput = new Output();
        LogWrapper objWrapper = new LogWrapper();
        objWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String responseBody;
        String strCode = '0000';
        String strMessage = '';
        String getRquest = '';
        List<String> errList = new List<String>();
        //2023.09.11 - sancho 
        Map<String, CJFW_BiddingInformation__c> leadMap = new Map<String, CJFW_BiddingInformation__c>();    //Lead -> CJFW_BiddingInformation__c

        try {
            IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL'];
            API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '공공데이터_Key'];

            //2023.09.11 - sancho
            List<CJFW_BiddingInformation__c> insertList = new List<CJFW_BiddingInformation__c>();

            if(sourceSiteChk == '1'){
                inputStr.substring(4,11);
            }
            //업무구분
            getRquest += '/' + workDivision;
            getRquest += '?inqryDiv=2';
            getRquest += '&type=json';
            if(sourceSiteChk == '1'){
                getRquest += '&bidNtceNo=' + inputStr.substring(4, 11);
            }else {
                if (workDivision == 'getBidPblancListInfoFrgcpt') {
                    getRquest += '&bidNtceNo=' + EncodingUtil.urlEncode(inputStr.substringBeforeLast('-'), 'UTF-8');
                }else {
                    getRquest += '&bidNtceNo=' + inputStr.substringBeforeLast('-');
                }
            }
            getRquest += '&pageNo=1';
            getRquest += '&numOfRows=200';
            getRquest += '&ServiceKey=' + authKey.KeyValue__c;
            System.debug('======================getRquest:::' + getRquest);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ifMasterObj.Endpoint__c + getRquest);
            request.setHeader('content-type', ifMasterObj.ContentType__c);
            request.setMethod(ifMasterObj.Method__c);
            request.setTimeout(110000);
            HttpResponse res = http.send(request);
            System.debug('res.getBody(): ' + res.getBody());
            if(res.getStatusCode() == 200) {
                Input input = (Input) JSON.deserialize(res.getBody(), Input.Class);
                responseBody = String.valueOf(input);
                
                //2023.09.11 - sancho (Lead -> CJFW_BiddingInformation__c)
                Id naraRecordId = Schema.SObjectType.CJFW_BiddingInformation__c.getRecordTypeInfosByDeveloperName().get('NaraMarket').getRecordTypeId();  //NaraMarketLead -> NaraMarket  신규(Military,Local,NaraMarket)
                Id d2bRecordId = Schema.SObjectType.CJFW_BiddingInformation__c.getRecordTypeInfosByDeveloperName().get('Military').getRecordTypeId();     //MilitaryLead -> Military  신규(Military,Local,NaraMarket)
                System.debug('==========================itmes:::'+ input.response.body.items);

                for (Items item : input.response.body.items) {
                    //국방물자조달시스템으로 입력한 공고번호에 대한것만 저장할수 있도록 하는 if문 '-'앞 모든 문자들이 일치하는지 검사
                    //sourceSiteChk = 1 외에는 모두 나라장터타입으로 저장
                    if (sourceSiteChk == '1' ) {
                        System.debug(inputStr.substringBefore('-'));
                        System.debug(item.d2bMngDmndYear + item.bidNtceNo + item.d2bMngDcsnNo);
                        System.debug(inputStr.substringBefore('-') == item.d2bMngDmndYear + item.bidNtceNo + item.d2bMngDcsnNo);
                        if (inputStr.substringBefore('-') == item.d2bMngDmndYear + item.bidNtceNo + item.d2bMngDcsnNo) {
                            
                            //2023.09.11 - sancho (Lead -> CJFW_BiddingInformation__c)
                            //Lead leadObj = new Lead();
                            CJFW_BiddingInformation__c leadObj = new CJFW_BiddingInformation__c();

                            //lead map을 이용하여 같은 공고번호중 가장 높은 차수를 검열하는 if문
                            if (leadMap.get(item.d2bMngDmndYear+item.bidNtceNo+item.d2bMngDcsnNo) == null 
                                || (leadMap.get(item.d2bMngDmndYear+item.bidNtceNo+item.d2bMngDcsnNo) <> null) 
                                && Integer.valueOf(leadMap.get(item.bidNtceOrd)) < Integer.valueOf(item.bidNtceOrd)
                                ) {
                                leadObj.PIC__c                  = (item.ntceInsttOfclNm == null || item.ntceInsttOfclNm == '') ? item.dminsttNm : item.ntceInsttOfclNm;
                                leadObj.Company__c              = item.dminsttNm;
                                leadobj.Phone__c                = item.ntceInsttOfclTelNo;
                                leadObj.Email__c                = item.ntceInsttOfclEmailAdrs;
                                //leadObj.LeadSource = 'Military';  //2023.10.17 사용안함
                                leadObj.BidNoticeStatus__c      = item.ntceKindNm;
                                //leadObj.BidNoticeName__c        = item.bidNtceNo;     //뭐지? 왜 Name 에 공고번호를 넣었을까?  - 일단, 바뀌면서 BidNoticeNumber__c 에 몰아 넣는다.
                                //공고차수가 문자열로 불규칙한 형태로 오기때문에 Integer로 변경후 숫자가 10보다 작을경우 앞에 0을 추가하고 String으로 변경
                                if (Integer.valueOf(item.bidNtceOrd) < 10) {
                                    Integer ord = Integer.valueOf(item.bidNtceOrd);
                                    //leadObj.g2bPblancNo__c = item.d2bMngDmndYear+item.bidNtceNo+item.d2bMngDcsnNo+'-0'+ String.valueOf(ord);
                                    leadObj.BidNoticeNumber__c = item.d2bMngDmndYear+item.bidNtceNo+item.d2bMngDcsnNo+'-0'+ String.valueOf(ord);
                                }else {
                                    //leadObj.g2bPblancNo__c = item.d2bMngDmndYear+item.bidNtceNo+item.d2bMngDcsnNo+'-'+item.bidNtceOrd;
                                    leadObj.BidNoticeNumber__c = item.d2bMngDmndYear+item.bidNtceNo+item.d2bMngDcsnNo+'-'+item.bidNtceOrd;
                                }
                                System.debug('leadObj.g2bPblancNo__c: ' + leadObj.BidNoticeNumber__c);
                                leadObj.Name                    = item.bidNtceNm;   //leadObj.BidNoticeName__c        = item.bidNtceNm; //2023.10.17
                                leadObj.BidMethod__c            = item.bidMethdNm;
                                leadObj.ContractSignMethod__c   = item.cntrctCnclsMthdNm;
                                leadObj.SubNumber__c            = item.bidNtceOrd;
                                leadObj.IsReBid__c              = (item.rbidPermsnYn == 'Y') ? true : false;
                                leadObj.BidBeginDateTime__c     = (item.bidBeginDt == null || item.bidBeginDt == '')    ? null : Datetime.valueOf(item.bidBeginDt);
                                leadObj.BidOpenDateTime__c      = (item.opengDt == null || item.opengDt == '')          ? null : Datetime.valueOf(item.opengDt);
                                leadObj.BidCloseDateTime__c     = (item.bidClseDt == null || item.bidClseDt == '')      ? null : Datetime.valueOf(item.bidClseDt);
                                leadObj.BidOpenPlace__c         = item.opengPlce;
                                leadObj.BidQualifyRegistCloseDateTime__c    = (item.bidQlfctRgstDt == null || item.bidQlfctRgstDt == '') ? null : Datetime.valueOf(item.bidQlfctRgstDt);
                                leadObj.PreArrangePriceDecisionMethod__c    = item.prearngPrceDcsnMthdNm;
                                leadObj.AssignBudgetAmountCurrency__c       = (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                                leadObj.CommonSupplierRegionLimitYN__c      = (item.cmmnSpldmdCorpRgnLmtYn == 'Y') ? true : false;
                                leadObj.IsIndustryLimitYN__c                = (item.indstrytyLmtYn == 'Y') ? true : false;
                                leadObj.BidNoticeDetailUrl__c               = item.bidNtceDtlUrl;
                                leadObj.BidNoticeCompanyCode__c             = item.dminsttCd;
                                
                                // leadobj.bidNtceOrd__c           = item.bidNtceOrd;
                                // leadobj.reNtceYn__c             = item.reNtceYn;
                                // leadobj.rgstTyNm__c             = item.rgstTyNm;
                                // leadobj.intrbidYn__c            = item.intrbidYn;
                                leadobj.bidNtceDt__c            = item.bidNtceDt;
                                // leadobj.refNo__c                = item.refNo;
                                // leadobj.ntceInsttCd__c          = item.ntceInsttCd;
                                // leadobj.ntceInsttNm__c          = item.ntceInsttNm;
                                // leadobj.exctvNm__c              = item.exctvNm;
                                // leadobj.cmmnSpldmdAgrmntRcptdocMethd__c     = item.cmmnSpldmdAgrmntRcptdocMethd;
                                // leadobj.cmmnSpldmdAgrmntClseDt__c           = item.cmmnSpldmdAgrmntClseDt;
                                leadobj.prdctClsfcLmtYn__c      = item.prdctClsfcLmtYn;
                                // leadobj.mnfctYn__c              = item.mnfctYn;
                                leadobj.totPrdprcNum__c         = item.totPrdprcNum;
                                leadobj.drwtPrdprcNum__c        = item.drwtPrdprcNum;
                                leadobj.presmptPrce__c          = item.presmptPrce;             //= item.presmptPrce <> null && item.presmptPrce <> '' ? Decimal.valueOf(item.presmptPrce) : null;
                                // leadobj.bidPrtcptFeePaymntYn__c = item.bidPrtcptFeePaymntYn;
                                // leadobj.bidPrtcptFee__c         = item.bidPrtcptFee;
                                // leadobj.bidGrntymnyPaymntYn__c  = item.bidGrntymnyPaymntYn;
                                // leadobj.crdtrNm__c              = item.crdtrNm;
                                // leadobj.dtilPrdctClsfcNo__c     = item.dtilPrdctClsfcNo;
                                // leadobj.dtilPrdctClsfcNoNm__c   = item.dtilPrdctClsfcNoNm;
                                // leadobj.prdctSpecNm__c          = item.prdctSpecNm;
                                // leadobj.prdctQty__c             = item.prdctQty;
                                
                                // leadobj.prdctUnit__c            = item.prdctUnit;
                                // leadobj.prdctUprc__c            = item.prdctUprc;
                                // leadobj.dlvrTmlmtDt__c          = item.dlvrTmlmtDt;
                                // leadobj.dlvrDaynum__c           = item.dlvrDaynum;
                                // leadobj.dlvryCndtnNm__c         = item.dlvryCndtnNm;
                                // leadobj.untyNtceNo__c           = item.untyNtceNo;
                                // leadobj.cmmnSpldmdMethdCd__c    = item.cmmnSpldmdMethdCd;
                                // leadobj.cmmnSpldmdMethdNm__c    = item.cmmnSpldmdMethdNm;
                                leadobj.brffcBidprcPermsnYn__c  = item.brffcBidprcPermsnYn;     //= item.brffcBidprcPermsnYn == 'Y' ? true : false;
                                // leadobj.dsgntCmptYn__c          = item.dsgntCmptYn;
                                // leadobj.rsrvtnPrceReMkngMthdNm__c = item.rsrvtnPrceReMkngMthdNm;
                                // leadobj.arsltApplDocRcptMthdNm__c = item.arsltApplDocRcptMthdNm;
                                // leadobj.arsltApplDocRcptDt__c   = item.arsltApplDocRcptDt;
                                // leadobj.orderPlanUntyNo__c      = item.orderPlanUntyNo;
                                // leadobj.sucsfbidLwltRate__c     = item.sucsfbidLwltRate;
                                leadobj.rgstDt__c               = item.rgstDt;              //= item.rgstDt <> null ? Date.valueOf(item.rgstDt) : null;
                                // leadobj.bfSpecRgstNo__c         = item.bfSpecRgstNo;
                                // leadobj.infoBizYn__c            = item.infoBizYn;
                                // leadobj.sucsfbidMthdCd__c       = item.sucsfbidMthdCd;
                                // leadobj.sucsfbidMthdNm__c       = item.sucsfbidMthdNm;
                                
                                // leadobj.chgDt__c                = item.chgDt;
                                // leadobj.linkInsttNm__c          = item.linkInsttNm;
                                // leadobj.dminsttOfclEmailAdrs__c = item.dminsttOfclEmailAdrs;
                                // leadobj.d2bMngDcmtgOprtnDt__c   = item.d2bMngDcmtgOprtnDt;
                                // leadobj.d2bMngDcmtgOprtnPlce__c = item.d2bMngDcmtgOprtnPlce;
                                // leadobj.d2bMngRgnLmtYn__c       = item.d2bMngRgnLmtYn;
                                // leadobj.d2bMngPblctPlceNm__c    = item.d2bMngPblctPlceNm;
                                // leadobj.d2bMngCntrctKindNm__c   = item.d2bMngCntrctKindNm;
                                // leadobj.d2bMngCntrybndDedtBgnDate__c        = item.d2bMngCntrybndDedtBgnDate;
                                // leadobj.d2bMngCntrybndDedtEndDate__c        = item.d2bMngCntrybndDedtEndDate;
                                // leadobj.d2bMngRsrvtnPrceBssOpenYn__c        = item.d2bMngRsrvtnPrceBssOpenYn;
                                // leadobj.d2bMngRrsrvtnPrceBssAplYn__c        = item.d2bMngRrsrvtnPrceBssAplYn;
                                // leadobj.d2bMngBssamt__c         = item.d2bMngBssamt;
                                // leadobj.d2bMngRgstEvalExmpYn__c = item.d2bMngRgstEvalExmpYn;
                                // leadobj.d2bMngCompCorpRsrchObjYn__c         = item.d2bMngCompCorpRsrchObjYn;
                                // leadobj.d2bMngOrgnlbdgtDedtBgnDate__c       = item.d2bMngOrgnlbdgtDedtBgnDate;
                                // leadobj.d2bMngOrgnlbdgtDedtEndDate__c       = item.d2bMngOrgnlbdgtDedtEndDate;
                                // leadobj.d2bMngAssmntUplmtRt__c  = item.d2bMngAssmntUplmtRt;
                                // leadobj.d2bMngAssmntLwstlmtRt__c            = item.d2bMngAssmntLwstlmtRt;
                                // leadobj.d2bMngPrdctnAbltySbmsnClseDt__c     = item.d2bMngPrdctnAbltySbmsnClseDt;
                                // leadobj.d2bMngProgrsSttusNm__c  = item.d2bMngProgrsSttusNm;
                                // leadobj.d2bMngExetTyNm__c       = item.d2bMngExetTyNm;
                                // leadobj.d2bMngExetTyCd__c       = item.d2bMngExetTyCd;
                                // leadobj.d2bMngPrdlstCd__c       = item.d2bMngPrdlstCd;
                                // leadobj.d2bMngItemNo__c         = item.d2bMngItemNo;
                                // leadobj.d2bMngNgttnStleNm__c    = item.d2bMngNgttnStleNm;
                                // leadobj.d2bMngNgttnPlanDate__c  = item.d2bMngNgttnPlanDate;
                                // leadobj.d2bMngDmndYear__c       = item.d2bMngDmndYear;
                                // leadobj.d2bMngDcsnNo__c         = item.d2bMngDcsnNo;
                                // leadobj.rbidOpengDt__c          = item.rbidOpengDt;
                                leadobj.VAT__c                  = item.VAT;             //= item.VAT <> null ? Decimal.valueOf(item.VAT) : null;
                                // leadobj.indutyVAT__c            = item.indutyVAT;
                                // leadobj.ntceSpecDocUrl1__c      = item.ntceSpecDocUrl1;
                                // leadobj.ntceSpecDocUrl2__c      = item.ntceSpecDocUrl2;
                                // leadobj.ntceSpecDocUrl3__c      = item.ntceSpecDocUrl3;
                                // leadobj.ntceSpecDocUrl4__c      = item.ntceSpecDocUrl4;
                                // leadobj.ntceSpecDocUrl5__c      = item.ntceSpecDocUrl5;
                                // leadobj.ntceSpecDocUrl6__c      = item.ntceSpecDocUrl6;
                                // leadobj.ntceSpecDocUrl7__c      = item.ntceSpecDocUrl7;
                                // leadobj.ntceSpecDocUrl8__c      = item.ntceSpecDocUrl8;
                                // leadobj.ntceSpecDocUrl9__c      = item.ntceSpecDocUrl9;
                                // leadobj.ntceSpecDocUrl10__c     = item.ntceSpecDocUrl10;
                                // leadobj.ntceSpecFileNm1__c      = item.ntceSpecFileNm1;
                                // leadobj.ntceSpecFileNm2__c      = item.ntceSpecFileNm2;
                                // leadobj.ntceSpecFileNm3__c      = item.ntceSpecFileNm3;
                                // leadobj.ntceSpecFileNm4__c      = item.ntceSpecFileNm4;
                                // leadobj.ntceSpecFileNm5__c      = item.ntceSpecFileNm5;
                                // leadobj.ntceSpecFileNm6__c      = item.ntceSpecFileNm6;
                                // leadobj.ntceSpecFileNm7__c      = item.ntceSpecFileNm7;
                                // leadobj.ntceSpecFileNm8__c      = item.ntceSpecFileNm8;
                                // leadobj.ntceSpecFileNm9__c      = item.ntceSpecFileNm9;
                                // leadobj.ntceSpecFileNm10__c     = item.ntceSpecFileNm10;
                                // leadobj.bidNtceUrl__c           = item.bidNtceUrl;
                                // leadobj.purchsObjPrdctList__c   = item.purchsObjPrdctList;
                                // leadobj.stdNtceDocUrl__c        = item.stdNtceDocUrl;
                                // leadobj.d2bMngStdIndstryClsfcCdList__c      = item.d2bMngStdIndstryClsfcCdList;
                                // leadobj.chgNtceRsn__c           = item.chgNtceRsn;

                                leadObj.RecordtypeId = d2bRecordId;

                                leadMap.put(item.d2bMngDmndYear+item.bidNtceNo+item.d2bMngDcsnNo, leadObj);
                            }
                        }
                    }else {
                        CJFW_BiddingInformation__c leadObj = new CJFW_BiddingInformation__c();
                        if (leadMap.get(item.bidNtceNo) == null || (leadMap.get(item.bidNtceNo) <> null) && Integer.valueOf(leadMap.get(item.bidNtceOrd)) < Integer.valueOf(item.bidNtceOrd)) {
                            leadObj.PIC__c                  = (item.ntceInsttOfclNm == null || item.ntceInsttOfclNm == '') ? item.dminsttNm : item.ntceInsttOfclNm;
                            leadObj.Company__c              = item.dminsttNm;
                            leadobj.Phone__c                = item.ntceInsttOfclTelNo;
                            leadObj.Email__c                = item.ntceInsttOfclEmailAdrs;
                            //leadObj.LeadSource = 'NaraMarket';
                            leadObj.BidNoticeStatus__c      = item.ntceKindNm;
                            if (Integer.valueOf(item.bidNtceOrd) < 10) {
                                Integer ord = Integer.valueOf(item.bidNtceOrd);
                                leadObj.BidNoticeNumber__c = item.bidNtceNo+'-0'+ String.valueOf(ord);
                            }else {
                                leadObj.BidNoticeNumber__c = item.bidNtceNo+'-'+item.bidNtceOrd;
                            }

                            leadObj.Name                    = item.bidNtceNm;
                            leadObj.BidMethod__c            = item.bidMethdNm;
                            leadObj.ContractSignMethod__c   = item.cntrctCnclsMthdNm;
                            leadObj.SubNumber__c            = item.bidNtceOrd;
                            leadObj.IsReBid__c              = (item.rbidPermsnYn == 'Y') ? true : false;
                            leadObj.BidBeginDateTime__c     = (item.bidBeginDt == null || item.bidBeginDt == '') ? null : Datetime.valueOf(item.bidBeginDt);
                            leadObj.BidOpenDateTime__c      = (item.opengDt == null || item.opengDt == '') ? null : Datetime.valueOf(item.opengDt);
                            leadObj.BidCloseDateTime__c     = (item.bidClseDt == null || item.bidClseDt == '') ? null : Datetime.valueOf(item.bidClseDt);
                            leadObj.BidOpenPlace__c         = item.opengPlce;
                            System.debug('item.bidQlfctRgstDt: ' + item.bidQlfctRgstDt);
                            if(item.bidQlfctRgstDt.length() < 21){
                                leadObj.BidQualifyRegistCloseDateTime__c = (item.bidQlfctRgstDt == null || item.bidQlfctRgstDt == '') ? null : Datetime.valueOf(item.bidQlfctRgstDt+':00');
                            }else {
                                leadObj.BidQualifyRegistCloseDateTime__c = (item.bidQlfctRgstDt == null || item.bidQlfctRgstDt == '') ? null : Datetime.valueOf(item.bidQlfctRgstDt);
                            }
                            leadObj.PreArrangePriceDecisionMethod__c    = item.prearngPrceDcsnMthdNm;
                            leadObj.AssignBudgetAmountCurrency__c       =  (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                            leadObj.CommonSupplierRegionLimitYN__c      = (item.cmmnSpldmdCorpRgnLmtYn == 'Y') ? true : false;
                            leadObj.IsIndustryLimitYN__c    = (item.indstrytyLmtYn == 'Y') ? true : false;
                            leadObj.BidNoticeDetailUrl__c   = item.bidNtceDtlUrl;
                            leadObj.BidNoticeCompanyCode__c = item.dminsttCd;
                            
                            // leadobj.bidNtceOrd__c           = item.bidNtceOrd;
                            // leadobj.reNtceYn__c             = item.reNtceYn;
                            // leadobj.rgstTyNm__c             = item.rgstTyNm;
                            // leadobj.intrbidYn__c            = item.intrbidYn;
                            leadobj.bidNtceDt__c            = item.bidNtceDt;
                            // leadobj.refNo__c                = item.refNo;
                            // leadobj.ntceInsttCd__c          = item.ntceInsttCd;
                            // leadobj.ntceInsttNm__c          = item.ntceInsttNm;
                            // leadobj.exctvNm__c              = item.exctvNm;
                            // leadobj.cmmnSpldmdAgrmntRcptdocMethd__c = item.cmmnSpldmdAgrmntRcptdocMethd;
                            // leadobj.cmmnSpldmdAgrmntClseDt__c = item.cmmnSpldmdAgrmntClseDt;
                            leadobj.prdctClsfcLmtYn__c      = item.prdctClsfcLmtYn;
                            //leadobj.mnfctYn__c              = item.mnfctYn;
                            leadobj.totPrdprcNum__c         = item.totPrdprcNum;
                            leadobj.drwtPrdprcNum__c        = item.drwtPrdprcNum;
                            leadobj.presmptPrce__c          = item.presmptPrce; //= item.presmptPrce <> null  && item.presmptPrce <> '' ? Decimal.valueOf(item.presmptPrce) : null;
                            // leadobj.bidPrtcptFeePaymntYn__c = item.bidPrtcptFeePaymntYn;
                            // leadobj.bidPrtcptFee__c         = item.bidPrtcptFee;
                            // leadobj.bidGrntymnyPaymntYn__c  = item.bidGrntymnyPaymntYn;
                            // leadobj.crdtrNm__c              = item.crdtrNm;
                            // leadobj.dtilPrdctClsfcNo__c     = item.dtilPrdctClsfcNo;
                            // leadobj.dtilPrdctClsfcNoNm__c   = item.dtilPrdctClsfcNoNm;
                            // leadobj.prdctSpecNm__c          = item.prdctSpecNm;
                            // leadobj.prdctQty__c             = item.prdctQty;
                            // leadobj.prdctUnit__c            = item.prdctUnit;
                            // leadobj.prdctUprc__c            = item.prdctUprc;
                            // leadobj.dlvrTmlmtDt__c          = item.dlvrTmlmtDt;
                            // leadobj.dlvrDaynum__c           = item.dlvrDaynum;
                            // leadobj.dlvryCndtnNm__c         = item.dlvryCndtnNm;
                            // leadobj.untyNtceNo__c           = item.untyNtceNo;
                            // leadobj.cmmnSpldmdMethdCd__c    = item.cmmnSpldmdMethdCd;
                            // leadobj.cmmnSpldmdMethdNm__c    = item.cmmnSpldmdMethdNm;
                            leadobj.brffcBidprcPermsnYn__c  = item.brffcBidprcPermsnYn;     //= item.brffcBidprcPermsnYn == 'Y' ? true : false;
                            // leadobj.dsgntCmptYn__c          = item.dsgntCmptYn;
                            // leadobj.rsrvtnPrceReMkngMthdNm__c = item.rsrvtnPrceReMkngMthdNm;
                            // leadobj.arsltApplDocRcptMthdNm__c = item.arsltApplDocRcptMthdNm;
                            // leadobj.arsltApplDocRcptDt__c   = item.arsltApplDocRcptDt;
                            // leadobj.orderPlanUntyNo__c      = item.orderPlanUntyNo;
                            // leadobj.sucsfbidLwltRate__c     = item.sucsfbidLwltRate;
                            leadobj.rgstDt__c               = item.rgstDt;                  //= item.rgstDt <> null ? Date.valueOf(item.rgstDt) : null;
                            // leadobj.bfSpecRgstNo__c         = item.bfSpecRgstNo;
                            // leadobj.infoBizYn__c            = item.infoBizYn;
                            // leadobj.sucsfbidMthdCd__c       = item.sucsfbidMthdCd;
                            // leadobj.sucsfbidMthdNm__c       = item.sucsfbidMthdNm;
                            // leadobj.chgDt__c                = item.chgDt;
                            // leadobj.linkInsttNm__c          = item.linkInsttNm;
                            // leadobj.dminsttOfclEmailAdrs__c = item.dminsttOfclEmailAdrs;
                            // leadobj.d2bMngDcmtgOprtnDt__c   = item.d2bMngDcmtgOprtnDt;
                            // leadobj.d2bMngDcmtgOprtnPlce__c = item.d2bMngDcmtgOprtnPlce;
                            // leadobj.d2bMngRgnLmtYn__c       = item.d2bMngRgnLmtYn;
                            // leadobj.d2bMngPblctPlceNm__c    = item.d2bMngPblctPlceNm;
                            // leadobj.d2bMngCntrctKindNm__c   = item.d2bMngCntrctKindNm;
                            // leadobj.d2bMngCntrybndDedtBgnDate__c = item.d2bMngCntrybndDedtBgnDate;
                            // leadobj.d2bMngCntrybndDedtEndDate__c = item.d2bMngCntrybndDedtEndDate;
                            // leadobj.d2bMngRsrvtnPrceBssOpenYn__c = item.d2bMngRsrvtnPrceBssOpenYn;
                            // leadobj.d2bMngRrsrvtnPrceBssAplYn__c = item.d2bMngRrsrvtnPrceBssAplYn;
                            // leadobj.d2bMngBssamt__c         = item.d2bMngBssamt;
                            // leadobj.d2bMngRgstEvalExmpYn__c = item.d2bMngRgstEvalExmpYn;
                            // leadobj.d2bMngCompCorpRsrchObjYn__c = item.d2bMngCompCorpRsrchObjYn;
                            // leadobj.d2bMngOrgnlbdgtDedtBgnDate__c = item.d2bMngOrgnlbdgtDedtBgnDate;
                            // leadobj.d2bMngOrgnlbdgtDedtEndDate__c = item.d2bMngOrgnlbdgtDedtEndDate;
                            // leadobj.d2bMngAssmntUplmtRt__c  = item.d2bMngAssmntUplmtRt;
                            // leadobj.d2bMngAssmntLwstlmtRt__c = item.d2bMngAssmntLwstlmtRt;
                            // leadobj.d2bMngPrdctnAbltySbmsnClseDt__c = item.d2bMngPrdctnAbltySbmsnClseDt;
                            // leadobj.d2bMngProgrsSttusNm__c  = item.d2bMngProgrsSttusNm;
                            // leadobj.d2bMngExetTyNm__c       = item.d2bMngExetTyNm;
                            // leadobj.d2bMngExetTyCd__c       = item.d2bMngExetTyCd;
                            // leadobj.d2bMngPrdlstCd__c       = item.d2bMngPrdlstCd;
                            // leadobj.d2bMngItemNo__c         = item.d2bMngItemNo;
                            // leadobj.d2bMngNgttnStleNm__c    = item.d2bMngNgttnStleNm;
                            // leadobj.d2bMngNgttnPlanDate__c  = item.d2bMngNgttnPlanDate;
                            // leadobj.d2bMngDmndYear__c       = item.d2bMngDmndYear;
                            // leadobj.d2bMngDcsnNo__c         = item.d2bMngDcsnNo;
                            // leadobj.rbidOpengDt__c          = item.rbidOpengDt;
                            leadobj.VAT__c                  = item.VAT;                     //= item.VAT <> null && item.VAT <> '' ? Decimal.valueOf(item.VAT) : null;
                            // leadobj.indutyVAT__c            = item.indutyVAT;
                            // leadobj.ntceSpecDocUrl1__c      = item.ntceSpecDocUrl1;
                            // leadobj.ntceSpecDocUrl2__c      = item.ntceSpecDocUrl2;
                            // leadobj.ntceSpecDocUrl3__c      = item.ntceSpecDocUrl3;
                            // leadobj.ntceSpecDocUrl4__c      = item.ntceSpecDocUrl4;
                            // leadobj.ntceSpecDocUrl5__c      = item.ntceSpecDocUrl5;
                            // leadobj.ntceSpecDocUrl6__c      = item.ntceSpecDocUrl6;
                            // leadobj.ntceSpecDocUrl7__c      = item.ntceSpecDocUrl7;
                            // leadobj.ntceSpecDocUrl8__c      = item.ntceSpecDocUrl8;
                            // leadobj.ntceSpecDocUrl9__c      = item.ntceSpecDocUrl9;
                            // leadobj.ntceSpecDocUrl10__c     = item.ntceSpecDocUrl10;
                            // leadobj.ntceSpecFileNm1__c      = item.ntceSpecFileNm1;
                            // leadobj.ntceSpecFileNm2__c      = item.ntceSpecFileNm2;
                            // leadobj.ntceSpecFileNm3__c      = item.ntceSpecFileNm3;
                            // leadobj.ntceSpecFileNm4__c      = item.ntceSpecFileNm4;
                            // leadobj.ntceSpecFileNm5__c      = item.ntceSpecFileNm5;
                            // leadobj.ntceSpecFileNm6__c      = item.ntceSpecFileNm6;
                            // leadobj.ntceSpecFileNm7__c      = item.ntceSpecFileNm7;
                            // leadobj.ntceSpecFileNm8__c      = item.ntceSpecFileNm8;
                            // leadobj.ntceSpecFileNm9__c      = item.ntceSpecFileNm9;
                            // leadobj.ntceSpecFileNm10__c     = item.ntceSpecFileNm10;
                            // leadobj.bidNtceUrl__c           = item.bidNtceUrl;
                            // leadobj.purchsObjPrdctList__c   = item.purchsObjPrdctList;
                            // leadobj.stdNtceDocUrl__c        = item.stdNtceDocUrl;
                            // leadobj.d2bMngStdIndstryClsfcCdList__c = item.d2bMngStdIndstryClsfcCdList;
                            // leadobj.chgNtceRsn__c           = item.chgNtceRsn;
                            leadObj.RecordtypeId            = naraRecordId;
                            
                            leadMap.put(item.bidNtceNo, leadObj);
                        }
                    }
                }
            System.debug('String.valueOf(leadMap): ' + String.valueOf(leadMap));
            }else {
                strCode = '0001';
                strStatus = 'ERROR';
                strMessage = 'HTTP Status code :' + res.getStatusCode();
            }
        } catch(Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
        }
        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        objResult.resultLead = leadMap <> null && leadMap.size() > 0 ? leadMap.values() : null;
        objOutput.result = objResult;

        objWrapper.status = strStatus;
        objWrapper.resultCode = strCode;
        objWrapper.resultMessage = strMessage;
        objWrapper.responseTime = Datetime.now();
        objWrapper.requestBody = getRquest;
        objWrapper.responseBody = responseBody;
        System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);

        IFUtil objIF = new IFUtil('IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL');
        objIf.setLog(objWrapper);
        
        return objOutput;
    }
}