/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 11-11-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
@isTest
public class IF_MDM_SFDC_INFO_PRODUCT_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_MDM_SFDC_INFO_PRODUCT'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'POST';
            objIFMaster.ContentType__c = 'application/json';
            objIFMaster.Endpoint__c = 'test';
            
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;

        List<String> listGdId = new List<String>{'10090203','10090204','10090301'};
        List<ProductCategory__c> listGd = new List<ProductCategory__c>();
        for(String str : listGdId) {
            ProductCategory__c obj = new ProductCategory__c();
            obj.gd_cls_id__c = str;
            obj.Name = 'test';

            listGd.add(obj);
        }

        insert listGd;
    }

    @isTest
    static void testIF_MDM_SFDC_INFO_PRODUCT() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{"transaction_id":"CR007_20221110142016","is_last":true,"data":[{"plt_ld_unit_cd":"BOX","stk_mng_yn":"1","mcd_dtl_ql_txt":"","pv_chmadiv":"N","gd_md_grp_cd":"B47","gd_tot_wt":"","pb_gd_cl_cd":"40","gd_cl_div_cd":"HAW1","fw_gd_mid_id":"","caut_atc_err_itm_txt":"","lgl_nd_cmpo_bd":"국내산","cftr_gd_yn":"0","rtn_unit_cd":"EA","nfxat_pkg_unit_cd":"","sigr_orinat_cd":"KR","asst_gd_nm":"","gd_crgr_id":"257496","gd_stds_txt":"3*3cm다이스","wt_unit_cd":"KG","plt_ctcnt_qty":"1.00","pkgm_frm_cd":"","gd_bd":"무우(CK용 3*3cm다이스 조림용 2Kg/EA)","bas_unit_cd":"EA","nfxat_avg_wt":"0.000","mcd_dtl_stds_txt":"","lvstk_cd":"","plt_ld_cntqty":"1","reg_dt":"2022-09-30 14:02:23.0","gd_en_nm":"","csmbl_yn":"0","mnfco_orinat_cd":"KR","regr_id":"SP_OD_TICBCM009","nfxat_gd_yn":"0","mdgrp_cd":"10","fd_cl_cd":"","strg_cond_cd":"20","avg_wt":"0.000","lgs_ctr_id":"","upd_dt":"2022-09-30 14:02:23.0","cj_mcd_srt_cd":"","co_id":"FW00","fw_gd_sml_id":"","liqusage":"","plt_ld_egnb_nm":"1","odd_spcf_yn":"0","chjd_itm_yn":"0","brd_nm":"","sale_rout_cd":"","dstr_tlmt_dd_cnt":"5","pbcg_yn":"","migr_orinat_cd":"KR","aset_yn":"0","liqkind":"","caut_atc_cok_txt":"","caut_atc_strg_hdl_txt":"","main_act_txt":"","fw_gdgrp_cd":"51","box_ctcnt_qty":"1.00","fw_gd_lar_id":"","gd_us_stts_cd":"NRML","taxt_cl_cd":"0","gd_no":"372057","gd_nm":"무우","updr_id":"SP_OD_TICBCM009","lvstk_part_nm":"","pac_ctcnt_qty":"1.00","mcd_dtl_us_txt":"","mnfco_cd":"","ql_grd_bd":"","cj_gd_no":"","isliq":"0","mnfco_oriplc_cd":"","ea_wt":"0.000","gdgrp_cd":"","fs_gd_yn":"1","pice_sale_psb_yn":"0","dstr_his_mng_yn":"1","ekgrp_m":"B47","ekgrp_n":"B47","gd_us_txt":"조림용","sale_unit_cd":"EA","pv_madiv":"Y","ekgrp_e":"D34","dstr_his_no_rpt_obj_yn":"3","ordr_unit_cd":"EA","ordr_div_cd":"70","mnf_ymd":"","us_yn":"1","lgl_dstr_tlmt_end_ymd":"","gd_cls_id":"10090203","itm_cl_cd":"","strgd_yn":"","ekgrp_w":"B86","ekgrp_s":""}],"total_page":1,"page_no":1}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IF_MDM_SFDC_INFO_PRODUCT.doPost();
    }
}