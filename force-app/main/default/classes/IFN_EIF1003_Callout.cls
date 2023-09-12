/**
 * @Class : IFN_EIF1003_Callout.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023-09-11
 * @Version : 1.0
 * @Description : Remember - 데이터 Callout 관리
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.11 | 박지오          | 최초작성
 * */
public with sharing class IFN_EIF1003_Callout {
    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;

    public IFN_EIF1003_Callout() {
        this.commlog = new IFN_CommonLog();
    }

    public IFN_EIF1003_Callout(String interfaceId, String type) {
        this.commlog = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }
    public IFN_CalloutResult getResponse(String interfaceId, Object params) {
        IFN_CalloutResult result = new IFN_CalloutResult();

        try {
            switch on interfaceId {
                when 'IFN_EIF1003_RE001_MD001' {
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_EIF1003_RE001_MD001(interfaceId, params);
                }
                when 'IFN_EIF1003_RE001_MD002' {
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                }
            }
        } catch (Exception e) {
            result.setResult('E', e.getMessage(), null);
        } //end of try~catch
        return result;
    }

    /**
     * @Description Remember 명함첩 데이터 가져오기
     * @param interfaceId IFN_EIF1003_RE001_MD001
     * @param params
    * @return IFN_CalloutResult
    * @request
        {
            "start_at" : "2023-09-11"

        }
       @response
        {
            "results": [
                            {
                                "msg_key": "1234567890",
                                "code": "C100",
                                "desc": "Success"
                            },
                            {...}
                        ]
        }
    */
    public IFN_CalloutResult IFN_EIF1003_RE001_MD001(String interfaceId, Object params) {
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = 'Callout Success';

        IFN_EIF1003_RE001_MD001.RE001ResultWrapper infResponse = new IFN_EIF1003_RE001_MD001.RE001ResultWrapper();
//        Map<String,Object> infResponse = new Map<String,Object>();

        try {
            System.debug('params >>>>>>>>>>>>>>>>>>>>>>>>>' + params);
            IFN_EIF1003_RE001_MD001.RE001RequestWrapper reqparam = new IFN_EIF1003_RE001_MD001.RE001RequestWrapper();
            reqparam = (IFN_EIF1003_RE001_MD001.RE001RequestWrapper) JSON.deserializeStrict((String) params, IFN_EIF1003_RE001_MD001.RE001RequestWrapper.class) ;

            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = fromDTO(reqparam);

            HttpResponse response = gateway.webCallout(requestBody, null, true);

            responsedata = response.getBody();

            if (response.getStatusCode() == 200) {
//                infResponse = (Map<String, Object>) JSON.deserializeUntyped((String) responsedata);
                infResponse = (IFN_EIF1003_RE001_MD001.RE001ResultWrapper) JSON.deserialize((String) responsedata, IFN_EIF1003_RE001_MD001.RE001ResultWrapper.class);
            } else {
//                infResponse = (Map<String, Object>) JSON.deserializeUntyped((String) responsedata);
                infResponse = (IFN_EIF1003_RE001_MD001.RE001ResultWrapper) JSON.deserialize((String) responsedata, IFN_EIF1003_RE001_MD001.RE001ResultWrapper.class);
                result_code = 'F';
                result_message = 'Callout Fail';
            }

        } catch (Exception e) {
            result_code = 'E';
            result_message = 'Interface Exception';
        }
        result.setResult(
                result_code
                , result_message
                , infResponse
        );
        return result;
    }


    public static String fromDTO(IFN_EIF1003_RE001_MD001.RE001RequestWrapper request) {
        List<String> params = new List<String>();

        if (String.isNotBlank(request.start_at)) {
            params.add('start_at=' + EncodingUtil.urlEncode(request.start_at, 'UTF-8'));
        }
        if (request.per != null) {
            params.add('per=' + request.per);
        }
        return String.join(params, '&');
    }
}