/**
 * @Class : IFN_LIF1012_PO001_MD002.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.11.08
 * @Version : 1.0
 * @Description : 미개약 상품 조회 인터페이스
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
     * 미계약 상품 인터페이스 Wrapper
     * =================================
     */
    /**
     * 요청 파라메터 
     */
    public class PO001_MD002ReqWrapper{
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
     public class PO001_MD002ResWrapper{
        public T_RETURN_ITM T_RETURN {get;set;}
    }

    public class T_RETURN_ITM{
        public String KUNNR {get;set;}
        public String WERKS {get;set;}
        public String LGORT {get;set;}
        public String MATNR {get;set;}
        public String BWTAR {get;set;}
        public String CHARG {get;set;}
        public String FRBNR {get;set;}
        public String HISTNO {get;set;}
        public String EBELN {get;set;}
        public String EBELP {get;set;}
        public String ZREGISTERNO {get;set;}
        public String ZPROFIT {get;set;}
        public String ZYEARRATE {get;set;}
        public String LBKUM {get;set;}
        public String VERPR {get;set;}
        public String BUDAT {get;set;}
        public String ZBOX  {get;set;}
        public String ZCONT_NO  {get;set;}
        public String CTYPE {get;set;}
        public String HSDAT {get;set;}
        public String MHDRZ {get;set;}
        public String ZSHELF_DAY {get;set;}
        public String RAUBE {get;set;}
        public String XSTAT {get;set;}
        public String XMSGS {get;set;}
        public String VERPR2 {get;set;}
        public String GUBUN {get;set;}
        public String NAME1 {get;set;}
        public String NAME1_WERKS {get;set;}
        public String LGOBE {get;set;}
        public String MAKTX {get;set;}
    }


}