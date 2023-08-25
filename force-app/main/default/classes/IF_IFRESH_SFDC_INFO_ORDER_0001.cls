/**
 * @description       : 매출원장정보 API
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/ifresh/sales/ledger/info')
global with sharing class IF_IFRESH_SFDC_INFO_ORDER_0001 {
    global IF_IFRESH_SFDC_INFO_ORDER_0001() {}

    global class Input {
        public List<Item> data;
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last;
    }

    global class Item {
        public String sales_ymd;
        public String sales_lnkg_cl_cd;
        public String sales_lnkg_cl_nm;
        public String ordr_no;
        public String bili_doc_no;
        public String slst_id;
        public String cust_nm;
        public String mngplc_id;
        public String mngplc_nm;
        public String slbz_org_id;
        public String div_id;
        public String div_nm;
        public String brc_id;
        public String brc_nm;
        public String crg_ma_id;
        public String crg_ma_nm;
        public String crg_sma_id;
        public String crg_sma_nm;
        public String schl_cd;
        public String schl_nm;
        public String sply_ctr_id;
        public String sply_ctr_nm;
        public String shiplc_id;
        public String shiplc_nm;
        public String lar_gd_cls_id;
        public String mid_gd_cls_id;
        public String sml_gd_cls_id;
        public String isliq;
        public String gd_no;
        public String gd_nm;
        public String gd_cls_id;
        public String pb_gd_cl_cd_nm;
        public String pb_gd_cl_cd;
        public String barcd_no;
        public String bcnr_id;
        public String bcnr_nm;
        public String dstr_his_no_rpt_obj_yn_nm;
        public String dstr_his_mng_yn_nm;
        public String dstr_his_no;
        public String bl_no;
        public String taxt_cl_cd_nm;
        public String rlstk_unit_rlstk_qty;
        public String rlstk_unit_rlstk_qty_kg;
        public String box_ctcnt_qty;
        public String rlstk_unit_cd_nm;
        public String rlstk_unit;
        public String real_buy_unprc;
        public String opt_unprc;
        public String ordr_real_buy_unprc;
        public String ordr_opt_unprc;
        public String sale_unprc;
        public String sales_at;
        public String sales_tat;
        public String sales_sum_at;
        public String sales_p_rt;
        public String sap_err_msg;
        public String bas_unit_cd;
        public String bas_unit;
        public String bas_tkstk_qty;
        public String reg_dt;
        public String upd_dt;
        public String ordr_dtl_no;
        public String sales_seq;
        public String sales_vat_seq;
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
                Input input = (input)JSON.deserialize(requestBody,  Input.class);
                List<SalesLedgerInformation__c> upsertObjList = new List<SalesLedgerInformation__c>();
                List<IF_IFRESH_SFDC_INFO_ORDER_0001__c> insertDummyList = new List<IF_IFRESH_SFDC_INFO_ORDER_0001__c>();
                
                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'item list is empty';
                }else {
                    for (Item item : input.data) {
                        IF_IFRESH_SFDC_INFO_ORDER_0001__c objDummy = new IF_IFRESH_SFDC_INFO_ORDER_0001__c();
                        objDummy.transactionId__c = input.transaction_Id;
                        objDummy.sales_ymd__c = item.sales_ymd;
                        objDummy.sales_lnkg_cl_cd__c = item.sales_lnkg_cl_cd;
                        objDummy.sales_lnkg_cl_nm__c = item.sales_lnkg_cl_nm;
                        objDummy.ordr_no__c = item.ordr_no;
                        objDummy.bili_doc_no__c = item.bili_doc_no;
                        objDummy.slst_id__c = item.slst_id;
                        objDummy.cust_nm__c = item.cust_nm;
                        objDummy.mngplc_id__c = item.MNGPLC_ID;
                        objDummy.mngplc_nm__c = item.MNGPLC_NM;
                        objDummy.slbz_org_id__c = item.slbz_org_id;
                        objDummy.div_id__c = item.div_id;
                        objDummy.div_nm__c = item.div_nm;
                        objDummy.brc_id__c = item.brc_id;
                        objDummy.brc_nm__c = item.brc_nm;
                        objDummy.crg_ma_id__c = item.crg_ma_id;
                        objDummy.crg_ma_nm__c = item.crg_ma_nm;
                        objDummy.crg_sma_id__c = item.crg_sma_id;
                        objDummy.crg_sma_nm__c = item.crg_sma_nm;
                        objDummy.schl_cd__c = item.schl_cd;
                        objDummy.schl_nm__c = item.schl_nm;
                        objDummy.sply_ctr_id__c = item.sply_ctr_id;
                        objDummy.sply_ctr_nm__c = item.sply_ctr_nm;
                        objDummy.shiplc_id__c = item.shiplc_id;
                        objDummy.shiplc_nm__c = item.shiplc_nm;                        
                        objDummy.lar_gd_cls_id__c = item.lar_gd_cls_id;
                        objDummy.mid_gd_cls_id__c = item.mid_gd_cls_id;
                        objDummy.sml_gd_cls_id__c = item.sml_gd_cls_id;
                        objDummy.isliq__c = item.isliq;
                        objDummy.gd_no__c = item.gd_no;
                        objDummy.gd_nm__c = item.gd_nm;
                        objDummy.gd_cls_id__c = item.gd_cls_id;
                        objDummy.pb_gd_cl_cd_nm__c = item.pb_gd_cl_cd_nm;
                        objDummy.pb_gd_cl_cd__c = item.pb_gd_cl_cd;
                        objDummy.BARCD_NO__c = item.barcd_no;
                        objDummy.BCNR_ID__c = item.bcnr_id;
                        objDummy.BCNR_NM__c = item.bcnr_nm;
                        objDummy.dstr_his_no_rpt_obj_yn_nm__c = item.dstr_his_no_rpt_obj_yn_nm;
                        objDummy.dstr_his_mng_yn_nm__c = item.dstr_his_mng_yn_nm;
                        objDummy.dstr_his_no__c = item.dstr_his_no;
                        objDummy.bl_no__c = item.bl_no;
                        objDummy.taxt_cl_cd_nm__c = item.taxt_cl_cd_nm;
                        objDummy.rlstk_unit_rlstk_qty__c = item.rlstk_unit_rlstk_qty;
                        objDummy.rlstk_unit_rlstk_qty_kg__c = item.rlstk_unit_rlstk_qty_kg;
                        objDummy.box_ctcnt_qty__c = item.box_ctcnt_qty;
                        objDummy.rlstk_unit_cd_nm__c = item.rlstk_unit_cd_nm;
                        objDummy.real_buy_unprc__c = item.real_buy_unprc;
                        objDummy.opt_unprc__c = item.opt_unprc;
                        objDummy.ordr_real_buy_unprc__c = item.ordr_real_buy_unprc;
                        objDummy.ordr_opt_unprc__c = item.ordr_opt_unprc;
                        objDummy.sale_unprc__c = item.sale_unprc;
                        objDummy.sales_at__c = item.sales_at;
                        objDummy.sales_tat__c = item.sales_tat;
                        objDummy.sales_sum_at__c = item.sales_sum_at;
                        objDummy.sales_p_rt__c = item.sales_p_rt;
                        objDummy.sap_err_msg__c = item.sap_err_msg;
                        objDummy.bas_unit_cd__c = item.bas_unit_cd;
                        objDummy.bas_tkstk_qty__c = item.bas_tkstk_qty;

                        objDummy.REG_DT__c = item.reg_dt;
                        objDummy.UPD_DT__c = item.upd_dt;
                        objDummy.ORDR_DTL_NO__c = item.ordr_dtl_no;
                        objDummy.sales_seq__c = item.sales_seq;
                        objDummy.sales_vat_seq__c = item.sales_vat_seq;


                        insertDummyList.add(objDummy);
                    }

                    if (insertDummyList <> null && insertDummyList.size() > 0) {
                        insert insertDummyList;
                        
                        if (Boolean.valueOf(input.is_last) == true) {
                            IF_IFRESH_SFDC_INFO_ORDER_0001_ba ba = new IF_IFRESH_SFDC_INFO_ORDER_0001_ba(input.transaction_Id);
                            Database.executeBatch(ba, 200);
                        }
                    }
                }
            }
        }catch(Exception e) {
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
        
        IFUtil objIF = new IFUtil('IF_IFRESH_SFDC_INFO_ORDER_0001');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}