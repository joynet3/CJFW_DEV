/**
 * @Class : IFN_LIF1002_OD002_MD002.cls
 * @group Framework : 주문
 * @Author : 김동영
 * @Date : 2023-08-16
 * @Version : 1.0
 * @Description : 주문시스템(샘플신청, 부가서비스신청) 문의 CRM 등록
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.16 | 김동영          | 최초작성
 * */
@RestResource(urlMapping='/LIF1002/OD002/MD002')
global with sharing class IFN_LIF1002_OD002_MD002 {
    
    global IFN_LIF1002_OD002_MD002() {}
    
    global class Input {
        public String ttl{get;set;}         // 접수 제목
        public String reqTp{get;set;}       // 문의 구분
        public String reqTpCd{get;set;}     // 문의 구분 코드
        public String reqMsg{get;set;}      // 접수 내용
        public String spItmTxt1{get;set;}   // 샘플 상품1
        public String spItmTxt2{get;set;}   // 샘플 상품2
        public String spItmTxt3{get;set;}   // 샘플 상품3
        public String ExtSrvcCtgr{get;set;} // 부가서비스내역
        public String ExtSvcCd{get;set;}    // 부가서비스내역코드
        public String mdmId{get;set;}       // MDM고객번호
        public String reqDt{get;set;}       // 작성일
        public String rcvNm{get;set;}       // 접수자이름
        public String reqId{get;set;}       // 문의데이터ID
    }

    global class Output {
        public String interface_id{get;set;}
        public String err_cd{get;set;}
        public String err_msg_ctt{get;set;}
        public ResData response{get;set;}
    }

    global class ResData {
        public String reqId{get;set;}   // 문의데이터ID
        public String succYn{get;set;}  // 성공여부   
        public String resId{get;set;}   // 답변데이터ID
    }

    @HttpPost
    global static Output doPost() {

        String strCode = '0000';
        String strMessage = 'Success.';
        String interfaceId = 'IFN_LIF1002_OD002_MD002';

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
                Map<String, String> plReqType = CommonUtil.getMapPickListLabel('OrderServiceRequest__c', 'ReqType__c');
                
                Input input = (Input)JSON.deserialize(requestBody, Input.class);

                // 필수 파라미터 체크
                if (String.isBlank(input.ttl) || String.isBlank(input.reqTp) || String.isBlank(input.reqTpCd) || String.isBlank(input.reqMsg)
                    || String.isBlank(input.mdmId) || String.isBlank(input.reqDt) || String.isBlank(input.rcvNm) || String.isBlank(input.reqId)) {

                    strCode = IFN_Util.STATUS_RQMT_PARAM_ERROR.split(':')[0];
                    strMessage = IFN_Util.STATUS_RQMT_PARAM_ERROR.split(':')[1];
    
                    strMessage = String.isBlank(input.ttl) ? strMessage + ',[ttl]' : strMessage;
                    strMessage = String.isBlank(input.reqTp) ? strMessage + ',[reqTp]' : strMessage;
                    strMessage = String.isBlank(input.reqTpCd) ? strMessage + ',[reqTpCd]' : strMessage;
                    strMessage = String.isBlank(input.reqMsg) ? strMessage + ',[reqMsg]' : strMessage;
                    strMessage = String.isBlank(input.mdmId) ? strMessage + ',[mdmId]' : strMessage;
                    strMessage = String.isBlank(input.reqDt) ? strMessage + ',[reqDt]' : strMessage;
                    strMessage = String.isBlank(input.rcvNm) ? strMessage + ',[rcvNm]' : strMessage;
                    strMessage = String.isBlank(input.reqId) ? strMessage + ',[reqId]' : strMessage;
                    
                    logWrap.ErrorCode = strCode;
                    logWrap.ErrorText.add(strMessage);
                } else {
                    try {
                        // 문의데이터 존재 여부
                        integer isExist = database.countQuery('select count() from OrderServiceRequest__c Where ReqRecordId__c =: :input.reqId');
                        if(isExist > 0) {    
                            strCode = IFN_Util.STATUS_DUPLICATION_INPUT_ERROR.split(':')[0];
                            strMessage = '이미 등록된 샘플 또는 부가서비스 신청이 존재합니다.';
                            logWrap.ErrorCode = strCode;
                            logWrap.ErrorText.add(strMessage);
                            objOutput.err_cd = strCode;
                            objOutput.err_msg_ctt = strMessage;
                            commlog.insertLog(logWrap);
                            return objOutput;
                        } 
                        Date requestDate = IFN_Util.convertDate(input.reqDt);

                        OrderServiceRequest__c orderServiceReq = new OrderServiceRequest__c(
                              Title__c = input.ttl
                            , ReqType__c = input.reqTp
                            // , ReqTypeCode__c = input.reqTpCd // 별도필드 존재하지 않음
                            , RequestMessage__c = input.reqMsg
                            , SampleitemText1__c = input.spItmTxt1
                            , SampleitemText2__c = input.spItmTxt2
                            , SampleitemText3__c = input.spItmTxt3
                            , ExtraServiceCategory__c = input.ExtSrvcCtgr
                            // , ExtraServiceCategoryCode__c = input.ExtSvcCd // 별도필드 존재하지 않음
                            , CustomerID__c = input.mdmId
                            , RequestDate__c = requestDate
                            , Finder__c = input.rcvNm
                            , ReqRecordId__c = input.reqId
                        );

                        Database.SaveResult result = Database.insert(orderServiceReq);
                        
                        if (result.isSuccess()) {
                            ResData resData = new ResData(); 
                        
                            resData.reqId = input.reqId;
                            resData.succYn = 'Y';
                            resData.resId = result.getId();
                            
                            objOutput.response = resData;
                        } else {
                            for(Database.Error err : result.getErrors()) {
                                strCode = '-1';
                                strMessage = err.getStatusCode() + ': ' + err.getMessage();
                                logWrap.ErrorCode = strCode;
                                logWrap.ErrorText.add(strMessage);
                            }
                        }
                    } catch (DmlException e) {
                        strCode = '-1';
                        strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       
                        logWrap.ErrorCode = strCode;
                        logWrap.ErrorText.add(strMessage);
                    }   
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