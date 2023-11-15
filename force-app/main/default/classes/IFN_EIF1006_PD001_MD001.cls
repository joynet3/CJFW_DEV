/**
 * @Class : EIF1006_PD001_MD001.cls - 조달청(나라장터) 낙찰 정보(물품, 공사, 용역)
 * @group Framework : 
 * @Author : 
 * @Date : 2023.11.13
 * @Version : 1.0
 * @Description : PD001 : 조달청(나라장터), PD002 : 방사청
 *              numOfRows - 1000 이면, 10건만 준다. 999건까지는 한번에 줌.
 *              낙찰자가 [씨제이프레시웨이주식회사] 인 경우 O/X 처리
 *              inqryDiv 에 따라 처리 할 수 있게 만들까 말까? (1.둥록일시, 2.공고일시, 3.개찰일시, 4.입찰공고번호)
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.13 | sancho         | 최초작성
 * */
//global with sharing class IFN_EIF1006_PD001_MD001 implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
global with sharing class IFN_EIF1006_PD001_MD001 implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {

    global String                   interfaceId = 'IFN_EIF1006_PD001_MD001';

    global IFN_CommonLog.LogWrap    logWrap{get;set;}
    global IFN_CommonLog            commlog;

    global String                   workDivision;
    global String                   inqryDiv;
    global String                   inqryBgnDt;
    global String                   inqryEndDt;
    global String                   bidNtceNo;

    //Constructor here
    
    /*
        한 페이지 결과 수	numOfRows	4	    필수	10	한 페이지 결과 수
        페이지 번호	        pageNo	    4	    필수	1	페이지 번호
        서비스키	        ServiceKey	400	    필수	공공데이터포털에서 받은 인증키	공공데이터포털에서 받은 인증키
        조회구분	        inqryDiv	1	    필수	1	검색하고자하는 조회구분 1.둥록일시, 2.공고일시, 3.개찰일시, 4.입찰공고번호
        조회시작일시	    inqryBgnDt	12	    옵션	201605010000	검색하고자하는 시작일시 ‘YYYYMMDDHHMM', 조회구분 1,2,3일 경우 필수
        조회종료일시	    inqryEndDt	12	    옵션	201605052359	검색하고자하는 종료일시 'YYYYMMDDHHMM', 조회구분 1,2,3일 경우 필수
        입찰공고번호	    bidNtceNo	40	    옵션	20160439522	검색하고자하는 입찰공고번호. 조회구분 4인 경우 필수
        타입	            type	    4	    옵션	json	오픈API 리턴 타입을 JSON으로 받고 싶을 경우 'json' 으로 지정
    */
    
    //기본 수행 시 생성자
    global IFN_EIF1006_PD001_MD001(String workDivision) {
        this.workDivision   = workDivision;
    }
    //쓸일은 없겠으나, 혹시나 만들어 두는 생성자
    global IFN_EIF1006_PD001_MD001(String workDivision, String inqryDiv, String inqryBgnDt, String inqryEndDt, String bidNtceNo ) {
        this.workDivision   = workDivision  ;
        this.inqryDiv       = inqryDiv      ;
        this.inqryBgnDt     = inqryBgnDt    ;
        this.inqryEndDt     = inqryEndDt    ;
        this.bidNtceNo      = bidNtceNo     ;
    }

    List<String> globalCount = new List<String>();
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 나라장터 3종 물품, 용역, 외자 처리
    ************************************************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {
        this.commlog = new IFN_CommonLog();
        this.logwrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Batch');
        
        this.logwrap.BatchCronId         = bc.getJobId();
        this.logwrap.BatchStartTime      = System.now();
        this.logwrap.ClassName           = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
        this.logwrap.LogText.add('### [Batch Start] ### \n');
        
        globalCount.add(String.valueOf(1));     // 1회 수행 한다.
        return globalCount;
    }
    
    global void execute(Database.BatchableContext BC, List<String> scope) {

        this.logwrap.LogText.add('### [Batch excute] ### \n');
        
        IFMaster__c                     ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name =: interfaceId];
        API_Authenticationkey__mdt      authKey     = [SELECT KeyValue__c, DateRange__c, MasterLabel FROM API_Authenticationkey__mdt WHERE MasterLabel = '공공데이터_Key'];
    
        String                          today       = String.valueOf(Datetime.now().format('yyyyMMdd')) + '0000';               //  time.now().format('yyyyMMdd')) + '0000';
        String                          yeday       = String.valueOf(Datetime.now().addDays(-1).format('yyyyMMdd')) + '0000';   //global String yeday = String.valueOf(Date.today().addDays(-1).format('yyyyMMdd')) + '0000';

        inqryDiv        = '3';      //1.둥록일시, 2.공고일시, 3.개찰일시, 4.입찰공고번호
        inqryBgnDt      = yeday;
        inqryEndDt      = today;

        String errResultCode;
        String errResultMsg;

        try{
            
            //  http://apis.data.go.kr/1230000/ScsbidInfoService/getScsbidListSttusThng?inqryDiv=3&type=json&inqryBgnDt=202311060000&inqryEndDt=202311090000&pageNo=1&numOfRows=999&ServiceKey=ewhZMDDBM/3wCJ5TMuXdFe5vxILI2XeTLbR3d1lUd2k2JC6NJWNVV3FO0djoICGHfrNQ7I19CFt10EzulcQXzw==
            //getScsbidListSttusThng    //물품
            //getScsbidListSttusServc   //용역
            //getScsbidListSttusFrgcpt  //외자
            
            IFN_CalloutResult ifRes = new IFN_CalloutResult();
            //Output param = new Output();
            String getRquest = '';
            
            getRquest += workDivision;

            getRquest += '?' + 'type=json';
            getRquest += '&' + 'ServiceKey='    + authKey.KeyValue__c;
            getRquest += '&' + 'pageNo=1';                              //고정
            getRquest += '&' + 'numOfRows=999';                         //고정 - 1000건 넘어가면, 10건씩 준다.
            getRquest += '&' + 'inqryDiv='      + inqryDiv;
            getRquest += '&' + 'inqryBgnDt='    + inqryBgnDt;
            getRquest += '&' + 'inqryEndDt='    + inqryEndDt;
            if(bidNtceNo != null && !bidNtceNo.equals('')) getRquest += '&' + 'bidNtceNo=' + bidNtceNo;
            
            try {
                IFN_EIF1006_Callout callout = new IFN_EIF1006_Callout(this.interfaceId, 'Real');
                
                ifRes = callout.getResponse(this.interfaceId, getRquest);                                   //  <-------------- callout

                if('S'.equals(ifRes.result)){
                    
                    Output  outObj          = (Output)ifRes.response;
                    List<items> resItems    = outObj.response.body.items;

                    // - 
                    // CJFW_BiddingInformation__c 용, 신규(Military,Local,NaraMarket)
                    Id naraRecordId = Schema.SObjectType.CJFW_BiddingInformation__c.getRecordTypeInfosByDeveloperName().get('NaraMarket').getRecordTypeId();
                    
                    //workDivision 에 따라 [bsnsDivNm__c] 더 세분화 할 수 있으나, 현재는 NaraMarket 전체로 한다.
                    List<CJFW_BiddingInformation__c>     updList = [
                        SELECT Id, BidNoticeNumber__c, Name 
                            , BidMethod__c, ContractSignMethod__c, SubNumber__c, IsReBid__c
                            , BidBeginDateTime__c, BidOpenDateTime__c, BidCloseDateTime__c, BidOpenPlace__c
                            , bsnsDivNm__c
                            , RecordtypeId, RecordType.Name
                            ,SelectCompany__c
                            ,SelectResult__c
                        FROM CJFW_BiddingInformation__c
                        WHERE RecordtypeId = :naraRecordId
                    ];
                    
                    for(CJFW_BiddingInformation__c nowBid : updList){
                        System.debug('nowBid:' + nowBid.Name + '/' + nowBid.BidNoticeNumber__c + '/' + nowBid.SubNumber__c);
                        for(items nowitem : resItems){
                            if(nowBid.BidNoticeNumber__c == nowitem.bidNtceNo + '-' + nowitem.bidNtceOrd) {
                                System.debug('sancho same:' + nowitem.bidNtceNm + '/' + nowitem.bidNtceNo + '/' + nowitem.bidNtceOrd);
                            }
                            
                        }

                    }

                    // if(insList != null && insList.size() >= 1){
                    //     List<CJFW_FoodAdditives__c> delList = [Select Id From CJFW_FoodAdditives__c];
                    //     if(delList != null) delete delList;
                    // }
    
                    // insert insList;
    
                    //logWrap.LogText.add(outObj.i1250.Result.CODE + '/' + outObj.i1250.Result.MSG);
                    
                }else{
                    
                    //errResultCode   = ifRes.result;
                    //errResultMsg    = ifRes.message + '\n' + (String)ifRes.response;
                    //errResultMsg    = ifRes.message + '\n' + ifRes.response;
                    this.logWrap.ErrorCode = ifRes.result;
                    this.logWrap.ErrorText.add(ifRes.message + '\n');
                    this.logWrap.ErrorText.add(ifRes.response + '\n');
   
                }


            } catch (Exception e) {
                this.logWrap.ErrorCode = '-1';
                this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
                this.logWrap.Status = 'ERROR';
            }

            
        } catch(Exception e) {
            
            this.logWrap.ErrorCode = errResultCode;
            this.logWrap.ErrorText.add(errResultMsg + '\n');
            this.logWrap.ErrorText.add('[' + e.getLineNumber() + ']' + '\n');
            this.logWrap.ErrorText.add(e.getMessage() + '\n');
        }

        
        
        commlog.insertLog(logWrap);
    }



    //finish
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 내용 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('IFN_EIF1006_PD001_MD001 finish !!');
    }



    
    global class Output {
        public response response		{get;set;}
    }

    global class response {
        public header header   			{get;set;}
        public body body				{get;set;}
    }
    
    global class header {
        public String resultCode		{get;set;}
        public String resultMsg			{get;set;}
    }

    global class body {
        public String numOfRows			{get;set;}
        public String pageNo			{get;set;}
        public String totalCount		{get;set;}
        public List<items> items			    {get;set;}
    }

    global class items {
        public String resultCode		{get;set;}	//결과코드					
        public String resultMsg         {get;set;}  //결과메세지                
        public String numOfRows         {get;set;}  //한 페이지 결과 수         
        public String pageNo            {get;set;}  //페이지 수                
        public String totalCount        {get;set;}  //데이터 총 개수            
        public String bidNtceNo         {get;set;}  //입찰공고번호              
        public String bidNtceOrd        {get;set;}  //입찰공고차수              
        public String bidClsfcNo        {get;set;}  //입찰분류번호              
        public String rbidNo            {get;set;}  //재입찰번호                
        public String ntceDivCd         {get;set;}  //공고구분코드              
        public String bidNtceNm         {get;set;}  //입찰공고명                
        public String prtcptCnum        {get;set;}  //참가업체수                
        public String bidwinnrNm        {get;set;}  //최종낙찰업체명            
        public String bidwinnrBizno     {get;set;}  //최종낙찰업체사업자등록번호
        public String bidwinnrCeoNm     {get;set;}  //최종낙찰업체대표자명      
        public String bidwinnrAdrs      {get;set;}  //최종낙찰업체주소          
        public String bidwinnrTelNo     {get;set;}  //최종낙찰업체전화번호      
        public String sucsfbidAmt       {get;set;}  //최종낙찰금액              
        public String sucsfbidRate      {get;set;}  //최종낙찰률                
        public String rlOpengDt         {get;set;}  //실개찰일시                
        public String dminsttCd         {get;set;}  //수요기관코드              
        public String dminsttNm         {get;set;}  //수요기관명                
        public String rgstDt            {get;set;}  //등록일시                 
        public String fnlSucsfDate      {get;set;}  //최종낙찰일자              
        public String fnlSucsfCorpOfcl  {get;set;}  //최종낙찰업체담당자        
        public String linkInsttNm       {get;set;}  //연계기관명                

    }
    
    


    /* 
    어린이집 위경도 
        - result S 일 때만 꺼내자. S 아니면 에러임.
        IFN_GET_KAKAOGEO_INFO api = new IFN_GET_KAKAOGEO_INFO();
        IFN_CalloutResult resData = api.getResponse('경기도 파주시 성재길 3');
        IFN_GET_KAKAOGEO_INFO.SearcXY ccc = (IFN_GET_KAKAOGEO_INFO.SearcXY) resData.response;
        System.debug(Json.serialize(ccc.XPoint));
        System.debug(Json.serialize(ccc.YPoint));

    */



    
    /***********************************************************************************************************
    *  Bacth   : start
    ************************************************************************************************************/
    /*
    global Database.QueryLocator start(Database.BatchableContext BC) {
   
        logwrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Batch');
        
        logwrap.BatchCronId         = bc.getJobId();
        logwrap.BatchStartTime      = System.now();
        logwrap.ClassName           = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
        logwrap.LogText.add('### [Batch Start] ###\n');

        // 미리 여기서 조회 해 놓기???
        // CJFW_BiddingInformation__c 용, 신규(Military,Local,NaraMarket)
        Id naraRecordId = Schema.SObjectType.CJFW_BiddingInformation__c.getRecordTypeInfosByDeveloperName().get('NaraMarket').getRecordTypeId();
        
        //workDivision 에 따라 [bsnsDivNm__c] 더 세분화 할 수 있으나, 현재는 NaraMarket 전체로 한다.
        return Database.getQueryLocator([
            SELECT Id, BidNoticeNumber__c, Name 
                , BidMethod__c, ContractSignMethod__c, SubNumber__c, IsReBid__c
                , BidBeginDateTime__c, BidOpenDateTime__c, BidCloseDateTime__c, BidOpenPlace__c
                , bsnsDivNm__c
                , RecordtypeId, RecordType.Name
                ,SelectCompany__c
                ,SelectResult__c
            FROM CJFW_BiddingInformation__c
            WHERE RecordtypeId = :naraRecordId
        ]);
    }
    */



}