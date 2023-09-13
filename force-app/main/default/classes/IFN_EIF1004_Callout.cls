/**
 * @Class : IFN_EIF1004_Callout.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023-09-08
 * @Version : 1.0
 * @Description : 클로바 - 음성 문자 변경 Callout 관리
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.08 | 박지오          | 최초작성
 * */

public class IFN_EIF1004_Callout {
    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;

    public IFN_EIF1004_Callout() {
        this.commlog = new IFN_CommonLog();
    }

    public IFN_EIF1004_Callout(String interfaceId, String type) {
        this.commlog = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }    
    public IFN_CalloutResult getResponse(String interfaceId, Object params) {
        IFN_CalloutResult result = new IFN_CalloutResult();

        try {
            switch on interfaceId {
                when 'IFN_EIF1004_CL001_MD001' {
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_EIF1004_CL001_MD002(interfaceId, params);
                }
                when 'IFN_EIF1004_CL001_MD002' {
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                }
            }
        } catch (Exception e) {
            result.setResult('E', e.getMessage(), null);
        } //end of try~catch
        return result;
    }
    public IFN_CalloutResult IFN_EIF1004_CL001_MD002(String interfaceId, Object params) {
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = 'Callout Success';

        IFN_EIF1004_CL001_MD002.CL001ResultWrapper infResponse = new IFN_EIF1004_CL001_MD002.CL001ResultWrapper();
        try {
            System.debug('params >>>>>>>>>>>>>>>>>>>>>>>>>' + params);
//            IFN_EIF1004_CL001_MD002.CL001RequestWrapper reqparam = new IFN_EIF1004_CL001_MD002.CL001RequestWrapper();
//            reqparam = (IFN_EIF1004_CL001_MD002.CL001RequestWrapper) params;

            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = JSON.serialize(params);

            HttpResponse response = gateway.webCallout(requestBody, null, true);

            responsedata = response.getBody();
            if (response.getStatusCode() == 200) {
                infResponse = (IFN_EIF1004_CL001_MD002.CL001ResultWrapper) JSON.deserializeStrict((String) responsedata, IFN_EIF1004_CL001_MD002.CL001ResultWrapper.class);
            } else {
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
}