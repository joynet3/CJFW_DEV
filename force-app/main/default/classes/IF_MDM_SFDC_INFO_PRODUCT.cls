/**
 * @description       : I-FRESH 상품정보 API
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
@RestResource(urlMapping='/ifresh/product/info')
global with sharing class IF_MDM_SFDC_INFO_PRODUCT {
    global IF_MDM_SFDC_INFO_PRODUCT() {}

    global class Input {
        public List<Item> data; 
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last; 
    }

    global class Item {
        public String co_id;
        public String gd_no;
        public String gd_nm;
        public String asst_gd_nm;
        public String gd_en_nm;
        public String gd_cl_div_cd;
        public String gd_cls_id;
        public String mdgrp_cd;
        public String gd_stds_txt;
        public String bas_unit_cd;
        public String ordr_unit_cd;
        public String sale_unit_cd;
        public String wt_unit_cd;
        public String pice_sale_psb_yn;
        public String gd_tot_wt;
        public String taxt_cl_cd;
        public String gd_bd;
        public String gd_us_stts_cd;
        public String pb_gd_cl_cd;
        public String itm_cl_cd;
        public String fd_cl_cd;
        public String odd_spcf_yn;
        public String lgl_dstr_tlmt_end_ymd;
        public String gd_us_txt;
        public String brd_nm;
        public String chjd_itm_yn;
        public String rtn_unit_cd;
        public String gd_crgr_id;
        public String box_ctcnt_qty;
        public String plt_ctcnt_qty;
        public String pac_ctcnt_qty;
        public String ea_wt;
        public String ordr_div_cd;
        public String strg_cond_cd;
        public String sale_rout_cd;
        public String mnf_ymd;
        public String mnfco_oriplc_cd;
        public String migr_orinat_cd;
        public String mnfco_orinat_cd;
        public String sigr_orinat_cd;
        public String mnfco_cd;
        public String pkgm_frm_cd;
        public String strgd_yn;
        public String avg_wt;
        public String us_yn;
        public String regr_id;
        public String reg_dt;
        public String updr_id;
        public String upd_dt;
        public String dstr_his_mng_yn;
        public String nfxat_gd_yn;
        public String nfxat_pkg_unit_cd;
        public String nfxat_avg_wt;
        public String gdgrp_cd;
        public String dstr_tlmt_dd_cnt;
        public String csmbl_yn;
        public String lgs_ctr_id;
        public String cftr_gd_yn;
        public String aset_yn;
        public String fw_gd_lar_id;
        public String fw_gd_mid_id;
        public String fw_gd_sml_id;
        public String fw_gd_scls_id;
        public String pbcg_yn;
        public String gd_md_grp_cd;
        public String stk_mng_yn;
        public String fs_gd_yn;
        public String lgl_nd_cmpo_bd;
        public String lvstk_cd;
        public String lvstk_part_nm;
        public String ql_grd_bd;
        public String fw_gdgrp_cd;
        public String cj_mcd_srt_cd;
        public String cj_gd_no;
        public String mcd_dtl_stds_txt;
        public String mcd_dtl_us_txt;
        public String mcd_dtl_ql_txt;
        public String main_act_txt;
        public String caut_atc_strg_hdl_txt;
        public String caut_atc_cok_txt;
        public String caut_atc_err_itm_txt;
        public String dstr_his_no_rpt_obj_yn;
        public String liqkind;
        public String liqusage;
        public String isliq;
        public String ekgrp_n;
        public String ekgrp_s;
        public String ekgrp_e;
        public String ekgrp_w;
        public String ekgrp_m;
        public String pv_chmadiv;
        public String pv_madiv;
        public String plt_ld_unit_cd;
        public String plt_ld_cntqty;
        public String plt_ld_egnb_nm;
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
                List<IF_MDM_SFDC_INFO_PRODUCT__c> insertDummyList = new List<IF_MDM_SFDC_INFO_PRODUCT__c>();

                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'item list is empty';
                }else {
                    // Map<String, String> lgsMap = CommonUtil.getMapPickList('Product2', 'lgs_ctr__c');
                        
                    for (Item item  : input.data) {
                        IF_MDM_SFDC_INFO_PRODUCT__c objDummy = new IF_MDM_SFDC_INFO_PRODUCT__c();
                        objDummy.transactionId__c = input.transaction_Id;
                        objDummy.co_id__c = item.co_id;
                        objDummy.gd_no__c = item.gd_no;
                        objDummy.gd_nm__c = item.gd_nm;
                        objDummy.asst_gd_nm__c = item.asst_gd_nm;
                        objDummy.gd_en_nm__c = item.gd_en_nm;
                        objDummy.gd_cl_div_cd__c = item.gd_cl_div_cd;
                        objDummy.gd_cls_id__c = item.gd_cls_id;
                        objDummy.mdgrp_cd__c = item.mdgrp_cd;
                        objDummy.gd_stds_txt__c = item.gd_stds_txt;
                        objDummy.bas_unit_cd__c = item.bas_unit_cd;
                        objDummy.ordr_unit_cd__c = item.ordr_unit_cd;
                        objDummy.sale_unit_cd__c = item.sale_unit_cd;
                        objDummy.wt_unit_cd__c = item.wt_unit_cd;
                        objDummy.pice_sale_psb_yn__c = item.pice_sale_psb_yn;
                        objDummy.gd_tot_wt__c = item.gd_tot_wt;
                        objDummy.taxt_cl_cd__c = item.taxt_cl_cd;
                        objDummy.gd_bd__c = item.gd_bd;
                        objDummy.gd_us_stts_cd__c = item.gd_us_stts_cd;
                        objDummy.pb_gd_cl_cd__c = item.pb_gd_cl_cd;
                        objDummy.itm_cl_cd__c = item.itm_cl_cd;
                        objDummy.fd_cl_cd__c = item.fd_cl_cd;
                        objDummy.odd_spcf_yn__c = item.odd_spcf_yn;
                        objDummy.lgl_dstr_tlmt_end_ymd__c = item.lgl_dstr_tlmt_end_ymd;
                        objDummy.gd_us_txt__c = item.gd_us_txt;
                        objDummy.brd_nm__c = item.brd_nm;
                        objDummy.chjd_itm_yn__c = item.chjd_itm_yn;
                        objDummy.rtn_unit_cd__c = item.rtn_unit_cd;
                        objDummy.gd_crgr_id__c = item.gd_crgr_id;
                        objDummy.box_ctcnt_qty__c = item.box_ctcnt_qty;
                        objDummy.plt_ctcnt_qty__c = item.plt_ctcnt_qty;
                        objDummy.pac_ctcnt_qty__c = item.pac_ctcnt_qty;
                        objDummy.ea_wt__c = item.ea_wt;
                        objDummy.ordr_div_cd__c = item.ordr_div_cd;
                        objDummy.strg_cond_cd__c = item.strg_cond_cd;
                        objDummy.sale_rout_cd__c = item.sale_rout_cd;
                        objDummy.mnf_ymd__c = item.mnf_ymd;
                        objDummy.mnfco_oriplc_cd__c = item.mnfco_oriplc_cd;
                        objDummy.migr_orinat_cd__c = item.migr_orinat_cd;
                        objDummy.mnfco_orinat_cd__c = item.mnfco_orinat_cd;
                        objDummy.sigr_orinat_cd__c = item.sigr_orinat_cd;
                        objDummy.mnfco_cd__c = item.mnfco_cd;
                        objDummy.pkgm_frm_cd__c = item.pkgm_frm_cd;
                        objDummy.strgd_yn__c = item.strgd_yn;
                        objDummy.avg_wt__c = item.avg_wt;
                        objDummy.us_yn__c = item.us_yn;
                        objDummy.regr_id__c = item.regr_id;
                        objDummy.reg_dt__c = item.reg_dt;
                        objDummy.updr_id__c = item.updr_id;
                        objDummy.upd_dt__c = item.upd_dt;
                        objDummy.dstr_his_mng_yn__c = item.dstr_his_mng_yn;
                        objDummy.nfxat_gd_yn__c = item.nfxat_gd_yn;
                        objDummy.nfxat_pkg_unit_cd__c = item.nfxat_pkg_unit_cd;
                        objDummy.nfxat_avg_wt__c = item.nfxat_avg_wt;
                        objDummy.gdgrp_cd__c = item.gdgrp_cd;
                        objDummy.dstr_tlmt_dd_cnt__c = item.dstr_tlmt_dd_cnt;
                        objDummy.csmbl_yn__c = item.csmbl_yn;
                        objDummy.lgs_ctr_id__c = item.lgs_ctr_id;
                        // objDummy.__c = item.;
                        objDummy.cftr_gd_yn__c = item.cftr_gd_yn;
                        objDummy.aset_yn__c = item.aset_yn;                        
                        objDummy.fw_gd_lar_id__c = item.fw_gd_lar_id;
                        objDummy.fw_gd_mid_id__c = item.fw_gd_mid_id;
                        objDummy.fw_gd_sml_id__c = item.fw_gd_sml_id;                        
                        objDummy.pbcg_yn__c = item.pbcg_yn;
                        objDummy.gd_md_grp_cd__c = item.gd_md_grp_cd;
                        objDummy.stk_mng_yn__c = item.stk_mng_yn;
                        objDummy.fs_gd_yn__c = item.fs_gd_yn;
                        objDummy.lgl_nd_cmpo_bd__c = item.lgl_nd_cmpo_bd;
                        objDummy.lvstk_cd__c = item.lvstk_cd;
                        objDummy.lvstk_part_nm__c = item.lvstk_part_nm;
                        objDummy.ql_grd_bd__c = item.ql_grd_bd;
                        objDummy.fw_gdgrp_cd__c = item.fw_gdgrp_cd;
                        objDummy.cj_mcd_srt_cd__c = item.cj_mcd_srt_cd;
                        objDummy.cj_gd_no__c = item.cj_gd_no;                        
                        objDummy.mcd_dtl_stds_txt__c = item.mcd_dtl_stds_txt;
                        objDummy.mcd_dtl_us_txt__c = item.mcd_dtl_us_txt;
                        objDummy.mcd_dtl_ql_txt__c = item.mcd_dtl_ql_txt;
                        objDummy.main_act_txt__c = item.main_act_txt;
                        objDummy.caut_atc_strg_hdl_txt__c = item.caut_atc_strg_hdl_txt;
                        objDummy.caut_atc_cok_txt__c = item.caut_atc_cok_txt;
                        objDummy.caut_atc_err_itm_txt__c = item.caut_atc_err_itm_txt;
                        objDummy.dstr_his_no_rpt_obj_yn__c = item.dstr_his_no_rpt_obj_yn;
                        objDummy.liqkind__c = item.liqkind;
                        objDummy.liqusage__c = item.liqusage;
                        objDummy.isliq__c = item.isliq;
                        objDummy.ekgrp_n__c = item.ekgrp_n;
                        objDummy.ekgrp_s__c = item.ekgrp_s;
                        objDummy.ekgrp_e__c = item.ekgrp_e;
                        objDummy.ekgrp_w__c = item.ekgrp_w;
                        objDummy.ekgrp_m__c = item.ekgrp_m;
                        objDummy.pv_chmadiv__c = item.pv_chmadiv;
                        objDummy.pv_madiv__c = item.pv_madiv;
                        objDummy.plt_ld_unit_cd__c = item.plt_ld_unit_cd;
                        objDummy.plt_ld_cntqty__c = item.plt_ld_cntqty;
                        objDummy.plt_ld_egnb_nm__c = item.plt_ld_egnb_nm;
                        insertDummyList.add(objDummy);
                    }
                }

                if (insertDummyList <> null && insertDummyList.size() > 0) {
                    insert insertDummyList;
                    if (Boolean.valueOf(input.is_last) == true) {
                        IF_MDM_SFDC_INFO_PRODUCT_ba ba = new IF_MDM_SFDC_INFO_PRODUCT_ba(input.transaction_Id);
                        Database.executeBatch(ba, 10);
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
        
        IFUtil objIF = new IFUtil('IF_MDM_SFDC_INFO_PRODUCT');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}