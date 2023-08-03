public class IFN_LIF007_Callout {

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;

    public IFN_LIF007_Callout(){
        this.commlog = new IFN_CommonLog();
    }

    public IFN_LIF007_Callout(String interfaceId, String type){
        this.commlog         = new IFN_CommonLog();
        this.commlog.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }




    public IFN_CalloutResult getResponse(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();
        this.commlog.logWrap = this.commlog.logWrap == null ? new IFN_CommonLog.LogWrap(interfaceId, 'REAL') : this.commlog.logWrap;             

        
        try {
            switch on interfaceId {
                //----- 선박위치정보 조회용 access token 획득 I/F
                when 'IF_SFDC_EACCT_INQ_OIL_AMOUNT'{ 
                    result = IF_SFDC_EACCT_INQ_OIL_AMOUNT(interfaceId, params);
                }
                



            }
        } catch(Exception e) {
            result.setResult('E' , e.getMessage() , null); 
        } //end of try~catch


        try{
            if(this.commlog.logWrap.isRealLogInsert){
                this.commlog.insertLog(this.commlog.logWrap);
            }
        } catch(Exception e){
            System.debug('insertLog Error = '+ e.getMessage());
        }

        

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

        this.commlog.logwrap.RequestTime = System.now();
        this.commlog.logWrap.RequestBody = (String) params;
        
        
        EC001ResultWrapper infResponse = new EC001ResultWrapper();  
        try{


            Date dateToday = Date.today();
            this.logwrap = new IFN_CommonLog.logWrap();
    
            EC001RequstWrapper reqparam = new EC001RequstWrapper();
            reqparam.BASE_MON = String.valueof(dateToday.year()) + String.valueof(dateToday.month()).leftPad(2, '0');
            reqparam.OIL_TYPE_CD = 'A';



            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = JSON.serialize(reqparam);
            Map<String,String> hemap = new Map<String,String>();
            hemap.put('Interface_req_dt',String.valueOf(Datetime.now().format('yyyyMMdd')));
            hemap.put('Interface_tracekey',String.valueOf(Datetime.now().format('yyyyMMddHHmmss')));

            
            HttpResponse response = gateway.webCallout(requestBody,hemap, true);

            if(response.getStatusCode() == 200) {

                responsedata = response.getBody();
                infResponse =  (EC001ResultWrapper)JSON.deserializeStrict((String)responsedata, EC001ResultWrapper.class);

            } else {
                result_code = 'F';
                result_message = 'Interface Error';
                responsedata = '';
                this.commlog.logWrap.ErrorText.add(response.getStatus());
            }

        } catch(Exception e) {
            
            result_code = 'F';
            result_message = 'Interface Error';
        }  

        this.commlog.logwrap.ResponseTime = System.now();
        this.commlog.logWrap.ResponseBody = responsedata;
        
        this.commLog.insertLog(this.logWrap);
        
        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        return result;
    }
    





    /**
     * ==================================== 
     * 유류비 조회 Wrapper
     * =================================
     */
    /**
     * 요청 파라메터 결과 
     */
    public class EC001RequstWrapper{
        public String system_type_cd ='LIF007';
        public String opcode = 'EC001';
        public String COM_CD = 'FW00';
        public String BASE_MON {get;set;}
        public String OIL_TYPE_CD {get;set;}
    }

    /**
     * 조회 결과 
     */
    public class EC001ResultWrapper {
        public String ERR_CD;
        public String ERR_MSG_CTT;
        public EC001DsMsterData DS_MASTER;
    }

    public class EC001DsMsterData {
        public List<EC001DataList> data;
        public String SVC_ERR_MSG_TEXT;
        public Integer ErrorCode;
    }

    public class EC001DataList {
        public Integer OIL_UNITP;
        public String BASE_MON;
        public String COM_CD;
        public String OIL_TYPE_CD;
        public Integer DPRC_UNITP;
    }
    /**
     * ==================================== 
     * 유류비 조회 Wrapper
     * =================================
     */


    

}