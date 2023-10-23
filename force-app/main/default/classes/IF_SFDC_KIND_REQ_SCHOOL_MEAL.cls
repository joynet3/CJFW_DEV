/**
 * @Class : IF_SFDC_KIND_REQ_SCHOOL_MEAL.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.10.18
 * @Version : 1.0
 * @Description : 유치원 알리미 [급식운영현황]
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.19 | sancho         | 최초작성
 * */
global with sharing class IF_SFDC_KIND_REQ_SCHOOL_MEAL implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Integer index;
    global List<SidoCode_Set__mdt> sidoList = new List<SidoCode_Set__mdt>();
    global  List<String> failSidoList;
    global Boolean isTarget;

    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_KIND_REQ_SCHOOL_MEAL'];
    API_Authenticationkey__mdt authKey = [select KeyValue__c from API_Authenticationkey__mdt where MasterLabel = 'KinderSchool_Key'];
    Id recordId = Schema.SObjectType.CJFW_PublicBiddingInformation__c.getRecordTypeInfosByDeveloperName().get('Kindergarten').getRecordTypeId();

    global IF_SFDC_KIND_REQ_SCHOOL_MEAL(Boolean isTarget, List<String> failSidoList) {
        this.isTarget = isTarget;
        this.failSidoList = failSidoList;
        if(this.failSidoList == null) {
            this.failSidoList = new List<String>();
        }
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 시도 메타데이터 조회
    *  sancho - 사용자정의 메타에 local_govCD__mdt (지방자치단체코드) 가 있으나
                , SidoCode_Set__mdt(어린이집정보공개포털 API 파라미터)를 별도로 만들어 사용 중이다.
                이유가 있을것으로 예상, 어린이집용 메타를 사용한다.
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        List<String> tempList = new List<String>();
        tempList = failSidoList;
        if (Test.isRunningTest()) {
            strQuery += '    SELECT SidoCode__c, SiGunGuName__c ';
            strQuery += '    FROM SidoCode_Set__mdt ';
            strQuery += '    WHERE isActive__c = TRUE';
            strQuery += '    LIMIT 1 ';
        }else {
            //활성화된 시군구 코드 조회 커스텀 메타데이터에서 시군구 조회 활성화/비활성화 가능
            strQuery += '    SELECT SidoCode__c, SiGunGuName__c ';
            strQuery += '    FROM SidoCode_Set__mdt ';
            strQuery += '    WHERE isActive__c = TRUE';
        }

        if(isTarget) {
            strQuery += '    AND SidoCode__c IN:tempList';
            failSidoList = new List<String>();
        }
        System.debug('=============================:::batch start');
        return Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 어린이집정보 API 호출 및 CJFW_PublicBiddingInformation__c upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<SidoCode_Set__mdt> scope) {


        String strCode = '0000';
        String strMessage = 'Success.';
        String interfaceId = 'IF_SFDC_KIND_REQ_SCHOOL_MEAL';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();
        
        List<CJFW_PublicBiddingInformation__c> listData = new List<CJFW_PublicBiddingInformation__c>();
        //LogWrapper LogWrapper = new LogWrapper();

        //URL sample : https://e-childschoolinfo.moe.go.kr/api/notice/schoolMeal.do?key=apikey&sidoCode=27&sggCode=27140

        String getParameter = '';
        //System.debug('========================================시군구이름 : ' + scope[0].SiGunGuName__c);
        getParameter += '?key='+authKey.KeyValue__c;
        getParameter += '&sidoCode=' + scope[0].SidoCode__c.substring(0,2);
        getParameter += '&sggCode='+ scope[0].SidoCode__c;

        //System.debug('==============================getParameter:::' + getParameter);
        //System.debug('============================== URL :::' + ifMasterObj.EndPoint__c + getParameter);

        logWrap.LogText.add('URL ::: ' + ifMasterObj.EndPoint__c + getParameter );
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ifMasterObj.EndPoint__c + getParameter);
        //system.debug(request.getEndpoint());
        request.setHeader('content-type', ifMasterObj.ContentType__c);
        request.setMethod(ifMasterObj.Method__c);
        request.setTimeout(110000);
        
        String requestBody = '';
        IFN_CMM_ERRUTIL.ErrorValueWrapper errWr = new IFN_CMM_ERRUTIL.ErrorValueWrapper();

        try {
            //LogWrapper.requestBody = ifMasterObj.EndPoint__c + getParameter;

            HttpResponse res = http.send(request);
            if(res.getStatusCode() == 200) {
                if(res.getBody() <> null){

                    logWrap.ResponseTime = Datetime.now();
                    logWrap.responseBody = res.getBody();
                    //System.debug('=========================> 1:' + res.getBody());
                    IF_SFDC_KIND_REQ_SCHOOL_MEAL.Response Response = (IF_SFDC_KIND_REQ_SCHOOL_MEAL.Response) JSON.deserialize(res.getBody(), IF_SFDC_KIND_REQ_SCHOOL_MEAL.Response.class);

                    logWrap.LogText.add(Response.status);
                    logWrap.LogText.add(Response.message);
                    
                    // SUCCESS : 성공, DENIED : 실패, ERROR : 실패
                    // ex. {"status":"SUCCESS","kinderInfo":[{"key":"1","kindercode":"1ecec08c-eecb-b044-e053-0a32095ab044","o
                    if(Response != null && Response.kinderInfo != null && Response.kinderInfo.size() > 0){

                        for (IF_SFDC_KIND_REQ_SCHOOL_MEAL.kinderInfo info : Response.kinderInfo) {
                            
                            CJFW_PublicBiddingInformation__c bidObj = new CJFW_PublicBiddingInformation__c();

                            bidObj.OfficeEdu__c	    		= info.officeedu            ;		//text
                            bidObj.SubOffiIceEdu__c			= info.subofficeedu         ;		//text
                            bidObj.KinderCode__c	    	= info.kinderCode           ;		//text
                            bidObj.Name	            		= info.kindername           ;		//Name
                            bidObj.establiIshType__c		= info.establish            ;		//text
                            bidObj.mlsrOprnWayTpCd__c		= info.mlsr_oprn_way_tp_cd  ;		//text
                            bidObj.consEntsNm__c	    	= info.cons_ents_nm         ;		//text
                            bidObj.alKpcnt__c	        	= info.al_kpcnt             != null && info.al_kpcnt             != '' ? Decimal.valueOf(info.al_kpcnt            ) : null;		//number
                            bidObj.mlsrKpcnt__c	    		= info.mlsr_kpcnt           != null && info.mlsr_kpcnt           != '' ? Decimal.valueOf(info.mlsr_kpcnt          ) : null;		//number
                            bidObj.nutrTchrAgmtYn__c		= info.ntrt_tchr_agmt_yn == 'Y' ? true : false;		//checkbox
                            bidObj.sngeAgmtNurtThcnt__c		= info.snge_agmt_ntrt_thcnt	!= null && info.snge_agmt_ntrt_thcnt != '' ? Decimal.valueOf(info.snge_agmt_ntrt_thcnt) : null;		//number
                            bidObj.cprtAgmtNtrtThcnt__c		= info.cprt_agmt_ntrt_thcnt	!= null && info.cprt_agmt_ntrt_thcnt != '' ? Decimal.valueOf(info.cprt_agmt_ntrt_thcnt) : null;		//number
                            bidObj.ckcnt__c	        		= info.ckcnt                != null && info.ckcnt                != '' ? Decimal.valueOf(info.ckcnt               ) : null;		//number
                            bidObj.cmcnt__c	        		= info.cmcnt                != null && info.cmcnt                != '' ? Decimal.valueOf(info.cmcnt               ) : null;		//number
                            bidObj.masMsplDclrYn__c			= info.mas_mspl_dclr_yn == 'Y' ? true : false;		//checkbox
                            bidObj.pbntTmng__c	        	= info.pbntTmng             ;		//text

                            bidObj.RecordtypeId         = recordId;
                            listData.add(bidObj);
                        }

                    }

                }else{
                    errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_BODYCTT_EMPTY_ERROR);
                    strCode = errWr.err_code;
                    strMessage = errWr.err_msg;
                    logWrap.ErrorCode = strCode;
                    logWrap.ErrorText.add(strMessage);
                }
            }else {
                //http status 200 이외의 통신에러는 failsidoList에 담아서 한번더 실행
                failSidoList.add(scope[0].SidoCode__c);
                System.debug('failsidolist === ' + failSidoList);
            }

            logWrap.LogText.add('listData.size ::: ' + listData.size());
            
            upsert listData KinderCode__c;

        }catch(Exception e) {
            errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_SERVER_ERROR);
            strCode = errWr.err_code;
            strMessage = errWr.err_msg;
            strMessage +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']';
            logWrap.ErrorCode = strCode;
            logWrap.ErrorText.add(strMessage);
        }

        logWrap.resultCode = strCode;
        logWrap.resultMessage = strMessage;

        commlog.insertLog(logWrap);
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 실패한 건에 대한 재호출
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('=============================:::batch finish');
        System.debug('=============================:::failSidoList : '+failSidoList);
        //실패한 건에 대한 재귀함수
        if(!failSidoList.isEmpty()){
            System.debug('failSidolist: ' + failSidolist);
            IF_SFDC_KIND_REQ_SCHOOL_MEAL b = new IF_SFDC_KIND_REQ_SCHOOL_MEAL(true, failSidoList);
            Database.executeBatch(b,1);
        }
    }



    global class Input{
        public Response response;
    }

    global class Response{
        public String message     ;
        public String status      ;
        public List<kinderInfo> kinderInfo;
    }

    global class kinderInfo{
        public String officeedu           ;
        public String subofficeedu        ;
        public String kinderCode          ;
        public String kindername          ;
        public String establish           ;
        public String mlsr_oprn_way_tp_cd ;
        public String cons_ents_nm        ;
        public String al_kpcnt            ;
        public String mlsr_kpcnt          ;
        public String ntrt_tchr_agmt_yn   ;
        public String snge_agmt_ntrt_thcnt;
        public String cprt_agmt_ntrt_thcnt;
        public String ckcnt               ;
        public String cmcnt               ;
        public String mas_mspl_dclr_yn	  ;
        public String pbntTmng            ;
    }



}