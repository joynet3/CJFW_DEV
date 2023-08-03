public  class IFN_SFDC_LIF1007_EC001_REQ {

    public Map<String, String> mapRequestBody = new Map<String, String>();
    public String interfaceId = 'IF_SFDC_EACCT_INQ_OIL_AMOUNT';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
        


    public String callout() {

        IFN_LIF007_Callout.EC001ResultWrapper ifRes = new IFN_LIF007_Callout.EC001ResultWrapper();

        
        try {
            IFN_LIF007_Callout callout = new IFN_LIF007_Callout();
            IFN_CalloutResult calloutResult =  callout.getResponse(this.interfaceId, null);

            if('S'.equals(calloutResult.result)) {

                try {
                    ifRes =  (IFN_LIF007_Callout.EC001ResultWrapper)calloutResult.response;
                    System.debug(ifRes.ERR_CD);
                }  catch (Exception e) {

                }

            }
            

        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
            this.logWrap.Status = 'ERROR';
            System.debug(e.getLineNumber() + ':::' + e.getMessage());

        }

        commlog.insertLog(this.logWrap);

        return Json.serialize(ifRes);

    }


}