public  class IFN_SFDC_LIF1007_EC001_REQ {

    public Map<String, String> mapRequestBody = new Map<String, String>();
    public String interfaceId = 'IF_SFDC_EACCT_INQ_OIL_AMOUNT';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
        


    public String callout() {

        IFN_LIF007_Callout.EC001ResultWrapper ifRes = new IFN_LIF007_Callout.EC001ResultWrapper();

        IFN_LIF007_Callout.EC001RequstWrapper param = new IFN_LIF007_Callout.EC001RequstWrapper();
        param.BASE_MON = '202212';
        param.OIL_TYPE_CD = '1';



        this.logWrap     = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog     = new IFN_CommonLog();

        
        try {
            IFN_LIF007_Callout callout = new IFN_LIF007_Callout(this.interfaceId, 'Real');
            IFN_CalloutResult calloutResult =  callout.getResponse(this.interfaceId, param);

            if('S'.equals(calloutResult.result)) {

                try {
                    ifRes =  (IFN_LIF007_Callout.EC001ResultWrapper)calloutResult.response;
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


}