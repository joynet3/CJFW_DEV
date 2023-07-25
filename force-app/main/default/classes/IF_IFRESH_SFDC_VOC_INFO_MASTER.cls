/**
 * @description       : VOC 마스터정보 API
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
@RestResource(urlMapping='/ifresh/voc/master/info')
global with sharing class IF_IFRESH_SFDC_VOC_INFO_MASTER {
    global IF_IFRESH_SFDC_VOC_INFO_MASTER() {}

    global class Input {
        public List<Item> data; 
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last; 
    }

    global class Item {
        public String voc_no;
        public String rcp_rout_cd;
        public String cll_div_cd;
        public String cll_stg_cd;
        public String cust_reqr_nm;
        public String reqr_div_cd;
        public String reqr_nm;
        public String cllr_tel_no;
        public String isu_yn;
        public String isu_cl_cd;
        public String regr_nm;
        public String regr_id;
        public String reg_dt;
        public String updr_nm;
        public String updr_id;
        public String upd_dt;
    }

    global class Output {
        public String err_cd;
        public String err_msg_ctt;
        /*
        public Result result;
        public ResultData resultData;
        */
    }

    global class Result {
        public String resultCode;
        public String resultMessage;
    }

    global class ResultData {
    }

    @HttpPost
    global static Output doPost() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Data has successfully upserted.';

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
            if(requestBody == '' || requestBody == null) {
                strStatus = 'ERROR';
                strCode = '-1';
                strMessage = 'request body value does not exist';
            }else {
                Input input = (Input)JSON.deserialize(requestBody,  Input.class);
                List<IF_IFRESH_SFDC_VOC_INFO_MASTER__c> insertDummyList = new List<IF_IFRESH_SFDC_VOC_INFO_MASTER__c>();

                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'item list is empty';
                }else{
                    for (Item item : input.data) {
                        IF_IFRESH_SFDC_VOC_INFO_MASTER__c objDummy = new IF_IFRESH_SFDC_VOC_INFO_MASTER__c();

                        objDummy.transactionId__c = input.transaction_Id;
                        
                        objDummy.VOC_NO__c = item.voc_no;
                        objDummy.RCP_ROUT_CD__c = item.rcp_rout_cd;
                        objDummy.CLL_DIV_CD__c = item.cll_div_cd;
                        objDummy.CLL_STG_CD__c = item.cll_stg_cd;
                        objDummy.CUST_REQR_NM__c = item.cust_reqr_nm;
                        objDummy.REQR_DIV_CD__c = item.reqr_div_cd;
                        objDummy.REQR_NM__c = item.reqr_nm;
                        objDummy.CLLR_TEL_NO__c = item.cllr_tel_no;
                        objDummy.ISU_YN__c = item.isu_yn;
                        objDummy.ISU_CL_CD__c = item.isu_cl_cd;
                        objDummy.REGR_NM__c = item.regr_nm;
                        objDummy.REGR_ID__c = item.regr_id;
                        objDummy.REG_DT__c = item.reg_dt;
                        objDummy.UPDR_ID__c = item.updr_id;
                        objDummy.UPDR_NM__c = item.updr_nm;
                        objDummy.UPD_DT__c = item.upd_dt;
                        
                        insertDummyList.add(objDummy);
                    }

                    if (insertDummyList <> null && insertDummyList.size() > 0) {
                        insert insertDummyList;
                    }
                }
            }
        } catch(Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       

            System.debug('========================> strMessage : '+strMessage);
        }
        /*
        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        
        objOutput.resultData = resultData;
        objOutput.result = objResult;
        */

        // 2022-11-11 Response 변경
        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;                
        

        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = requestBody;
        LogWrapper.responseBody = JSON.serialize(objOutput);
        
        IFUtil objIF = new IFUtil('IF_IFRESH_SFDC_VOC_INFO_MASTER');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}