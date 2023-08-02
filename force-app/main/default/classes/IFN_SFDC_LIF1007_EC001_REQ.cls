global  class IFN_SFDC_LIF1007_EC001_REQ {

    public Map<String, String> mapRequestBody = new Map<String, String>();
    public String interfaceId = 'IF_SFDC_EACCT_INQ_OIL_AMOUNT';

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
        

    public IFN_SFDC_LIF1007_EC001_REQ() {}

    global String callout() {

        IFX_LIF007_Callout.EC001ResultWrapper res = new IFX_LIF007_Callout.EC001ResultWrapper();

        
        try {

            
            
            

        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
            this.logWrap.Status = 'ERROR';
            System.debug(e.getLineNumber() + ':::' + e.getMessage());

        }

        commlog.insertLog(this.logWrap);

        return Json.serialize(res);

    }


}