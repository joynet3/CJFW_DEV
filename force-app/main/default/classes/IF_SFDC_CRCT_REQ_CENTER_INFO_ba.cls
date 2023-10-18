/**
 * @description       : 어린이집 정보공개포털 api Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-14-2023
 * @last modified by  : admin
 * 
 * @last modified on  : 2023.10.12
 * @last modified by  : sancho     Lead -> 　CJFW_PublicBiddingInformation__c
**/
global with sharing class IF_SFDC_CRCT_REQ_CENTER_INFO_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global Integer index;
    global List<SidoCode_Set__mdt> sidoList = new List<SidoCode_Set__mdt>();
    global  List<String> failSidoList;
    global Boolean isTarget;

    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_CRCT_REQ_CENTER_INFO'];
    API_Authenticationkey__mdt authKey = [select KeyValue__c from API_Authenticationkey__mdt where MasterLabel = 'CareCenter_Key'];

    global IF_SFDC_CRCT_REQ_CENTER_INFO_ba(Boolean isTarget, List<String> failSidoList) {
        this.isTarget = isTarget;
        this.failSidoList = failSidoList;
        if(this.failSidoList == null) {
            this.failSidoList = new List<String>();
        }
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 시도 메타데이터 조회
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
    *  내용    : 어린이집정보 API 호출 및 Lead upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<SidoCode_Set__mdt> scope) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '';

        List<CJFW_PublicBiddingInformation__c> listData = new List<CJFW_PublicBiddingInformation__c>();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String getParameter = '';
        System.debug('========================================구이름 : ' + scope[0].SiGunGuName__c);
        getParameter += '?key='+authKey.KeyValue__c;
        getParameter += '&arcode='+scope[0].SidoCode__c;
        getParameter += '&stcode=';

        System.debug('==============================getParameter:::' + getParameter);
        System.debug('============================== URL :::' + ifMasterObj.EndPoint__c + getParameter);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ifMasterObj.EndPoint__c + getParameter);
        system.debug(request.getEndpoint());
        request.setHeader('content-type', ifMasterObj.ContentType__c);
        request.setMethod(ifMasterObj.Method__c);
        request.setTimeout(110000);
        

        try {
            LogWrapper.requestBody = ifMasterObj.EndPoint__c + getParameter;

            HttpResponse res = http.send(request);
            if(res.getStatusCode() == 200) {
                if(res.getBody() <> null){
                    LogWrapper.responseBody = res.getBody();

                    System.debug('=========================> 1');
                    //String strJSON = XMLParser.xmlToJson(res.getBody());
                    XMLSerializer XMLObj = new XMLSerializer();
                    String strJSON = XMLObj.XMLToJSON(res.getBody());

                    if(strJSON.contains(',""')) {
                        strJSON = strJSON.replaceAll(',""', '');
                    }
                    System.debug('===========> strJSON : '+strJSON);
                    System.debug('=========================> 2');                
                    IF_SFDC_CRCT_REQ_CENTER_INFO_sc.Input input = (IF_SFDC_CRCT_REQ_CENTER_INFO_sc.Input) JSON.deserialize(strJSON, IF_SFDC_CRCT_REQ_CENTER_INFO_sc.Input.class);
                    System.debug('=========================> 3');
                    Id recordId = Schema.SObjectType.CJFW_PublicBiddingInformation__c.getRecordTypeInfosByDeveloperName().get('ChildCenter').getRecordTypeId();

                    IF_SFDC_CRCT_REQ_CENTER_INFO_sc.Res inputRes = input.response;

                    if(inputRes <> null && inputRes.item <> null && inputRes.item.size() > 0) {
                        for (IF_SFDC_CRCT_REQ_CENTER_INFO_sc.Items obj : input.response.item) {
                            
                            CJFW_PublicBiddingInformation__c objLead = new CJFW_PublicBiddingInformation__c();
            
                            // objLead.BidNoticeSource__c = '어린이집 정보 공개 포털';
                            objLead.Name                    = obj.CRREPNAME <> null && obj.CRREPNAME <> '' ? obj.CRREPNAME : obj.crname;
                            //objLead.Status = 'New';
                            //objLead.Company = obj.crname;
                            objLead.Location__Latitude__s   = obj.la <> null && obj.la <> '' ? Decimal.valueOf(obj.la) : null;
                            objLead.Location__Longitude__s  = obj.lo <> null && obj.lo <> '' ? Decimal.valueOf(obj.lo) : null;
                            objLead.Phone__c                = obj.crtelno;
                            objLead.Fax__c                  = obj.crfaxno;
                            objLead.Homepage__c             = obj.crhome;
                            objLead.ChildCenterCode__c      = obj.stcode;
                            objLead.ChildCenterType__c      = obj.crtypename;
                            objLead.AuthorizedCapacity__c   = Integer.valueOf(obj.crcapat);
                            objLead.NumberofChildren__c     = Integer.valueOf(obj.crchcnt);
                            objLead.TemporarilyCloseStartDate__c    = obj.crpausebegindt <> null && obj.crpausebegindt <> '' ? Date.valueOf(obj.crpausebegindt) : null;
                            objLead.TemporarilyCloseEndDate__c      = obj.crpauseenddt <> null && obj.crpauseenddt <> '' ? Date.valueOf(obj.crpauseenddt) : null;
                            objLead.CloseDate__c            = obj.crabldt <> null && obj.crabldt <> '' ? Date.valueOf(obj.crabldt) : null;
                            objLead.Databasedate__c         = obj.datastdrdt <> null && obj.datastdrdt <> '' ? Date.valueOf(obj.datastdrdt) : null;
                            objLead.AddressDetails__c       = obj.craddr;
                            //objLead.Address__c = obj.sigunname <> null ? obj.sidoname +' '+obj.sigunname : obj.sidoname;  //2023.10.18 왜 막아 놨지? 
                            objLead.PostalCode__c           = obj.zipcode;
                            objLead.AuthorizationDate__c    = obj.crcnfmdt <> null && obj.crcnfmdt <> '' ? Date.valueOf(obj.crcnfmdt) : null;
                            objLead.RecordtypeId            = recordId;
                            listData.add(objLead);
                        }
                    }
                }
            }else {
                //http status 200 이외의 통신에러는 failsidoList에 담아서 한번더 실행
                failSidoList.add(scope[0].SidoCode__c);
                System.debug('failsidolist === ' + failSidoList);
            }
            
            upsert listData ChildCenterCode__c;

        }catch(Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();
            System.debug('=================> Error');
            System.debug('=================> e : '+e.getMessage());
            System.debug('=================> ifMasterObj.EndPoint__c : '+ifMasterObj.EndPoint__c);
            System.debug('=================> getParameter : '+getParameter);
            System.debug('=================> URL  : '+ifMasterObj.EndPoint__c + getParameter);
        }

        if(strStatus == 'ERROR') {
            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = strMessage;
            LogWrapper.responseTime = Datetime.now();
            
            IFUtil objIF = new IFUtil('IF_SFDC_CRCT_REQ_CENTER_INFO');
            objIF.setLog(LogWrapper);
        }
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
            IF_SFDC_CRCT_REQ_CENTER_INFO_ba b = new IF_SFDC_CRCT_REQ_CENTER_INFO_ba(true, failSidoList);
            Database.executeBatch(b,1);
        }
    }
}