global  class IFN_SFDC_LIF1007_EC001_REQ {

    public Map<String, String> mapRequestBody = new Map<String, String>();
    public String interfaceId = 'IF_SFDC_EACCT_INQ_OIL_AMOUNT';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
        

    public IFN_SFDC_LIF1007_EC001_REQ() {}

    global String callout() {

        IFN_SFDC_LIF1007_EC001_REQ.Result res = new IFN_SFDC_LIF1007_EC001_REQ.Result();
        Date dateToday = Date.today();
        this.logwrap = new IFN_CommonLog.logWrap();

        IFN_SFDC_LIF1007_EC001_REQ.requstParam reqparam = new IFN_SFDC_LIF1007_EC001_REQ.requstParam();
        reqparam.BASE_MON = String.valueof(dateToday.year()) + String.valueof(dateToday.month()).leftPad(2, '0');
        reqparam.OIL_TYPE_CD = 'A';
        System.debug('aaaaaaaaaaa');
        
        try {
            IFN_ApiGateWay gateway = new IFN_ApiGateWay(this.interfaceId);
            String requestBody = JSON.serialize(reqparam);

            
            system.debug( 'check Input ::: ' + requestBody );
            HttpResponse response = gateway.webCallout(requestBody, true);


            system.debug( 'response.getStatusCode() ::: ' + response.getStatusCode() );
            system.debug( 'check Output ::: ' + response.getBody() );


        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
            this.logWrap.Status = 'ERROR';

        }

        commlog.insertLog(this.logWrap);

        return Json.serialize(res);

    }


    /**
     * 조회 파라메터  
     */
    global class requstParam{
        public String system_type_cd ='LIF1007';
        public String opcode = 'EC001';
        public String COM_CD = 'FW00';
        public String BASE_MON {get;set;}
        public String OIL_TYPE_CD {get;set;}
    }

    /**
     * ==================================== 
     * 조회 결과 
     * =================================
     */
    global class Result {
        public String ERR_CD;
        public String ERR_MSG_CTT;
        public String DS_MASTER;
    }

    global class dsMsterData {
        public List<dataList> data;
        public String SVC_ERR_MSG_TEXT;
        public Integer ErrorCode;
    }

    global class dataList {
        public Integer OIL_UNITP;
        public String BASE_MON;
        public String COM_CD;
        public String OIL_TYPE_CD;
        public Integer DPRC_UNITP;
    }
    /**
     * ==================================== 
     * 조회 결과 
     * =================================
     */

}