/**
 * @Class : IFN_LIF1002_OD002_MD003.cls
 * @group Framework : 주문
 * @Author : 김동영
 * @Date : 2023-08-17
 * @Version : 1.0
 * @Description : 주문시스템(샘플신청, 부가서비스신청) 답변 조회
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.17 | 김동영          | 최초작성
 * */
@RestResource(urlMapping='/LIF1002/OD002/MD003')
global with sharing class IFN_LIF1002_OD002_MD003 {
    global IFN_LIF1002_OD002_MD003() {}

    global class Input {
        public String reqId{get;set;}   // 문의데이터ID
        public String resId{get;set;}   // 답변데이터ID
    }

    global class Output {
        public String interface_id{get;set;}
        public String err_cd{get;set;}
        public String err_msg_ctt{get;set;}
        public ResData response{get;set;}
    }

    global class ResData {
        public String stts{get;set;}    // 답변상태
        public String sttsCd{get;set;}  // 답변상태코드
        public String resDt{get;set;}   // 답변일
        public String resTtl{get;set;}  // 답변제목
        public String mngNm{get;set;}   // 담당자명
        public String resMsg{get;set;}  // 답변내용
        public String reqId{get;set;}   // 문의데이터ID
        public String resId{get;set;}   // 답변데이터ID
    }

    @HttpPost
    global static Output doPost() {

        String strCode = '0000';
        String strMessage = 'Success.';
        String interfaceId = 'IFN_LIF1002_OD002_MD003';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();

        Output objOutput = new Output();
        objOutput.interface_id = interfaceId;

        String requestBody = '';

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            logWrap.requestBody = requestBody;   

            if(requestBody == '' || requestBody == null) {
                strCode = IFN_Util.STATUS_BODYCTT_EMPTY_ERROR.split(':')[0];
                strMessage = IFN_Util.STATUS_BODYCTT_EMPTY_ERROR.split(':')[1];
                logWrap.ErrorCode = strCode;
                logWrap.ErrorText.add(strMessage);
            } else {
                Map<String, String> plStatus = CommonUtil.getMapPickListLabel('OrderServiceRequest__c', 'Status__c');
                
                Input input = (Input)JSON.deserialize(requestBody, Input.class);

                // 필수 파라미터 체크
                if (String.isBlank(input.reqId)) {

                    strCode = IFN_Util.STATUS_RQMT_PARAM_ERROR.split(':')[0];
                    strMessage = IFN_Util.STATUS_RQMT_PARAM_ERROR.split(':')[1];
    
                    strMessage = String.isBlank(input.reqId) ? strMessage + ',[reqId]' : strMessage;
                    // strMessage = String.isBlank(input.resId) ? strMessage + ',[resId]' : strMessage;
                    
                    logWrap.ErrorCode = strCode;
                    logWrap.ErrorText.add(strMessage);
                } else {
                    
                    String reqRecordId = input.reqId;
                    String sfid = input.resId;

                    // 문의데이터 존재 여부
                    String qry = 'select count() from OrderServiceRequest__c Where ReqRecordId__c =:reqRecordId';
                    integer isExist = database.countQuery(qry);
                    
                    if(isExist == 0) {
                        strCode = IFN_Util.STATUS_DATA_NOTFOUND_ERROR.split(':')[0];
                        strMessage = '샘플 또는 부가서비스신청이 존재하지 않습니다.';
                        logWrap.ErrorCode = strCode;
                        logWrap.ErrorText.add(strMessage);
                        objOutput.err_cd = strCode;
                        objOutput.err_msg_ctt = strMessage;
                        commlog.insertLog(logWrap);
                        return objOutput; 
                    }          

                    qry = 'Select Status__c,       ResponseDate__c,     ResponseTitle__c, '
                        + '       Manager__r.Name, ResponseMessage__c, ReqRecordId__c, Id '
                        + '  From OrderServiceRequest__c '
                        + ' Where ReqRecordId__c = :reqRecordId ';
                    
                    if(String.isBlank(sfid)) {
                        qry += ' Order by RequestDate__c desc Limit 1';
                    } else {
                        qry += 'And Id = :sfid ';
                    }

                    OrderServiceRequest__c osrObj = Database.query(qry);
                    ResData resData = new ResData(); 

                    resData.stts = plStatus.get(osrObj.Status__c); // picklist label
                    //resData.stts = plStatus.Status__c;    
                    resData.sttsCd = osrObj.Status__c;  // picklist api name
                    resData.resDt = IFN_Util.converDateToStrFormat(osrObj.ResponseDate__c);
                    resData.resTtl = osrObj.ResponseTitle__c;
                    resData.mngNm = osrObj.Manager__r.Name;
                    resData.resMsg = osrObj.ResponseMessage__c;
                    resData.reqId = osrObj.ReqRecordId__c;
                    resData.resId = osrObj.Id;

                    objOutput.response = resData;
                      
                }
            }
        } catch(Exception e) {
            strCode = IFN_Util.STATUS_EXCEPT.split(':')[0];
            strMessage = IFN_Util.STATUS_EXCEPT.split(':')[1];
            strMessage +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']';
            logWrap.ErrorCode = strCode;
            logWrap.ErrorText.add(strMessage);
        }
        // objOutput.interface_id = interfaceId;
        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;
        commlog.insertLog(logWrap);

        return objOutput;
    }

}