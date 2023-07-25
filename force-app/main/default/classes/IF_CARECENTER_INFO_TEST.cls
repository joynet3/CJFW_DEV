/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 08-10-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
public with sharing class IF_CARECENTER_INFO_TEST {
    public IF_CARECENTER_INFO_TEST() {}

    public class Input{
        public Res response;
    }

    public class Res{
        public Items item;
    }

    public class Items{
        public String sidoname;
        public String sigunname;
        // public String stcode;
        public String crname;
        // public String crtypename;
        // public String crstatusname;
        // public String zipcode;
        // public String craddr;
        // public String crtelno;
        // public String crfaxno;
        // public String crhome;
        // public String nrtrroomcnt;
        // public String nrtrroomsize;
        // public String plgrdco;
        // public String cctvinstlcnt;
        public String chcrtescnt;
        public String crcapat;
        public String crchcnt;
        // public String la;
        // public String lo;
        // public String crcargbname;
        // public String crcnfmdt;
        // public String crpausebegindt;
        // public String crpauseenddt;
        // public String crabldt;
        // public String datastdrdt;
        // public String crspec;
        // public String CLASS_CNT_00;
        // public String CLASS_CNT_01;
        // public String CLASS_CNT_02;
        // public String CLASS_CNT_03;
        // public String CLASS_CNT_04;
        // public String CLASS_CNT_05;
        // public String CLASS_CNT_M2;
        // public String CLASS_CNT_M5;
        // public String CLASS_CNT_SP;
        // public String CLASS_CNT_TOT;
        // public String CHILD_CNT_00;
        // public String CHILD_CNT_01;
        // public String CHILD_CNT_02;
        // public String CHILD_CNT_03;
        // public String CHILD_CNT_04;
        // public String CHILD_CNT_05;
        // public String CHILD_CNT_M2;
        // public String CHILD_CNT_M5;
        // public String CHILD_CNT_SP;
        // public String CHILD_CNT_TOT;
        // public String EM_CNT_0Y;
        // public String EM_CNT_1Y;
        // public String EM_CNT_2Y;
        // public String EM_CNT_4Y;
        // public String EM_CNT_6Y;
        // public String EM_CNT_A1;
        // public String EM_CNT_A2;
        // public String EM_CNT_A3;
        // public String EM_CNT_A4;
        // public String EM_CNT_A5;
        // public String EM_CNT_A6;
        // public String EM_CNT_A10;
        // public String EM_CNT_A7;
        // public String EM_CNT_A8;
        // public String EM_CNT_TOT;
    }

    public class Output {
        public Result result;
    }

    public class Result {
        public String resultCode;
        public String resultMessage;
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
        String getParameter = '';

        try {

            IFMaster__c callOutIf = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_CARECENTER_INFO_TEST'];
            getParameter += '?key=110b97ddc07c433a8af0f727b0e0b1f8';
            getParameter += '&arcode=11110';
            getParameter += '&stcode=';

            System.debug('==============================getParameter:::' + getParameter);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(callOutIf.EndPoint__c + getParameter);
            system.debug(request.getEndpoint());
            request.setHeader('content-type', callOutIf.ContentType__c);
            request.setMethod(callOutIf.Method__c);
            request.setTimeout(110000);

            HttpResponse res = http.send(request);
            if(res.getStatusCode() == 200){
                String strJSON = XMLParser.xmlToJson(res.getBody());
                result = strJSON;
                System.debug('===========================strJSON:::' + strJSON);
                Input input = (Input) JSON.deserialize(strJSON, Input.class);
                result = JSON.serialize(input.response.item);
                System.debug('===========================result item.crname:::' + input.response.item.crname);
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
            LogWrapper.resultMessage = strMessage;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = getParameter;
            LogWrapper.responseBody = result;
            System.debug('===========================finally::: strMessage:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            IFUtil objIF = new IFUtil('IF_CARECENTER_INFO_TEST');
            objIF.setLog(LogWrapper);
        }

        return objOutput;
    }

}