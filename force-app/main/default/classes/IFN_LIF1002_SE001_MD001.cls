/**
 * @Class : IFN_LIF1002_SE001_MD001.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.08.30
 * @Version : 1.0
 * @Description : 주문 시스템 검색엔진 조회
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.30 | 조일근  | 최초작성
 * */
public class IFN_LIF1002_SE001_MD001 {

    public String interfaceId = 'IFN_LIF1002_SE001_MD001';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;




    public SE001_01ResultWrapper callout( SE001RequstWrapper params){
        SE001_01ResultWrapper result = new SE001_01ResultWrapper();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();


        
      
        try {
            
            IFN_LIF1002_Callout callout = new IFN_LIF1002_Callout(this.interfaceId, 'Real');
            IFN_CalloutResult calloutRes = callout.getResponse(this.interfaceId, Json.serialize(params));

            result = (SE001_01ResultWrapper)calloutRes.response;

            this.logWrap.LogText.add(Json.serialize(result));
            
        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
            this.logWrap.Status = 'ERROR';
        }


        //commlog.insertLog(this.logWrap);
        return result;


    }


    /**
     * ==================================== 
     * 검색엔진 조회 요청 Wrapper
     * =================================
     */
    /**
     * 요청 파라메터 
     */
    public class SE001RequstWrapper{
        public String searchSp {get;set;}
        public String keywd_sp {get;set;}
        public String keywd    {get;set;}
        public String pageSize    {get;set;}
        public String page   {get;set;}
        public String order   {get;set;}
        public String order_mt   {get;set;}
    }


    /** 
     * 조회 결과 
     */
    public class SE001_01ResultWrapper {
        public String total;
        public List<SearchLst> search;
        public String code;
        public String err_cd;
        public String err_msg_ctt;
        
    }

    /** 
     * 조회 결과 
     */
    public class SearchLst {
        public String migr_orinat_cd_nm {get;set;}
        public String strg_cond_cd_nm {get;set;}
        public String migr_orinat_cd {get;set;}
        public String gd_cls_id1 {get;set;}
        public String id {get;set;}
        public String taxt_cl_cd_nm {get;set;}
        public String gd_bd_kw {get;set;}
        public String strg_cond_cd {get;set;}
        public String upd_dt {get;set;} 
        public String sale_unit_cd {get;set;}
        public String co_id {get;set;} 
        public String box_ctcnt_qty {get;set;}
        public String gd_cls_id3 {get;set;}
        public String gd_cls_id2 {get;set;}
        public String gd_cls_id4 {get;set;}
        public String gd_cls_nm3 {get;set;}
        public String gd_cls_nm2 {get;set;}
        public String gd_cls_nm4 {get;set;}
        public String img_url {get;set;}
        public String taxt_cl_cd {get;set;}
        public String gd_cls_nm1 {get;set;}
        public String gd_cls_id {get;set;}
        public String gd_no {get;set;}
        public String brd_nm {get;set;}
        public String gd_bd {get;set;}
                
    }    


}