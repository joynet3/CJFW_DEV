/**
 * @description       : 상품정보 Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global with sharing class IF_MDM_SFDC_INFO_PRODUCT_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{

    global String transactionId;

    global IF_MDM_SFDC_INFO_PRODUCT_ba(String transactionId) {
        this.transactionId = transactionId;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : IF Dummy Object 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('transactionId: ' + transactionId);
        String strQuery = '';
        strQuery += 'SELECT Id, transactionId__c, co_id__c, gd_no__c, gd_nm__c, asst_gd_nm__c, gd_en_nm__c, gd_cl_div_cd__c,';
        strQuery += '   gd_cls_id__c, mdgrp_cd__c, gd_stds_txt__c, bas_unit_cd__c, ordr_unit_cd__c, sale_unit_cd__c, wt_unit_cd__c,';
        strQuery += '   pice_sale_psb_yn__c, gd_tot_wt__c, taxt_cl_cd__c, gd_bd__c, gd_us_stts_cd__c, pb_gd_cl_cd__c, itm_cl_cd__c,';
        strQuery += '   fd_cl_cd__c, odd_spcf_yn__c, lgl_dstr_tlmt_end_ymd__c, gd_us_txt__c, brd_nm__c, chjd_itm_yn__c, rtn_unit_cd__c,';
        strQuery += '   gd_crgr_id__c, box_ctcnt_qty__c, plt_ctcnt_qty__c, pac_ctcnt_qty__c, ea_wt__c, ordr_div_cd__c, strg_cond_cd__c,';
        strQuery += '   sale_rout_cd__c, mnf_ymd__c, mnfco_oriplc_cd__c, migr_orinat_cd__c, mnfco_orinat_cd__c, sigr_orinat_cd__c,';
        strQuery += '   mnfco_cd__c, pkgm_frm_cd__c, strgd_yn__c, avg_wt__c, us_yn__c, regr_id__c, reg_dt__c, updr_id__c, upd_dt__c,';
        strQuery += '   dstr_his_mng_yn__c, nfxat_gd_yn__c, nfxat_pkg_unit_cd__c, nfxat_avg_wt__c, gdgrp_cd__c, dstr_tlmt_dd_cnt__c,';
        strQuery += '   csmbl_yn__c, lgs_ctr_id__c, cftr_gd_yn__c, aset_yn__c,fw_gd_lar_id__c, fw_gd_mid_id__c, fw_gd_sml_id__c,';
        strQuery += '   pbcg_yn__c, gd_md_grp_cd__c, stk_mng_yn__c, fs_gd_yn__c, lgl_nd_cmpo_bd__c, lvstk_cd__c, lvstk_part_nm__c,';
        strQuery += '   ql_grd_bd__c, fw_gdgrp_cd__c, cj_mcd_srt_cd__c, cj_gd_no__c, mcd_dtl_stds_txt__c, mcd_dtl_us_txt__c,';
        strQuery += '   mcd_dtl_ql_txt__c, main_act_txt__c, caut_atc_strg_hdl_txt__c, caut_atc_cok_txt__c, caut_atc_err_itm_txt__c,';
        strQuery += '   dstr_his_no_rpt_obj_yn__c, liqkind__c, liqusage__c, isliq__c, ekgrp_n__c, ekgrp_s__c, ekgrp_e__c, ekgrp_w__c,';
        strQuery += '   ekgrp_m__c, pv_chmadiv__c, pv_madiv__c, plt_ld_unit_cd__c, plt_ld_cntqty__c, plt_ld_egnb_nm__c';
        strQuery += '   FROM IF_MDM_SFDC_INFO_PRODUCT__c';
        strQuery += '   WHERE   transactionId__c =\'' + transactionId + '\'';
        strQuery += '   AND     IsUpdate__c = false' ;

        System.debug('strQuery: ' + strQuery);

        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 상품정보 upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<IF_MDM_SFDC_INFO_PRODUCT__c> scope) {
        List<Product2> upsertProductList = new List<Product2>();
        Map<String, String> lgsMap = CommonUtil.getMapPickListActive('Product2', 'lgs_ctr__c');
        Set<String> gdIdSet = new Set<String>();
        for (IF_MDM_SFDC_INFO_PRODUCT__c obj : scope) {
            gdIdSet.add(obj.gd_cls_id__c);
        }

        Map<String,Id> gdIdMap = new Map<String,Id>();
        // List<ProductCategory__c> productCategoryList = new List<ProductCategory__c>();

        // productCategoryList = [
        //     SELECT Id,gd_cls_id__c
        //     FROM ProductCategory__c
        //     WHERE gd_cls_id__c IN :gdIdSet
        // ];

        for (ProductCategory__c obj : [
            SELECT Id,gd_cls_id__c
            FROM ProductCategory__c
            WHERE gd_cls_id__c IN :gdIdSet
        ]) {
            gdIdMap.put(obj.gd_cls_id__c, obj.Id);
        }

        List<IF_MDM_SFDC_INFO_PRODUCT__c> listUpdate = new List<IF_MDM_SFDC_INFO_PRODUCT__c>();

        Set<String> setId = new Set<String>();

        for (IF_MDM_SFDC_INFO_PRODUCT__c obj : scope) {
            for (String centercode : lgsMap.values()) {
                Product2 productObj = new Product2();
                productObj.ExtId__c = centercode + '_' + obj.gd_no__c;
                productObj.ProductCode = centercode + '_' + obj.gd_no__c;
                //상품 카테고리 lookup 필드 추가 202211114
                productObj.ProductCategory__c = gdIdMap.get(obj.gd_cls_id__c);
                productObj.Name = obj.gd_bd__c <> null ? obj.gd_bd__c : obj.gd_nm__c;
                productObj.co_id__c = obj.co_id__c;
                productObj.gd_no__c = obj.gd_no__c;
                productObj.gd_nm__c = obj.gd_nm__c;
                productObj.asst_gd_nm__c = obj.asst_gd_nm__c;
                productObj.gd_en_nm__c = obj.gd_en_nm__c;
                productObj.gd_cl_div_cd__c = obj.gd_cl_div_cd__c;
                productObj.gd_cls_id__c = obj.gd_cls_id__c;
                productObj.family = obj.mdgrp_cd__c;
                productObj.gd_stds_txt__c = obj.gd_stds_txt__c;
                productObj.bas_unit_cd__c = obj.bas_unit_cd__c;
                productObj.ordr_unit_cd__c = obj.ordr_unit_cd__c;
                productObj.sale_unit_cd__c = obj.sale_unit_cd__c;
                productObj.wt_unit_cd__c = obj.wt_unit_cd__c;
                productObj.pice_sale_psb_yn__c = obj.pice_sale_psb_yn__c;
                productObj.gd_tot_wt__c = obj.gd_tot_wt__c == null ? null : Decimal.valueOf(obj.gd_tot_wt__c);
                productObj.taxt_cl_cd__c = obj.taxt_cl_cd__c;
                productObj.gd_us_stts_cd__c = obj.gd_us_stts_cd__c;
                productObj.pb_gd_cl_cd__c = obj.pb_gd_cl_cd__c;
                productObj.itm_cl_cd__c = obj.itm_cl_cd__c;
                productObj.fd_cl_cd__c = obj.fd_cl_cd__c;
                productObj.odd_spcf_yn__c = obj.odd_spcf_yn__c;
                productObj.lgl_dstr_tlmt_end_ymd__c = obj.lgl_dstr_tlmt_end_ymd__c;
                productObj.gd_us_txt__c = obj.gd_us_txt__c;
                productObj.brd_nm__c = obj.brd_nm__c;
                productObj.chjd_itm_yn__c = obj.chjd_itm_yn__c;
                productObj.rtn_unit_cd__c = obj.rtn_unit_cd__c;
                productObj.gd_crgr_id__c = obj.gd_crgr_id__c;
                productObj.box_ctcnt_qty__c = obj.box_ctcnt_qty__c == null ? null : Decimal.valueOf(obj.box_ctcnt_qty__c);
                productObj.plt_ctcnt_qty__c = obj.plt_ctcnt_qty__c == null ? null : Decimal.valueOf(obj.plt_ctcnt_qty__c);
                productObj.pac_ctcnt_qty__c = obj.pac_ctcnt_qty__c == null ? null : Decimal.valueOf(obj.pac_ctcnt_qty__c);
                productObj.ea_wt__c = obj.ea_wt__c == null ? null : Decimal.valueOf(obj.ea_wt__c);
                productObj.ordr_div_cd__c = obj.ordr_div_cd__c;
                productObj.strg_cond_cd__c = obj.strg_cond_cd__c;
                productObj.sale_rout_cd__c = obj.sale_rout_cd__c;
                productObj.mnf_ymd__c = obj.mnf_ymd__c;
                productObj.mnfco_oriplc_cd__c = obj.mnfco_oriplc_cd__c;
                productObj.migr_orinat_cd__c = obj.migr_orinat_cd__c;
                productObj.mnfco_orinat_cd__c = obj.mnfco_orinat_cd__c;
                productObj.sigr_orinat_cd__c = obj.sigr_orinat_cd__c;
                productObj.mnfco_cd__c = obj.mnfco_cd__c;
                productObj.pkgm_frm_cd__c = obj.pkgm_frm_cd__c;
                productObj.strgd_yn__c = obj.strgd_yn__c;
                productObj.avg_wt__c = obj.avg_wt__c == null ? null : Decimal.valueOf(obj.avg_wt__c);
                productObj.us_yn__c = obj.us_yn__c <> null && obj.us_yn__c == '1' ? true : false;
                productObj.IsActive = obj.us_yn__c <> null && obj.us_yn__c == '1' ? true : false;
                productObj.regr_id__c = obj.regr_id__c;
                productObj.reg_dt__c = obj.reg_dt__c == null ? null : Datetime.valueOf(obj.reg_dt__c.replace('T', ' '));
                productObj.updr_id__c = obj.updr_id__c;
                productObj.upd_dt__c = obj.upd_dt__c == null ? null : Datetime.valueOf(obj.upd_dt__c.replace('T', ' '));
                productObj.dstr_his_mng_yn__c = obj.dstr_his_mng_yn__c;
                productObj.nfxat_gd_yn__c = obj.nfxat_gd_yn__c;
                productObj.nfxat_pkg_unit_cd__c = obj.nfxat_pkg_unit_cd__c;
                productObj.nfxat_avg_wt__c = obj.nfxat_avg_wt__c == null ? null : Decimal.valueOf(obj.nfxat_avg_wt__c);
                productObj.gdgrp_cd__c = obj.gdgrp_cd__c;
                productObj.dstr_tlmt_dd_cnt__c = obj.dstr_tlmt_dd_cnt__c == null ? null : Decimal.valueOf(obj.dstr_tlmt_dd_cnt__c);
                productObj.csmbl_yn__c = obj.csmbl_yn__c;
                // picklist
                productObj.lgs_ctr__c = centercode;
                // code
                productObj.lgs_ctr_id__c = centercode;
                productObj.cftr_gd_yn__c = obj.cftr_gd_yn__c == '1' ? true : false;
                productObj.aset_yn__c = obj.aset_yn__c == '1' ? true : false;
                productObj.fw_gd_lar_id__c = obj.fw_gd_lar_id__c;
                productObj.fw_gd_mid_id__c = obj.fw_gd_mid_id__c;
                productObj.fw_gd_sml_id__c = obj.fw_gd_sml_id__c;
                productObj.pbcg_yn__c = obj.pbcg_yn__c;
                productObj.gd_md_grp_cd__c = obj.gd_md_grp_cd__c;
                productObj.stk_mng_yn__c = obj.stk_mng_yn__c == '1' ? true : false;
                productObj.fs_gd_yn__c = obj.fs_gd_yn__c == '1' ? true : false;
                productObj.lgl_nd_cmpo_bd__c = obj.lgl_nd_cmpo_bd__c;
                productObj.lvstk_cd__c = obj.lvstk_cd__c;
                productObj.lvstk_part_nm__c = obj.lvstk_part_nm__c;
                productObj.ql_grd_bd__c = obj.ql_grd_bd__c;
                productObj.fw_gdgrp_cd__c = obj.fw_gdgrp_cd__c;
                productObj.cj_mcd_srt_cd__c = obj.cj_mcd_srt_cd__c;
                productObj.cj_gd_no__c = obj.cj_gd_no__c;
                productObj.mcd_dtl_stds_txt__c = obj.mcd_dtl_stds_txt__c;
                productObj.mcd_dtl_us_txt__c = obj.mcd_dtl_us_txt__c;
                productObj.mcd_dtl_ql_txt__c = obj.mcd_dtl_ql_txt__c;
                productObj.main_act_txt__c = obj.main_act_txt__c;
                productObj.caut_atc_strg_hdl_txt__c = obj.caut_atc_strg_hdl_txt__c;
                productObj.caut_atc_cok_txt__c = obj.caut_atc_cok_txt__c;                
                productObj.caut_atc_err_itm_txt__c = obj.caut_atc_err_itm_txt__c;
                productObj.dstr_his_no_rpt_obj_yn__c = obj.dstr_his_no_rpt_obj_yn__c;
                productObj.liqkind__c = obj.liqkind__c;
                productObj.liqusage__c = obj.liqusage__c;
                productObj.isliq__c = obj.isliq__c  == '1' ? true : false;
                productObj.ekgrp_n__c = obj.ekgrp_n__c;
                productObj.ekgrp_s__c = obj.ekgrp_s__c;
                productObj.ekgrp_e__c = obj.ekgrp_e__c;
                productObj.ekgrp_w__c = obj.ekgrp_w__c;
                productObj.ekgrp_m__c = obj.ekgrp_m__c;
                productObj.pv_chmadiv__c = obj.pv_chmadiv__c == '1' ? true : false;
                productObj.pv_madiv__c = obj.pv_madiv__c  == '1' ? true : false;
                productObj.plt_ld_unit_cd__c = obj.plt_ld_unit_cd__c;
                productObj.plt_ld_cntqty__c = obj.plt_ld_cntqty__c;
                productObj.plt_ld_egnb_nm__c = obj.plt_ld_egnb_nm__c;
                upsertProductList.add(productObj);
            }

            IF_MDM_SFDC_INFO_PRODUCT__c objTarget = new IF_MDM_SFDC_INFO_PRODUCT__c();
            objTarget.Id = obj.Id;
            objTarget.IsUpdate__c = true;
            listUpdate.add(objTarget);
        }

        Savepoint sp = Database.setSavepoint();

        // try {
            if(upsertProductList <> null && upsertProductList.size() > 0) {
                upsert upsertProductList ExtId__c;

                if(listUpdate <> null && listUpdate.size() > 0) {
                    update listUpdate;
                }
            }
        // }catch(Exception e) {
        //     Database.rollback(sp);

        //     System.debug('=============================> Error Line '+e.getLineNumber());
        //     System.debug('=============================> Error '+e.getMessage());
        // }
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : IF_DUMMY_DEL_ba Batch 실행
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        IF_DUMMY_DEL_ba price_ba = new IF_DUMMY_DEL_ba('IF_MDM_SFDC_INFO_PRODUCT__c', this.transactionId);
        Database.executeBatch(price_ba, 200);
    }
}