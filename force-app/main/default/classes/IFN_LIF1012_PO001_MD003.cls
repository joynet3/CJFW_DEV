/**
 * @Class : IFN_LIF1012_PO001_MD003.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.11.08
 * @Version : 1.0
 * @Description : 미계약 상품 조회 인터페이스
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.08 | 조일근  | 최초작성
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
        public ZMMT1380_ITM ZMMT1380 {get;set;}
    }
    public class ZMMT1380_ITM {
        public String MATNR {get;set;} // 자재번호
        public String FRBNR {get;set;} // B/L번호
        public String CTYPE {get;set;} // 계약구분
        
    }


    /**
     * 수신 데이터
     */
     public class PO001_MD003ResWrapper{
        public T_RETURN_ITM T_RETURN {get;set;}
    }

    public class T_RETURN_ITM{
        public String KUNNR {get;set;}       // 고객 번호   
        public String WERKS {get;set;}       // 플랜트 
        public String LGORT {get;set;}       // 저장 위치
        public String MATNR {get;set;}       // 자재 번호
        public String BWTAR {get;set;}       // 평가 유형
        public String CHARG {get;set;}       // 배치 번호
        public String FRBNR {get;set;}       // BL번호
        public String HISTNO {get;set;}      // 유통이력번호
        public String EBELN {get;set;}       // 구매 문서 번호
        public String EBELP {get;set;}       // 구매 문서 품목 번호
        public String ZREGISTERNO {get;set;} // 심의품의번호
        public String ZPROFIT {get;set;}     // 이익율 
        public String ZYEARRATE {get;set;}   // 연금리 
        public String LBKUM {get;set;}       // 총 평가 재고
        public String VERPR {get;set;}       // 이동평균가/주기단위가격 
        public String BUDAT {get;set;}       // 전표의 전기일 
        public String ZBOX  {get;set;}       // 수량
        public String ZCONT_NO  {get;set;}   // C/T ID
        public String CTYPE {get;set;}       // 계약구분
        public String HSDAT {get;set;}       // 제조일
        public String MHDRZ {get;set;}       // 최저 잔존 유효 기간
        public String ZSHELF_DAY {get;set;}  // 유통기한 잔여일
        public String RAUBE {get;set;}       // 저장조건
        public String XSTAT {get;set;}       // EAI_처리결과(S : 처리 완료, E : 에러발생)
        public String XMSGS {get;set;}       // 에러메세지
        public String VERPR2 {get;set;}      // 이동평균가/주기단위가격
        public String GUBUN {get;set;}       // 역감모 여부
        public String NAME1 {get;set;}       // 고객 내역
        public String NAME1_WERKS {get;set;} // 플랜트 내역
        public String LGOBE {get;set;}       // 저장위치 내역
        public String MAKTX {get;set;}       // 자재 내역
    }


}