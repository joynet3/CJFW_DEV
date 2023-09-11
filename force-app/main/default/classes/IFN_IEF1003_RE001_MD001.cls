/**
 * Created by 박지오사원 on 2023-09-08.
 */

public class IFN_IEF1003_RE001_MD001 {
    public String interfaceId = 'IFN_EIF1003_RE001_MD001';

    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;

    public IFN_CalloutResult callout(String fileUrl) {
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();

   /*     try {
            IFN_EIF1004_Callout callout = new IFN_EIF1004_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, Json.serialize(new IFN_EIF1004_CL001_MD002.CL001RequestWrapper(fileUrl)));

            if ('S'.equals(calloutResult.result)) {

            } else {

            }
        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber() + e.getMessage() + e.getStackTraceString());
            this.logWrap.Status = 'ERROR';
        }*/

        commlog.insertLog(this.logWrap);
        return calloutResult;
    }

}