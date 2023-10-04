/**
 * @Class : IFN_EIF1003_CL001_MD001.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023-09-08
 * @Version : 1.0
 * @Description : ClovaSpeech STT 등록
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.08 | 박지오          | 최초작성
 * */
public class IFN_EIF1003_CL001_MD001 {
    public String interfaceId = 'IFN_EIF1003_CL001_MD001';

    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;

    public IFN_CalloutResult callout(String fileUrl) {
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();

        try {
            IFN_EIF1003_Callout callout = new IFN_EIF1003_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, JSON.serialize(new IFN_EIF1003_CL001_MD001.CL001RequestWrapper(fileUrl)));

            System.debug(calloutResult);
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
//        Map<String, Object> userdata;
        Boolean wordAlignment = true;
        Boolean fullText = true;
        Boolean resultToObs = false;
        String forbiddens = 'comma separated words';
//        List<Boosting> boostings = new List<Boosting>();
//        Diarization diarization = new Diarization();

        public CL001RequestWrapper(String url) {
            this.url = url;
        }
    }
    public class Boosting {
        public String words { get; set; }
    }

    public class Diarization {
        public Integer label { get; set; }
        public Boolean enable { get; set; }
        public Integer speakerCountMin { get; set; }
        public Integer speakerCountMax { get; set; }
    }
    public class CL001ResultWrapper {
        public Object result { get; set; }
    }
    public class ResponseSync {
        public String result { get; set; }
        public String message { get; set; }
        public String token { get; set; }
        public String version { get; set; }
        public Params params { get; set; }
        public Integer progress { get; set; }
        public Keywords keywords { get; set; }
        public List<Segment>segments { get; set; }
        public String text { get; set; }
        public Double confidence { get; set; }
        public List<Speaker> speakers { get; set; }
    }
    public class Params {
        public String service { get; set; }
        public String domain { get; set; }
        public String lang { get; set; }
        public String completion { get; set; }
//        public String callback { get; set; }
        public Diarization diarization { get; set; }
        public List<Boosting> boostings { get; set; }
        public String forbiddens { get; set; }
        public Boolean wordAlignment { get; set; }
        public Boolean fullText { get; set; }
        public Boolean noiseFiltering { get; set; }
        public Boolean resultToObs { get; set; }
        public Integer priority { get; set; }
        public UserData userdata { get; set; }


    }
    public class UserData {
        public String ncp_DomainCode { get; set; }
        public Integer ncp_DomainId { get; set; }
        public Integer ncp_TaskId { get; set; }
        public String ncp_TraceId { get; set; }
    }
    public class Keywords {

    }
    public class Segment {
        public Integer start { get; set; }
        public Integer endCnt { get; set; }
        public String text { get; set; }
        public Double confidence { get; set; }
        public Diarization diarization { get; set; }
        public Speaker speaker { get; set; }
        public List<Word> words { get; set; }
        public String textEdited { get; set; }
    }
    public class Speaker {
        public String label { get; set; }
        public String name { get; set; }
        public Boolean edited { get; set; }
    }
    public class Word {
        public Integer st { get; set; }
        public Integer en { get; set; }
        public String value { get; set; }
    }
}