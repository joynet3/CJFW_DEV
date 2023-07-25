/**
 * @description       : VOC 조치 이력 API
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/ifresh/voc/comment/info')
global with sharing class IF_IFRESH_SFDC_VOC_INFO_COMMENT {
    global IF_IFRESH_SFDC_VOC_INFO_COMMENT() {}

    global class Input {
        public List<Item> data; 
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last; 
    }

    global class Item {
        public String voc_no;
        public String prs_bd_no;
        public String prs_dt;
        public String prsr_nm;
        public String prsr_emp_no;
        public String prs_cl_nm;
        public String prs_cl_cd;
        public String prs_txt_nm;
        public String prs_txt_cd;
        public String dlwr_nm;
        public String bcnr_opn_yn;
        public String txt;
        public String reg_dt;
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

        /*
        Result objResult = new Result();
        ResultData resultData = new ResultData();
        */

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
                List<IF_IFRESH_SFDC_VOC_INFO_COMMENT__c> insertDummyList = new List<IF_IFRESH_SFDC_VOC_INFO_COMMENT__c>();
                /*
                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'data list is empty';
                }else{ 
                    for (Item item : input.data) {
                        IF_IFRESH_SFDC_VOC_INFO_COMMENT__c obj = new IF_IFRESH_SFDC_VOC_INFO_COMMENT__c();

                        obj.transactionId__c = input.transaction_Id;
                        obj.VOC_NO__c = item.voc_no;
                        obj.PRS_BD_NO__c = item.prs_bd_no;
                        obj.PRS_DT__c = item.prs_dt;
                        obj.PRSR_NM__c = item.prsr_nm;
                        obj.PRSR_EMP_NO__c = item.prsr_emp_no;
                        obj.PRS_CL_CD__c = item.prs_cl_cd;
                        obj.PRS_TXT_CD__c = item.prs_txt_cd;
                        obj.DLWR_NM__c = item.dlwr_nm;
                        obj.BCNR_OPN_YN__c = item.bcnr_opn_yn;
                        obj.TXT__c = item.txt;
                        obj.REG_DT__c = item.reg_dt;
                        obj.UPD_DT__c = item.upd_dt;
                        insertDummyList.add(obj);
                    }
                }
                */

                if(input.data <> null) {
                    for (Item item : input.data) {
                        IF_IFRESH_SFDC_VOC_INFO_COMMENT__c obj = new IF_IFRESH_SFDC_VOC_INFO_COMMENT__c();
    
                        obj.transactionId__c = input.transaction_Id;
                        obj.VOC_NO__c = item.voc_no;
                        obj.PRS_BD_NO__c = item.prs_bd_no;
                        obj.PRS_DT__c = item.prs_dt;
                        obj.PRSR_NM__c = item.prsr_nm;
                        obj.PRSR_EMP_NO__c = item.prsr_emp_no;
                        obj.PRS_CL_CD__c = item.prs_cl_cd;
                        obj.PRS_TXT_CD__c = item.prs_txt_cd;
                        obj.DLWR_NM__c = item.dlwr_nm;
                        obj.BCNR_OPN_YN__c = item.bcnr_opn_yn;
                        obj.TXT__c = item.txt;
                        obj.REG_DT__c = item.reg_dt;
                        obj.UPD_DT__c = item.upd_dt;

                        insertDummyList.add(obj);
                    }
                }

                if(insertDummyList <> null && insertDummyList.size() > 0) {
                    insert insertDummyList;
                }

                if(Boolean.valueOf(input.is_last)) {
                    IF_IFRESH_SFDC_VOC_INFO_MASTER_ba ba = new IF_IFRESH_SFDC_VOC_INFO_MASTER_ba(input.transaction_Id);
                    Database.executeBatch(ba, 200);
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
        
        IFUtil objIF = new IFUtil('IF_IFRESH_SFDC_VOC_INFO_COMMENT');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}