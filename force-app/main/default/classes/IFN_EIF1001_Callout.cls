/**
 * @Class : IFN_EIF1001_Callout.cls
 * @group Framework : 알림 발송
 * @Author : 김동영
 * @Date : 2023-08-28
 * @Version : 1.0
 * @Description : 알림 - 메세징 시스템 이미지 업로드 Callout 관리
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.28 | 김동영          | 최초작성
 * */
public class IFN_EIF1001_Callout {
    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
    
    public IFN_EIF1001_Callout() {
        this.commlog = new IFN_CommonLog();
    }

    public IFN_EIF1001_Callout(String interfaceId, String type) {
        this.commlog = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }

    public IFN_CalloutResult getResponse(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();
        
        try {
            switch on interfaceId {
                // MMS Image Upload
                when 'IFN_EIF1001_EC002_MD003'{ 
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_EIF1001_EC002_MD003(interfaceId, params);
                }
                // KAKAO AT Image Upload
                when 'IFN_EIF1001_EC002_MD004'{ 
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_EIF1001_EC002_MD004(interfaceId, params);
                }
            }
        } catch(Exception e) {
            result.setResult('E' , e.getMessage() , null); 
        } //end of try~catch
        return result;
    }

    /**
     * @Description MMS 이미지 업로드
     * @param interfaceId IFN_EIF1001_EC002_MD003
     * @param params image
     * @return IFN_CalloutResult
     * @request
        {
            "image": file data
        }
       @response
        {
            "data" : 
            {
                "image_key": "20200721141516123_mms_jpg_app1_135790",
                "request_date": "20200721",
                "name": "test.jpg"
            }
        }
       @error response
        {
            "errcode" : "",
            "errmsg" : "",
        }
    */
    public IFN_CalloutResult IFN_EIF1001_EC002_MD003(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = 'Upload Success';
        
        IFN_EIF1001_EC002_MD003.EC002ResultWrapper infResponse = new IFN_EIF1001_EC002_MD003.EC002ResultWrapper();  
        
        try{
            Date dateToday = Date.today();
            System.debug('params >>>>>>>>>>>>>>>>>>>>>>>>>' + params);

            IFN_EIF1001_EC002_MD003.EC002RequstWrapper reqparam = new IFN_EIF1001_EC002_MD003.EC002RequstWrapper();
            reqparam = (IFN_EIF1001_EC002_MD003.EC002RequstWrapper)params;

            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = JSON.serialize(reqparam);
            Map<String,String> hemap = new Map<String,String>();
            hemap.put('Interface_req_dt',String.valueOf(Datetime.now().format('yyyyMMdd')));
            hemap.put('Interface_tracekey',String.valueOf(Datetime.now().format('yyyyMMddHHmmss')));

            HttpResponse response = gateway.webCallout(requestBody, hemap, true);

            responsedata = response.getBody();
            if(response.getStatusCode() == 200) {
                IFN_EIF1001_EC002_MD003.EC002Response resData = (IFN_EIF1001_EC002_MD003.EC002Response)JSON.deserializeStrict((String)responsedata, IFN_EIF1001_EC002_MD003.EC002Response.class);
                IFN_EIF1001_EC002_MD003.EC002SuccessData successData = resData.data;
                infResponse.response = (Object)successData;
            } else {
                IFN_EIF1001_EC002_MD003.EC002ErrorData errData = (IFN_EIF1001_EC002_MD003.EC002ErrorData)JSON.deserializeStrict((String)responsedata, IFN_EIF1001_EC002_MD003.EC002ErrorData.class);
                result_code = 'F';
                result_message = 'Upload Error';
                infResponse.response = (Object)errData;
            }

        } catch(Exception e) {
            result_code = 'E';
            result_message = 'Interface Error';
        }  

        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        return result;
    }

    /**
     * @Description KaKao 알림톡 이미지 업로드
     * @param interfaceId IFN_EIF1001_EC002_MD004
     * @param params image
     * @return IFN_CalloutResult
     * @request
        {
            "image": file data
        }
       @response
        {
            "data" : 
            {
                "image_key": "20200721141516123_mms_jpg_app1_135790",
                "request_date": "20200721",
                "name": "test.jpg", 
                "url" : "http://mud-kage.kakao.com/dn/fdB1j/btqFS8c1GnD/c6AQJBAbTR2yNi1XJNgUV0/img_1.jpg"
            }
        }
       @error response
        {
            "errcode" : "",
            "errmsg" : "",
        }
    */
    public IFN_CalloutResult IFN_EIF1001_EC002_MD004(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = 'Upload Success';
        
        IFN_EIF1001_EC002_MD004.EC002ResultWrapper infResponse = new IFN_EIF1001_EC002_MD004.EC002ResultWrapper();  
        
        try{
            Date dateToday = Date.today();
            System.debug('params >>>>>>>>>>>>>>>>>>>>>>>>>' + params);

            IFN_EIF1001_EC002_MD004.EC002RequstWrapper reqparam = new IFN_EIF1001_EC002_MD004.EC002RequstWrapper();
            reqparam = (IFN_EIF1001_EC002_MD004.EC002RequstWrapper)params;

            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = JSON.serialize(reqparam);
            Map<String,String> hemap = new Map<String,String>();
            hemap.put('Interface_req_dt',String.valueOf(Datetime.now().format('yyyyMMdd')));
            hemap.put('Interface_tracekey',String.valueOf(Datetime.now().format('yyyyMMddHHmmss')));

            HttpResponse response = gateway.webCallout(requestBody, hemap, true);

            responsedata = response.getBody();
            if(response.getStatusCode() == 200) {
                IFN_EIF1001_EC002_MD004.EC002Response resData = (IFN_EIF1001_EC002_MD004.EC002Response)JSON.deserializeStrict((String)responsedata, IFN_EIF1001_EC002_MD004.EC002Response.class);
                IFN_EIF1001_EC002_MD004.EC002SuccessData successData = resData.data;
                infResponse.response = (Object)successData;
            } else {
                IFN_EIF1001_EC002_MD004.EC002ErrorData errData = (IFN_EIF1001_EC002_MD004.EC002ErrorData)JSON.deserializeStrict((String)responsedata, IFN_EIF1001_EC002_MD004.EC002ErrorData.class);
                result_code = 'F';
                result_message = 'Upload Error';
                if(errData.errcode.equals('E400')){
                    for(String key : IFN_EIF1001_EC002_MD004.convertMessage.keySet()){
                        if(key.contains(errData.errmsg)){
                            errData.errmsg = IFN_EIF1001_EC002_MD004.convertMessage.get(key);
                        }
                    }
                } 
                infResponse.response = (Object)errData;
            }

        } catch(Exception e) {
            result_code = 'E';
            result_message = 'Interface Error';
        }  

        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        return result;
    }
}