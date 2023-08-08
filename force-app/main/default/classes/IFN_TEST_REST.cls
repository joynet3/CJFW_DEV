/**
 * @Class : IFN_TEST_REST.cls
 * @group Framework : test Rest 프로그램
 * @Author : 조일근
 * @Date : 2023-08-07
 * @Version : 1.0
 * @Description : 
 * @Modified : 조일근
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.07 |  조일근          | 최초작성
 * */
@RestResource(urlMapping='/ifresh/voc/detail/test')
global without sharing class IFN_TEST_REST {
    global IFN_TEST_REST() {}

    global class Input {
        public List<Item> data; 
        public String transaction_Id;
    }

    global class Item {
        public String testData1;
        public String testData2;
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