
@RestResource(urlMapping='/ifresh/ord/dataselect')
global without sharing class INF_TEST_REST_SELECT {
    global IFN_TEST_REST() {}

    global class Input {
        public String schttl {get;set;}
        public String stDt {get;set;}
        public String edDt {get;set;}
        public String dataCnt {get;set;}
        public String pgNo {get;set;}
        public String mdmCd {get;set;}
    }


    global class Output {
        public String err_cd;
        public String err_msg_ctt;
    }
    


    
    @HttpPost
    global static Output doPost() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Data has successfully upserted.';

        String interfaceId = 'IF_SFDC_EACCT_INQ_OIL_AMOUNT';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();

    

        Output objOutput = new Output();
        


        String requestBody = '';

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            logWrap.requestBody = requestBody;   

            if(requestBody == '' || requestBody == null) {
                strStatus = 'ERROR';
                strCode = '-1';
                strMessage = 'request body value does not exist';
                logWrap.ErrorCode = 'strStatus';
                logWrap.ErrorText.add(strMessage);
            }else {

                List<testIfData__c> upsertData = new List<testIfData__c>();
                Input input = (Input)JSON.deserialize(requestBody,  Input.class);
                for (Item item : input.data) {
                    testIfData__c objDummy = new testIfData__c();
                    objDummy.testData1__c = item.testData1;
                    objDummy.testData2__c = item.testData2;
                    upsertData.add(objDummy);
                }
                logWrap.LogText.add(Json.serialize(upsertData));
                upsert upsertData;


            }
        } catch(Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       

            System.debug('========================> strMessage : '+strMessage);
        }

        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strStatus;
        commlog.insertLog(logWrap);

        return objOutput;
        
    }

}