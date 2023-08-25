/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
public with sharing class IF_API_NARA_TENDER_INFO_TEST {
    public IF_API_NARA_TENDER_INFO_TEST() {}
    public class Input{
        public Res response;
    }

    public class Output {
        public Result result;
    }

    public class Result {
        public String resultCode;
        public String resultMessage;
        public List<Items> resultItems;
    }

    public class Res{
        public Body body;
    }

    public class Body{
        public String totalCount;
        public String pageNo;
        public String numOfRows;
        public List<Items> items;
    }

    public class Items{
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
    }
    public Output callOut(){
        Result objResult = new Result();
        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();


        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String result = '';
        String getRquest = '';
        String today = String.valueOf(Datetime.now().format('yyyyMMdd')) + '0000';
        Datetime endDt = Datetime.now();
        System.debug('=====================today:::'+today);
        
        try {
            IFMaster__c i = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_API_NARA_TENDER_INFO_TEST'];
            API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '공공데이터_Key'];
            endDt += Integer.valueof(authKey.DateRange__c);
            System.debug('==================enddt:::' + endDt.format('yyyyMMdd'));

            getRquest += '/getBidPblancListInfoThngPPSSrch';
            getRquest += '?inqryDiv=2';
            getRquest += '&type=json';
            getRquest += '&inqryBgnDt=' + today;
            getRquest += '&inqryEndDt=' + endDt.format('yyyyMMdd')+'0000';
            String encodedString = EncodingUtil.urlEncode('식자재', 'UTF-8');
            System.debug('=====================encodedString:::'+encodedString);
            getRquest += '&bidNtceNm=' + encodedString;
            getRquest += '&pageNo=1';
            getRquest += '&numOfRows=500';
            getRquest += '&ServiceKey=' + authKey.KeyValue__c;
            System.debug('======================getRquest:::' + getRquest);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(i.Endpoint__c + getRquest);
            request.setHeader('content-type', i.ContentType__c);
            request.setMethod(i.Method__c);
            request.setTimeout(110000);
            HttpResponse res = http.send(request);

            if(res.getStatusCode() == 200) {
                // System.debug('=============================getbody:::' + res.getBody());
                result = res.getBody();
                Input input = (Input) JSON.deserialize(res.getBody(), Input.class);
                result = String.valueof(input);
                System.debug('==========================totalCount:::'+input.response.body.totalCount);
                for (Items item : input.response.body.items) {
                    System.debug('======================item:::'+ item);
                }
                objResult.resultItems = input.response.body.items;
            }else {
                strCode = '-1';
                strStatus = 'ERROR';
                strMessage = 'httpcallout error';
            }

        } catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
        } finally {
            objResult.resultCode = strCode;
            objResult.resultMessage = strMessage;
            
            objOutput.result = objResult;

            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'strMessage:::' + strMessage;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = getRquest;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            IFUtil objIF = new IFUtil('IF_API_NARA_TENDER_INFO_TEST');
            objIF.setLog(LogWrapper);
        }
        return objOutput;
    }
}