/**
 * @Class : IFN_EIF1001_EC003_MD005.cls
 * @group Framework : 알림 발송
 * @Author : 김동영
 * @Date : 2023-08-31
 * @Version : 1.0
 * @Description : KaKao AT 전송
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.31 | 김동영          | 최초작성
 * */
public class IFN_EIF1001_EC003_MD005 {
    public String interfaceId = 'IFN_EIF1001_EC003_MD005';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
    
    public IFN_CalloutResult callout() {
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();
        
        EC003RequstWrapper param = new EC003RequstWrapper();
        EC003RequstData reqData = new EC003RequstData();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();
      
        try {
            IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, param);

            // Target Object 확정 후 코드 처리 필요
            if('S'.equals(calloutResult.result)) {
                // 메시지 전송 결과값 정상 수신

            } else {
                // 인터페이스 처리 오류 Or Http 오류 결과 수신

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
    public class EC003RequstWrapper{
        public String msg_type {get;set;}
        public List<EC003RequstData> msg_data {get;set;} 
    }

    // Request Message Data
    public class EC003RequstData{
        public String msg_key {get;set;}
        public String sub_id {get;set;}
        public String sender_number {get;set;}
        public String receiver_number {get;set;}
        public String msg {get;set;}
        public String sender_key {get;set;}
        public String template_code {get;set;}
        public String tile {get;set;}
        public String header {get;set;}
        public Integer price {get;set;}
        public String currency_type {get;set;}
        public String ad_flag {get;set;}    // 친구톡 전용
        public EC003RequstAttachment attachment {get;set;}
        public EC003RequstSupplement supplement {get;set;}
        public EC003RequstFailback failback_data {get;set;}
    }

    public class EC003RequstAttachment{
        public List<EC003RequstButton> button {get;set;}
        public EC003RequstItemHighlight item_highlight {get;set;}
        public EC003RequstItem item {get;set;}
        public EC003RequstImage image {get;set;}    // 친구톡 이미지 속성 데이터
    }

    public class EC003RequstButton{
        public String name {get;set;}
        public String type {get;set;}
        public String url_pc {get;set;}
        public String url_mobile {get;set;}
        public String scheme_android {get;set;}
        public String scheme_ios {get;set;}
        public String chat_extra {get;set;}
        public String chat_event {get;set;}   
    }

    public class EC003RequstItemHighlight{
        public String title {get;set;}
        public String description {get;set;}
    }

    public class EC003RequstItem{
        public List<EC003RequestList> itemlist {get;set;}
        public List<EC003RequestSummary> summary {get;set;}
    }

    public class EC003RequestList{
        public String title {get;set;}
        public String description {get;set;}
    }

    public class EC003RequestSummary{
        public String title {get;set;}
        public String description {get;set;}
    }

    // 친구톡 전용
    public class EC003RequstImage{ 
        public String img_url {get;set;}
        public String img_link {get;set;}
    }

    public class EC003RequstSupplement{
        public List<EC003RequstQuickReply> quick_reply {get;set;}
    }

    public class EC003RequstQuickReply{
        public String name {get;set;}
        public String type {get;set;}
        public String scheme_android {get;set;}
        public String scheme_ios {get;set;}
        public String url_mobile {get;set;}
        public String url_pc {get;set;}
        public String chat_extra {get;set;}
        public String chat_event {get;set;}
    }

    public class EC003RequstFailback{
        public String failback_type {get;set;}
        public String failback_title {get;set;}
        public String failback_msg {get;set;}
        public String failback_id {get;set;}
    }

    // result
    public class EC003ResultWrapper {
         // msg_key, code, desc
        public List<Map<String, Object>> results;
    }
}