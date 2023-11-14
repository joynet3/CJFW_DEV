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
                when 'IFN_LIF1012_PO001_MD002'{ 
                    result = IFN_LIF1012_PO001_MD002(interfaceId, params);
                }

            }
        } catch(Exception e) {
            result.setResult('E' , e.getMessage() , null); 
        } //end of try~catch
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
    

}