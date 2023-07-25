/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
public with sharing class IF_API_NARAMARKET_TEST {
    public IF_API_NARAMARKET_TEST() {}

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
        public String chgDt;
        public String rgstDt;
        public String toplvlInsttNm;
        public String toplvlInsttCd;
        public String dltYn;
        public String hmpgAdrs;
        public String faxNo;
        public String telNo;
        public String dtlAdrs;
        public String adrs;
        public String zip;
        public String rgnNm;
        public String rgnCd;
        public String ofclFaxNo;
        public String indstrytyNm;
        public String bizcndtnNm;
        public String insttTyCdSmlclsfcNm;
        public String insttTyCdMidclsfcNm;
        public String insttTyCdLrgclsfcNm;
        public String jrsdctnDivNm;
        public String bizno;
        public String corprtRgstNo;
        public String dminsttEngNm;
        public String dminsttAbrvtNm;
        public String dminsttNm;
        public String vldPrdEndDt;
        public String vldPrdBgnDt;
        public String dminsttCd;
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
        String body = '';

        try {
            IFMaster__c naraMarketIf = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_API_NARAMARKET_TEST'];
            API_Authenticationkey__mdt authKey = [select KeyValue__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '공공데이터_Key'];
            body += ('?inqryDiv=1'); /*검색하고자하는 조회구분 입력 1: 등록일기준 검색, 2: 변경일기준 검색, 3: 사업자등록번호 기준검색*/
            body += ('&inqryBgnDt=201605010000'); /*검색하고자하는 검색기준시작일시 입력 */
            body += ('&inqryEndDt=201605052359'); /*검색하고자하는 검색기준종료일시 입력 */
            body += ('&pageNo=1'); /*페이지 번호*/
            body += ('&numOfRows=100'); /*한 페이지 결과 수*/
            // body += ('&dminsttCd=9111117'); /*검색하고자하는 수요기관코드 조회구분 1,2인 경우 선택*/
            // body += ('&dminsttNm=경상남도교육청 경상남도거제교육지원청 거제장평중학교'); /*검색하고자하는 수요기관명 조회구분 1,2인 경우 선택*/
            // body += ('&bizno=6128306057'); /*검색하고자하는 사업자등록번호 조회구분 3인 경우 필수*/
            body += ('&type=json'); /*오픈API 리턴 타입을 JSON으로 받고 싶을 경우 'json' 으로 지정함*/
            body += ('&serviceKey='+authKey.KeyValue__c); /*Service Key*/
    
            System.debug('======================:::body' + body);
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(naraMarketIf.Endpoint__c + body);
            request.setHeader('content-type', naraMarketIf.ContentType__c);
            request.setMethod(naraMarketIf.Method__c);
    
            HttpResponse res = http.send(request);
            if(res.getStatusCode() == 200) {
                // System.debug('=============================getbody:::' + res.getBody());
                Input input = (Input) JSON.deserialize(res.getBody(), Input.class);
                result = String.valueof(input);
                System.debug('==========================totalCount:::'+input.response.body.totalCount);
                for (Integer i = 0; i < input.response.body.items.size(); i++) {
                    System.debug('=========================items['+i+']:::' + input.response.body.items[i]);
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
        } finally{
            objResult.resultCode = strCode;
            objResult.resultMessage = strMessage;
            
            objOutput.result = objResult;

            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'strMessage:::' + strMessage;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = body;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            IFUtil objIF = new IFUtil('IF_API_NARAMARKET_TEST');
            objIF.setLog(LogWrapper);
        }
        return objOutput;
    }
}