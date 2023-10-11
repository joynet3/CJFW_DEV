/**
 * @Class : IFN_EIF1001_EC001_MD002.cls
 * @group Framework : MMS
 * @Author : 김동영
 * @Date : 2023-08-22
 * @Version : 1.0
 * @Description : MMS 메시지 전송 결과 Webhook Callback API
 *				  Comm.one(메시징시스템) -> 중계서버 -> Salesforce
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.22 | 김동영          | 최초작성
 * */
@RestResource(urlMapping='/EIF1001/EC003/MD006')
global with sharing class IFN_EIF1001_EC003_MD006 {
    global IFN_EIF1001_EC003_MD006() {}
    
    @HttpPost
    global static String doPost() {
        String strCode = '100'; // webhook 전송 정상 접수 확인
        String strMessage = 'Success';
        String interfaceId = 'IFN_EIF1001_EC003_MD006';

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
                            "msg_key"       발송요청 메시지키
                            "code"          카카오 메시지 발송 결과 코드
                            "desc"          카카오 메시지 발송 결과 코드 상세
                            "failback_dest" failback 최종 착신 통신사
                            "failback_code" failback 메시지 발송 결과 코드
                            "failback_desc" failback 메시지 발송 결과 코드 상세
                            "done_date"     메시지 최종 처리 시각 (yyyyMMdd24HHmmss)
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
                    if(resultItem.get('code').toString().equals('C100')) {
                        // 메시지 발송 성공 처리
                    } else {
                        // 메시지 발송 실패 처리
                    }
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