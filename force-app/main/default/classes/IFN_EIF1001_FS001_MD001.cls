/**
 * @Class : IFN_EIF1001_FS001_MD001.cls
 * @group Framework : 
 * @Author : sancho
 * @Date : 2023.08.29
 * @Version : 1.0
 * @Description : 식품(첨가물)품목제조보고-전용유 조회
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.29 | sancho         | 최초작성
 * */
global with sharing class IFN_EIF1001_FS001_MD001 implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {

    String interfaceId = 'IFN_EIF1001_FS001_MD001';

    IFMaster__c ifMasterObj =               [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name =: interfaceId];
    API_Authenticationkey__mdt authKey =    [SELECT KeyValue__c, DateRange__c, MasterLabel FROM API_Authenticationkey__mdt WHERE MasterLabel = '식품의약품안전처_Key'];

    List<String> globalCount = new List<String>();
    
    global IFN_EIF1001_FS001_MD001() {}

    IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
    IFN_CommonLog commlog = new IFN_CommonLog();


    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 식품(첨가물)품목제조보고
    ************************************************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {
        globalCount.add(String.valueOf(1));     // 1회 수행 한다.
        return globalCount;
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 식품(첨가물)품목제조보고
    ************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<String> scope) {
        String errResultCode;
        String errResultMsg;
        try{
            
            //  https://openapi.foodsafetykorea.go.kr/api/dfc53a7c97a844899df4/I1250/json/1/1000/PRDLST_NM=%EC%A0%84%EC%9A%A9%EC%9C%A0
            
            // --- 2023.08.30 : IFMaster Endpoint 에 전체 URL 저장 한다. ApiGateWay 방식으로 하려면, 파라메터를 넘기는 식으로 하려면, 혼선이 있을 수 있다.
            //                  현재 업무는 단일 고정이며, 유니크한 url 이기에 Endpoint에 고정하기로 한다.

            // *** http ***
            // Http http = new Http();
            // HttpRequest request = new HttpRequest();
            // request.setEndpoint(ifMasterObj.Endpoint__c + getRquest);
            // request.setHeader('content-type', ifMasterObj.ContentType__c);
            // request.setMethod(ifMasterObj.Method__c);
            // request.setTimeout(110000);
            // HttpResponse res = http.send(request);
            // Integer totalCount = 0;
            // Integer numOfRow = 0;


            
            IFN_CalloutResult ifRes = new IFN_CalloutResult();
            Output param = new Output();

            try {
                IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout(this.interfaceId, 'Real');
                ifRes = callout.getResponse(this.interfaceId, param);                                   //  <-------------- callout

                // To - Be ...
                /*
    @AuraEnabled public String result{get;set;}
    @AuraEnabled public String message{get;set;}
    @AuraEnabled public Object response{get;set;}
    @AuraEnabled public Integer totalCount{get;set;}    
    public IFN_CommonLog.LogWrap log{get;set;}
                */
                //if (ifRes.getStatusCode() == 200) {
                if(ifRes.result.equals('S')){
                
                    List<CJFW_FoodAdditives__c>     insList     = new List<CJFW_FoodAdditives__c>();
                    CJFW_FoodAdditives__c           insObj      = new CJFW_FoodAdditives__c();
                    
                    //Output outObj = (Output) JSON.deserialize(ifRes.getBody(), Output.class); //callout 에서 Output 형으로 만들어 response 에 넣어 뒀다.
                    Output outObj = (Output)ifRes.response;
                    for(row nowrow : outObj.i1250.row){
                        insObj = Converter(nowrow);
                        insList.add(insObj);
                    }
    
                    if(insList != null && insList.size() >= 1){
                        List<CJFW_FoodAdditives__c> delList = [Select Id From CJFW_FoodAdditives__c];
                        if(delList != null) delete delList;
                    }
    
                    insert insList;
    
                    logWrap.LogText.add(outObj.i1250.Result.CODE + '/' + outObj.i1250.Result.MSG);
                    
                    //Input input = (Input)JSON.deserialize(requestBody,  Input.class);
                    //global static CJFW_FoodAdditives__c Converter(row row){
                }else{
                    
                    errResultCode   = ifRes.result;
                    errResultMsg    = ifRes.message + '\n' + (String)ifRes.response;
   
                }


            } catch (Exception e) {
                this.logWrap.ErrorCode = '-1';
                this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
                this.logWrap.Status = 'ERROR';
            }

            
        } catch(Exception e) {
            
            logWrap.ErrorCode = errResultCode;
            logWrap.ErrorText.add(errResultMsg + '\n');
            logWrap.ErrorText.add('[' + e.getLineNumber() + ']' + '\n');
            logWrap.ErrorText.add(e.getMessage() + '\n');
        }

        
        commlog.insertLog(logWrap);
    }


    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 실패한 건에 대한 재호출
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('batch finish start ====================');
    }

    global static CJFW_FoodAdditives__c Converter(row row){
        CJFW_FoodAdditives__c item = new CJFW_FoodAdditives__c();
        item.LCNS_NO__c						= row.LCNS_NO					;
        item.BSSH_NM__c						= row.BSSH_NM					;
        item.PRDLST_REPORT_NO__c			= row.PRDLST_REPORT_NO			;
        item.PRMS_DT__c						= row.PRMS_DT					;
        item.PRDLST_NM__c					= row.PRDLST_NM					;
        item.PRDLST_DCNM__c					= row.PRDLST_DCNM				;
        item.PRODUCTION__c					= row.PRODUCTION				;
        item.HIENG_LNTRT_DVS_NM__c			= row.HIENG_LNTRT_DVS_NM		;
        item.CHILD_CRTFC_YN__c				= row.CHILD_CRTFC_YN			;
        item.POG_DAYCNT__c					= row.POG_DAYCNT				;
        item.LAST_UPDT_DTM__c				= row.LAST_UPDT_DTM				;
        item.INDUTY_CD_NM__c				= row.INDUTY_CD_NM				;
        item.QLITY_MNTNC_TMLMT_DAYCNT__c	= row.QLITY_MNTNC_TMLMT_DAYCNT	;
        item.USAGE__c						= row.USAGE						;
        item.PRPOS__c						= row.PRPOS						;

        return item;
    }




    
    /*
    {
        "I1250": {
            "total_count": "1000",
            "row": [
                {
                    "PRDLST_REPORT_NO": "19630364001121",
                    "PRMS_DT": "19920822",
                    "LAST_UPDT_DTM": "20160706",
                    "LCNS_NO": "19630364001",
                    "PRDLST_NM": "허벌엣센스케이",
                    "QLITY_MNTNC_TMLMT_DAYCNT": "",
                    "BSSH_NM": "(주)보락",
                    "PRDLST_DCNM": "혼합제제",
                    "CHILD_CRTFC_YN": "",
                    "INDUTY_CD_NM": "식품첨가물제조업",
                    "USAGE": "착향료",
                    "POG_DAYCNT": "유통기간미등록",
                    "HIENG_LNTRT_DVS_NM": "해당없음",
                    "PRODUCTION": "아니오",
                    "PRPOS": ""
                }
            ],
            "RESULT": {
                "MSG": "정상처리되었습니다.",
                "CODE": "INFO-000"
            }
        }
    }
    */

    global class Output {
        public I1250 i1250						{get;set;}
    }
    global class I1250 {
        public String total_count   			{get;set;}
        public List<row> row					{get;set;}
        public RESULT Result					{get;set;}
    }
    global class row {
        public String PRDLST_REPORT_NO			{get;set;}
        public String PRMS_DT					{get;set;}
        public String LAST_UPDT_DTM				{get;set;}
        public String LCNS_NO					{get;set;}
        public String PRDLST_NM					{get;set;}
        public String QLITY_MNTNC_TMLMT_DAYCNT	{get;set;}
        public String BSSH_NM					{get;set;}
        public String PRDLST_DCNM				{get;set;}
        public String CHILD_CRTFC_YN			{get;set;}
        public String INDUTY_CD_NM				{get;set;}
        public String USAGE						{get;set;}
        public String POG_DAYCNT				{get;set;}
        public String HIENG_LNTRT_DVS_NM		{get;set;}
        public String PRODUCTION				{get;set;}
        public String PRPOS						{get;set;}
    }
    global class RESULT {
        public String MSG						{get;set;}
        public String CODE						{get;set;}
    }

    // from callout  전달용
    public class ResObject {
        public Object response					{get;set;}
    }

    

    
}