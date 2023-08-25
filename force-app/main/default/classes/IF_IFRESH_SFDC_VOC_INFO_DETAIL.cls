/**
 * @description       : VOC 항목 API
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/ifresh/voc/detail/info')
global without sharing class IF_IFRESH_SFDC_VOC_INFO_DETAIL {
    global IF_IFRESH_SFDC_VOC_INFO_DETAIL() {}

    global class Input {
        public List<Item> data; 
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last; 
    }

    global class Item {
        public String voc_no;
        public String voc_dtl_no;
        public String voc_prg_nm;
        public String voc_prg_cd;
        public String dlv_ymd;
        public String occr_ymd;
        public String mngplc_nm;
        public String mngplc_id;
        public String gd_no;
        public String gd_bd;
        public String migr_orinat_nm;
        public String ordr_unit_cd;
        public String ordr_qty;
        public String dlv_qty;
        public String voc_unit_cd;
        public String voc_qty;
        public String rtn_nfxat_box_qty;
        public String sale_prc;
        public String voc_lcls_id;
        public String voc_mcls_id;
        public String voc_dcls_id;
        public String rqrm_cd;
        public String prs_txt_cd;
        public String menu_txt;
        public String impt_dept_div_cd;
        public String chg_rsn;
        public String blng_dept_div_cd;
        public String real_yn;
        public String norm_yn;
        public String lgs_actn_rslt_cd;
        public String dstfd_div_cd;
        public String dstr_tlmt_ymd;
        public String mnf_ymd;
        public String dstr_his_no;
        public String rtn_req_ymd;
        public String rtn_cfm_ymd;
        public String ordr_no;
        public String ordr_dtl_no;
        public String voc_scls_id;
        public String voc_rsn_no;
        public String voc_dtl_txt;
        public String reg_dt;
        public String regr_id;
        public String upd_dt;
        public String updr_id;
        public String slst_nm;
        public String slst_id;
        public String lotn_dtl_addr;
        public String sma_emp_hpno;
        public String brc_nm;
        public String brc_id;
        public String nutr_emp_nm;
        public String nutr_emp_id;
        public String gend_cd;
        public String age;
        public String ma_emp_nm;
        public String ma_emp_id;
        public String nutr_emp_hpno;
        public String cust_reqr_nm;
        public String ma_emp_hpno;
        public String crgr_div_cd;
        public String cust_reqr_tel_no;
        public String sma_emp_nm;
        public String sma_emp_id;
        public String slf_prs_yn;
        public String mnfco_nm;
        public String mnf_no;
        public String bcnr_nm;
        public String bcnr_id;
        public String gd_nm;
        public String bcnr_voc_tel_no;
        public String bcnr_sted_txt;
        public String bcnr_voc_crgr_nm;
        public String impt_vgu_yn;
        public String md_emp_nm;
        public String md_emp_id;
        public String gd_div_cd;
        public String md_emp_hpno;
        public String img_file_url1;
        public String img_file_url2;
        public String img_file_url3;
        public String shpto_addr;
        public String mngplc_addr;
        public String shpto_id;
        public String shpto_nm;
        public String lgs_ctr_id;

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
                List<IF_IFRESH_SFDC_VOC_INFO_DETAIL__c> insertDummyList = new List<IF_IFRESH_SFDC_VOC_INFO_DETAIL__c>();
                // Set<String> productCodeSet = new Set<String>();

                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'item list is empty';
                }else{
                    for (Item item : input.data) {
                        IF_IFRESH_SFDC_VOC_INFO_DETAIL__c objDummy = new IF_IFRESH_SFDC_VOC_INFO_DETAIL__c();
                        objDummy.transactionId__c = input.transaction_Id;
                        objDummy.VOC_NO__c = item.voc_no;
                        objDummy.VOC_DTL_NO__c = item.voc_dtl_no;
                        objDummy.VOC_PRG_NM__c = item.voc_prg_nm;
                        objDummy.VOC_PRG_CD__c = item.voc_prg_cd;
                        objDummy.DLV_YMD__c = item.dlv_ymd;
                        objDummy.OCCR_YMD__c = item.occr_ymd;
                        objDummy.MNGPLC_NM__c = item.mngplc_nm;
                        objDummy.MNGPLC_ID__c = item.mngplc_id;
                        objDummy.GD_NO__c = item.gd_no;
                        objDummy.GD_BD__c = item.gd_bd;
                        objDummy.MIGR_ORINAT_NM__c = item.migr_orinat_nm;
                        objDummy.ORDR_UNIT_CD__c = item.ordr_unit_cd;
                        objDummy.ORDR_QTY__c = item.ordr_qty;
                        objDummy.DLV_QTY__c = item.dlv_qty;
                        objDummy.VOC_UNIT_CD__c = item.voc_unit_cd;
                        objDummy.VOC_QTY__c = item.voc_qty;
                        objDummy.RTN_NFXAT_BOX_QTY__c = item.rtn_nfxat_box_qty;
                        objDummy.SALE_PRC__c = item.sale_prc;
                        objDummy.VOC_LCLS_ID__c = item.voc_lcls_id;
                        objDummy.VOC_MCLS_ID__c = item.voc_mcls_id;
                        objDummy.VOC_DCLS_ID__c = item.voc_dcls_id;
                        objDummy.RQRM_CD__c = item.rqrm_cd;
                        objDummy.PRS_TXT_CD__c = item.prs_txt_cd;
                        objDummy.MENU_TXT__c = item.menu_txt;
                        objDummy.IMPT_DEPT_DIV_CD__c = item.impt_dept_div_cd;
                        objDummy.CHG_RSN__c = item.chg_rsn;
                        objDummy.BLNG_DEPT_DIV_CD__c = item.blng_dept_div_cd;
                        objDummy.REAL_YN__c = item.real_yn;
                        objDummy.NORM_YN__c = item.norm_yn;
                        objDummy.LGS_ACTN_RSLT_CD__c = item.lgs_actn_rslt_cd;
                        objDummy.dstfd_div_cd__c = item.dstfd_div_cd;
                        objDummy.DSTR_TLMT_YMD__c = item.dstr_tlmt_ymd;
                        objDummy.MNF_YMD__c = item.mnf_ymd;
                        objDummy.DSTR_HIS_NO__c = item.dstr_his_no;
                        objDummy.RTN_REQ_YMD__c = item.rtn_req_ymd;
                        objDummy.RTN_CFM_YMD__c = item.rtn_cfm_ymd;
                        objDummy.ORDR_NO__c = item.ordr_no;
                        objDummy.ORDR_DTL_NO__c = item.ordr_dtl_no;
                        objDummy.VOC_SCLS_ID__c = item.voc_scls_id;
                        objDummy.VOC_RSN_NO__c = item.voc_rsn_no;
                        objDummy.VOC_DTL_TXT__c = item.voc_dtl_txt;
                        objDummy.REG_DT__c = item.reg_dt;
                        objDummy.REGR_ID__c = item.regr_id;
                        objDummy.UPD_DT__c = item.upd_dt;
                        objDummy.UPDR_ID__c = item.updr_id;
                        objDummy.SLST_NM__c = item.slst_nm;
                        objDummy.SLST_ID__c = item.slst_id;
                        objDummy.LOTN_DTL_ADDR__c = item.lotn_dtl_addr;
                        objDummy.SMA_EMP_HPNO__c = item.sma_emp_hpno;
                        objDummy.BRC_NM__c = item.brc_nm;
                        objDummy.BRC_ID__c = item.brc_id;
                        objDummy.NUTR_EMP_NM__c = item.nutr_emp_nm;
                        objDummy.NUTR_EMP_ID__c = item.nutr_emp_id;
                        objDummy.GEND_CD__c = item.gend_cd;
                        objDummy.AGE__c = item.age;
                        objDummy.MA_EMP_NM__c = item.ma_emp_nm;
                        objDummy.MA_EMP_ID__c = item.ma_emp_id;
                        objDummy.NUTR_EMP_HPNO__c = item.nutr_emp_hpno;
                        objDummy.CUST_REQR_NM__c = item.cust_reqr_nm;
                        objDummy.MA_EMP_HPNO__c = item.ma_emp_hpno;
                        objDummy.CRGR_DIV_CD__c = item.crgr_div_cd;
                        objDummy.CUST_REQR_TEL_NO__c = item.cust_reqr_tel_no;
                        objDummy.SMA_EMP_NM__c = item.sma_emp_nm;
                        objDummy.SMA_EMP_ID__c = item.sma_emp_id;
                        objDummy.SLF_PRS_YN__c = item.slf_prs_yn;
                        objDummy.MNFCO_NM__c = item.mnfco_nm;
                        objDummy.MNF_NO__c = item.mnf_no;
                        objDummy.BCNR_NM__c = item.bcnr_nm;
                        objDummy.BCNR_ID__c = item.bcnr_id;
                        objDummy.GD_NM__c = item.gd_nm;
                        objDummy.BCNR_VOC_TEL_NO__c = item.bcnr_voc_tel_no;
                        objDummy.BCNR_STED_TXT__c = item.bcnr_sted_txt;
                        objDummy.BCNR_VOC_CRGR_NM__c = item.bcnr_voc_crgr_nm;
                        objDummy.IMPT_VGU_YN__c = item.impt_vgu_yn;
                        objDummy.MD_EMP_NM__c = item.md_emp_nm;
                        objDummy.MD_EMP_ID__c = item.md_emp_id;
                        objDummy.GD_DIV_CD__c = item.gd_div_cd;
                        objDummy.MD_EMP_HPNO__c = item.md_emp_hpno;
                        objDummy.VOC_DTL_TXT__c = item.voc_dtl_txt;
                        objDummy.img_file_url1__c = item.img_file_url1;
                        objDummy.img_file_url2__c = item.img_file_url2;
                        objDummy.img_file_url3__c = item.img_file_url3;

                        objDummy.SHPTO_ADDR__c = item.shpto_addr;
                        objDummy.MNGPLC_ADDR__c = item.mngplc_addr;
                        objDummy.SHPTO_ID__c = item.shpto_id;
                        objDummy.SHPTO_NM__c = item.shpto_nm;
                        objDummy.LGS_CTR_ID__c = item.lgs_ctr_id;
                        insertDummyList.add(objDummy);
                    }
                }
                if (insertDummyList <> null && insertDummyList.size() > 0) {
                    insert insertDummyList;
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
        
        IFUtil objIF = new IFUtil('IF_IFRESH_SFDC_VOC_INFO_DETAIL');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}