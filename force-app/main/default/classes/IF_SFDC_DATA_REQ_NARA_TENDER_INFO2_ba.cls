/**
 * @description       : 나라장터 입찰공고 민간 API Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global with sharing class IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts{

    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_NARA_TENDER_INFO2'];
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

    global IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba(List<NaramarketKeyword__mdt> keywordList, String operationName, Integer targetIndex, Set<Id> nextBatchLeadSet) {
        this.operationName = operationName;
        this.keywordList = keywordList;
        this.targetIndex = targetIndex;
        this.nextBatchLeadSet = nextBatchLeadSet;
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
        getRquest += '&inqryBgnDt=' + today;
        getRquest += '&inqryEndDt=' + endDt.format('yyyyMMdd')+'0000';
        System.debug('keywordList[targetIndex].Keyword__c: ' + keywordList[targetIndex].Keyword__c);
        String encodedString = EncodingUtil.urlEncode(String.valueOf(keywordList[targetIndex].Keyword__c), 'UTF-8');
        System.debug('=====================encodedString:::'+encodedString);
        getRquest += '&bidNtceNm=' + encodedString;
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
        getParameter += '&numOfRows=200';
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
                            uptLead.LastName = (item.ofclNm == null || item.ofclNm == '') ? item.ntceInsttNm : item.ofclNm;
                            uptLead.Company = item.ntceInsttNm;
                            uptLead.Status = 'New';
                            uptLead.MobilePhone = item.ofclTelNo;
                            uptLead.Email = item.ofclEmail;
                            uptLead.LeadSource = 'NaraMarket';
                            uptLead.BidNoticeStatus__c = item.ntceDivNm;
                            if (Integer.valueOf(item.bidNtceOrd) < 10) {
                                Integer ord = Integer.valueOf(item.bidNtceOrd);
                                uptLead.BidNoticeNumber__c = item.bidNtceNo+'-0'+ String.valueOf(ord);
                            }else {
                                uptLead.BidNoticeNumber__c = item.bidNtceNo+'-'+item.bidNtceOrd;
                            }
                            uptLead.bidNtceOrd__c = item.bidNtceOrd;
                            uptLead.BidNoticeName__c = item.ntceNm;
                            uptLead.BidMethod__c = item.bidMethdNm;
                            uptLead.ContractSignMethod__c = item.cntrctMthdNm;
                            uptLead.SubNumber__c = item.bidNtceOrd;
                            uptLead.IsReBid__c = (item.rbidDivNm == 'Y') ? true : false;
                            uptLead.BidBeginDateTime__c = (item.bidBeginDt == null || item.bidBeginDt == '') ? null : Datetime.valueOf(item.bidBeginDt);
                            uptLead.BidOpenDateTime__c = (item.opengDt == null || item.opengDt == '') ? null : Datetime.valueOf(item.opengDt);
                            uptLead.BidCloseDateTime__c = (item.bidClseDt == null || item.bidClseDt == '') ? null : Datetime.valueOf(item.bidClseDt);
                            uptLead.BidOpenPlace__c = item.opengPlce;
                            uptLead.AssignBudgetAmountCurrency__c =  (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                            uptLead.bsnsDivNm__c = item.bidNtceClsfc;
                            uptLead.PblancDate__c = item.rgstDt <> null ? Date.valueOf(item.rgstDt) : null;
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
                            if (operationName == 'getPrvtBidPblancListInfoServcPPSSrch') {
                                uptLead.bsnsDivNm__c = '민간용역';
                            }else if (operationName == 'getPrvtBidPblancListInfoThngPPSSrch') {
                                uptLead.bsnsDivNm__c = '민간물품';
                            }else if (operationName == 'getPrvtBidPblancListInfoEtcPPSSrch') {
                                uptLead.bsnsDivNm__c = '민간기타';
                            }
                            uptLead.Keyword__c = keywordList[targetIndex].Keyword__c;
                            uptLead.RecordtypeId = recordId;
                            for (NaramarketKeyword__mdt keyword : subKeywordList) {
                                if (item.ntceNm.contains(keyword.Keyword__c)) {
                                    uptLead.KeywordSub__c = keyword.Keyword__c;
                                    break;
                                }
                            }
                            updateList.add(uptLead);
                        }else {
                            Lead leadObj = new Lead();
                            leadobj.setOptions(dmlOpts);
                            //국방전자조달시스템 외의 공고건만 적재
                            if (item.opengPlce != '국방전자조달시스템') {
                                //lead map을 이용하여 같은 공고번호중 가장 높은 차수를 검열하는 if문
                                if (insertMap.get(item.bidNtceNo) == null || (insertMap.get(item.bidNtceNo) <> null) && Integer.valueOf(insertMap.get(item.bidNtceOrd)) < Integer.valueOf(item.bidNtceOrd)) {
                                    leadObj.LastName = (item.ofclNm == null || item.ofclNm == '') ? item.ntceInsttNm : item.ofclNm;
                                    leadObj.Company = item.ntceInsttNm;
                                    leadObj.Status = 'New';
                                    leadobj.MobilePhone = item.ofclTelNo;
                                    leadObj.Email = item.ofclEmail;
                                    leadObj.LeadSource = 'NaraMarket';
                                    leadObj.BidNoticeStatus__c = item.ntceDivNm;
                                    if (Integer.valueOf(item.bidNtceOrd) < 10) {
                                        Integer ord = Integer.valueOf(item.bidNtceOrd);
                                        leadObj.BidNoticeNumber__c = item.bidNtceNo+'-0'+ String.valueOf(ord);
                                    }else {
                                        leadObj.BidNoticeNumber__c = item.bidNtceNo+'-'+item.bidNtceOrd;
                                    }
                                    leadObj.bidNtceOrd__c = item.bidNtceOrd;
                                    leadObj.BidNoticeName__c = item.ntceNm;
                                    leadObj.BidMethod__c = item.bidMethdNm;
                                    leadObj.ContractSignMethod__c = item.cntrctMthdNm;
                                    leadObj.SubNumber__c = item.bidNtceOrd;
                                    leadObj.IsReBid__c = (item.rbidDivNm == 'Y') ? true : false;
                                    leadObj.BidBeginDateTime__c = (item.bidBeginDt == null || item.bidBeginDt == '') ? null : Datetime.valueOf(item.bidBeginDt);
                                    leadObj.BidOpenDateTime__c = (item.opengDt == null || item.opengDt == '') ? null : Datetime.valueOf(item.opengDt);
                                    leadObj.BidCloseDateTime__c = (item.bidClseDt == null || item.bidClseDt == '') ? null : Datetime.valueOf(item.bidClseDt);
                                    leadObj.BidOpenPlace__c = item.opengPlce;
                                    leadObj.AssignBudgetAmountCurrency__c =  (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                                    leadObj.bsnsDivNm__c = item.bidNtceClsfc;
                                    leadobj.PblancDate__c = item.rgstDt <> null ? Date.valueOf(item.rgstDt) : null;
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
                                    if (operationName == 'getPrvtBidPblancListInfoServcPPSSrch') {
                                        leadObj.bsnsDivNm__c = '민간용역';
                                    }else if (operationName == 'getPrvtBidPblancListInfoThngPPSSrch') {
                                        leadObj.bsnsDivNm__c = '민간물품';
                                    }else if (operationName == 'getPrvtBidPblancListInfoEtcPPSSrch') {
                                        leadObj.bsnsDivNm__c = '민간기타';
                                    }
                                    leadObj.Keyword__c = keywordList[targetIndex].Keyword__c;
                                    leadObj.RecordtypeId = recordId;
                                    for (NaramarketKeyword__mdt keyword : subKeywordList) {
                                        if (item.ntceNm.contains(keyword.Keyword__c)) {
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
        
        IFUtil objIF = new IFUtil('IF_SFDC_DATA_REQ_NARA_TENDER_INFO2');
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
            IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba ba = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba(keywordList, operationName, targetIndex, nextBatchLeadSet);
            Database.executeBatch(ba, 1);
        }
        if(targetIndex == keywordList.size()){
            //지역 참가제한, 면허제한 조회 배치 실행
            if (nextBatchLeadSet <> null && nextBatchLeadSet.size() > 0) {
                IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba b = new IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba(nextBatchLeadSet, 1);
                IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE2_ba b2 = new IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE2_ba(nextBatchLeadSet, 1);
                Database.executeBatch(b,1);
                Database.executeBatch(b2,1);
            }
        }
    }
}