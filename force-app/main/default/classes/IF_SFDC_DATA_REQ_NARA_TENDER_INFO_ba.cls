/**
 * @description       : 나라장터 입찰공고 api Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
 * 
 * @last modified on  : 10-17-2023
 * @last modified by  : sancho : Lead -> CJFW_BiddingInformation__c
**/
global with sharing class IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts{

    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_NARA_TENDER_INFO'];
    API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '공공데이터_Key'];
    //2023.10.17
    //AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
    List<NaramarketKeyword__mdt> subKeywordList = [SELECT Keyword__c, keyword_seq__c FROM NaramarketKeyword__mdt WHERE Keyword_lv__c = 2 ORDER BY keyword_seq__c ASC];
    Database.DMLOptions dmlOpts = new Database.DMLOptions();
    
    global List<NaramarketKeyword__mdt> keywordList = new List<NaramarketKeyword__mdt>();
    global String operationName;
    global Integer targetIndex = 0;
    global String today = String.valueOf(Datetime.now().format('yyyyMMdd')) + '0000';
    global Set<Id> nextBatchLeadSet = new Set<Id>();
    Datetime endDt = Datetime.now();
    global String stDt;
    global String enDt;
    // global List<String> errList = new List<String>();
    
    global IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(List<NaramarketKeyword__mdt> keywordList, String operationName, Integer targetIndex, Set<Id> nextBatchLeadSet, String stDt, String enDt) {
        this.operationName = operationName;     //sc에서 넘어옴 getBidPblancListInfoEtcPPSSrch(기타)
        this.keywordList = keywordList;
        this.targetIndex = targetIndex;
        this.nextBatchLeadSet = nextBatchLeadSet;
        if(stDt <> null){
            this.stDt = stDt;
        }
        if (enDt <> null) {
            this.enDt = enDt;
        }
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 나라장터 입찰공고 API 조회
    ************************************************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {

        System.debug('=============================:::batch start');
        System.debug('keywordList: ' + keywordList);

        List<String> totalPageList = new List<String>();
        Integer totalPage;
        String getRquest = '';

        endDt += (Integer.valueof(authKey.DateRange__c));
        System.debug('==================enddt:::' + endDt.format('yyyyMMdd'));

        getRquest += '/' + operationName;
        getRquest += '?inqryDiv=1';
        getRquest += '&type=json';
        if(stDt <> null && enDt <> null){
            getRquest += '&inqryBgnDt=' + stDt+'0000';
            getRquest += '&inqryEndDt=' + enDt+'0000';
        }else {
            getRquest += '&inqryBgnDt=' + today;
            getRquest += '&inqryEndDt=' + endDt.format('yyyyMMdd')+'0000';
        }
        System.debug('keywordList[targetIndex].Keyword__c: ' + keywordList[targetIndex].Keyword__c);
        String encodedString = EncodingUtil.urlEncode(String.valueOf(keywordList[targetIndex].Keyword__c), 'UTF-8');
        System.debug('=====================encodedString:::'+encodedString);
        getRquest += '&bidNtceNm=' + encodedString;
        getRquest += '&pageNo=1';
        getRquest += '&numOfRows=1000';
        getRquest += '&ServiceKey=' + authKey.KeyValue__c;
        System.debug('======================getRquest:::' + getRquest);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ifMasterObj.Endpoint__c + getRquest);
        request.setHeader('content-type', ifMasterObj.ContentType__c);
        request.setMethod(ifMasterObj.Method__c);
        request.setTimeout(120000);
        HttpResponse res = http.send(request);

        if(res.getStatusCode() == 200) {
            IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Input input = (IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Input) JSON.deserialize(res.getBody(), IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Input.Class);
            System.debug('==========================totalCount:::'+input.response.body.totalCount);
            Integer totalCount = Integer.valueOf(input.response.body.totalCount);
            Integer numOfRow = Integer.valueOf(input.response.body.numOfRows);
            totalPage = (totalCount/numOfRow);
            System.debug('==============================totalPage:::'+totalPage);
            for (Integer i = 0; i <= totalPage ; i++) {
                totalPageList.add(String.valueOf(i));
            }
            System.debug('============================totalPageList:::' + String.valueOf(totalPageList));
        }
        return totalPageList;
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 나라장터 입찰공고 Paging API 조회
    ************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<String> scope) {
        
        //2023.09.11 - sancho
        List<CJFW_BiddingInformation__c> insertList = new List<CJFW_BiddingInformation__c>();
        List<CJFW_BiddingInformation__c> updateList = new List<CJFW_BiddingInformation__c>();
        Map<String, CJFW_BiddingInformation__c> insertMap = new Map<String, CJFW_BiddingInformation__c>(); 
        Boolean saveBool = false;
        //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        // dmlOpts.EmailHeader.TriggerUserEmail = true;
        
        String result = '';
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String getParameter = '';

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        endDt += Integer.valueof(authKey.DateRange__c);
        System.debug('==================enddt:::' + endDt.format('yyyyMMdd'));
        getParameter += '/' + operationName;
        getParameter += '?inqryDiv=2';
        getParameter += '&type=json';
        getParameter += '&inqryBgnDt=' + today;
        getParameter += '&inqryEndDt=' + endDt.format('yyyyMMdd')+'0000';
        String encodedString = EncodingUtil.urlEncode(String.valueOf(keywordList[targetIndex].Keyword__c) , 'UTF-8');
        System.debug('=====================encodedString:::'+encodedString);
        getParameter += '&bidNtceNm=' + encodedString;
        getParameter += '&pageNo='+String.valueOf((Integer.valueOf(scope[0])+1));
        getParameter += '&numOfRows=1000';
        getParameter += '&ServiceKey=' + authKey.KeyValue__c;
        System.debug('======================getParameter:::' + getParameter);
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ifMasterObj.Endpoint__c + getParameter);
            request.setHeader('content-type', ifMasterObj.ContentType__c);
            request.setMethod(ifMasterObj.Method__c);
            request.setTimeout(110000);
            HttpResponse res = http.send(request);
            result = res.getBody();

            if(res.getStatusCode() == 200) {
                // System.debug('==============================================>>getbody' + res.getBody());
                IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Input input = (IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Input) JSON.deserialize(res.getBody(), IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Input.Class);
                
                //2023.10.17 - sancho //NaraMarketLead -> NaraMarket  신규(Military,Local,NaraMarket)
                Id recordId = Schema.SObjectType.CJFW_BiddingInformation__c.getRecordTypeInfosByDeveloperName().get('NaraMarket').getRecordTypeId();
                
                Set<String> uptBidNoSet = new Set<String>();
                Map<String,CJFW_BiddingInformation__c> uptLeadMap = new Map<String,CJFW_BiddingInformation__c>();

                if (input.response.body.items <> null && input.response.body.items.size() > 0) {
                    for (IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Items item : input.response.body.items) {
                        if (Integer.valueOf(item.bidNtceOrd) < 10) {
                            Integer ord = Integer.valueOf(item.bidNtceOrd);
                            uptBidNoSet.add(item.bidNtceNo+'-0'+ String.valueOf(ord));
                        }else {
                            uptBidNoSet.add(item.bidNtceNo+'-'+item.bidNtceOrd);
                        }
                    }

                    //2023.10.17 - sancho update용 Map
                    for (CJFW_BiddingInformation__c obj : [SELECT Id, BidNoticeNumber__c FROM CJFW_BiddingInformation__c WHERE BidNoticeNumber__c IN:uptBidNoSet]) {
                        uptLeadMap.put(obj.BidNoticeNumber__c, obj);
                    }

                    for (IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Items item : input.response.body.items) {
                        String bidNo = '';
                        if (Integer.valueOf(item.bidNtceOrd) < 10) {
                            Integer ord = Integer.valueOf(item.bidNtceOrd);
                            bidNo = (item.bidNtceNo+'-0'+ String.valueOf(ord));
                        }else {
                            bidNo = (item.bidNtceNo+'-'+item.bidNtceOrd);
                        }
                        if (uptLeadMap.get(bidNo) <> null) {
                            
                            CJFW_BiddingInformation__c uptLead = uptLeadMap.get(bidNo);     //2023.10.17 - sancho

                            uptLead.PIC__c                  = (item.ntceInsttOfclNm == null || item.ntceInsttOfclNm == '') ? item.dminsttNm : item.ntceInsttOfclNm;
                            uptLead.Company__c              = item.dminsttNm;
                            //uptLead.Status = 'New';               //2023.10.17 사용안함
                            uptLead.Phone__c                = item.ntceInsttOfclTelNo;
                            uptLead.Email__c                = item.ntceInsttOfclEmailAdrs;
                            //uptLead.LeadSource = 'NaraMarket';    //2023.10.17 사용안함
                            uptLead.BidNoticeStatus__c      = item.ntceKindNm;
                            if (Integer.valueOf(item.bidNtceOrd) < 10) {
                                Integer ord = Integer.valueOf(item.bidNtceOrd);
                                uptLead.BidNoticeNumber__c      = item.bidNtceNo+'-0'+ String.valueOf(ord);
                            }else {
                                uptLead.BidNoticeNumber__c      = item.bidNtceNo+'-'+item.bidNtceOrd;
                            }
                            uptLead.Name                    = item.bidNtceNm;  //uptLead.BidNoticeName__c = item.bidNtceNm; //2023.10.17
                            uptLead.BidMethod__c            = item.bidMethdNm;
                            uptLead.ContractSignMethod__c   = item.cntrctCnclsMthdNm;
                            uptLead.SubNumber__c            = item.bidNtceOrd;
                            uptLead.IsReBid__c              = (item.rbidPermsnYn == 'Y') ? true : false;
                            uptLead.BidBeginDateTime__c     = (item.bidBeginDt == null || item.bidBeginDt == '') ? null : Datetime.valueOf(item.bidBeginDt);
                            if (item.opengDt <> null) {
                                Datetime dt = Datetime.newInstance(
                                Integer.valueOf(item.opengDt.substring(0,4))
                                ,Integer.valueOf(item.opengDt.substring(5,7))
                                ,Integer.valueOf(item.opengDt.substring(8,10))
                                ,Integer.valueOf(item.opengDt.substring(11,13))
                                ,Integer.valueOf(item.opengDt.substring(14,16))
                                , 0
                                );
                                uptLead.BidOpenDateTime__c      = dt;
                            }
                            // uptLead.BidOpenDateTime__c = (item.opengDt == null || item.opengDt == '') ? null : Datetime.valueOf(item.opengDt);
                            uptLead.BidCloseDateTime__c     = (item.bidClseDt == null || item.bidClseDt == '') ? null : Datetime.valueOf(item.bidClseDt);
                            uptLead.BidOpenPlace__c         = item.opengPlce;
                            if (item.bidQlfctRgstDt <> null && item.bidQlfctRgstDt <> '') {
                                if (item.bidQlfctRgstDt.length() == 16) {
                                    uptLead.BidQualifyRegistCloseDateTime__c    = Datetime.valueOf(item.bidQlfctRgstDt + ':00');
                                }else {
                                    uptLead.BidQualifyRegistCloseDateTime__c    = Datetime.valueOf(item.bidQlfctRgstDt);
                                }
                            }else {
                                uptLead.BidQualifyRegistCloseDateTime__c    = null;
                            }
                            // uptLead.BidQualifyRegistCloseDateTime__c = (item.bidQlfctRgstDt == null || item.bidQlfctRgstDt == '') ? null : Datetime.valueOf(item.bidQlfctRgstDt);
                            uptLead.PreArrangePriceDecisionMethod__c    = item.prearngPrceDcsnMthdNm;
                            uptLead.AssignBudgetAmountCurrency__c       =  (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                            uptLead.CommonSupplierRegionLimitYN__c      = (item.cmmnSpldmdCorpRgnLmtYn == 'Y') ? true : false;
                            uptLead.IsIndustryLimitYN__c                = (item.indstrytyLmtYn == 'Y') ? true : false;
                            uptLead.BidNoticeDetailUrl__c               = item.bidNtceDtlUrl;
                            uptLead.BidNoticeCompanyCode__c             = item.dminsttCd;
                            // uptLead.bidNtceOrd__c           = item.bidNtceOrd;
                            // uptLead.reNtceYn__c             = item.reNtceYn;
                            // uptLead.rgstTyNm__c             = item.rgstTyNm;
                            // uptLead.intrbidYn__c            = item.intrbidYn;
                            uptLead.bidNtceDt__c            = item.bidNtceDt;
                            // uptLead.refNo__c                = item.refNo;
                            // uptLead.ntceInsttCd__c          = item.ntceInsttCd;
                            // uptLead.ntceInsttNm__c          = item.ntceInsttNm;
                            // uptLead.exctvNm__c              = item.exctvNm;
                            // uptLead.cmmnSpldmdAgrmntRcptdocMethd__c     = item.cmmnSpldmdAgrmntRcptdocMethd;
                            // uptLead.cmmnSpldmdAgrmntClseDt__c           = item.cmmnSpldmdAgrmntClseDt;
                            uptLead.prdctClsfcLmtYn__c      = item.prdctClsfcLmtYn;
                            // uptLead.mnfctYn__c              = item.mnfctYn;
                            uptLead.totPrdprcNum__c         = item.totPrdprcNum;
                            uptLead.drwtPrdprcNum__c        = item.drwtPrdprcNum;
                            uptLead.presmptPrce__c          = item.presmptPrce;     //= item.presmptPrce <> null && item.presmptPrce <> '' ? Decimal.valueOf(item.presmptPrce) : null;
                            // uptLead.bidPrtcptFeePaymntYn__c = item.bidPrtcptFeePaymntYn;
                            // uptLead.bidPrtcptFee__c         = item.bidPrtcptFee;
                            // uptLead.bidGrntymnyPaymntYn__c  = item.bidGrntymnyPaymntYn;
                            // uptLead.crdtrNm__c              = item.crdtrNm;
                            // uptLead.dtilPrdctClsfcNo__c     = item.dtilPrdctClsfcNo;
                            // uptLead.dtilPrdctClsfcNoNm__c   = item.dtilPrdctClsfcNoNm;
                            // uptLead.prdctSpecNm__c          = item.prdctSpecNm;
                            // uptLead.prdctQty__c             = item.prdctQty;
                            // uptLead.prdctUnit__c            = item.prdctUnit;
                            // uptLead.prdctUprc__c            = item.prdctUprc;
                            // uptLead.dlvrTmlmtDt__c          = item.dlvrTmlmtDt;
                            // uptLead.dlvrDaynum__c           = item.dlvrDaynum;
                            // uptLead.dlvryCndtnNm__c         = item.dlvryCndtnNm;
                            // uptLead.untyNtceNo__c           = item.untyNtceNo;
                            // uptLead.cmmnSpldmdMethdCd__c    = item.cmmnSpldmdMethdCd;
                            // uptLead.cmmnSpldmdMethdNm__c    = item.cmmnSpldmdMethdNm;
                            uptLead.brffcBidprcPermsnYn__c  = item.brffcBidprcPermsnYn; //= item.brffcBidprcPermsnYn == 'Y' ? true : false;
                            // uptLead.dsgntCmptYn__c          = item.dsgntCmptYn;
                            // uptLead.rsrvtnPrceReMkngMthdNm__c   = item.rsrvtnPrceReMkngMthdNm;
                            // uptLead.arsltApplDocRcptMthdNm__c   = item.arsltApplDocRcptMthdNm;
                            // uptLead.arsltApplDocRcptDt__c   = item.arsltApplDocRcptDt;
                            // uptLead.orderPlanUntyNo__c      = item.orderPlanUntyNo;
                            // uptLead.sucsfbidLwltRate__c     = item.sucsfbidLwltRate;
                            // if (item.rgstDt <> null) {
                            //     Datetime dt = Datetime.newInstance(
                            //     Integer.valueOf(item.rgstDt.substring(0,4))
                            //     ,Integer.valueOf(item.rgstDt.substring(5,7))
                            //     ,Integer.valueOf(item.rgstDt.substring(8,10))
                            //     ,Integer.valueOf(item.rgstDt.substring(11,13))
                            //     ,Integer.valueOf(item.rgstDt.substring(14,16))
                            //     , 0
                            //     );
                            //     uptLead.rgstDt__c               = dt;
                            // }
                            uptLead.rgstDt__c               = item.rgstDt;      //= item.rgstDt <> null ? Datetime.valueOf(item.rgstDt) : null;
                            // uptLead.bfSpecRgstNo__c         = item.bfSpecRgstNo;
                            // uptLead.infoBizYn__c            = item.infoBizYn;
                            // uptLead.sucsfbidMthdCd__c       = item.sucsfbidMthdCd;
                            // uptLead.sucsfbidMthdNm__c       = item.sucsfbidMthdNm;
                            // uptLead.chgDt__c                = item.chgDt;
                            // uptLead.linkInsttNm__c          = item.linkInsttNm;
                            // uptLead.dminsttOfclEmailAdrs__c = item.dminsttOfclEmailAdrs;
                            // uptLead.d2bMngDcmtgOprtnDt__c   = item.d2bMngDcmtgOprtnDt;
                            // uptLead.d2bMngDcmtgOprtnPlce__c = item.d2bMngDcmtgOprtnPlce;
                            // uptLead.d2bMngRgnLmtYn__c       = item.d2bMngRgnLmtYn;
                            // uptLead.d2bMngPblctPlceNm__c    = item.d2bMngPblctPlceNm;
                            // uptLead.d2bMngCntrctKindNm__c   = item.d2bMngCntrctKindNm;
                            // uptLead.d2bMngCntrybndDedtBgnDate__c    = item.d2bMngCntrybndDedtBgnDate;
                            // uptLead.d2bMngCntrybndDedtEndDate__c    = item.d2bMngCntrybndDedtEndDate;
                            // uptLead.d2bMngRsrvtnPrceBssOpenYn__c    = item.d2bMngRsrvtnPrceBssOpenYn;
                            // uptLead.d2bMngRrsrvtnPrceBssAplYn__c    = item.d2bMngRrsrvtnPrceBssAplYn;
                            // uptLead.d2bMngBssamt__c         = item.d2bMngBssamt;
                            // uptLead.d2bMngRgstEvalExmpYn__c = item.d2bMngRgstEvalExmpYn;
                            // uptLead.d2bMngCompCorpRsrchObjYn__c     = item.d2bMngCompCorpRsrchObjYn;
                            // uptLead.d2bMngOrgnlbdgtDedtBgnDate__c   = item.d2bMngOrgnlbdgtDedtBgnDate;
                            // uptLead.d2bMngOrgnlbdgtDedtEndDate__c   = item.d2bMngOrgnlbdgtDedtEndDate;
                            // uptLead.d2bMngAssmntUplmtRt__c  = item.d2bMngAssmntUplmtRt;
                            // uptLead.d2bMngAssmntLwstlmtRt__c        = item.d2bMngAssmntLwstlmtRt;
                            // uptLead.d2bMngPrdctnAbltySbmsnClseDt__c = item.d2bMngPrdctnAbltySbmsnClseDt;
                            // uptLead.d2bMngProgrsSttusNm__c          = item.d2bMngProgrsSttusNm;
                            // uptLead.d2bMngExetTyNm__c       = item.d2bMngExetTyNm;
                            // uptLead.d2bMngExetTyCd__c       = item.d2bMngExetTyCd;
                            // uptLead.d2bMngPrdlstCd__c       = item.d2bMngPrdlstCd;
                            // uptLead.d2bMngItemNo__c         = item.d2bMngItemNo;
                            // uptLead.d2bMngNgttnStleNm__c    = item.d2bMngNgttnStleNm;
                            // uptLead.d2bMngNgttnPlanDate__c  = item.d2bMngNgttnPlanDate;
                            // uptLead.d2bMngDmndYear__c       = item.d2bMngDmndYear;
                            // uptLead.d2bMngDcsnNo__c         = item.d2bMngDcsnNo;
                            // uptLead.rbidOpengDt__c          = item.rbidOpengDt;
                            uptLead.VAT__c                  = item.VAT;     //= item.VAT <> null && item.VAT <> '' ? Decimal.valueOf(item.VAT) : null;
                            // uptLead.indutyVAT__c            = item.indutyVAT;
                            // uptLead.ntceSpecDocUrl1__c      = item.ntceSpecDocUrl1;
                            // uptLead.ntceSpecDocUrl2__c      = item.ntceSpecDocUrl2;
                            // uptLead.ntceSpecDocUrl3__c      = item.ntceSpecDocUrl3;
                            // uptLead.ntceSpecDocUrl4__c      = item.ntceSpecDocUrl4;
                            // uptLead.ntceSpecDocUrl5__c      = item.ntceSpecDocUrl5;
                            // uptLead.ntceSpecDocUrl6__c      = item.ntceSpecDocUrl6;
                            // uptLead.ntceSpecDocUrl7__c      = item.ntceSpecDocUrl7;
                            // uptLead.ntceSpecDocUrl8__c      = item.ntceSpecDocUrl8;
                            // uptLead.ntceSpecDocUrl9__c      = item.ntceSpecDocUrl9;
                            // uptLead.ntceSpecDocUrl10__c     = item.ntceSpecDocUrl10;
                            // uptLead.ntceSpecFileNm1__c      = item.ntceSpecFileNm1;
                            // uptLead.ntceSpecFileNm2__c      = item.ntceSpecFileNm2;
                            // uptLead.ntceSpecFileNm3__c      = item.ntceSpecFileNm3;
                            // uptLead.ntceSpecFileNm4__c      = item.ntceSpecFileNm4;
                            // uptLead.ntceSpecFileNm5__c      = item.ntceSpecFileNm5;
                            // uptLead.ntceSpecFileNm6__c      = item.ntceSpecFileNm6;
                            // uptLead.ntceSpecFileNm7__c      = item.ntceSpecFileNm7;
                            // uptLead.ntceSpecFileNm8__c      = item.ntceSpecFileNm8;
                            // uptLead.ntceSpecFileNm9__c      = item.ntceSpecFileNm9;
                            // uptLead.ntceSpecFileNm10__c     = item.ntceSpecFileNm10;
                            // uptLead.bidNtceUrl__c           = item.bidNtceUrl;
                            // uptLead.purchsObjPrdctList__c   = item.purchsObjPrdctList;
                            // uptLead.stdNtceDocUrl__c        = item.stdNtceDocUrl;
                            // uptLead.d2bMngStdIndstryClsfcCdList__c  = item.d2bMngStdIndstryClsfcCdList;
                            // uptLead.chgNtceRsn__c           = item.chgNtceRsn;
                            uptLead.Keyword__c              = keywordList[targetIndex].Keyword__c;
                            if (operationName == 'getBidPblancListInfoServcPPSSrch') {
                                uptLead.bsnsDivNm__c = '용역';
                            }else if (operationName == 'getBidPblancListInfoFrgcptPPSSrch') {
                                uptLead.bsnsDivNm__c = '외자';
                            }else if (operationName == 'getBidPblancListInfoThngPPSSrch') {
                                uptLead.bsnsDivNm__c = '물품';
                            }else if (operationName == 'getBidPblancListInfoEtcPPSSrch') {
                                uptLead.bsnsDivNm__c = '기타';
                            }
                            uptLead.RecordtypeId            = recordId;
                            for (NaramarketKeyword__mdt keyword : subKeywordList) {
                                if (item.bidNtceNm.contains(keyword.Keyword__c)) {
                                    uptLead.KeywordSub__c   = keyword.Keyword__c;                       //KeywordSub 넣기 - 내부용 검색어 인듯하다.
                                    break;
                                }
                            }

                            updateList.add(uptLead);
                        }else {
                            CJFW_BiddingInformation__c leadObj = new CJFW_BiddingInformation__c();
                            leadobj.setOptions(dmlOpts);
                            if (item.opengPlce != '국방전자조달시스템') {
                                //lead map을 이용하여 같은 공고번호중 가장 높은 차수를 검열하는 if문
                                if (insertMap.get(item.bidNtceNo) == null || (insertMap.get(item.bidNtceNo) <> null) && Integer.valueOf(insertMap.get(item.bidNtceOrd)) < Integer.valueOf(item.bidNtceOrd)) {
                                    leadObj.PIC__c              = (item.ntceInsttOfclNm == null || item.ntceInsttOfclNm == '') ? item.dminsttNm : item.ntceInsttOfclNm;
                                    leadObj.Company__c          = item.dminsttNm;
                                    //leadObj.Status = 'New';               //2023.10.17 사용안함
                                    leadobj.Phone__c            = item.ntceInsttOfclTelNo;
                                    leadObj.Email__c            = item.ntceInsttOfclEmailAdrs;
                                    //leadObj.LeadSource = 'NaraMarket';    //2023.10.17 사용안함
                                    leadObj.BidNoticeStatus__c = item.ntceKindNm;
                                    if (Integer.valueOf(item.bidNtceOrd) < 10) {
                                        Integer ord = Integer.valueOf(item.bidNtceOrd);
                                        leadObj.BidNoticeNumber__c = item.bidNtceNo+'-0'+ String.valueOf(ord);
                                    }else {
                                        leadObj.BidNoticeNumber__c = item.bidNtceNo+'-'+item.bidNtceOrd;
                                    }
                                    leadObj.Name                = item.bidNtceNm;
                                    leadObj.BidMethod__c        = item.bidMethdNm;
                                    leadObj.ContractSignMethod__c   = item.cntrctCnclsMthdNm;
                                    leadObj.SubNumber__c        = item.bidNtceOrd;
                                    leadObj.IsReBid__c          = (item.rbidPermsnYn == 'Y') ? true : false;
                                    leadObj.BidBeginDateTime__c = (item.bidBeginDt == null || item.bidBeginDt == '') ? null : Datetime.valueOf(item.bidBeginDt);
                                    if (item.opengDt <> null) {
                                        Datetime dt = Datetime.newInstance(
                                        Integer.valueOf(item.opengDt.substring(0,4))
                                        ,Integer.valueOf(item.opengDt.substring(5,7))
                                        ,Integer.valueOf(item.opengDt.substring(8,10))
                                        ,Integer.valueOf(item.opengDt.substring(11,13))
                                        ,Integer.valueOf(item.opengDt.substring(14,16))
                                        , 0
                                        );
                                        leadObj.BidOpenDateTime__c = dt;
                                    }
                                    // leadObj.BidOpenDateTime__c = (item.opengDt == null || item.opengDt == '') ? null : Datetime.valueOf(item.opengDt);
                                    leadObj.BidCloseDateTime__c = (item.bidClseDt == null || item.bidClseDt == '') ? null : Datetime.valueOf(item.bidClseDt);
                                    leadObj.BidOpenPlace__c     = item.opengPlce;
                                    if (item.bidQlfctRgstDt <> null && item.bidQlfctRgstDt <> '') {
                                        if (item.bidQlfctRgstDt.length() == 16) {
                                            leadObj.BidQualifyRegistCloseDateTime__c = Datetime.valueOf(item.bidQlfctRgstDt + ':00');
                                        }else {
                                            leadObj.BidQualifyRegistCloseDateTime__c = Datetime.valueOf(item.bidQlfctRgstDt);
                                        }
                                    }else {
                                        leadObj.BidQualifyRegistCloseDateTime__c = null;
                                    }
                                    // leadObj.BidQualifyRegistCloseDateTime__c = (item.bidQlfctRgstDt == null || item.bidQlfctRgstDt == '') ? null : Datetime.valueOf(item.bidQlfctRgstDt);
                                    leadObj.PreArrangePriceDecisionMethod__c    = item.prearngPrceDcsnMthdNm;
                                    leadObj.AssignBudgetAmountCurrency__c       =  (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                                    leadObj.CommonSupplierRegionLimitYN__c      = (item.cmmnSpldmdCorpRgnLmtYn == 'Y') ? true : false;
                                    leadObj.IsIndustryLimitYN__c                = (item.indstrytyLmtYn == 'Y') ? true : false;
                                    leadObj.BidNoticeDetailUrl__c               = item.bidNtceDtlUrl;
                                    leadObj.BidNoticeCompanyCode__c             = item.dminsttCd;
                                    // leadObj.bidNtceOrd__c           = item.bidNtceOrd;
                                    // leadObj.reNtceYn__c             = item.reNtceYn;
                                    // leadObj.rgstTyNm__c             = item.rgstTyNm;
                                    // leadObj.intrbidYn__c            = item.intrbidYn;
                                    // leadObj.bidNtceDt__c            = item.bidNtceDt;
                                    // leadObj.refNo__c                = item.refNo;
                                    // leadObj.ntceInsttCd__c          = item.ntceInsttCd;
                                    // leadObj.ntceInsttNm__c          = item.ntceInsttNm;
                                    // leadObj.exctvNm__c              = item.exctvNm;
                                    // leadObj.cmmnSpldmdAgrmntRcptdocMethd__c     = item.cmmnSpldmdAgrmntRcptdocMethd;
                                    // leadObj.cmmnSpldmdAgrmntClseDt__c           = item.cmmnSpldmdAgrmntClseDt;
                                    // leadObj.prdctClsfcLmtYn__c      = item.prdctClsfcLmtYn;
                                    // leadObj.mnfctYn__c              = item.mnfctYn;
                                    // leadObj.totPrdprcNum__c         = item.totPrdprcNum;
                                    // leadObj.drwtPrdprcNum__c        = item.drwtPrdprcNum;
                                    // leadObj.presmptPrce__c          = item.presmptPrce <> null && item.presmptPrce <> '' ? Decimal.valueOf(item.presmptPrce) : null;
                                    // leadObj.bidPrtcptFeePaymntYn__c = item.bidPrtcptFeePaymntYn;
                                    // leadObj.bidPrtcptFee__c         = item.bidPrtcptFee;
                                    // leadObj.bidGrntymnyPaymntYn__c  = item.bidGrntymnyPaymntYn;
                                    // leadObj.crdtrNm__c              = item.crdtrNm;
                                    // leadObj.dtilPrdctClsfcNo__c     = item.dtilPrdctClsfcNo;
                                    // leadObj.dtilPrdctClsfcNoNm__c   = item.dtilPrdctClsfcNoNm;
                                    // leadObj.prdctSpecNm__c          = item.prdctSpecNm;
                                    // leadObj.prdctQty__c             = item.prdctQty;
                                    // leadObj.prdctUnit__c            = item.prdctUnit;
                                    // leadObj.prdctUprc__c            = item.prdctUprc;
                                    // leadObj.dlvrTmlmtDt__c          = item.dlvrTmlmtDt;
                                    // leadObj.dlvrDaynum__c           = item.dlvrDaynum;
                                    // leadObj.dlvryCndtnNm__c         = item.dlvryCndtnNm;
                                    // leadObj.untyNtceNo__c           = item.untyNtceNo;
                                    // leadObj.cmmnSpldmdMethdCd__c    = item.cmmnSpldmdMethdCd;
                                    // leadObj.cmmnSpldmdMethdNm__c    = item.cmmnSpldmdMethdNm;
                                    leadObj.brffcBidprcPermsnYn__c  = item.brffcBidprcPermsnYn;     //= item.brffcBidprcPermsnYn == 'Y' ? true : false;
                                    // leadObj.dsgntCmptYn__c          = item.dsgntCmptYn;
                                    // leadObj.rsrvtnPrceReMkngMthdNm__c   = item.rsrvtnPrceReMkngMthdNm;
                                    // leadObj.arsltApplDocRcptMthdNm__c   = item.arsltApplDocRcptMthdNm;
                                    // leadObj.arsltApplDocRcptDt__c   = item.arsltApplDocRcptDt;
                                    // leadObj.orderPlanUntyNo__c      = item.orderPlanUntyNo;
                                    // leadObj.sucsfbidLwltRate__c     = item.sucsfbidLwltRate;
                                    // if (item.rgstDt <> null) {
                                    //     Datetime dt = Datetime.newInstance(
                                    //     Integer.valueOf(item.rgstDt.substring(0,4))
                                    //     ,Integer.valueOf(item.rgstDt.substring(5,7))
                                    //     ,Integer.valueOf(item.rgstDt.substring(8,10))
                                    //     ,Integer.valueOf(item.rgstDt.substring(11,13))
                                    //     ,Integer.valueOf(item.rgstDt.substring(14,16))
                                    //     , 0
                                    //     );
                                    //     leadObj.rgstDt__c               = dt;
                                    // }
                                    leadObj.rgstDt__c = item.rgstDt;        //= item.rgstDt <> null ? Datetime.valueOf(item.rgstDt) : null;
                                    // leadObj.bfSpecRgstNo__c         = item.bfSpecRgstNo;
                                    // leadObj.infoBizYn__c            = item.infoBizYn;
                                    // leadObj.sucsfbidMthdCd__c       = item.sucsfbidMthdCd;
                                    // leadObj.sucsfbidMthdNm__c       = item.sucsfbidMthdNm;
                                    // leadObj.chgDt__c                = item.chgDt;
                                    // leadObj.linkInsttNm__c          = item.linkInsttNm;
                                    // leadObj.dminsttOfclEmailAdrs__c = item.dminsttOfclEmailAdrs;
                                    // leadObj.d2bMngDcmtgOprtnDt__c   = item.d2bMngDcmtgOprtnDt;
                                    // leadObj.d2bMngDcmtgOprtnPlce__c = item.d2bMngDcmtgOprtnPlce;
                                    // leadObj.d2bMngRgnLmtYn__c       = item.d2bMngRgnLmtYn;
                                    // leadObj.d2bMngPblctPlceNm__c    = item.d2bMngPblctPlceNm;
                                    // leadObj.d2bMngCntrctKindNm__c   = item.d2bMngCntrctKindNm;
                                    // leadObj.d2bMngCntrybndDedtBgnDate__c    = item.d2bMngCntrybndDedtBgnDate;
                                    // leadObj.d2bMngCntrybndDedtEndDate__c    = item.d2bMngCntrybndDedtEndDate;
                                    // leadObj.d2bMngRsrvtnPrceBssOpenYn__c    = item.d2bMngRsrvtnPrceBssOpenYn;
                                    // leadObj.d2bMngRrsrvtnPrceBssAplYn__c    = item.d2bMngRrsrvtnPrceBssAplYn;
                                    // leadObj.d2bMngBssamt__c         = item.d2bMngBssamt;
                                    // leadObj.d2bMngRgstEvalExmpYn__c = item.d2bMngRgstEvalExmpYn;
                                    // leadObj.d2bMngCompCorpRsrchObjYn__c     = item.d2bMngCompCorpRsrchObjYn;
                                    // leadObj.d2bMngOrgnlbdgtDedtBgnDate__c   = item.d2bMngOrgnlbdgtDedtBgnDate;
                                    // leadObj.d2bMngOrgnlbdgtDedtEndDate__c   = item.d2bMngOrgnlbdgtDedtEndDate;
                                    // leadObj.d2bMngAssmntUplmtRt__c  = item.d2bMngAssmntUplmtRt;
                                    // leadObj.d2bMngAssmntLwstlmtRt__c        = item.d2bMngAssmntLwstlmtRt;
                                    // leadObj.d2bMngPrdctnAbltySbmsnClseDt__c = item.d2bMngPrdctnAbltySbmsnClseDt;
                                    // leadObj.d2bMngProgrsSttusNm__c          = item.d2bMngProgrsSttusNm;
                                    // leadObj.d2bMngExetTyNm__c       = item.d2bMngExetTyNm;
                                    // leadObj.d2bMngExetTyCd__c       = item.d2bMngExetTyCd;
                                    // leadObj.d2bMngPrdlstCd__c       = item.d2bMngPrdlstCd;
                                    // leadObj.d2bMngItemNo__c         = item.d2bMngItemNo;
                                    // leadObj.d2bMngNgttnStleNm__c    = item.d2bMngNgttnStleNm;
                                    // leadObj.d2bMngNgttnPlanDate__c  = item.d2bMngNgttnPlanDate;
                                    // leadObj.d2bMngDmndYear__c       = item.d2bMngDmndYear;
                                    // leadObj.d2bMngDcsnNo__c         = item.d2bMngDcsnNo;
                                    // leadObj.rbidOpengDt__c          = item.rbidOpengDt;
                                    leadObj.VAT__c                  = item.VAT;     //= item.VAT <> null && item.VAT <> '' ? Decimal.valueOf(item.VAT) : null;
                                    // leadObj.indutyVAT__c            = item.indutyVAT;
                                    // leadObj.ntceSpecDocUrl1__c      = item.ntceSpecDocUrl1;
                                    // leadObj.ntceSpecDocUrl2__c      = item.ntceSpecDocUrl2;
                                    // leadObj.ntceSpecDocUrl3__c      = item.ntceSpecDocUrl3;
                                    // leadObj.ntceSpecDocUrl4__c      = item.ntceSpecDocUrl4;
                                    // leadObj.ntceSpecDocUrl5__c      = item.ntceSpecDocUrl5;
                                    // leadObj.ntceSpecDocUrl6__c      = item.ntceSpecDocUrl6;
                                    // leadObj.ntceSpecDocUrl7__c      = item.ntceSpecDocUrl7;
                                    // leadObj.ntceSpecDocUrl8__c      = item.ntceSpecDocUrl8;
                                    // leadObj.ntceSpecDocUrl9__c      = item.ntceSpecDocUrl9;
                                    // leadObj.ntceSpecDocUrl10__c     = item.ntceSpecDocUrl10;
                                    // leadObj.ntceSpecFileNm1__c      = item.ntceSpecFileNm1;
                                    // leadObj.ntceSpecFileNm2__c      = item.ntceSpecFileNm2;
                                    // leadObj.ntceSpecFileNm3__c      = item.ntceSpecFileNm3;
                                    // leadObj.ntceSpecFileNm4__c      = item.ntceSpecFileNm4;
                                    // leadObj.ntceSpecFileNm5__c      = item.ntceSpecFileNm5;
                                    // leadObj.ntceSpecFileNm6__c      = item.ntceSpecFileNm6;
                                    // leadObj.ntceSpecFileNm7__c      = item.ntceSpecFileNm7;
                                    // leadObj.ntceSpecFileNm8__c      = item.ntceSpecFileNm8;
                                    // leadObj.ntceSpecFileNm9__c      = item.ntceSpecFileNm9;
                                    // leadObj.ntceSpecFileNm10__c     = item.ntceSpecFileNm10;
                                    // leadObj.bidNtceUrl__c           = item.bidNtceUrl;
                                    // leadObj.purchsObjPrdctList__c   = item.purchsObjPrdctList;
                                    // leadObj.stdNtceDocUrl__c        = item.stdNtceDocUrl;
                                    // leadObj.d2bMngStdIndstryClsfcCdList__c  = item.d2bMngStdIndstryClsfcCdList;
                                    // leadObj.chgNtceRsn__c           = item.chgNtceRsn;
                                    leadObj.Keyword__c              = keywordList[targetIndex].Keyword__c;
                                    if (operationName == 'getBidPblancListInfoServcPPSSrch') {
                                        leadObj.bsnsDivNm__c = '용역';
                                    }else if (operationName == 'getBidPblancListInfoFrgcptPPSSrch') {
                                        leadObj.bsnsDivNm__c = '외자';
                                    }else if (operationName == 'getBidPblancListInfoThngPPSSrch') {
                                        leadObj.bsnsDivNm__c = '물품';
                                    }else if (operationName == 'getBidPblancListInfoEtcPPSSrch') {
                                        leadObj.bsnsDivNm__c = '기타';
                                    }
                                    leadObj.RecordtypeId = recordId;
                                    for (NaramarketKeyword__mdt keyword : subKeywordList) {
                                        if (item.bidNtceNm.contains(keyword.Keyword__c)) {
                                            leadObj.KeywordSub__c = keyword.Keyword__c;
                                            break;
                                        }
                                    }
                                    insertMap.put(leadObj.BidNoticeNumber__c, leadObj);
                                }
                            }
                        }
                    }    
                    insertList = insertMap.values();
                    saveBool = true;
                }
            }
        } catch(Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
        }
        if (updateList <> null) {
            update updateList;
            for (CJFW_BiddingInformation__c obj : updateList) {
                nextBatchLeadSet.add(obj.Id);
            }
        }

        if (insertList <> null) {
            insert insertList;
            for (CJFW_BiddingInformation__c obj : insertList) {
                nextBatchLeadSet.add(obj.Id);
            }
        }

        // if (saveBool) {
        //     upsert insertList BidNoticeNumber__c;
        // }
        
        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = getParameter;
        LogWrapper.responseBody = result;
        
        IFUtil objIF = new IFUtil('IF_SFDC_DATA_REQ_NARA_TENDER_INFO');
        objIF.setLog(LogWrapper);
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 다음 키워드로 나라장터 입찰공고 조회
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('=============================:::batch finish');
        targetIndex++;
        if (targetIndex < keywordList.size()) {
            if(stDt <> null && enDt <> null){
                IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba ba = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(keywordList, operationName, targetIndex, nextBatchLeadSet, stDt, enDt);
                Database.executeBatch(ba, 1);
            }else {
                IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba ba = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(keywordList, operationName, targetIndex, nextBatchLeadSet, null, null);
                Database.executeBatch(ba, 1);
            }
        }
        if(targetIndex == keywordList.size()){
            //지역 참가제한, 면허제한 조회 배치 실행
            // IF_SFDC_DATA_REQ_NARA_TENDER_RERT_ba b = new IF_SFDC_DATA_REQ_NARA_TENDER_RERT_ba(nextBatchLeadSet, 1);
            IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba b2 = new IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba(nextBatchLeadSet, 1);
            // Database.executeBatch(b,1);
            Database.executeBatch(b2,1);
        }
    }
}