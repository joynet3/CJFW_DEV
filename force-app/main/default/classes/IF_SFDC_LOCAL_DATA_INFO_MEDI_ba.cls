/**
 * @Class : IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.10.12
 * @Version : 1.0
 * @Description : 의료기관
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.12 | sancho         | 최초작성
 * */
global with sharing class IF_SFDC_LOCAL_DATA_INFO_MEDI_ba implements Database.Batchable<String>,
 Database.AllowsCallouts, Database.Stateful{
    IFMaster__c ifMasterObj = [
        SELECT Id, Name, ContentType__c, Endpoint__c, Method__c
        FROM IFMaster__c
        WHERE Name = 'IF_SFDC_LOCAL_DATA_INFO'
    ];

    API_Authenticationkey__mdt authKey = [
        SELECT KeyValue__c, DateRange__c, MasterLabel
        FROM API_Authenticationkey__mdt
        WHERE MasterLabel = '지방인허가(의료)_Key'
    ];

    Map<String,String> localToSiGunGuMap = new Map<String,String>();
    Map<String,String> localToSiDoMap = new Map<String,String>();
    Set<String> instCodeSet = new Set<String>();
    List<String> upsertFailList = new List<String>();
    Id recordIdEx = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('LeadLocalData').getRecordTypeId();

    global IF_SFDC_LOCAL_DATA_INFO_MEDI_ba(List<String> upsertFailList) {
        this.upsertFailList = upsertFailList;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 지방인허가 정보 관련 메타데이터 조회 및 api 호출
    ************************************************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {
        System.debug('==========================::: batch start');
        List<String> totalPageList = new List<String>();
        String getRequest = '';

        // for(Industry_Code__mdt obj : [
        //     SELECT IndustryCode__c
        //     FROM Industry_Code__mdt
        //     WHERE Active__c = true
        // ]){
        //     instCodeSet.add(obj.IndustryCode__c);
        // }

        for (local_govCD__mdt obj : [
            SELECT DeveloperName,MasterLabel,SiGunGuName__c,SiGunGuCode__c,
            LocalGovCode__c,SidoName__c,SidoCode__c,SidoLocalGovCode__c
            FROM local_govCD__mdt
        ]) {
            localToSiGunGuMap.put(obj.LocalGovCode__c, obj.SiGunGuCode__c);
            localToSiDoMap.put(obj.LocalGovCode__c, obj.SidoCode__c);
        }
        if (upsertFailList <> null && upsertFailList.size() > 0) {
            totalPageList = upsertFailList;
        }else {
            getRequest += '?authKey=' + authKey.KeyValue__c;
            if (authKey.DateRange__c <> null) {
                Datetime today = Datetime.now();
                Integer dateRange = Integer.valueOf(authKey.DateRange__c);
                getRequest += '&lastModTsBgn=' + today.addDays(-dateRange).format('yyyymmdd');
                getRequest += '&lastModTsEnd=' + today.format('yyyymmdd');
            }
            getRequest += '&pageIndex=1';
            getRequest += '&pageSize=200';
            getRequest += '&resultType=json';
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ifMasterObj.Endpoint__c + getRequest);
            request.setHeader('content-type', ifMasterObj.ContentType__c);
            request.setMethod(ifMasterObj.Method__c);
            request.setTimeout(110000);
            HttpResponse res = http.send(request);
    
            if (res.getStatusCode() == 200) {
                // System.debug('http response ============ :::' + res.getBody());
                IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Input input = (IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Input) JSON.deserialize(res.getBody(), IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Input.class);
                Integer totalPageNo = Integer.valueOf(input.result.header.paging.totalCount)/Integer.valueOf(input.result.header.paging.pageSize);
                for (Integer i = 0; i <= totalPageNo; i++) {
                    totalPageList.add(String.valueOf(i));
                }
            }
        }
        return totalPageList;
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 지방인허가 정보 Paging api 호출 및 리드 생성
    ************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<String> scope) {
        System.debug('=========================' + scope[0] + '\'th execute');
        String getRequest = '';
        List<Lead> upsertLeadList = new List<Lead>();
        
        getRequest += '?authKey=' + authKey.KeyValue__c;
        if (authKey.DateRange__c <> null) {
            Datetime today = Datetime.now();
            Integer dateRange = Integer.valueOf(authKey.DateRange__c);
            getRequest += '&lastModTsBgn=' + today.addDays(-dateRange).format('yyyymmdd');
            getRequest += '&lastModTsEnd=' + today.addDays(-2).format('yyyymmdd');
        }
        getRequest += '&pageIndex=' + String.valueOf((Integer.valueOf(scope[0])+1));
        getRequest += '&pageSize=200';
        getRequest += '&resultType=json';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ifMasterObj.Endpoint__c + getRequest);
        request.setHeader('content-type', ifMasterObj.ContentType__c);
        request.setMethod(ifMasterObj.Method__c);
        request.setTimeout(110000);
        HttpResponse res = http.send(request);

        if (res.getStatusCode() == 200) {
            IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Input input = (IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Input) JSON.deserialize(res.getBody(), IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Input.class);

            System.debug('==============> input : '+JSON.serialize(input));

            IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Result inputResult = input.result;

            if(inputResult <> null && inputResult.body <> null) {
                IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Body inputBody = inputResult.body;

                if(inputBody <> null && inputBody.rows <> null && inputBody.rows.size() > 0) {                    
                    for(IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.row objRows : inputBody.rows) {
                        if(objRows <> null && objRows.row <> null && objRows.row.size() > 0) {
                            for (IF_SFDC_LOCAL_DATA_INFO_MEDI_ba.Item item : objRows.row) {
                                
                                Lead leadObj = new Lead();
                                System.debug(item.bplcNm + ', ' + item.opnSvcId + ' : ' + item.opnSvcNm);
                                //공통 제공항목
                                leadObj.LocationState__c = localToSiGunGuMap.get(item.opnSfTeamCode);
                                leadObj.LocationStateProvince__c = localToSiDoMap.get(item.opnSfTeamCode);
                                leadObj.mgtNo__c = item.mgtNo;
                                leadObj.opnSvcId__c = item.opnSvcId;
                                leadObj.updateGbn__c = item.updateGbn;
                                leadObj.updateDt__c = item.updateDt <> null && item.updateDt <> '' ? Datetime.valueOf(item.updateDt) : null;
                                leadObj.opnSvcNm__c = item.opnSvcNm;
                                leadObj.Company = item.bplcNm;
                                leadObj.LastName = item.bplcNm;
                                leadObj.sitePostNo__c = item.sitePostNo;
                                leadObj.siteWhlAddr__c = item.siteWhlAddr;
                                leadObj.PostalCode__c = item.rdnPostNo;
                                leadObj.Address__c = item.rdnWhlAddr;
                                leadObj.siteArea__c = item.siteArea <> null && item.siteArea <> '' ? Decimal.valueOf(item.siteArea.replaceAll(',','')) : null;
                                if (item.apvPermYmd <> null && item.apvPermYmd <> '') {
                                    Date dt = Date.newInstance(
                                    Integer.valueOf(item.apvPermYmd.substring(0,4))
                                    , Integer.valueOf(item.apvPermYmd.substring(5,7))
                                    , Integer.valueOf(item.apvPermYmd.substring(8,10))
                                    );
                                leadObj.apvPermYmd__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                if (item.apvCancelYmd <> null && item.apvCancelYmd <> '') {
                                    Date dt = Date.newInstance(
                                    Integer.valueOf(item.apvCancelYmd.substring(0,4))
                                    , Integer.valueOf(item.apvCancelYmd.substring(5,7))
                                    , Integer.valueOf(item.apvCancelYmd.substring(8,10))
                                    );
                                leadObj.apvCancelYmd__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                if (item.dcbYmd <> null && item.dcbYmd <> '') {
                                    Date dt = Date.newInstance(
                                    Integer.valueOf(item.dcbYmd.substring(0,4))
                                    , Integer.valueOf(item.dcbYmd.substring(5,7))
                                    , Integer.valueOf(item.dcbYmd.substring(8,10))
                                    );
                                leadObj.dcbYmd__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                if (item.clgStdt <> null && item.clgStdt <> '') {
                                    Date dt = Date.newInstance(
                                    Integer.valueOf(item.clgStdt.substring(0,4))
                                    , Integer.valueOf(item.clgStdt.substring(5,7))
                                    , Integer.valueOf(item.clgStdt.substring(8,10))
                                    );
                                leadObj.clgStdt__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                if (item.clgEnddt <> null && item.clgEnddt <> '') {
                                    Date dt = Date.newInstance(
                                    Integer.valueOf(item.clgEnddt.substring(0,4))
                                    , Integer.valueOf(item.clgEnddt.substring(5,7))
                                    , Integer.valueOf(item.clgEnddt.substring(8,10))
                                    );
                                leadObj.clgEnddt__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                if (item.ropnYmd <> null && item.ropnYmd <> '') {
                                    Date dt = Date.newInstance(
                                    Integer.valueOf(item.ropnYmd.substring(0,4))
                                    , Integer.valueOf(item.ropnYmd.substring(5,7))
                                    , Integer.valueOf(item.ropnYmd.substring(8,10))
                                    );
                                leadObj.ropnYmd__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                if (item.lastModTs <> null && item.lastModTs <> '') {
                                    Datetime dt = Datetime.newInstance(
                                    Integer.valueOf(item.lastModTs.substring(0,4))
                                    ,Integer.valueOf(item.lastModTs.substring(5,7))
                                    ,Integer.valueOf(item.lastModTs.substring(8,10))
                                    ,Integer.valueOf(item.lastModTs.substring(11,13))
                                    ,Integer.valueOf(item.lastModTs.substring(14,16))
                                    , Integer.valueOf(item.lastModTs.substring(17,19))
                                    );
                                leadObj.lastModTs__c = Datetime.newInstance(dt.year(), dt.month(),
                                    dt.day(), dt.hour(), dt.minute(), dt.second()); 
                                }
                                leadObj.trdStateNm__c = item.trdStateNm;
                                leadObj.dtlStateNm__c = item.dtlStateNm;
                                leadObj.x__c = item.x;
                                leadObj.y__c = item.y;
                                leadObj.BusinessConditions__c = item.uptaeNm;
                                leadObj.Phone = item.siteTel;
                                //상세 제공항목
                                leadObj.bdngOwnSeNm__c = item.bdngOwnSeNm;
                                leadObj.fctyOwkEpCnt__c = item.fctyOwkEpCnt <> null  && item.fctyOwkEpCnt <> '' ? Decimal.valueOf(item.fctyOwkEpCnt) : null;
                                leadObj.fctyPdtJobEpCnt__c = item.fctyOwkEpCnt <> null  && item.fctyPdtJobEpCnt <> '' ? Decimal.valueOf(item.fctyPdtJobEpCnt) : null;
                                leadObj.fctySilJobEpCnt__c = item.fctySilJobEpCnt <> null  && item.fctySilJobEpCnt <> '' ? Decimal.valueOf(item.fctySilJobEpCnt) : null;
                                leadObj.wtrSplyFacilSeNm__c = item.wtrSplyFacilSeNm;
                                leadObj.manEipCnt__c = item.manEipCnt <> null  && item.manEipCnt <> '' ? Decimal.valueOf(item.manEipCnt) : null;
                                leadObj.multUsnUpsoYn__c = item.multUsnUpsoYn <> 'Y' ? false : true;
                                leadObj.lvSeNm__c = item.lvSeNm;
                                leadObj.isreAm__c = item.isreAm <> null  && item.isreAm <> '' ? Decimal.valueOf(item.isreAm) : null;
                                leadObj.hoffEpCnt__c = item.hoffEpCnt <> null  && item.hoffEpCnt <> '' ? Decimal.valueOf(item.hoffEpCnt) : null;
                                leadObj.facilTotScp__c = item.facilTotScp <> null  && item.facilTotScp <> '' ? Decimal.valueOf(item.facilTotScp) : null;
                                leadObj.wmEipCnt__c = item.wmEipCnt <> null  && item.wmEipCnt <> '' ? Decimal.valueOf(item.wmEipCnt) : null;
                                leadObj.trdpJubnSeNm__c = item.trdpJubnSeNm;
                                leadObj.monAm__c = item.monAm <> null  && item.monAm <> '' ? Decimal.valueOf(item.monAm) : null;
                                leadObj.sntUptaeNm__c = item.sntUptaeNm;
                                leadObj.jtUpsoMainEdf__c = item.jtUpsoMainEdf;
                                leadObj.jtUpsoAsgnNo__c = item.jtUpsoAsgnNo;
                                leadObj.totEpNum__c = item.totEpNum <> null  && item.totEpNum <> '' ? Decimal.valueOf(item.totEpNum) : null;
                                leadObj.Website = item.homepage;
                                leadObj.LeadSource = '지방행정인허가';
                                leadObj.Status = 'New';
                                leadObj.RecordTypeId = recordIdEx;
                                upsertLeadList.add(leadObj);
                                
                            }
                        }
                    }
                }
            }
        }else {
            upsertFailList.add(String.valueOf((Integer.valueOf(scope[0])+1)));
        }
        if (upsertLeadList.size() > 0) {
            upsert upsertLeadList mgtNo__c;
        }
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 실패건 재호출
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('batch finish start ====================');
        if (upsertFailList <> null && upsertFailList.size() > 0) {
            IF_SFDC_LOCAL_DATA_INFO_MEDI_ba ba = new IF_SFDC_LOCAL_DATA_INFO_MEDI_ba(upsertFailList);
            Database.executeBatch(ba, 1);
        }
    }



    // ------------------ inner class
    
    global class Input {
        public Result result;
    }

    global class Result {
        public Header header;
        public Body body;
    }

    global class Header {
        public Paging paging;
        // public Proces process;
    }

    global class Paging {
        public String pageIndex;
        public String totalCount;
        public String pageSize;
    }

    global class Body {
        public List<Row> rows;
    }

    global class Row {
        public List<Item> row;
    }

    global class Item {
        public String rowNum;
        public String opnSfTeamCode;
        public String mgtNo;
        public String opnSvcId;
        public String updateGbn;
        public String updateDt;
        public String opnSvcNm;
        public String bplcNm;
        public String sitePostNo;
        public String siteWhlAddr;
        public String rdnPostNo;
        public String rdnWhlAddr;
        public String siteArea;
        public String apvPermYmd;
        public String apvCancelYmd;
        public String dcbYmd;
        public String clgStdt;
        public String clgEnddt;
        public String ropnYmd;
        public String trdStateGbn;
        public String trdStateNm;
        public String dtlStateGbn;
        public String dtlStateNm;
        public String x;
        public String y;
        public String lastModTs;
        public String uptaeNm;
        public String siteTel;
        public String bdngOwnSeNm;
        public String fctyOwkEpCnt;
        public String fctyPdtJobEpCnt;
        public String fctySilJobEpCnt;
        public String rgtMbdSno;
        public String wtrSplyFacilSeNm;
        public String manEipCnt;
        public String multUsnUpsoYn;
        public String lvSeNm;
        public String isreAm;
        public String hoffEpCnt;
        public String equSiz;
        public String facilTotScp;
        public String wmEipCnt;
        public String trdpJubnSeNm;
        public String monAm;
        public String sntUptaeNm;
        public String jtUpsoMainEdf;
        public String jtUpsoAsgnNo;
        public String totEpNum;
        public String lindPrcbGbnNm;
        public String lindJobGbnNm;
        public String lindSeqNo;
        public String homepage;
    }

}