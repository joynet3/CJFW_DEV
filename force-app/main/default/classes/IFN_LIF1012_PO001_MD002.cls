/**
 * @Class : IFN_LIF1012_PO001_MD002.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.11.08
 * @Version : 1.0
 * @Description : 매출 채권현황 리포트 조회 인터페이스
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.08 | 조일근  | 최초작성
 * */
public class IFN_LIF1012_PO001_MD002 {

    public String interfaceId = 'IFN_LIF1012_PO001_MD002';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;


    public PO001_MD002ResWrapper callout( PO001_MD002ReqWrapper params){
        PO001_MD002ResWrapper result = new PO001_MD002ResWrapper();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();
      
        try {
            
            IFN_LIF1012_Callout callout = new IFN_LIF1012_Callout(this.interfaceId, 'Real');
            IFN_CalloutResult calloutRes = callout.getResponse(this.interfaceId, Json.serialize(params));

            result = (PO001_MD002ResWrapper)calloutRes.response;

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
     * 매출 채권현황 리포트 인터페이스 Wrapper
     * =================================
     */
    /**
     * 요청 파라메터 
     */
    public class PO001_MD002ReqWrapper{
        public String XROWS {get;set;} // 파라메터 요청 갯수(리스트 요청일 경우)
        public String XSYS {get;set;} // SD 고정
        public String XDATS {get;set;} // 요청일자
        public String XTIMS {get;set;} // 요청시간
        public ITEM_ITM ITEM {get;set;}
    }
    public class ITEM_ITM {
        public String VKORG {get;set;} // 판매 조직
        public String VKBUR {get;set;} // 사업장 
        public String VKGRP {get;set;} // 영업 그룹
        public String PERNR {get;set;} // 사원 번호
        public String KUNNR {get;set;} // 고객 번호
        public String STIDA {get;set;} // [FI] 미결항목일자
    }


    /**
     * 수신 데이터
     */
     public class PO001_MD002ResWrapper{
        public String XSTAT {get;set;}
        public String XMSGS {get;set;}
        public T_OUTPUT_ITM T_OUTPUT {get;set;}
    }

    public class T_OUTPUT_ITM{
        public String VKORG {get;set;}       // 판매 조직
        public String VKBUR {get;set;}       // 사업장 
        public String VKGRP {get;set;}       // 영업 그룹
        public String PERNR {get;set;}       // 사원 번호
        public String KUNNR {get;set;}       // 고객 번호
        public String STIDA {get;set;}       // [FI] 미결항목일자
        public String NAME1 {get;set;}       // 이름 1
        public String LB004 {get;set;}       // 20자 
        public String MS004 {get;set;}       // 20자 
        public String MR006 {get;set;}       // 20자 
        public String MB004 {get;set;}       // 20자 
        public String ALLOWANCE {get;set;}   // 20자 
        public String MB02 {get;set;}        // 20자 
        public String DMBTRT {get;set;}      // 20자 
        public String VTEXT {get;set;}       // 영업 조직내역
        public String BEZEI_VKBUR {get;set;} // 사업장 내역
        public String BEZEI_VKGRP {get;set;} // 영업그룹 내역
        public String PV_HNAME {get;set;}    // 사원번호 내역
    }


}