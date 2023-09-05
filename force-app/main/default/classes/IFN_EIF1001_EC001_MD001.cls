/**
 * @Class : IFN_EIF1001_EC001_MD001.cls
 * @group Framework : 알림 발송
 * @Author : 김동영
 * @Date : 2023-08-31
 * @Version : 1.0
 * @Description : MMS 메세지 전송
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.31 | 김동영          | 최초작성
 * */
public class IFN_EIF1001_EC001_MD001 {
    public String interfaceId = 'IFN_EIF1001_EC001_MD001';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
    public IFN_EIF1001_EC001_MD001.EC001RequstWrapper param;

    public IFN_CalloutResult callout() {
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();
        
        // EC001RequstWrapper param = new EC001RequstWrapper();
        // EC001RequstData reqData = new EC001RequstData();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();
      
        try {
            IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, this.param);

            if('S'.equals(calloutResult.result)) {

            } else {

            }
        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
            this.logWrap.Status = 'ERROR';
        }

        commlog.insertLog(this.logWrap);
        return calloutResult;
    }

    // Request
    public class EC001RequstWrapper{
        public String msg_type {get;set;}
        public List<EC001RequstData> msg_data {get;set;} 
    }

    // Request Message Data
    public class EC001RequstData{
        public String msg_key {get;set;}
        public String sub_id {get;set;}
        public String sender_number {get;set;}
        public String receiver_number {get;set;}
        public String title {get;set;}
        public String msg {get;set;}
        public String image_key {get;set;}
        public String origin_cid {get;set;}
    }

    // result
    public class EC001ResultWrapper {
        // msg_key, code, desc
        public List<Map<String, Object>> results;
    }
}