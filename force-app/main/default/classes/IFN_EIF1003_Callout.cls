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
            "result": {
                        "id": 123,
                        "name": "홍길동",
                        "company": "드라마앤컴퍼니",
                        "department": "사업개발팀",
                        "position": "과장",
                        "mobile": {
                                    "international_code": "82",
                                    "national_number": "01012345678",
                                    "normalized_number": "821012345678"
                                 },
                        "fax": {
                                "international_code": "82",
                                "national_number": "025561234",
                                "normalized_number": "8225561234"
                                },
                        "tel": {
                                "international_code": "",
                                "national_number": "",
                                "normalized_number": ""
                                },
                        "email": "gd.hong@dramancompany.com",
                        "address": {
                                    "default": "서울시 강남구 언주로85길 24",
                                    "detail": "2층 (역삼동, 유니팜타워)",
                                   },
                        "image_url": {
                                    "front": "https://...",
                                    "back": "https://..."
                                    },
                        "user": {
                                "id": 100,
                                "email": "ss.lee@korea.kr"

                                }
                       }
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

            System.debug(requestBody);
            HttpResponse response = gateway.webCallout(requestBody, null, true);

            responsedata = response.getBody();

            if (response.getStatusCode() == 200) {
                infResponse.result = (IFN_EIF1003_RE001_MD001.RE001SuccessWrapper) JSON.deserialize((String) responsedata.replace('"default"','"defaultVal"'), IFN_EIF1003_RE001_MD001.RE001SuccessWrapper.class);
            } else {
                infResponse.result = (IFN_EIF1003_RE001_MD001.RE001ErrorWrapper) JSON.deserialize((String) responsedata, IFN_EIF1003_RE001_MD001.RE001ErrorWrapper.class);
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
        if (request.page != null) {
            params.add('page=' + request.page);
        }
        return String.join(params, '&');
    }
}