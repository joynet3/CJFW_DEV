/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 10-11-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
@RestResource(urlMapping='/api/test')
global with sharing class IF_API_CALL_TEST {
    public IF_API_CALL_TEST() {}

    global class Input {
        public String today;
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
        public String callResult;
    }

    @HttpPost
    global static Output doPost() {

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Success called';

        Result objResult = new Result();
        ResultData resultData = new ResultData();

        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String requestBody = '';

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            LogWrapper.requestBody = requestBody;      

            if(requestBody == '' || requestBody == null){
                strStatus = 'ERROR';
                strCode = '-1';
                strMessage = 'request body value does not exist';
            }else {
                Input input = (input)JSON.deserialize(requestBody,  Input.class);
                if (input.today == null || input.today == '') {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'data value is empty';
                }else {
                    Date chkToday = System.today();
                    if (Date.valueOf(input.today) == chkToday) {
                        resultData.callResult = '호출 정상';
                    }
                }
            }
        } catch(Exception e) {

            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       

            System.debug('========================> strMessage : '+strMessage);
        }

        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        
        objOutput.resultData = resultData;
        objOutput.result = objResult;
        

        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = requestBody;
        LogWrapper.responseBody = JSON.serialize(objOutput);
        
        IFUtil objIF = new IFUtil('IF_API_CALL_TEST');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}