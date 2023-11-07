/**
 * @Class : IFN_EIF1001_EC001_MD002.cls
 * @group Framework : MMS
 * @Author : 김동영
 * @Date : 2023-08-22
 * @Version : 1.0
 * @Description : MMS 메시지 전송 결과 Webhook Callback API
 *                Comm.one(메세징시스템) -> 중계서버 -> Salesforce
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.22 | 김동영          | 최초작성
 *  2. | 2023.10.30 | 김동영          | 테스트용도 Object 추가에 따른 레코드 조회 및 업데이트 추가
 * */
@RestResource(urlMapping='/EIF1001/EC001/MD002')
global with sharing class IFN_EIF1001_EC001_MD002 {
    global IFN_EIF1001_EC001_MD002() {}
    
    @HttpPost
    global static String doPost() {
        String strCode = '100'; // webhook 전송 정상 접수 확인
        String strMessage = 'Success';
        String interfaceId = 'IFN_EIF1001_EC001_MD002';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();

        Map<String, String> response = new Map<String, String>();
        String requestBody = '';

        IFN_CMM_ERRUTIL.ErrorValueWrapper errWr = new IFN_CMM_ERRUTIL.ErrorValueWrapper();

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            logWrap.requestBody = requestBody;   

            if(requestBody == '' || requestBody == null) {
                errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_BODYCTT_EMPTY_ERROR);
                strCode = errWr.err_code;
                strMessage = errWr.err_msg;
                logWrap.ErrorCode = strCode;
                logWrap.ErrorText.add(strMessage);
            } else {
                // Input input = (Input)JSON.deserialize(requestBody, Input.class);
                /*
                - requestBody
                { 
                    "results" : [ 
                        {
                            "msg_key"   발송요청 메시지키
                            "code"      메시지 발송 결과 코드
                            "desc"      메시지 발송 결과 코드 상세
                            "dest"      메시지 최종착신 통신사
                            "done_date" 메시지 최종 처리 시각
                        }
                    ]
                }
                - responseBody
                {
                    "code"  Callback 수신 코드 : 성공-100 / 실패-others
                    "desc"  Callback 수신 메시지 : 성공-Success / 실패-others
                }
                */

                Map<String, Object> callbackResult = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
                List<Object> results = (List<Object>) callbackResult.get('results');

                for(Object result : results){
                    Map<String, Object> resultItem = (Map<String, Object>)result;
                    // 메시지 발송 결과 저장 - 현재 테스트용도 생성된 Object에 입력, 추후 수정 Or 변경될 수 있음.
                    // ================================= 테스트 용 추가코드 Start =================================
                    String msgKey = resultItem.get('msg_key').toString();
                    List<ChannelTransHist__c> MMSHist = [select Id, ImageKey__c,
                                     		SendYn__c, SendResultCode__c, SendResultDesc__c, SendResultDest__c, SendResultDoneDate__c, 
                                     		ErrorCode__c, ErrorMsg__c
  									   from ChannelTransHist__c 
                                     where MsgKey__c =: msgKey 
                                       and MsgType__c = 'MMS'];

                    if(MMSHist.size() > 0 ){
                        for(ChannelTransHist__c mms : MMSHist){
                            if(resultItem.get('code').toString().equals('0')) mms.SendYn__c = 'Y';
                            else mms.SendYn__c = 'N';

                            mms.SendResultCode__c = resultItem.get('code').toString();
                            mms.SendResultDesc__c = resultItem.get('desc').toString();
                            mms.SendResultDesc__c = resultItem.get('dest').toString();
                            mms.SendResultDesc__c = resultItem.get('done_date').toString();
                            try {
                                update mms;
                            } catch (DmlException e) {
                                // Process exception here
                            }
                        }    
                    }
                    // ================================= 테스트 용 추가코드 END =================================
                }
            }
        } catch(Exception e) {

            errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_SERVER_ERROR);
            strCode = errWr.err_code;
            strMessage = errWr.err_msg;
            strMessage +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']';
            logWrap.ErrorCode = strCode;
            logWrap.ErrorText.add(strMessage);
        }
        response.put('code', strCode);
        response.put('desc', strMessage);
        commlog.insertLog(logWrap);

        return JSON.serialize(response);
    }
}