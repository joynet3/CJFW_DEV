/**
 * @Class : IFN_LIF1012_PO001_MD003.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.11.08
 * @Version : 1.0
 * @Description : 여신 사용 현황  조회 인터페이스
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.14 | 조일근  | 최초작성
 * */
public class IFN_LIF1012_PO001_MD003 {

    public String interfaceId = 'IFN_LIF1012_PO001_MD003';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;


    public PO001_MD003ResWrapper callout( PO001_MD003ReqWrapper params){
        PO001_MD003ResWrapper result = new PO001_MD003ResWrapper();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();
      
        try {
            
            IFN_LIF1012_Callout callout = new IFN_LIF1012_Callout(this.interfaceId, 'Real');
            IFN_CalloutResult calloutRes = callout.getResponse(this.interfaceId, Json.serialize(params));

            result = (PO001_MD003ResWrapper)calloutRes.response;

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
     * 미계약 상품 인터페이스 Wrapper
     * =================================
     */
    /**
     * 요청 파라메터 
     */
    public class PO001_MD003ReqWrapper{
        public String XROWS {get;set;} // 파라메터 요청 갯수(리스트 요청일 경우)
        public String XSYS {get;set;} // SD 고정
        public String XDATS {get;set;} // 요청일자
        public String XTIMS {get;set;} // 요청시간
        public T_INPUT_ITM T_INPUT {get;set;}
    }
    public class T_INPUT_ITM {
        public String KUNNR {get;set;} // 자재번호
        public String KKBER {get;set;} // B/L번호
        
    }


    /**
     * 수신 데이터
     */
     public class PO001_MD003ResWrapper{
        public String XSTAT {get;set;}
        public String XMSGS {get;set;}
        public T_OUTPUT_ITM T_OUTPUT {get;set;}
    }

    public class T_OUTPUT_ITM{
        public String KUNNR {get;set;}       // 고객 번호
        public String KKBER {get;set;}       // 여신 관리 영역
        public String VKORG {get;set;}       // 판매 조직
        public String KLIMK {get;set;}       // 고객의 여신한도
        public String SAUFT {get;set;}       // 매출환산가치 합계
        public String SBGRP {get;set;}       // 여신관리사원그룹 
        public String KATR2 {get;set;}       // 고객등급
        public String ZINCOME {get;set;}     // 당월 입금액
        public String VTEXT {get;set;}       // 영업 조직내역
        public String VTEXT_KART2 {get;set;} // 고객등급 내역
        public String STEXT {get;set;}       // 여신관리사원그룹 내역 
        public String KKBTX {get;set;}       // 여신 관리 영역 내역
    }


}