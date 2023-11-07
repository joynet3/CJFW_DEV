/**
 * @Class : IFN_EIF1001_EC001_MD001.cls
 * @group Framework : 알림 발송
 * @Author : 김동영
 * @Date : 2023-08-31
 * @Version : 1.0
 * @Description : MMS 메세지 전송
 *                Salesforce -> 중계서버 -> Comm.one(메세징시스템)
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.31 | 김동영          | 최초작성
 *  2. | 2023.10.30 | 김동영          | results Wrapper 추가 
 *                                     테스트용도 Object 추가에 따른 레코드 조회 및 업데이트 추가
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

            // Target Object 확정 후 코드 처리 필요
            if('S'.equals(calloutResult.result)) {
                // 메시지 전송 결과값 정상 수신
                // 메시지 전송 결과 저장 - 현재 테스트용도 생성된 Object에 입력, 추후 수정 Or 변경될 수 있음.
                // ================================= 테스트 용 추가코드 Start =================================
                IFN_EIF1001_EC001_MD001.EC001ResultWrapper resultResponse = (IFN_EIF1001_EC001_MD001.EC001ResultWrapper)calloutResult.response;
                for(IFN_EIF1001_EC001_MD001.results result : resultResponse.results) {
                    
                    String msgKey = result.msg_key;
                    
                    List<ChannelTransHist__c> MMSHist = [select Id, 
                                     		MsgType__c, ImageKey__c, Title__c, SubId__c, MsgKey__c, SenderNumber__c, ReceiveNumber__c, Msg__c, OriginCid__c, 
                                     		DeliveryYn__c, DeliveryResultCode__c, DeliveryResultDesc__c
  									   from ChannelTransHist__c 
                                     where MsgKey__c =: msgKey
                                       and MsgType__c = 'MMS'];

                    if(MMSHist.size() > 0 ){
                        for(ChannelTransHist__c mms : MMSHist){
                            mms.DeliveryYn__c = result.code.equals('C100') ? 'Y' : 'N';
                            mms.DeliveryResultCode__c = result.code;
                            mms.DeliveryResultDesc__c = result.result_desc;
                            
                            try {
                                update mms;
                            } catch (DmlException e) {
                                // Process exception here
                            }
                        }    
                    }
                    System.debug('msg_key :::::::' + result.msg_key);
                    System.debug('code :::::::' + result.code);
                    System.debug('result_desc :::::::' + result.result_desc);
                }
                // ================================= 테스트 용 추가코드 END =================================
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
        public List<results> results {get;set;}
    }

    public class results {
        // msg_key, code, desc
        public String msg_key {get;set;}
        public String code {get;set;}
        public String result_desc {get;set;} //Salesforce Keyword
    }
}