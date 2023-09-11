/**
 * @Class : IFN_EIF1004_CL001_MD002.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023-09-08
 * @Version : 1.0
 * @Description : ClovaSpeech 음성->문자 변경 등록
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.08 | 박지오          | 최초작성
 * */
public class IFN_EIF1004_CL001_MD002 {
    public String interfaceId = 'IFN_EIF1004_CL001_MD002';

    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;

    public IFN_CalloutResult callout(String fileUrl) {
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();

        try {
            IFN_EIF1004_Callout callout = new IFN_EIF1004_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, Json.serialize(new IFN_EIF1004_CL001_MD002.CL001RequestWrapper(fileUrl)));

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

    public class CL001RequestWrapper {
        String url { get; set; }
        String language = 'ko-KR';
        String completion = 'sync';
        Map<String, Object> userdata;
        Boolean wordAlignment = true;
        Boolean fullText = true;
        Boolean resultToObs = false;
        String forbiddens = 'comma separated words';
        List<Boosting> boostings;
        Diarization diarization;

        public CL001RequestWrapper(String url) {
            this.url = url;
        }
    }
    public class Boosting {
        public String words = 'comma separated words';
    }

    public class Diarization {
        public Boolean enable = false;
        public Integer speakerCountMin;
        public Integer speakerCountMax;
    }
    public class CL001ResultWrapper {
        public Map<String, Object> result;
    }
}