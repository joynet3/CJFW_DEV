/**
 * @description       : 국방전자조달시스템 검색조건에대한 list를 받아오는 api
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global with sharing class IF_SFDC_DATA_REQ_D2BBID_INFO_ba implements Database.batchable<String>, Database.Stateful, Database.AllowsCallouts{

    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_D2BBID_INFO'];
    API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '공공데이터_Key'];
    
    global List<NaramarketKeyword__mdt> keywordList = new List<NaramarketKeyword__mdt>();
    global List<String> errList = new List<String>();
    global List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> inputItemsList = new List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items>();
    global Integer targetIndex = 0;
    Datetime endDt = Datetime.now();
    
    global IF_SFDC_DATA_REQ_D2BBID_INFO_ba(List<NaramarketKeyword__mdt> keywordList, Integer targetIndex, List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> inputItemsList) {

        this.keywordList = keywordList;
        this.targetIndex = targetIndex;
        this.inputItemsList = inputItemsList;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 국방부 전자조달 시스템 API 호출
    ************************************************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {
        System.debug('=============================:::info batch start');
        //키워드별 totalpage
        List<String> totalPageList = new List<String>();
        Integer totalPage;
        String getParameter = '';
        endDt.addDays((Integer.valueof(authKey.DateRange__c)));

        getParameter += 'getDmstcCmpetBidPblancList';
        getParameter += '?anmtDateBegin='+ Datetime.now().format('yyyyMMdd');
        getParameter += '&anmtDateEnd='+ endDt.format('yyyyMMdd');
        System.debug('keywordList[targetIndex].Keyword__c: ' + keywordList[targetIndex].Keyword__c);
        String encodedString = EncodingUtil.urlEncode(String.valueOf(keywordList[targetIndex].Keyword__c), 'UTF-8');
        System.debug('=====================encodedString:::'+encodedString);
        getParameter += '&bidNm='+ encodedString;
        getParameter += '&numOfRows=200';
        getParameter += '&pageNo=1';
        System.debug(getParameter);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ifMasterObj.Endpoint__c + getParameter);
        System.debug(request.getEndpoint());
        request.setHeader('content-type', ifMasterObj.ContentType__c);
        request.setMethod(ifMasterObj.Method__c);
        request.setTimeout(110000);
        HttpResponse res = http.send(request);

        Integer totalCount = 0;
        Integer numOfRow = 0;
        if(res.getStatusCode() == 200) {
            String strJSON = XMLParser.xmlToJson(res.getBody());
            System.debug('=======================calloutResult:::' + strJSON);
            try {
                //xml로 응답하는경우 응답값이 단일알경우 parsing 오류를 방지하기 위한 trycatch
                IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input input = (IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input) JSON.deserialize(strJSON, IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input.class);
                System.debug('==========================totalCount:::'+input.response.body.totalCount);
                totalCount = Integer.valueOf(input.response.body.totalCount);
                numOfRow = Integer.valueOf(input.response.body.numOfRows);
            } catch (Exception e) {
                System.debug(e.getMessage() + ' ' + e.getLineNumber() + '======otherInput start');
                IF_SFDC_DATA_REQ_D2BBID_INFO_sc.otherInput otherInput = (IF_SFDC_DATA_REQ_D2BBID_INFO_sc.otherInput) JSON.deserialize(strJSON, IF_SFDC_DATA_REQ_D2BBID_INFO_sc.otherInput.class);
                totalCount = Integer.valueOf(otherInput.response.body.totalCount);
                numOfRow = Integer.valueOf(otherInput.response.body.numOfRows);
            }
            totalPage = (totalCount/numOfRow);
            System.debug('==============================totalPage:::'+totalPage);
            for (Integer i = 0; i <= totalPage ; i++) {
                totalPageList.add(String.valueOf(i));
            }
            System.debug('============================totalPageList:::' + String.valueOf(totalPageList));
        }
        return totalPageList;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 국방부 전자조달 시스템 API Paging 호출
    ************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<String> scope) {
        String getParameter = '';
        //keywordList와 totalpage를 이용해서 순차적으로 페이지 호출
        getParameter += 'getDmstcCmpetBidPblancList';
        getParameter += '?opengDateBegin='+ Datetime.now().format('yyyyMMdd');
        System.debug('keywordList[targetIndex].Keyword__c: ' + keywordList[targetIndex].Keyword__c);
        String encodedString = EncodingUtil.urlEncode(String.valueOf(keywordList[targetIndex].Keyword__c), 'UTF-8');
        System.debug('=====================encodedString:::'+encodedString);
        getParameter += '&bidNm='+ encodedString;
        getParameter += '&numOfRows=200';
        getParameter += '&pageNo=' + String.valueOf((Integer.valueOf(scope[0])+1));
        System.debug(getParameter);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ifMasterObj.Endpoint__c + getParameter);
        System.debug(request.getEndpoint());
        request.setHeader('content-type', ifMasterObj.ContentType__c);
        request.setMethod(ifMasterObj.Method__c);
        request.setTimeout(110000);
        HttpResponse res = http.send(request);

        if(res.getStatusCode() == 200) {
            String strJSON = XMLParser.xmlToJson(res.getBody());
            // System.debug('=======================calloutResult:::' + strJSON);
            try {
                IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input input = (IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input) JSON.deserialize(strJSON, IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input.class);

                if (input.response.body.items <> null && input.response.body.items.size() > 0) {
                    for (IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items obj : input.response.body.items) {
                        obj.keyword = keywordList[targetIndex].Keyword__c;
                        inputItemsList.add(obj);
                    }
                }
            } catch (Exception e) {
                System.debug(e.getMessage() + ' ' + e.getLineNumber() + '======otherInput start');
                IF_SFDC_DATA_REQ_D2BBID_INFO_sc.otherInput otherInput = (IF_SFDC_DATA_REQ_D2BBID_INFO_sc.otherInput) JSON.deserialize(strJSON, IF_SFDC_DATA_REQ_D2BBID_INFO_sc.otherInput.class);
                if(otherInput.response.body.items <> null) {
                    //단일 오브젝트로 응답이 오는경우 새로 할당하여 inputItemList 구성
                    IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items otherItems = new IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items();
                    otherItems.dcsNo = otherInput.response.body.items.item.dcsNo;
                    otherItems.demandYear = otherInput.response.body.items.item.demandYear;
                    otherItems.orntCode = otherInput.response.body.items.item.orntCode;
                    otherItems.pblancNo = otherInput.response.body.items.item.pblancNo;
                    otherItems.pblancOdr = otherInput.response.body.items.item.pblancOdr;
                    otherItems.keyword = keywordList[targetIndex].Keyword__c;
                    inputItemsList.add(otherItems);
                }
            }
        }
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : targetIndex 이용하여 키워드 목록을 순차적으로 재귀
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        //targetIndex 이용하여 키워드 목록을 순차적으로 재귀
        targetIndex++;
        System.debug('targetIndex: ' + targetIndex);
        System.debug('keywordList.size(): ' + keywordList.size());
        if (targetIndex < keywordList.size()) {
            IF_SFDC_DATA_REQ_D2BBID_INFO_ba ba = new IF_SFDC_DATA_REQ_D2BBID_INFO_ba(keywordList, targetIndex, inputItemsList);
            Database.executeBatch(ba, 1);
        }
        if (!Test.isRunningTest()) {
            if(targetIndex == keywordList.size()){
                // 키워드 조회가 끝나면 상세조회 Batch 호출
                IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba b = new IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba(inputItemsList);
                Database.executeBatch(b,1);
            }
        }

        System.debug('=============================:::info batch finish');
        
    }
}