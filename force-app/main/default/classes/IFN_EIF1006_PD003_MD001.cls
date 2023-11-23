/**
 * @Class : IFN_EIF1006_PD003_MD001.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.11.23
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.23 | 조일근  | 최초작성
 * */
public class IFN_EIF1006_PD003_MD001 {

    public String interfaceId = 'IFN_EIF1006_PD003_MD001';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;


    public PD003_MD001ResWrapper callout( PD003_MD001RequstWrapper params){
        PD003_MD001ResWrapper result = new PD003_MD001ResWrapper();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();
      
        try {
            
            IFN_EIF1006_Callout callout = new IFN_EIF1006_Callout(this.interfaceId, 'Real');
            IFN_CalloutResult calloutRes = callout.getResponse(this.interfaceId, params);

            result = (PD003_MD001ResWrapper)calloutRes.response;

            this.logWrap.LogText.add(JSon.serialize(result));
            
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
     * 공휴일 조회 요청 Wrapper
     * =================================
     */
    /**
     * 요청 파라메터 
     */
    public class PD003_MD001RequstWrapper{
        public String searchSp {get;set;}
        public String solYear   {get;set;}
        public String solMonth   {get;set;}
    }

    /**
     * 수신 파라메터 
     */

     public class PD003_MD001ResWrapper{
        public PD003_MD001response response {get;set;}
    }

    public class PD003_MD001response{
        public headeritm header {get;set;}
        public bodyitm body {get;set;}
    }

    public class headeritm{
        public String resultCode {get;set;}
        public String resultMsg {get;set;}
    }


    public class bodyitm{
        public itmData items {get;set;}
        public String numOfRows {get;set;}
        public String pageNo {get;set;}
        public String totalCount {get;set;}
    }

    public class itmData{
        public List<itmList> item {get;set;}
    }
    public class itmList{
        public String dateKind {get;set;}
        public String dateName {get;set;}
        public String isHoliday {get;set;}
        public String locdate {get;set;}
        public String seq {get;set;}
    }







}