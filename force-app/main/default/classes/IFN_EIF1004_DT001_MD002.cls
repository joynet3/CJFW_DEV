/**
 * @Class : IFN_EIF1004_DT001_MD002.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.10.20
 * @Version : 1.0
 * @Description : 두탑BID : 학교별 급식정보 조회
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.20 | sancho         | 최초작성
 * */       
public class IFN_EIF1004_DT001_MD002 {

    public String interfaceId               = 'IFN_EIF1004_DT001_MD002';
    public IFN_CommonLog.LogWrap            logWrap{get;set;}
    public IFN_CommonLog                    commlog;
    
    public Output callout(MD002RequstWrapper param) {

        Output  objOutput   = new Output();
        meta    objMeta     = new meta();
        item    objItem     = new item();
        
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();

        String errResultCode;
        String errResultMsg;
      
        try {

            IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IFN_EIF1004_DT001_MD002'];
            API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = 'dotopBID_Key'];

            //https://dotop.kr/Service/API/?serviceKey=944FB5A82EAE4149B3F8AAE5C48E7752&serviceDiv=A02&NeisCodeStd=7261070&StartDate=20231001&EndDate=20231030
            
            //Output param = new Output();
            String getRquest = '';

            getRquest += 'serviceKey=' + authKey.KeyValue__c;       // ? 는 ApiGatewqy 에서 붙혀 준다.
            getRquest += '&serviceDiv=A02';                         //서비스 구분 : A01 지역별 학교정보, A02 학교별 급식정보
            getRquest += '&NeisCodeStd=' + param.NeisCodeStd;       
            getRquest += '&StartDate=' + param.StartDate;
            getRquest += '&EndDate=' + param.EndDate;               //전체 다 필수 항목이다. 없으면 exception 발생?!



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

    // Request - 학교별 급식 정보조회
    public class MD002RequstWrapper{
        public String serviceKey	{get;set;}	//서비스키(고정값)-호출 고정값
        public String serviceDiv	{get;set;}  //업무구분(고정값)
        public String NeisCodeStd	{get;set;}  //학교코드 
        public String StartDate		{get;set;}  //
        public String EndDate		{get;set;}  //
    }

    /*
    {
        "meta": [
            {
                "result_code": "0",
                "err_message": "",
                "err_stack": "",
                "total_count": "70",
                "NeisCodeStd": "7569036",
                "SchoolTitle": "안양동초등학교"
            }
        ],
        "item": [
            {
                "MealDate": "2023-10-04",
                "MealDivText": "중식",
                "MenuTitle": "칼슘찹쌀밥.",
                "AlgInfoText": "",
                "NeisCodeStd": "7569036"
            },
            {
                "MealDate": "2023-10-04",
                "MealDivText": "중식",
                "MenuTitle": "브로콜리스프.",
                "AlgInfoText": "(2.5.6.13.16)",
                "NeisCodeStd": "7569036"
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
        public String NeisCodeStd   {get;set;}
        public String SchoolTitle   {get;set;}
    }

    public class item {
        public String MealDate	    {get;set;}
        public String MealDivText   {get;set;}
        public String MenuTitle     {get;set;}
        public String AlgInfoText   {get;set;}
        public String NeisCodeStd   {get;set;}
    }

    
}