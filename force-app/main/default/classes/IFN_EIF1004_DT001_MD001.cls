/**
 * @Class : IFN_EIF1004_DT001_MD001.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.10.20
 * @Version : 1.0
 * @Description : 두탑BID : 지역별 학교 정보 조회
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.20 | sancho         | 최초작성
 * */
public class IFN_EIF1004_DT001_MD001 {

    public String interfaceId               = 'IFN_EIF1004_DT001_MD001';
    public IFN_CommonLog.LogWrap            logWrap{get;set;}
    public IFN_CommonLog                    commlog;
    
    public Output callout(MD001RequstWrapper param) {

        Output  objOutput   = new Output();
        meta    objMeta     = new meta();
        item    objItem     = new item();
        
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();

        String errResultCode;
        String errResultMsg;
      
        try {

            IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IFN_EIF1004_DT001_MD001'];
            API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = 'dotopBID_Key'];

            //https://dotop.kr/Service/API/?serviceKey=944FB5A82EAE4149B3F8AAE5C48E7752&serviceDiv=A01&Address1=서울

            //Output param = new Output();
            String getRquest = '';

            getRquest += 'serviceKey=' + authKey.KeyValue__c;       // ? 는 ApiGatewqy 에서 붙혀 준다.
            getRquest += '&serviceDiv=A01';                         //서비스 구분 : A01 지역별 학교정보, A02 학교별 급식정보
            if(param.Address1 != null && String.isNotBlank(param.Address1)) getRquest += '&Address1=' + param.Address1;
            if(param.Address2 != null && String.isNotBlank(param.Address2)) getRquest += '&Address2=' + param.Address2;



            IFN_EIF1004_Callout callout = new IFN_EIF1004_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, getRquest);

            if('S'.equals(calloutResult.result)) {
                // 메시지 전송 결과값 정상 수신
                //from 이경훈 두탑BID - result_Code 가 0 인경우는 정상적인경우이고 -1xx 오류는 정상적인 오류이고, -9xx 오류는 시스템 오류라 이야기 해주시면 수정하겠습니다.
                objOutput   = (Output)calloutResult.response;

            } else {
                // 인터페이스 처리 오류 Or Http 오류 결과 수신
                errResultCode   = calloutResult.result;
                errResultMsg    = calloutResult.message + '\n' + (String)calloutResult.response;
            }
            
        } catch (Exception e) {
            this.logWrap.ErrorCode = errResultCode;
            this.logWrap.ErrorText.add(errResultMsg + '\n');
            this.logWrap.ErrorText.add('[' + e.getLineNumber() + ']' + '\n');
            this.logWrap.ErrorText.add(e.getMessage() + '\n');
            
        }

        commlog.insertLog(this.logWrap);
        
        return objOutput;
    }

    // Request - 지역별학교정보조회
    public class MD001RequstWrapper{
        public String serviceKey	{get;set;}	//서비스키(고정값)-호출 고정값
        public String serviceDiv	{get;set;}  //업무구분(고정값)
        public String Address1		{get;set;}  //시도 값(한글, 서울,경기,...)
        public String Address2		{get;set;}  //시군구 값(한글, 성남시, 영덕군, 부평구,...)
        public String Keyword		{get;set;}  //
    }

    /*
        {
            "meta": [
                {
                    "result_code": "0",
                    "err_message": "",
                    "err_stack": "",
                    "total_count": "2000"
                }
            ],
            "item": [
                {
                    "NeisCodeStd": "7631226",
                    "SchoolTitle": "평택새빛초등학교",
                    "Tel": null,
                    "Fax": null,
                    "CountRoom": 0,
                    "CountTeacher": 0,
                    "CountStudent": 0,
                    "Address1": "경기",
                    "Address2": "경기"
                },
                {
                    "NeisCodeStd": "7652275",
                    "SchoolTitle": "해밀초등학교",
                    "Tel": null,
                    "Fax": null,
                    "CountRoom": 0,
                    "CountTeacher": 0,
                    "CountStudent": 0,
                    "Address1": "경기",
                    "Address2": "경기"
                },
    */
    
    // result
    // Output - json 최외곽
    public class Output {
        public List<meta> meta      {get;set;}
        public List<item> item      {get;set;}
    }

    public class meta {
        public String result_code	{get;set;}
        public String err_message   {get;set;}
        public String err_stack     {get;set;}
        public String total_count   {get;set;}
    }

    public class item {
        public String NeisCodeStd	{get;set;}
        public String SchoolTitle   {get;set;}
        public String Tel           {get;set;}
        public String Fax           {get;set;}
        public String CountRoom     {get;set;}
        public String CountTeacher  {get;set;}
        public String CountStudent  {get;set;}
        public String Address1      {get;set;}
        public String Address2      {get;set;}
    }

}