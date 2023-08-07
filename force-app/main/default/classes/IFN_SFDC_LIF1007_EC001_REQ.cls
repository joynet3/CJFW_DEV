public  class IFN_SFDC_LIF1007_EC001_REQ {

    public Map<String, String> mapRequestBody = new Map<String, String>();
    public String interfaceId = 'IF_SFDC_EACCT_INQ_OIL_AMOUNT';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
        


    public String callout() {

        EC001ResultWrapper ifRes = new EC001ResultWrapper();

        EC001RequstWrapper param = new EC001RequstWrapper();
        param.BASE_MON = '202212';
        param.OIL_TYPE_CD = '1';



        this.logWrap     = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog     = new IFN_CommonLog();

        
        try {
            IFN_LIF007_Callout callout = new IFN_LIF007_Callout(this.interfaceId, 'Real');
            IFN_CalloutResult calloutResult =  callout.getResponse(this.interfaceId, param);

            if('S'.equals(calloutResult.result)) {

                try {
                    ifRes =  (EC001ResultWrapper)calloutResult.response;
                }  catch (Exception e) {
                    this.logWrap.ErrorCode = '-1';
                    this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
                    this.logWrap.Status = 'ERROR';
                }

            }
            

        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
            this.logWrap.Status = 'ERROR';
        }

        commlog.insertLog(this.logWrap);

        return Json.serialize(ifRes);

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