/**
 * @description       : 나라장터 업종제한 api 조회
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global without sharing class IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba implements Database.Batchable<Lead>, Database.Stateful, Database.AllowsCallouts {
    
    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE'];
    API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where DeveloperName = 'Data_Key'];
    
    global Set<Id> joinLeadIdSet = new Set<Id>();
    Set<Id> overLeadIdSet = new Set<Id>();
    Set<Id> failLeadIdSet = new Set<Id>();
    Integer pageNo = 1;
    Integer totalPageno = 0;

    global IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba(Set<Id> joinLeadIdSet, Integer pageNo) {
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
        public String lmtGrpNo;
        public String lmtSno;
        public String lcnsLmtNm;
        public String permsnIndstrytyList;
        public String rgstDt;
        public String d2bMngDmndYear;
        public String d2bMngCnstwkNo;
        public String bsnsDivNm;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 나라장터 Lead 조회
    ************************************************************************************************************/
    global Iterable<Lead> start(Database.BatchableContext bc) {
        List<Lead> updateLeadList = [
            SELECT Id, prtcptPsblRgnNm__c, lmtGrpNo__c, lmtSno__c, lcnsLmtNm__c, permsnIndstrytyList__c, bsnsDivNm__c, BidNoticeNumber__c, bidNtceOrd__c
            FROM Lead
            WHERE Id IN :joinLeadIdSet
        ];

        failLeadIdSet.clear();
        return updateLeadList;
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 나라장터 업종제한 API 호출 및 Lead update
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        
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
        
        getRquest += '/getBidPblancListInfoLicenseLimit';
        getRquest += '?inqryDiv=2';
        getRquest += '&type=json';
        getRquest += '&bidNtceNo=' + EncodingUtil.urlEncode((scope[0].BidNoticeNumber__c).substringBeforeLast('-'), 'UTF-8');
        if (Integer.valueOf(scope[0].bidNtceOrd__c) < 10) {
            Integer ord = Integer.valueOf(scope[0].bidNtceOrd__c);
            getRquest += '&bidNtceOrd=0' + String.valueOf(ord);
        }else {
            getRquest += '&bidNtceOrd=' + scope[0].bidNtceOrd__c;
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
                        scope[0].lmtGrpNo__c = item.lmtGrpNo;
                        scope[0].lmtSno__c = item.lmtSno;
                        scope[0].lcnsLmtNm__c = item.lcnsLmtNm;
                        scope[0].permsnIndstrytyList__c = item.permsnIndstrytyList;
                        // scope[0].bsnsDivNm__c = item.bsnsDivNm;
                    }

                    if (this.totalPageno > 1 && this.pageNo <= this.totalPageno) {
                        overLeadIdSet.add(scope[0].Id);
                    }
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
        
        IFUtil objIF = new IFUtil('IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE');
        objIF.setLog(LogWrapper);
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 나라장터 업종제한 다음 Lead 재호출
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('=============================:::batch finish');
        if (this.totalPageno > 1 && this.pageNo <= this.totalPageno) {
            this.pageNo++;
            IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba ba = new IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba(this.overLeadIdSet, this.pageNo);
            Database.executeBatch(ba, 1);
        }
        system.debug(failLeadIdSet);
        if (failLeadIdSet.size() > 0) {
            IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba ba = new IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba(this.failLeadIdSet, 1);
            Database.executeBatch(ba, 1);
        }
        system.debug(joinLeadIdSet);
        IF_SFDC_DATA_REQ_NARA_TENDER_RERT_ba ba = new IF_SFDC_DATA_REQ_NARA_TENDER_RERT_ba(joinLeadIdSet, 1);
        Database.executeBatch(ba, 1);
    }
}