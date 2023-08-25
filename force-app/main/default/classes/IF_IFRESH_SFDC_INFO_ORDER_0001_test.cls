/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 11-11-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
@isTest
public class IF_IFRESH_SFDC_INFO_ORDER_0001_test {

    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_IFRESH_SFDC_INFO_ORDER_0001'};

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
    }

    @isTest
    static void testIF_IFRESH_SFDC_INFO_ORDER_0001() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String strBody = '{"transaction_id":"CR010_20221109120908","is_last":true,"data":[{"bcnr_id":"1001399","slbz_org_nm":"전략사업본부","bili_doc_no":"Z000000000","crg_ma_nm":"신승윤","sply_ctr_id":"2600","ordr_opt_unprc":"3587.0000000000000000000","div_nm":"헬씨누리사업부","crg_sma_id":"","cust_nm":"헬씨누리)헬씨누리전문점팀","sales_lnkg_cl_cd":"ZP05","sales_ymd":"20221004","mngplc_id":"468100","ordr_no":"2172550485","opt_unprc":"3587.0000000000000000","ordr_real_buy_unprc":"1991.0000000000000000000","lar_gd_cls_cd":"","sales_p_rt":"4.99024254251463618600","div_id":"4705","crg_sma_nm":"","box_ctcnt_qty":"20.00","sap_err_msg":"","bcnr_nm":"(주)명현유통","shiplc_nm":"이천물류센터","rlstk_unit_rlstk_qty":"3.000","sales_at":"0","barcd_no":"8801111186247","mngplc_nm":"헬씨누리)헬씨누리전문점팀","gd_no":"246734","sales_lnkg_cl_nm":"자가소비 판촉 오더","gd_nm":"크라운제과 화이트하임(142g/EA)","gd_cls_cd":"","real_buy_unprc":"1991.0000000000000000","dstr_his_no":"","bl_no":"","slst_id":"468100","schl_nm":"","shiplc_id":"2600","mid_gd_cls_cd":"","brc_nm":"헬씨누리)헬씨누리전문점팀","bas_unit_cd":"EA","sml_gd_cls_cd":"","dstr_his_mng_yn_nm":"대상아님","sales_sum_at":"0","reg_dt":"2022-10-04 08:30:46","dstr_his_no_rpt_obj_yn_nm":"해당없음","crg_ma_id":"253655","isliq":"0","rlstk_unit_cd_nm":"EA","bas_tkstk_qty":"3.000","ordr_dtl_no":"10","taxt_cl_cd_nm":"과세","schl_cd":"","rlstk_unit_rlstk_qty_kg":"0.426","upd_dt":"2022-10-04 10:52:55","brc_id":"374","slbz_org_id":"3001","sply_ctr_nm":"이천물류센터","sale_unprc":"3766.000","pb_gd_cl_cd_nm":"40","sales_tat":"0"}],"total_page":1,"page_no":1}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IF_IFRESH_SFDC_INFO_ORDER_0001.doPost();
        
    }
}