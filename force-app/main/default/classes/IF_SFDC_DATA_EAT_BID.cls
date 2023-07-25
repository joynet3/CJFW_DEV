/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
global with sharing class IF_SFDC_DATA_EAT_BID {
    global IF_SFDC_DATA_EAT_BID() {

    }

    global class Input {
        public Response response;
    }

    global class Response {
        public Header header;
        public Body body;
    }

    global class Header {
        public String resultCode;
        public String resultMsg;
        public String supOrganNm;
        public String supOrganCd;
        public String svcNm;
        public String supDt;
    }

    global class Body {
        public list<Item> items;
        public String numOfRows;
        public String pageNo;
        public String totalCount;
    }

    // global class Items {
    //     public List<Item> item;
    // }

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

    global class Output {
        public Result result;
        public ResultData resultData;
    }

    global class Result {
        public String resultCode;
        public String resultMessage;
    }

    global class ResultData {
    }
    public Output callOut(){
        IFUtil objIf = new IFUtil('IF_SFDC_DATA_EAT_BID');
        Output objOutput = new Output();
        Result objResult = new Result();
        ResultData objResultData = new ResultData();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String result = '';
        String getParameter = '';

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        try {
            IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_EAT_BID'];
            API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '공공데이터_Key'];
            Datetime strDate = system.today().addDays(-60);
            Datetime endDate = system.today();
            getParameter += 'eaTBidList';
            getParameter += '?numOfRows=2000';
            getParameter += '&pageNo=10';
            // getParameter += '&ancmStsrDt=20221004';
            // getParameter += '&ancmEndDt=20221114';
            getParameter += '&ancmStsrDt=' + strDate.format('yyyyMMdd');
            getParameter += '&ancmEndDt=' + endDate.format('yyyyMMdd');
            String encodedString = EncodingUtil.urlEncode('조달청', 'UTF-8');
            getParameter += '&useOrganNm=' + encodedString;
            getParameter += '&useOrganCd=1230000';
            getParameter += '&ServiceKey=' + authKey.KeyValue__c;
            System.debug(getParameter);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ifMasterObj.Endpoint__c + getParameter);
            System.debug(request.getEndpoint());
            request.setHeader('content-type', ifMasterObj.ContentType__c);
            request.setMethod(ifMasterObj.Method__c);
            request.setTimeout(110000);
            HttpResponse res = http.send(request);
            System.debug('res.getStatusCode(): ' + res.getStatusCode());
            if(res.getStatusCode() == 200) {
                String strJSON = XMLParser.xmlToJson(res.getBody());
                LogWrapper.responseBody = strJSON;
                System.debug('=======================calloutResult:::' + strJSON);
                Input input = (Input) JSON.deserialize(strJSON, Input.class);
                System.debug('input: ' + input);
            }
            
            
        } catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
        } finally {
            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = strMessage;
            LogWrapper.responseTime = Datetime.now();

            objResult.resultCode = strCode;
            objResult.resultMessage = strMessage;
            objOutput.result = objResult;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            objIf.setLog(LogWrapper);
        }

        return objOutput;
    }
}