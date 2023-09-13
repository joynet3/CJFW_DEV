/**
 * @Class : IFN_EIF1001_EC002_MD004.cls
 * @group Framework : 알림 발송
 * @Author : 김동영
 * @Date : 2023-08-28
 * @Version : 1.0
 * @Description : MMS 이미지 업로드
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.28 | 김동영          | 최초작성
 * */
public class IFN_EIF1001_EC002_MD004 {
    public String interfaceId = 'IFN_EIF1001_EC002_MD004';
    public String contDocId;
    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;

    public static final Map<String, String> convertMessage = new Map<String, String>{
        'InvalidImageMaxLengthException' =>'이미지 용량 초과', 
        'InvalidImageShapeException' =>'발송할 수 없는 이미지 사이즈',
        'InvalidImageFormatException' =>'지원하지 않는 이미지 형식',
        'FailedToUploadImageException' =>'카카오 시스템 오류'
    };
        
    public IFN_CalloutResult callout() {
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();
        EC002RequstWrapper param = new EC002RequstWrapper();

        ContentVersion content = [select id, versiondata 
                                    from ContentVersion
                                   where ContentDocumentId = :contDocId 
                                     and isLatest = true
                                    limit 1];

        Blob fileData = content.VersionData;
        param.image = EncodingUtil.base64Encode(fileData);

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();
      
        try {
            IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, param);
        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
            this.logWrap.Status = 'ERROR';
        }

        commlog.insertLog(this.logWrap);
        return calloutResult;
    }

    // Request
    public class EC002RequstWrapper{
        public String image {get;set;}
    }

    // result
    public class EC002ResultWrapper {
        public Object response;
    }

    // Success Response Wrapper
    public class EC002Response{
        public EC002SuccessData data;
    }

    // Success Response Data
    public class EC002SuccessData {
        public String image_key;
        public String request_date;
        public String name;
        public String url;
    }

    // Error Response Data
    public class EC002ErrorData {
        public String errcode;
        public String errmsg;
    }
}