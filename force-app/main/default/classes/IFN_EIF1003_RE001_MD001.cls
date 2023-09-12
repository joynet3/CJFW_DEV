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

    public class TestCall {
        public Map<String, Object> call() {
            HttpRequest requestH = new HttpRequest();
            HttpResponse response2 = new HttpResponse();
            Http http = new Http();
            requestH.setEndpoint('https://open-api-teambook.rememberapp.co.kr/stacks.json?start_at=2023-09-10&per=200');
            requestH.setMethod('GET');
            requestH.setHeader('API-CLIENT-ID', '76e500f61681efbf243cc89181bedbfb');
            requestH.setHeader('API-CLIENT-SECRET', '9d2ae4b0dc2bd85800584bcf7932a3e2');
            Map<String, Object> res = new Map<String, Object>();
//        String requestBody = System.JSON.serialize(new Clova_RequestDTO(fileUrl));
//        requestH.setBody(requestBody);

            response2 = http.send(requestH);
            if (response2.getStatusCode() == 200) {
                res = (Map<String, Object>) System.JSON.deserializeUntyped(response2.getBody());
            }
            return res;
        }

    }

    public class RE001RequestWrapper {
        public String start_at { get; set; }
//        public String end_at { get; set; }
//        public Integer page 1;
        public Integer per = 200;
    }
    public class RE001ResultWrapper {
//        public Map<String,Object> stacks;
        public List<Object> stacks;
        public Metainfo metainfo;
    }
    public class Metainfo {
        public Integer page{get;set;}
        public Integer per{get;set;}
        public Integer total_count{get;set;}
        public Integer total_pages{get;set;}
    }
}