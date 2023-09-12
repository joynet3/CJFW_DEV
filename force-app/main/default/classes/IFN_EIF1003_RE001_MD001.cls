/**
 * @Class : IFN_EIF1003_RE001_MD001.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023-09-11
 * @Version : 1.0
 * @Description : Remember 명함 데이터 GET
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.11 | 박지오          | 최초작성
 * */
public class IFN_EIF1003_RE001_MD001 {
    public String interfaceId = 'IFN_EIF1003_RE001_MD001';

    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;
    public IFN_EIF1003_RE001_MD001.RE001RequestWrapper param;

    public IFN_CalloutResult callout() {
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();

        try {
            IFN_EIF1003_Callout callout = new IFN_EIF1003_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, JSON.serialize(this.param));

            if ('S'.equals(calloutResult.result)) {

            } else {

            }
        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber() + e.getMessage() + e.getStackTraceString());
            this.logWrap.Status = 'ERROR';
        }

        commlog.insertLog(this.logWrap);
        return calloutResult;
    }


    public class RE001RequestWrapper {
        public String start_at { get; set; }
//        public String end_at { get; set; }
//        public Integer page 1;
        public Integer per = 200;
    }
    public class RE001ResultWrapper {
        public Map<String, Object> result;
    }
}