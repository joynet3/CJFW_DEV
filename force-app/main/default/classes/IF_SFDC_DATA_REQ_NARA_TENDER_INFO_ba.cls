/**
 * @description       : 나라장터 입찰공고 api Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global with sharing class IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts{

    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_NARA_TENDER_INFO'];
    API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '공공데이터_Key'];
    AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
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
        this.operationName = operationName;
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
        
        List<Lead> insertList = new List<Lead>();
        List<Lead> updateList = new List<Lead>();
        Map<String, Lead> insertMap = new Map<String, Lead>(); 
        Boolean saveBool = false;
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
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
                Id recordId = Schema.SObjectType.LEAD.getRecordTypeInfosByDeveloperName().get('NaraMarketLead').getRecordTypeId();
                // System.debug('==========================itmes:::'+JSON.serialize(input.response.body.items));
                // System.debug('==========================itmes:::'+ input.response.body.items.size());
                Set<String> uptBidNoSet = new Set<String>();
                Map<String,Lead> uptLeadMap = new Map<String,Lead>();

                if (input.response.body.items <> null && input.response.body.items.size() > 0) {
                    for (IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc.Items item : input.response.body.items) {
                        if (Integer.valueOf(item.bidNtceOrd) < 10) {
                            Integer ord = Integer.valueOf(item.bidNtceOrd);
                            uptBidNoSet.add(item.bidNtceNo+'-0'+ String.valueOf(ord));
                        }else {
                            uptBidNoSet.add(item.bidNtceNo+'-'+item.bidNtceOrd);
                        }
                    }
                    for (Lead obj : [SELECT Id, BidNoticeNumber__c 
                                        FROM Lead 
                                        WHERE BidNoticeNumber__c IN:uptBidNoSet]) {
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
                            Lead uptLead = uptLeadMap.get(bidNo);
                            uptLead.LastName = (item.ntceInsttOfclNm == null || item.ntceInsttOfclNm == '') ? item.dminsttNm : item.ntceInsttOfclNm;
                            uptLead.Company = item.dminsttNm;
                            uptLead.Status = 'New';
                            uptLead.MobilePhone = item.ntceInsttOfclTelNo;
                            uptLead.Email = item.ntceInsttOfclEmailAdrs;
                            uptLead.LeadSource = 'NaraMarket';
                            uptLead.BidNoticeStatus__c = item.ntceKindNm;
                            if (Integer.valueOf(item.bidNtceOrd) < 10) {
                                Integer ord = Integer.valueOf(item.bidNtceOrd);
                                uptLead.BidNoticeNumber__c = item.bidNtceNo+'-0'+ String.valueOf(ord);
                            }else {
                                uptLead.BidNoticeNumber__c = item.bidNtceNo+'-'+item.bidNtceOrd;
                            }
                            uptLead.BidNoticeName__c = item.bidNtceNm;
                            uptLead.BidMethod__c = item.bidMethdNm;
                            uptLead.ContractSignMethod__c = item.cntrctCnclsMthdNm;
                            uptLead.SubNumber__c = item.bidNtceOrd;
                            uptLead.IsReBid__c = (item.rbidPermsnYn == 'Y') ? true : false;
                            uptLead.BidBeginDateTime__c = (item.bidBeginDt == null || item.bidBeginDt == '') ? null : Datetime.valueOf(item.bidBeginDt);
                            if (item.opengDt <> null) {
                                Datetime dt = Datetime.newInstance(
                                Integer.valueOf(item.opengDt.substring(0,4))
                                ,Integer.valueOf(item.opengDt.substring(5,7))
                                ,Integer.valueOf(item.opengDt.substring(8,10))
                                ,Integer.valueOf(item.opengDt.substring(11,13))
                                ,Integer.valueOf(item.opengDt.substring(14,16))
                                , 0
                                );
                                uptLead.BidOpenDateTime__c = dt;
                            }
                            // uptLead.BidOpenDateTime__c = (item.opengDt == null || item.opengDt == '') ? null : Datetime.valueOf(item.opengDt);
                            uptLead.BidCloseDateTime__c = (item.bidClseDt == null || item.bidClseDt == '') ? null : Datetime.valueOf(item.bidClseDt);
                            uptLead.BidOpenPlace__c = item.opengPlce;
                            if (item.bidQlfctRgstDt <> null && item.bidQlfctRgstDt <> '') {
                                if (item.bidQlfctRgstDt.length() == 16) {
                                    uptLead.BidQualifyRegistCloseDateTime__c = Datetime.valueOf(item.bidQlfctRgstDt + ':00');
                                }else {
                                    uptLead.BidQualifyRegistCloseDateTime__c = Datetime.valueOf(item.bidQlfctRgstDt);
                                }
                            }else {
                                uptLead.BidQualifyRegistCloseDateTime__c = null;
                            }
                            // uptLead.BidQualifyRegistCloseDateTime__c = (item.bidQlfctRgstDt == null || item.bidQlfctRgstDt == '') ? null : Datetime.valueOf(item.bidQlfctRgstDt);
                            uptLead.PreArrangePriceDecisionMethod__c = item.prearngPrceDcsnMthdNm;
                            uptLead.AssignBudgetAmountCurrency__c =  (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                            uptLead.CommonSupplierRegionLimitYN__c = (item.cmmnSpldmdCorpRgnLmtYn == 'Y') ? true : false;
                            uptLead.IsIndustryLimitYN__c = (item.indstrytyLmtYn == 'Y') ? true : false;
                            uptLead.BidNoticeDetailUrl__c = item.bidNtceDtlUrl;
                            uptLead.BidNoticeCompanyCode__c = item.dminsttCd;
                            uptLead.bidNtceOrd__c = item.bidNtceOrd;
                            uptLead.reNtceYn__c = item.reNtceYn;
                            uptLead.rgstTyNm__c = item.rgstTyNm;
                            uptLead.intrbidYn__c = item.intrbidYn;
                            uptLead.bidNtceDt__c = item.bidNtceDt;
                            uptLead.refNo__c = item.refNo;
                            uptLead.ntceInsttCd__c = item.ntceInsttCd;
                            uptLead.ntceInsttNm__c = item.ntceInsttNm;
                            uptLead.exctvNm__c = item.exctvNm;
                            uptLead.cmmnSpldmdAgrmntRcptdocMethd__c = item.cmmnSpldmdAgrmntRcptdocMethd;
                            uptLead.cmmnSpldmdAgrmntClseDt__c = item.cmmnSpldmdAgrmntClseDt;
                            uptLead.prdctClsfcLmtYn__c = item.prdctClsfcLmtYn;
                            uptLead.mnfctYn__c = item.mnfctYn;
                            uptLead.totPrdprcNum__c = item.totPrdprcNum;
                            uptLead.drwtPrdprcNum__c = item.drwtPrdprcNum;
                            uptLead.presmptPrce__c = item.presmptPrce <> null && item.presmptPrce <> '' ? Decimal.valueOf(item.presmptPrce) : null;
                            uptLead.bidPrtcptFeePaymntYn__c = item.bidPrtcptFeePaymntYn;
                            uptLead.bidPrtcptFee__c = item.bidPrtcptFee;
                            uptLead.bidGrntymnyPaymntYn__c = item.bidGrntymnyPaymntYn;
                            uptLead.crdtrNm__c = item.crdtrNm;
                            uptLead.dtilPrdctClsfcNo__c = item.dtilPrdctClsfcNo;
                            uptLead.dtilPrdctClsfcNoNm__c = item.dtilPrdctClsfcNoNm;
                            uptLead.prdctSpecNm__c = item.prdctSpecNm;
                            uptLead.prdctQty__c = item.prdctQty;
                            uptLead.prdctUnit__c = item.prdctUnit;
                            uptLead.prdctUprc__c = item.prdctUprc;
                            uptLead.dlvrTmlmtDt__c = item.dlvrTmlmtDt;
                            uptLead.dlvrDaynum__c = item.dlvrDaynum;
                            uptLead.dlvryCndtnNm__c = item.dlvryCndtnNm;
                            uptLead.untyNtceNo__c = item.untyNtceNo;
                            uptLead.cmmnSpldmdMethdCd__c = item.cmmnSpldmdMethdCd;
                            uptLead.cmmnSpldmdMethdNm__c = item.cmmnSpldmdMethdNm;
                            uptLead.brffcBidprcPermsnYn__c = item.brffcBidprcPermsnYn == 'Y' ? true : false;
                            uptLead.dsgntCmptYn__c = item.dsgntCmptYn;
                            uptLead.rsrvtnPrceReMkngMthdNm__c = item.rsrvtnPrceReMkngMthdNm;
                            uptLead.arsltApplDocRcptMthdNm__c = item.arsltApplDocRcptMthdNm;
                            uptLead.arsltApplDocRcptDt__c = item.arsltApplDocRcptDt;
                            uptLead.orderPlanUntyNo__c = item.orderPlanUntyNo;
                            uptLead.sucsfbidLwltRate__c = item.sucsfbidLwltRate;
                            if (item.rgstDt <> null) {
                                Datetime dt = Datetime.newInstance(
                                Integer.valueOf(item.rgstDt.substring(0,4))
                                ,Integer.valueOf(item.rgstDt.substring(5,7))
                                ,Integer.valueOf(item.rgstDt.substring(8,10))
                                ,Integer.valueOf(item.rgstDt.substring(11,13))
                                ,Integer.valueOf(item.rgstDt.substring(14,16))
                                , 0
                                );
                                uptLead.rgstDt__c = dt;
                            }
                            // uptLead.rgstDt__c = item.rgstDt <> null ? Datetime.valueOf(item.rgstDt) : null;
                            uptLead.bfSpecRgstNo__c = item.bfSpecRgstNo;
                            uptLead.infoBizYn__c = item.infoBizYn;
                            uptLead.sucsfbidMthdCd__c = item.sucsfbidMthdCd;
                            uptLead.sucsfbidMthdNm__c = item.sucsfbidMthdNm;
                            uptLead.chgDt__c = item.chgDt;
                            uptLead.linkInsttNm__c = item.linkInsttNm;
                            uptLead.dminsttOfclEmailAdrs__c = item.dminsttOfclEmailAdrs;
                            uptLead.d2bMngDcmtgOprtnDt__c = item.d2bMngDcmtgOprtnDt;
                            uptLead.d2bMngDcmtgOprtnPlce__c = item.d2bMngDcmtgOprtnPlce;
                            uptLead.d2bMngRgnLmtYn__c = item.d2bMngRgnLmtYn;
                            uptLead.d2bMngPblctPlceNm__c = item.d2bMngPblctPlceNm;
                            uptLead.d2bMngCntrctKindNm__c = item.d2bMngCntrctKindNm;
                            uptLead.d2bMngCntrybndDedtBgnDate__c = item.d2bMngCntrybndDedtBgnDate;
                            uptLead.d2bMngCntrybndDedtEndDate__c = item.d2bMngCntrybndDedtEndDate;
                            uptLead.d2bMngRsrvtnPrceBssOpenYn__c = item.d2bMngRsrvtnPrceBssOpenYn;
                            uptLead.d2bMngRrsrvtnPrceBssAplYn__c = item.d2bMngRrsrvtnPrceBssAplYn;
                            uptLead.d2bMngBssamt__c = item.d2bMngBssamt;
                            uptLead.d2bMngRgstEvalExmpYn__c = item.d2bMngRgstEvalExmpYn;
                            uptLead.d2bMngCompCorpRsrchObjYn__c = item.d2bMngCompCorpRsrchObjYn;
                            uptLead.d2bMngOrgnlbdgtDedtBgnDate__c = item.d2bMngOrgnlbdgtDedtBgnDate;
                            uptLead.d2bMngOrgnlbdgtDedtEndDate__c = item.d2bMngOrgnlbdgtDedtEndDate;
                            uptLead.d2bMngAssmntUplmtRt__c = item.d2bMngAssmntUplmtRt;
                            uptLead.d2bMngAssmntLwstlmtRt__c = item.d2bMngAssmntLwstlmtRt;
                            uptLead.d2bMngPrdctnAbltySbmsnClseDt__c = item.d2bMngPrdctnAbltySbmsnClseDt;
                            uptLead.d2bMngProgrsSttusNm__c = item.d2bMngProgrsSttusNm;
                            uptLead.d2bMngExetTyNm__c = item.d2bMngExetTyNm;
                            uptLead.d2bMngExetTyCd__c = item.d2bMngExetTyCd;
                            uptLead.d2bMngPrdlstCd__c = item.d2bMngPrdlstCd;
                            uptLead.d2bMngItemNo__c = item.d2bMngItemNo;
                            uptLead.d2bMngNgttnStleNm__c = item.d2bMngNgttnStleNm;
                            uptLead.d2bMngNgttnPlanDate__c = item.d2bMngNgttnPlanDate;
                            uptLead.d2bMngDmndYear__c = item.d2bMngDmndYear;
                            uptLead.d2bMngDcsnNo__c = item.d2bMngDcsnNo;
                            uptLead.rbidOpengDt__c = item.rbidOpengDt;
                            uptLead.VAT__c = item.VAT <> null && item.VAT <> '' ? Decimal.valueOf(item.VAT) : null;
                            uptLead.indutyVAT__c = item.indutyVAT;
                            uptLead.ntceSpecDocUrl1__c = item.ntceSpecDocUrl1;
                            uptLead.ntceSpecDocUrl2__c = item.ntceSpecDocUrl2;
                            uptLead.ntceSpecDocUrl3__c = item.ntceSpecDocUrl3;
                            uptLead.ntceSpecDocUrl4__c = item.ntceSpecDocUrl4;
                            uptLead.ntceSpecDocUrl5__c = item.ntceSpecDocUrl5;
                            uptLead.ntceSpecDocUrl6__c = item.ntceSpecDocUrl6;
                            uptLead.ntceSpecDocUrl7__c = item.ntceSpecDocUrl7;
                            uptLead.ntceSpecDocUrl8__c = item.ntceSpecDocUrl8;
                            uptLead.ntceSpecDocUrl9__c = item.ntceSpecDocUrl9;
                            uptLead.ntceSpecDocUrl10__c = item.ntceSpecDocUrl10;
                            uptLead.ntceSpecFileNm1__c = item.ntceSpecFileNm1;
                            uptLead.ntceSpecFileNm2__c = item.ntceSpecFileNm2;
                            uptLead.ntceSpecFileNm3__c = item.ntceSpecFileNm3;
                            uptLead.ntceSpecFileNm4__c = item.ntceSpecFileNm4;
                            uptLead.ntceSpecFileNm5__c = item.ntceSpecFileNm5;
                            uptLead.ntceSpecFileNm6__c = item.ntceSpecFileNm6;
                            uptLead.ntceSpecFileNm7__c = item.ntceSpecFileNm7;
                            uptLead.ntceSpecFileNm8__c = item.ntceSpecFileNm8;
                            uptLead.ntceSpecFileNm9__c = item.ntceSpecFileNm9;
                            uptLead.ntceSpecFileNm10__c = item.ntceSpecFileNm10;
                            uptLead.bidNtceUrl__c = item.bidNtceUrl;
                            uptLead.purchsObjPrdctList__c = item.purchsObjPrdctList;
                            uptLead.stdNtceDocUrl__c = item.stdNtceDocUrl;
                            uptLead.d2bMngStdIndstryClsfcCdList__c = item.d2bMngStdIndstryClsfcCdList;
                            uptLead.chgNtceRsn__c = item.chgNtceRsn;
                            uptLead.Keyword__c = keywordList[targetIndex].Keyword__c;
                            if (operationName == 'getBidPblancListInfoServcPPSSrch') {
                                uptLead.bsnsDivNm__c = '용역';
                            }else if (operationName == 'getBidPblancListInfoFrgcptPPSSrch') {
                                uptLead.bsnsDivNm__c = '외자';
                            }else if (operationName == 'getBidPblancListInfoThngPPSSrch') {
                                uptLead.bsnsDivNm__c = '물품';
                            }else if (operationName == 'getBidPblancListInfoEtcPPSSrch') {
                                uptLead.bsnsDivNm__c = '기타';
                            }
                            uptLead.RecordtypeId = recordId;
                            for (NaramarketKeyword__mdt keyword : subKeywordList) {
                                if (item.bidNtceNm.contains(keyword.Keyword__c)) {
                                    uptLead.KeywordSub__c = keyword.Keyword__c;
                                    break;
                                }
                            }

                            updateList.add(uptLead);
                        }else {
                            Lead leadObj = new Lead();
                            leadobj.setOptions(dmlOpts);
                            if (item.opengPlce != '국방전자조달시스템') {
                                //lead map을 이용하여 같은 공고번호중 가장 높은 차수를 검열하는 if문
                                if (insertMap.get(item.bidNtceNo) == null || (insertMap.get(item.bidNtceNo) <> null) && Integer.valueOf(insertMap.get(item.bidNtceOrd)) < Integer.valueOf(item.bidNtceOrd)) {
                                    leadObj.LastName = (item.ntceInsttOfclNm == null || item.ntceInsttOfclNm == '') ? item.dminsttNm : item.ntceInsttOfclNm;
                                    leadObj.Company = item.dminsttNm;
                                    leadObj.Status = 'New';
                                    leadobj.MobilePhone = item.ntceInsttOfclTelNo;
                                    leadObj.Email = item.ntceInsttOfclEmailAdrs;
                                    leadObj.LeadSource = 'NaraMarket';
                                    leadObj.BidNoticeStatus__c = item.ntceKindNm;
                                    if (Integer.valueOf(item.bidNtceOrd) < 10) {
                                        Integer ord = Integer.valueOf(item.bidNtceOrd);
                                        leadObj.BidNoticeNumber__c = item.bidNtceNo+'-0'+ String.valueOf(ord);
                                    }else {
                                        leadObj.BidNoticeNumber__c = item.bidNtceNo+'-'+item.bidNtceOrd;
                                    }
                                    leadObj.BidNoticeName__c = item.bidNtceNm;
                                    leadObj.BidMethod__c = item.bidMethdNm;
                                    leadObj.ContractSignMethod__c = item.cntrctCnclsMthdNm;
                                    leadObj.SubNumber__c = item.bidNtceOrd;
                                    leadObj.IsReBid__c = (item.rbidPermsnYn == 'Y') ? true : false;
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
                                    leadObj.BidOpenPlace__c = item.opengPlce;
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
                                    leadObj.PreArrangePriceDecisionMethod__c = item.prearngPrceDcsnMthdNm;
                                    leadObj.AssignBudgetAmountCurrency__c =  (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                                    leadObj.CommonSupplierRegionLimitYN__c = (item.cmmnSpldmdCorpRgnLmtYn == 'Y') ? true : false;
                                    leadObj.IsIndustryLimitYN__c = (item.indstrytyLmtYn == 'Y') ? true : false;
                                    leadObj.BidNoticeDetailUrl__c = item.bidNtceDtlUrl;
                                    leadObj.BidNoticeCompanyCode__c = item.dminsttCd;
                                    leadobj.bidNtceOrd__c = item.bidNtceOrd;
                                    leadobj.reNtceYn__c = item.reNtceYn;
                                    leadobj.rgstTyNm__c = item.rgstTyNm;
                                    leadobj.intrbidYn__c = item.intrbidYn;
                                    leadobj.bidNtceDt__c = item.bidNtceDt;
                                    leadobj.refNo__c = item.refNo;
                                    leadobj.ntceInsttCd__c = item.ntceInsttCd;
                                    leadobj.ntceInsttNm__c = item.ntceInsttNm;
                                    leadobj.exctvNm__c = item.exctvNm;
                                    leadobj.cmmnSpldmdAgrmntRcptdocMethd__c = item.cmmnSpldmdAgrmntRcptdocMethd;
                                    leadobj.cmmnSpldmdAgrmntClseDt__c = item.cmmnSpldmdAgrmntClseDt;
                                    leadobj.prdctClsfcLmtYn__c = item.prdctClsfcLmtYn;
                                    leadobj.mnfctYn__c = item.mnfctYn;
                                    leadobj.totPrdprcNum__c = item.totPrdprcNum;
                                    leadobj.drwtPrdprcNum__c = item.drwtPrdprcNum;
                                    leadobj.presmptPrce__c = item.presmptPrce <> null && item.presmptPrce <> '' ? Decimal.valueOf(item.presmptPrce) : null;
                                    leadobj.bidPrtcptFeePaymntYn__c = item.bidPrtcptFeePaymntYn;
                                    leadobj.bidPrtcptFee__c = item.bidPrtcptFee;
                                    leadobj.bidGrntymnyPaymntYn__c = item.bidGrntymnyPaymntYn;
                                    leadobj.crdtrNm__c = item.crdtrNm;
                                    leadobj.dtilPrdctClsfcNo__c = item.dtilPrdctClsfcNo;
                                    leadobj.dtilPrdctClsfcNoNm__c = item.dtilPrdctClsfcNoNm;
                                    leadobj.prdctSpecNm__c = item.prdctSpecNm;
                                    leadobj.prdctQty__c = item.prdctQty;
                                    leadobj.prdctUnit__c = item.prdctUnit;
                                    leadobj.prdctUprc__c = item.prdctUprc;
                                    leadobj.dlvrTmlmtDt__c = item.dlvrTmlmtDt;
                                    leadobj.dlvrDaynum__c = item.dlvrDaynum;
                                    leadobj.dlvryCndtnNm__c = item.dlvryCndtnNm;
                                    leadobj.untyNtceNo__c = item.untyNtceNo;
                                    leadobj.cmmnSpldmdMethdCd__c = item.cmmnSpldmdMethdCd;
                                    leadobj.cmmnSpldmdMethdNm__c = item.cmmnSpldmdMethdNm;
                                    leadobj.brffcBidprcPermsnYn__c = item.brffcBidprcPermsnYn == 'Y' ? true : false;
                                    leadobj.dsgntCmptYn__c = item.dsgntCmptYn;
                                    leadobj.rsrvtnPrceReMkngMthdNm__c = item.rsrvtnPrceReMkngMthdNm;
                                    leadobj.arsltApplDocRcptMthdNm__c = item.arsltApplDocRcptMthdNm;
                                    leadobj.arsltApplDocRcptDt__c = item.arsltApplDocRcptDt;
                                    leadobj.orderPlanUntyNo__c = item.orderPlanUntyNo;
                                    leadobj.sucsfbidLwltRate__c = item.sucsfbidLwltRate;
                                    if (item.rgstDt <> null) {
                                        Datetime dt = Datetime.newInstance(
                                        Integer.valueOf(item.rgstDt.substring(0,4))
                                        ,Integer.valueOf(item.rgstDt.substring(5,7))
                                        ,Integer.valueOf(item.rgstDt.substring(8,10))
                                        ,Integer.valueOf(item.rgstDt.substring(11,13))
                                        ,Integer.valueOf(item.rgstDt.substring(14,16))
                                        , 0
                                        );
                                        leadObj.rgstDt__c = dt;
                                    }
                                    // leadobj.rgstDt__c = item.rgstDt <> null ? Datetime.valueOf(item.rgstDt) : null;
                                    leadobj.bfSpecRgstNo__c = item.bfSpecRgstNo;
                                    leadobj.infoBizYn__c = item.infoBizYn;
                                    leadobj.sucsfbidMthdCd__c = item.sucsfbidMthdCd;
                                    leadobj.sucsfbidMthdNm__c = item.sucsfbidMthdNm;
                                    leadobj.chgDt__c = item.chgDt;
                                    leadobj.linkInsttNm__c = item.linkInsttNm;
                                    leadobj.dminsttOfclEmailAdrs__c = item.dminsttOfclEmailAdrs;
                                    leadobj.d2bMngDcmtgOprtnDt__c = item.d2bMngDcmtgOprtnDt;
                                    leadobj.d2bMngDcmtgOprtnPlce__c = item.d2bMngDcmtgOprtnPlce;
                                    leadobj.d2bMngRgnLmtYn__c = item.d2bMngRgnLmtYn;
                                    leadobj.d2bMngPblctPlceNm__c = item.d2bMngPblctPlceNm;
                                    leadobj.d2bMngCntrctKindNm__c = item.d2bMngCntrctKindNm;
                                    leadobj.d2bMngCntrybndDedtBgnDate__c = item.d2bMngCntrybndDedtBgnDate;
                                    leadobj.d2bMngCntrybndDedtEndDate__c = item.d2bMngCntrybndDedtEndDate;
                                    leadobj.d2bMngRsrvtnPrceBssOpenYn__c = item.d2bMngRsrvtnPrceBssOpenYn;
                                    leadobj.d2bMngRrsrvtnPrceBssAplYn__c = item.d2bMngRrsrvtnPrceBssAplYn;
                                    leadobj.d2bMngBssamt__c = item.d2bMngBssamt;
                                    leadobj.d2bMngRgstEvalExmpYn__c = item.d2bMngRgstEvalExmpYn;
                                    leadobj.d2bMngCompCorpRsrchObjYn__c = item.d2bMngCompCorpRsrchObjYn;
                                    leadobj.d2bMngOrgnlbdgtDedtBgnDate__c = item.d2bMngOrgnlbdgtDedtBgnDate;
                                    leadobj.d2bMngOrgnlbdgtDedtEndDate__c = item.d2bMngOrgnlbdgtDedtEndDate;
                                    leadobj.d2bMngAssmntUplmtRt__c = item.d2bMngAssmntUplmtRt;
                                    leadobj.d2bMngAssmntLwstlmtRt__c = item.d2bMngAssmntLwstlmtRt;
                                    leadobj.d2bMngPrdctnAbltySbmsnClseDt__c = item.d2bMngPrdctnAbltySbmsnClseDt;
                                    leadobj.d2bMngProgrsSttusNm__c = item.d2bMngProgrsSttusNm;
                                    leadobj.d2bMngExetTyNm__c = item.d2bMngExetTyNm;
                                    leadobj.d2bMngExetTyCd__c = item.d2bMngExetTyCd;
                                    leadobj.d2bMngPrdlstCd__c = item.d2bMngPrdlstCd;
                                    leadobj.d2bMngItemNo__c = item.d2bMngItemNo;
                                    leadobj.d2bMngNgttnStleNm__c = item.d2bMngNgttnStleNm;
                                    leadobj.d2bMngNgttnPlanDate__c = item.d2bMngNgttnPlanDate;
                                    leadobj.d2bMngDmndYear__c = item.d2bMngDmndYear;
                                    leadobj.d2bMngDcsnNo__c = item.d2bMngDcsnNo;
                                    leadobj.rbidOpengDt__c = item.rbidOpengDt;
                                    leadobj.VAT__c = item.VAT <> null && item.VAT <> '' ? Decimal.valueOf(item.VAT) : null;
                                    leadobj.indutyVAT__c = item.indutyVAT;
                                    leadobj.ntceSpecDocUrl1__c = item.ntceSpecDocUrl1;
                                    leadobj.ntceSpecDocUrl2__c = item.ntceSpecDocUrl2;
                                    leadobj.ntceSpecDocUrl3__c = item.ntceSpecDocUrl3;
                                    leadobj.ntceSpecDocUrl4__c = item.ntceSpecDocUrl4;
                                    leadobj.ntceSpecDocUrl5__c = item.ntceSpecDocUrl5;
                                    leadobj.ntceSpecDocUrl6__c = item.ntceSpecDocUrl6;
                                    leadobj.ntceSpecDocUrl7__c = item.ntceSpecDocUrl7;
                                    leadobj.ntceSpecDocUrl8__c = item.ntceSpecDocUrl8;
                                    leadobj.ntceSpecDocUrl9__c = item.ntceSpecDocUrl9;
                                    leadobj.ntceSpecDocUrl10__c = item.ntceSpecDocUrl10;
                                    leadobj.ntceSpecFileNm1__c = item.ntceSpecFileNm1;
                                    leadobj.ntceSpecFileNm2__c = item.ntceSpecFileNm2;
                                    leadobj.ntceSpecFileNm3__c = item.ntceSpecFileNm3;
                                    leadobj.ntceSpecFileNm4__c = item.ntceSpecFileNm4;
                                    leadobj.ntceSpecFileNm5__c = item.ntceSpecFileNm5;
                                    leadobj.ntceSpecFileNm6__c = item.ntceSpecFileNm6;
                                    leadobj.ntceSpecFileNm7__c = item.ntceSpecFileNm7;
                                    leadobj.ntceSpecFileNm8__c = item.ntceSpecFileNm8;
                                    leadobj.ntceSpecFileNm9__c = item.ntceSpecFileNm9;
                                    leadobj.ntceSpecFileNm10__c = item.ntceSpecFileNm10;
                                    leadobj.bidNtceUrl__c = item.bidNtceUrl;
                                    leadobj.purchsObjPrdctList__c = item.purchsObjPrdctList;
                                    leadobj.stdNtceDocUrl__c = item.stdNtceDocUrl;
                                    leadobj.d2bMngStdIndstryClsfcCdList__c = item.d2bMngStdIndstryClsfcCdList;
                                    leadobj.chgNtceRsn__c = item.chgNtceRsn;
                                    leadObj.Keyword__c = keywordList[targetIndex].Keyword__c;
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
            for (Lead obj : updateList) {
                nextBatchLeadSet.add(obj.Id);
            }
        }

        if (insertList <> null) {
            insert insertList;
            for (Lead obj : insertList) {
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