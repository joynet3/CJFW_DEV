/**
 * @Class : IFN_LIF1012_Callout.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.11.08
 * @Version : 1.0
 * @Description : 미계약 조회 인터페이스
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.08 | 조일근  | 최초작성
 * */
public class IFN_LIF1012_Callout {
    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
    
    public IFN_LIF1012_Callout() {
        this.commlog = new IFN_CommonLog();
    }

    public IFN_LIF1012_Callout(String interfaceId, String type) {
        this.commlog = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }

    public IFN_CalloutResult getResponse(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();
        
        try {
            switch on interfaceId {
                when 'IFN_LIF1012_PO001_MD001'{ 
                    result = IFN_LIF1012_PO001_MD001(interfaceId, params);
                }                
                when 'IFN_LIF1012_PO001_MD002'{ 
                    result = IFN_LIF1012_PO001_MD002(interfaceId, params);
                }
                when 'IFN_LIF1012_PO001_MD003'{ 
                    result = IFN_LIF1012_PO001_MD003(interfaceId, params);
                }

            }
        } catch(Exception e) {
            result.setResult('E' , e.getMessage() , null); 
        } //end of try~catch
        return result;
    }


    /**
     * 매출채권현황리포트 조회
     * 
     * @param  변수명 파라미터 설명 (있는경우)
     * @return  리턴값 설명 (있는경우)
     * @exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
     * @example 
     *  예제코드 태그 아래줄에서 예제 작성
     * */
    public IFN_CalloutResult IFN_LIF1012_PO001_MD001(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        return result;
    }
 /**
     * 미계약 상품 상품 조회
     * @param interfaceId IFN_LIF1012_PO001_MD002
     * @param params 
     * @return  
     * @request Sample
        {
        "searchSp":"01",
        "keywd":"우유",
        }
     * @response Sample
       {
            "total": 649,
            "search": [],
            "code": ""
        }
     */
    public IFN_CalloutResult IFN_LIF1012_PO001_MD002(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = '';
        
        IFN_LIF1012_PO001_MD002.PO001_MD002ResWrapper infResponse = new IFN_LIF1012_PO001_MD002.PO001_MD002ResWrapper();  
        

        IFN_CMM_ERRUTIL.ErrorValueWrapper errWr = new IFN_CMM_ERRUTIL.ErrorValueWrapper();
        try{


            Date dateToday = Date.today();
    
            this.logWrap.RequestTime = Datetime.now();

            this.logWrap.LogText.add(Json.serialize(params));

            IFN_LIF1012_PO001_MD002.PO001_MD002ReqWrapper reqparam = new IFN_LIF1012_PO001_MD002.PO001_MD002ReqWrapper();
            reqparam = (IFN_LIF1012_PO001_MD002.PO001_MD002ReqWrapper)JSON.deserializeStrict((String) params, IFN_LIF1012_PO001_MD002.PO001_MD002ReqWrapper.class);


            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = JSON.serialize(reqparam);
            this.logWrap.RequestBody = requestBody;

            HttpResponse response = gateway.webCallout(requestBody,null, false);

            if(response.getStatusCode() == 200) {

                responsedata = response.getBody();
                infResponse =  (IFN_LIF1012_PO001_MD002.PO001_MD002ResWrapper)JSON.deserializeStrict((String)responsedata, IFN_LIF1012_PO001_MD002.PO001_MD002ResWrapper.class);
                this.logWrap.LogText.add('infResponse.search >>>>>>>>>> ' + JSON.serialize(infResponse.T_RETURN));
                this.logWrap.ResponseBody = (String)responsedata;
                this.logWrap.ResponseTime = Datetime.now();
            } else {

                List<String> errMsgLst = new List<String>{String.valueOf(response.getStatus())};
                errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY_FORMAT('COMMON', IFN_CMM_ERRUTIL.ERRKEY_INTERFACE_STATUS_ERROR,errMsgLst);
                result_code =  errWr.err_code;
                result_message =  errWr.err_msg;
                
                responsedata = '';
                this.logWrap.LogText.add(response.getStatus());
                this.logWrap.ErrorText.add(response.getStatus());
            }

        } catch(Exception e) {
            
            this.logWrap.LogText.add(e.getMessage() + '/' + e.getLineNumber());
            this.logWrap.ErrorText.add(e.getMessage() + '/' + e.getLineNumber());

            List<String> errMsgLst = new List<String>{String.valueOf(e.getMessage())};
            errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY_FORMAT('COMMON', IFN_CMM_ERRUTIL.ERRKEY_INTERFACE_STATUS_ERROR,errMsgLst);
            result_code =  errWr.err_code;
            result_message =  errWr.err_msg;

        }  

        this.logWrap.Status = result_code;
        this.logWrap.ErrorCode = 'S'.equals(result_code) ? 'Success' : 'error';
        if('F'.equals(result_code))  this.logWrap.ErrorText.add(result_message);

        commlog.insertLog(this.logWrap);
        
        
        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        return result;
    }



