public class IFN_LIF007_Callout {

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;

    public IFN_LIF007_Callout(){
        this.commlog = new IFN_CommonLog();
    }

    public IFN_LIF007_Callout(String interfaceId, String type){
        this.commlog         = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }




    public IFN_CalloutResult getResponse(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        
        try {
            switch on interfaceId {
                //----- 테스트 IF
                when 'IF_SFDC_EACCT_INQ_OIL_AMOUNT'{ 
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IF_SFDC_EACCT_INQ_OIL_AMOUNT(interfaceId, params);
                }
                
            }
        } catch(Exception e) {
            result.setResult('E' , e.getMessage() , null); 
        } //end of try~catch


        return result;

    }

    


    /**
     * 주유비 조회 인터페이스
     * @param interfaceId dlsxjvpdltm ID
     * @param params 추가 파라메터
     * @return  `IFN_CalloutResult`
     * @request Sample
       {
            "OIL_TYPE_CD": "1",
            "BASE_MON": "202212",
            "COM_CD": "FW00",
            "opcode": "EC001",
            "system_type_cd": "LIF007"
        }
    * @response Sample
        {
            "ERR_CD": "S",
            "ERR_MSG_CTT": "",
            "DS_MASTER": {
                "data": [
                    {
                        "OIL_UNITP": 201,
                        "BASE_MON": "202212",
                        "COM_CD": "FW00",
                        "OIL_TYPE_CD": "1",
                        "DPRC_UNITP": 101
                    }
                ],
                "SVC_ERR_MSG_TEXT": "",
                "ErrorCode": 0
            }
        }

     */
    public IFN_CalloutResult IF_SFDC_EACCT_INQ_OIL_AMOUNT(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = '';
        
        IFN_SFDC_LIF1007_EC001_REQ.EC001ResultWrapper infResponse = new IFN_SFDC_LIF1007_EC001_REQ.EC001ResultWrapper();  
        

        try{


            Date dateToday = Date.today();
    
            System.debug('params >>>>>>>>>>>>>>>>>>>>>>>>>' + params);

            IFN_SFDC_LIF1007_EC001_REQ.EC001RequstWrapper reqparam = new IFN_SFDC_LIF1007_EC001_REQ.EC001RequstWrapper();
            reqparam = (IFN_SFDC_LIF1007_EC001_REQ.EC001RequstWrapper)params;

            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = JSON.serialize(reqparam);
            Map<String,String> hemap = new Map<String,String>();
            hemap.put('Interface_req_dt',String.valueOf(Datetime.now().format('yyyyMMdd')));
            hemap.put('Interface_tracekey',String.valueOf(Datetime.now().format('yyyyMMddHHmmss')));

            
            HttpResponse response = gateway.webCallout(requestBody,hemap, true);

            if(response.getStatusCode() == 200) {

                responsedata = response.getBody();
                infResponse =  (IFN_SFDC_LIF1007_EC001_REQ.EC001ResultWrapper)JSON.deserializeStrict((String)responsedata, IFN_SFDC_LIF1007_EC001_REQ.EC001ResultWrapper.class);

            } else {
                result_code = 'F';
                result_message = 'Interface Error';
                responsedata = '';
            }

        } catch(Exception e) {
            
            result_code = 'F';
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