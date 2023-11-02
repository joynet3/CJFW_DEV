/**
 * @Class : IF_SFDC_KIND_REQ_BASE_INFO.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.10.18
 * @Version : 1.0
 * @Description : 유치원 알리미 [일반현황]
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.18 | sancho         | 최초작성
 * */
global with sharing class IF_SFDC_KIND_REQ_BASE_INFO implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Integer index;
    global List<SidoCode_Set__mdt> sidoList = new List<SidoCode_Set__mdt>();
    global  List<String> failSidoList;
    global Boolean isTarget;

    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_KIND_REQ_BASE_INFO'];
    API_Authenticationkey__mdt authKey = [select KeyValue__c from API_Authenticationkey__mdt where MasterLabel = 'KinderSchool_Key'];
    Id recordId = Schema.SObjectType.CJFW_PublicBiddingInformation__c.getRecordTypeInfosByDeveloperName().get('Kindergarten').getRecordTypeId();

    global IF_SFDC_KIND_REQ_BASE_INFO(Boolean isTarget, List<String> failSidoList) {
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
        String interfaceId = 'IF_SFDC_KIND_REQ_BASE_INFO';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();
        
        List<CJFW_PublicBiddingInformation__c> listData = new List<CJFW_PublicBiddingInformation__c>();
        //LogWrapper LogWrapper = new LogWrapper();
        

        //URL sample : https://e-childschoolinfo.moe.go.kr/api/notice/basicInfo2.do?key=apikey&sidoCode=27&sggCode=27140
        String getParameter = '';
        //System.debug('========================================시군구이름 : ' + scope[0].SiGunGuName__c);
        getParameter += '?key='+authKey.KeyValue__c;
        getParameter += '&sidoCode=' + scope[0].SidoCode__c.substring(0,2);
        getParameter += '&sggCode='+ scope[0].SidoCode__c;

        //2023.11.01 : sancho 시도/시군구 코드 넣기
        String SidoCode     = scope[0].SidoCode__c.substring(0,2);
        String SingunguCode = scope[0].SidoCode__c;


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
                    IF_SFDC_KIND_REQ_BASE_INFO.Response Response = (IF_SFDC_KIND_REQ_BASE_INFO.Response) JSON.deserialize(res.getBody(), IF_SFDC_KIND_REQ_BASE_INFO.Response.class);

                    //{"status":"SUCCESS","kinderInfo":[{"key":"1","kindercode":"1ecec08c-eecb-b044-e053-0a32095ab044","o
                    if(Response != null && Response.kinderInfo != null && Response.kinderInfo.size() > 0){

                        //2023.11.01 PickList
                        List<String> sidoMap    = IFN_Util.getPickList('CJFW_PublicBiddingInformation__c', 'State__c');
                        List<String> sigunguMap = IFN_Util.getPickList('CJFW_PublicBiddingInformation__c', 'City__c');

                        for (IF_SFDC_KIND_REQ_BASE_INFO.kinderInfo info : Response.kinderInfo) {
                            
                            CJFW_PublicBiddingInformation__c bidObj = new CJFW_PublicBiddingInformation__c();

                            bidObj.OfficeEdu__c		    = info.officeedu		;	//text
                            bidObj.SubOffiIceEdu__c	    = info.subofficeedu     ;	//text
                            bidObj.KinderCode__c	    = info.kinderCode	    ;	//text
                            bidObj.Name				    = info.kindername	    ;	//Name
                            bidObj.establiIshType__c    = info.establish	    ;	//text
                            bidObj.rppnName__c		    = info.rppnname	        ;	//text
                            bidObj.ldgrName__c		    = info.ldgrname	        ;	//text
                            //bidObj.establishDate__c	    = info.edate != null && info.edate != '' ? Date.valueOf(info.edate)	: null	    ;	//Date
                            //bidObj.OpenDate__c		    = info.odate != null && info.edate != '' ? Date.valueOf(info.edate)	: null	    ;	//Date
                            // 안되네...;;;
                            if (info.edate <> null && info.edate <> '') {
                                Date dt = Date.newInstance(Integer.valueOf(info.edate.substring(0,4)), Integer.valueOf(info.edate.substring(4,6)), Integer.valueOf(info.edate.substring(6,8)));
                                bidObj.establishDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                            }
                            if (info.odate <> null && info.odate <> '') {
                                Date dt = Date.newInstance(Integer.valueOf(info.odate.substring(0,4)), Integer.valueOf(info.odate.substring(4,6)), Integer.valueOf(info.odate.substring(6,8)));
                                bidObj.OpenDate__c      = Date.newInstance(dt.year(), dt.month(), dt.day());
                            }

                            bidObj.Address__c		    = info.addr		        ;	//text
                            bidObj.Phone__c			    = info.telno		    ;	//phone
                            bidObj.Homepage__c		    = info.hpaddr		    ;	//url
                            bidObj.OperTime__c		    = info.opertime	        ;	//text
                            bidObj.clcnt3__c		    = info.clcnt3	!= null && info.clcnt3		!= '' ? Decimal.valueOf(info.clcnt3	)		: null   ;	//number
                            bidObj.clcnt4__c		    = info.clcnt4	!= null && info.clcnt4		!= '' ? Decimal.valueOf(info.clcnt4	)    	: null	;	//number
                            bidObj.clcnt5__c		    = info.clcnt5	!= null && info.clcnt5		!= '' ? Decimal.valueOf(info.clcnt5	)    	: null	;	//number
                            bidObj.mixclcnt__c		    = info.mixclcnt	!= null && info.mixclcnt	!= '' ? Decimal.valueOf(info.mixclcnt	)   : null   ;	//number
                            bidObj.shclcnt__c		    = info.shclcnt	!= null && info.shclcnt		!= '' ? Decimal.valueOf(info.shclcnt	)   : null	;	//number
                            bidObj.prmstfcnt__c		    = info.prmstfcnt!= null && info.prmstfcnt	!= '' ? Decimal.valueOf(info.prmstfcnt)    	: null	;	//number
                            bidObj.ag3fpcnt__c		    = info.ag3fpcnt	!= null && info.ag3fpcnt	!= '' ? Decimal.valueOf(info.ag3fpcnt	)   : null   ;	//number
                            bidObj.ag4fpcnt__c		    = info.ag4fpcnt	!= null && info.ag4fpcnt	!= '' ? Decimal.valueOf(info.ag4fpcnt	)   : null   ;	//number
                            bidObj.ag5fpcnt__c		    = info.ag5fpcnt	!= null && info.ag5fpcnt	!= '' ? Decimal.valueOf(info.ag5fpcnt	)   : null   ;	//number
                            bidObj.mixfpcnt__c		    = info.mixfpcnt	!= null && info.mixfpcnt	!= '' ? Decimal.valueOf(info.mixfpcnt	)   : null   ;	//number
                            bidObj.spcnfpcnt__c		    = info.spcnfpcnt!= null && info.spcnfpcnt	!= '' ? Decimal.valueOf(info.spcnfpcnt)    	: null	;	//number
                            bidObj.ppcnt3__c		    = info.ppcnt3	!= null && info.ppcnt3		!= '' ? Decimal.valueOf(info.ppcnt3	)    	: null	;	//number
                            bidObj.ppcnt4__c		    = info.ppcnt4	!= null && info.ppcnt4		!= '' ? Decimal.valueOf(info.ppcnt4	)    	: null	;	//number
                            bidObj.ppcnt5__c		    = info.ppcnt5	!= null && info.ppcnt5		!= '' ? Decimal.valueOf(info.ppcnt5	)    	: null	;	//number
                            bidObj.mixppcnt__c		    = info.mixppcnt	!= null && info.mixppcnt	!= '' ? Decimal.valueOf(info.mixppcnt	)   : null   ;	//number
                            bidObj.shppcnt__c		    = info.shppcnt	!= null && info.shppcnt		!= '' ? Decimal.valueOf(info.shppcnt	)	: null	;	//number
                            bidObj.pbntTmng__c		    = info.pbnttmng	        ;	//text

                            bidObj.State__c             = sidoMap.contains(SidoCode) ? SidoCode : null;    //SidoCode
                            bidObj.City__c              = sigunguMap.contains(SingunguCode) ? SingunguCode : null; //sigunguMap

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
            //logWrap.LogText.add('listData ::: ' + listData);
            
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
            IF_SFDC_KIND_REQ_BASE_INFO b = new IF_SFDC_KIND_REQ_BASE_INFO(true, failSidoList);
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
        public String officeedu   ;
        public String subofficeedu;
        public String kinderCode  ;
        public String kindername  ;
        public String establish   ;
        public String rppnname    ;
        public String ldgrname    ;
        public String edate       ;
        public String odate       ;
        public String addr        ;
        public String telno       ;
        public String hpaddr      ;
        public String opertime    ;
        public String clcnt3      ;
        public String clcnt4      ;
        public String clcnt5      ;
        public String mixclcnt    ;
        public String shclcnt     ;
        public String prmstfcnt   ;
        public String ag3fpcnt    ;
        public String ag4fpcnt    ;
        public String ag5fpcnt    ;
        public String mixfpcnt    ;
        public String spcnfpcnt   ;
        public String ppcnt3      ;
        public String ppcnt4      ;
        public String ppcnt5      ;
        public String mixppcnt    ;
        public String shppcnt     ;
        public String pbnttmng	  ;
    }
    



}