    /**
     * 여신 사용 현황  조회
     * 
     * @param  
     * 	{"T_INPUT" :
            {
                "KUNNR": "50000",
                "KKBER": "FW00"
            }
        }
     * 
     * @return  
            {
                "XSTAT": "S",
                "XMSGS": "",
                "T_OUTPUT": {
                    "KUNNR": "50000",
                    "KKBER": "FW00",
                    "VKORG": "2000",
                    "KLIMK": "100000000.00 ",
                    "SAUFT": "42509218.00 ",
                    "SBGRP": "C",
                    "KATR2": "B1",
                    "ZINCOME": "0.00 ",
                    "VTEXT": "영업2본부",
                    "VTEXT_KART2": "양호(4등급)",
                    "STEXT": "보통",
                    "KKBTX": "CJ프레시웨이 여신관리영역"
                }
            }


     * @exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
     * @example 
     *  예제코드 태그 아래줄에서 예제 작성
     * */
    public IFN_CalloutResult IFN_LIF1012_PO001_MD003(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = '';
        
        IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper infResponse = new IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper();  
        

        IFN_CMM_ERRUTIL.ErrorValueWrapper errWr = new IFN_CMM_ERRUTIL.ErrorValueWrapper();
        try{


            Date dateToday = Date.today();
    
            this.logWrap.RequestTime = Datetime.now();

            this.logWrap.LogText.add(Json.serialize(params));

            IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper reqparam = new IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper();
            reqparam = (IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper)JSON.deserializeStrict((String) params, IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper.class);

            String ymdhms = Datetime.now().format('yyyyMMddHHmmss');
            String yyyymmdd = ymdhms.substring(0, 8);
            String hhmmss = ymdhms.substring(8);
            reqparam.XROWS = '1';
            reqparam.XSYS = 'SD';
            reqparam.XDATS = yyyymmdd;
            reqparam.XTIMS = hhmmss;


            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = JSON.serialize(reqparam);
            this.logWrap.RequestBody = requestBody;

            Map<String,String> dynamicHd = new Map<String,String>();

            HttpResponse response = gateway.webCallout(requestBody,null, false);

            if(response.getStatusCode() == 200) {

                responsedata = response.getBody();
                infResponse =  (IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper)JSON.deserializeStrict((String)responsedata, IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper.class);
                this.logWrap.LogText.add('infResponse.search >>>>>>>>>> ' + JSON.serialize(infResponse.T_OUTPUT));
                this.logWrap.ResponseBody = (String)responsedata;
                this.logWrap.ResponseTime = Datetime.now();
            } else {

                List<String> errMsgLst = new List<String>{String.valueOf(response.getStatus())};
                errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY_FORMAT('COMMON', IFN_CMM_ERRUTIL.ERRKEY_INTERFACE_STATUS_ERROR,errMsgLst);
                result_code =  errWr.err_code;
                result_message =  errWr.err_msg;
                
                responsedata = '';
                this.logWrap.LogText.add(response.getStatus());
                this.logWrap.ErrorText.add(response.getStatus());
            }

        } catch(Exception e) {
            
            this.logWrap.LogText.add(e.getMessage() + '/' + e.getLineNumber());
            this.logWrap.ErrorText.add(e.getMessage() + '/' + e.getLineNumber());

            List<String> errMsgLst = new List<String>{String.valueOf(e.getMessage())};
            errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY_FORMAT('COMMON', IFN_CMM_ERRUTIL.ERRKEY_INTERFACE_STATUS_ERROR,errMsgLst);
            result_code =  errWr.err_code;
            result_message =  errWr.err_msg;

        }  

        this.logWrap.Status = result_code;
        this.logWrap.ErrorCode = 'S'.equals(result_code) ? 'Success' : 'error';
        if('F'.equals(result_code))  this.logWrap.ErrorText.add(result_message);

        commlog.insertLog(this.logWrap);
        
        
        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        return result;
    }
    

}