/**
 * @description       : 민간 공고 지역참가 제한 api Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
 * 
 * @last modified on  : 10-20-2023
 * @last modified by  : sancho : Lead -> CJFW_BiddingInformation__c
**/
global without sharing class IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba implements Database.Batchable<CJFW_BiddingInformation__c>, Database.Stateful, Database.AllowsCallouts{
    
    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_NARA_TENDER_RERT2'];
    API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where DeveloperName = 'Data_Key'];

    global Set<Id> joinLeadIdSet = new Set<Id>();
    Set<Id> overLeadIdSet = new Set<Id>();
    Set<Id> failLeadIdSet = new Set<Id>();
    Integer pageNo = 1;
    Integer totalPageno = 0;

    global IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba(Set<Id> joinLeadIdSet, Integer pageNo) {
        this.joinLeadIdSet = joinLeadIdSet;
        this.pageNo = pageNo;
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
        public List<Item> items;
    }

    global class Item{
        public String bidNtceNo;
        public String bidNtceOrd;
        public String lmtSno;
        public String prtcptPsblRgnNm;
        public String rgstDt;
        public String d2bMngDmndYear;
        public String d2bMngDcsnNo;
        public String d2bMngCnstwkNo;
        public String bsnsDivNm;
    }

    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 나라장터 CJFW_BiddingInformation__c 조회
    ************************************************************************************************************/
    global Iterable<CJFW_BiddingInformation__c> start(Database.BatchableContext bc) {
        List<CJFW_BiddingInformation__c> updateLeadList = [
            SELECT Id, prtcptPsblRgnNm__c, BidNoticeNumber__c, SubNumber__c
            FROM CJFW_BiddingInformation__c
            WHERE Id IN :joinLeadIdSet
        ];
        System.debug('=============================:::batch start');
        failLeadIdSet.clear();
        return updateLeadList;
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 나라장터 지역참가제한 API 호출 및 Lead update
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<CJFW_BiddingInformation__c> scope) {
        
        String result = '';
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String getRquest = '';
        Boolean saveBool = false;
        String insertprtc = '';
        List<String> errList = new List<String>();

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        
        getRquest += '/getPrvtBidPblancListInfoPrtcptPsblRgn';
        getRquest += '?inqryDiv=2';
        getRquest += '&type=json';
        getRquest += '&bidNtceNo=' + EncodingUtil.urlEncode((scope[0].BidNoticeNumber__c).substringBeforeLast('-'), 'UTF-8');
        if (Integer.valueOf(scope[0].SubNumber__c) < 10) {
            Integer ord = Integer.valueOf(scope[0].SubNumber__c);
            getRquest += '&bidNtceOrd=0' + String.valueOf(ord);
        }else {
            getRquest += '&bidNtceOrd=' + scope[0].SubNumber__c;
        }
        getRquest += '&pageNo='+pageNo;
        getRquest += '&numOfRows=200';
        getRquest += '&ServiceKey=' + authKey.KeyValue__c;
        System.debug('======================getRquest:::' + getRquest);
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ifMasterObj.Endpoint__c + getRquest);
            request.setHeader('content-type', ifMasterObj.ContentType__c);
            request.setMethod(ifMasterObj.Method__c);
            request.setTimeout(110000);
            HttpResponse res = http.send(request);
            result = res.getBody();

            if(res.getStatusCode() == 200) {
                Input input = (Input) JSON.deserialize(res.getBody(), Input.Class);
                System.debug('==========================input:::'+ input);
            
                if (input.response.body.totalCount != '0' && input.response.body.items <> null) {
                    /** 삽입할 레코드 리스트 생성 시작 */
                    this.totalPageno = Integer.valueOf(input.response.body.totalCount) / Integer.valueOf(input.response.body.numOfRows);
                    for (Item item : input.response.body.items) {
                        insertprtc += item.prtcptPsblRgnNm;
                    }
                    if (this.totalPageno > 1 && this.pageNo <= this.totalPageno) {
                        overLeadIdSet.add(scope[0].Id);
                    }
                    scope[0].prtcptPsblRgnNm__c = insertprtc;
                    saveBool = true;
                }
            }
        } catch(Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
            failLeadIdSet.add(scope[0].Id);
        }

        if (saveBool) {
            update scope[0];
        }

        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = getRquest;
        LogWrapper.responseBody = result;
        
        IFUtil objIF = new IFUtil('IF_SFDC_DATA_REQ_NARA_TENDER_RERT2');
        objIF.setLog(LogWrapper);
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 나라장터 지역참가제한 다음 Lead 재호출
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('=============================:::batch finish');
        if (this.totalPageno > 1 && this.pageNo <= this.totalPageno) {
            this.pageNo++;
            IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba ba = new IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba(this.overLeadIdSet, this.pageNo);
            Database.executeBatch(ba, 1);
        }
        if (failLeadIdSet.size() > 0) {
            IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba ba = new IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba(this.failLeadIdSet, 1);
            Database.executeBatch(ba, 1);
        }
    }
}