/**
 * @description       : EAT API 조회 Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             :
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
 **/
global with sharing class IF_SFDC_DATA_REQ_EAT_BID_INFO_ba implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
    IFMaster__c ifMasterObj = [
        SELECT Id, Name, ContentType__c, Endpoint__c, Method__c
        FROM IFMaster__c
        WHERE Name = 'IF_SFDC_DATA_REQ_EAT_BID_INFO'
    ];
    API_Authenticationkey__mdt authKey = [
        SELECT KeyValue__c, DateRange__c, MasterLabel
        FROM API_Authenticationkey__mdt
        WHERE MasterLabel = '공공데이터_Key'
    ];
    global List<NaramarketKeyword__mdt> keywordList = new List<NaramarketKeyword__mdt>();
    
    List<String> failPageList = new List<String>();
    global String operationName;
    global String today = String.valueOf(Datetime.now().format('yyyyMMdd'));
    Datetime endDt = Datetime.now().addDays(Integer.valueOf(authKey.DateRange__c));
    Id recordIdEx = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EATLead').getRecordTypeId();

    global IF_SFDC_DATA_REQ_EAT_BID_INFO_ba(List<NaramarketKeyword__mdt> keywordList, String operationName, List<String> failPageList) {
        
        this.operationName = operationName;
        this.keywordList = keywordList;
        this.failPageList = failPageList;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : EAT API 조회
    ************************************************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {
        System.debug('=============================:::batch start');
        System.debug('failPageList: ' + failPageList);
        List<String> totalPageList = new List<String>();
        // System.debug('keywordList: ' + keywordList);
        if (failPageList.size() < 1 || failPageList == null) {
          system.debug('totalpagelist calc start-------------------');
          Integer totalPage = 0;
          String getRquest = '';
          // endDt += (Integer.valueof(authKey.DateRange__c));
          endDt = Datetime.valueOf('2022-12-15 00:00:00');
          getRquest += '/' + operationName;
          
          //sancho 0808 - start --------------------------------------------------------------------- //
          //getRquest += '?ancmStsrDt=20221101'; // + today;
          //getRquest += '&ancmEndDt=' + endDt.format('yyyyMMdd');

            Datetime todaytime = Datetime.now();
            Integer dateRange = Integer.valueOf(authKey.DateRange__c);
            String sDt = String.valueOf( todaytime.addDays(-1).format('yyyyMMdd')           );
            String eDt = String.valueOf( todaytime.addDays(-dateRange).format('yyyyMMdd')   );

          getRquest += '?ancmStsrDt=' + sDt;
          getRquest += '&ancmEndDt=' + eDt;
          //sancho 0808 - end  --------------------------------------------------------------------- //

          getRquest += '&pageNo=1';
          getRquest += '&numOfRows=200';
          String encodedString = EncodingUtil.urlEncode('조달청', 'UTF-8');
          getRquest += '&useOrganNm=' + encodedString;
          getRquest += '&useOrganCd=1230000';
          getRquest += '&ServiceKey=' + authKey.KeyValue__c;
  
          Http http = new Http();
          HttpRequest request = new HttpRequest();
          request.setEndpoint(ifMasterObj.Endpoint__c + getRquest);
          request.setHeader('content-type', ifMasterObj.ContentType__c);
          request.setMethod(ifMasterObj.Method__c);
          request.setTimeout(110000);
          HttpResponse res = http.send(request);
          Integer totalCount = 0;
          Integer numOfRow = 0;
  
          if (res.getStatusCode() == 200) {
              System.debug('res.getBody(): ' + res.getBody());
              String strJSON = XMLParser.xmlToJson(res.getBody().replaceAll('&', ' ').replaceAll('	', ' '));
  
              IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.Input input = (IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.Input) JSON.deserialize(
                  strJSON,
                  IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.Input.class
              );
  
              if (Integer.valueOf(input.response.body.totalCount) <> 0) {
                  totalPage = Integer.valueOf(input.response.body.pageNo);
              }
  
              System.debug('==============================totalPage:::'+totalPage);
              for (Integer i = 0; i <= totalPage; i++) {
                  totalPageList.add(String.valueOf(i));
              }
              System.debug('============================totalPageList:::' + String.valueOf(totalPageList));
          }
          return totalPageList;
        }else {
          totalPageList = failPageList;
          failPageList = new List<String>();
          return totalPageList;
        }
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : EAT API Paging 조회
    ************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<String> scope) {
        System.debug('====================' + String.valueOf((Integer.valueOf(scope[0])+1)) + '\'th execute');
        String getRquest = '';
        List<Lead> insertLeadList = new List<Lead>();

        getRquest += '/' + operationName;
        getRquest += '?ancmStsrDt=20221101'; // + today;
        getRquest += '&ancmEndDt=' + endDt.format('yyyyMMdd');
        getRquest += '&pageNo=' + String.valueOf((Integer.valueOf(scope[0])+1));
        getRquest += '&numOfRows=200';
        String encodedString = EncodingUtil.urlEncode('조달청', 'UTF-8');
        getRquest += '&useOrganNm=' + encodedString;
        getRquest += '&useOrganCd=1230000';
        getRquest += '&ServiceKey=' + authKey.KeyValue__c;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ifMasterObj.Endpoint__c + getRquest);
        request.setHeader('content-type', ifMasterObj.ContentType__c);
        request.setMethod(ifMasterObj.Method__c);
        request.setTimeout(110000);
        HttpResponse res = http.send(request);
        if (res.getStatusCode() == 200) {
            String strJSON = XMLParser.xmlToJson(res.getBody().replaceAll('&', ' ').replaceAll('	', ' '));
            try {
                IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.Input input = (IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.Input) JSON.deserialize(
                    strJSON,
                    IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.Input.class
                );
                if (input.response.header.resultCode == '00') {
                    for (IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.Item obj : input.response.body.items) {
                        Lead leadObj = new Lead();
                        if (obj.etnBidSttNm <> '공고취소') {
                            for (NaramarketKeyword__mdt keyword : keywordList) {
                                if (obj.bidNm.contains(keyword.Keyword__c)) {
                                    System.debug(obj.bidNm);
                                    leadObj.LastName = obj.dmdOrganNm;
                                    LeadObj.Status = 'New';
                                    leadObj.Company = obj.dmdOrganNm;
                                    leadObj.BidNoticeNumber__c = obj.etnBidNo;
                                    leadObj.BidNoticeName__c = obj.bidNm;
                                    leadObj.BidNoticeStatus__c = obj.etnBidSttNm;
                                    leadObj.bsnsDivNm__c = obj.bizSortNm;
                                    leadObj.NaraBidYN__c = obj.g2bYn == 'Y' ? true : false;
                                    leadObj.OnlineBidYN__c = obj.etnBidYn == 'Y' ? true : false;
                                    leadObj.BidOpenDateTime__c = obj.bidOpenDt <> null
                                        ? Datetime.valueOf((obj.bidOpenDt).substringBefore(' ') + ' ' + obj.bidOpenHh + ':00')
                                        : null;
                                    leadObj.BidOpenPlace__c = obj.bidOpenPlc;
                                    leadObj.rgstDt__c = obj.ancmDt <> null
                                        ? Datetime.valueOf((obj.ancmDt).substringBefore(' ') + ' ' + obj.ancmHh + ':00')
                                        : null;
                                    leadObj.ContractSignMethod__c = obj.cntrctFormNm + ', ' + obj.limitConditionNm;
                                    leadObj.Databasedate__c = obj.dmRegDt <> null ? Date.valueOf(obj.dmRegDt) : null;
                                    leadObj.Keyword__c = keyword.Keyword__c;
                                    leadObj.RecordTypeId = recordIdEx;
                                    insertLeadList.add(leadObj);
                                    break;
                                }
                            }
                        }
                    }
                }else {
                  failPageList.add(String.valueOf((Integer.valueOf(scope[0])+1)));
                }
            } catch (Exception e) {
                System.debug(e.getMessage() + ' ' + e.getLineNumber() + '======otherInput start');

                IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.otherInput otherInput = (IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.otherInput) JSON.deserialize(
                    strJSON,
                    IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.otherInput.class
                );
                if (otherInput.response.header.resultCode == '00') {
                    IF_SFDC_DATA_REQ_EAT_BID_INFO_sc.otherItem obj = otherInput.response.body.items;

                    Lead leadObj = new Lead();
                    if (obj.etnBidSttNm <> '공고취소') {
                        for (NaramarketKeyword__mdt keyword : keywordList) {
                            if (obj.bidNm.contains(keyword.Keyword__c)) {
                                System.debug(obj.bidNm);
                                leadObj.LastName = obj.dmdOrganNm;
                                leadObj.Company = obj.dmdOrganNm;
                                leadObj.BidNoticeNumber__c = obj.etnBidNo;
                                leadObj.BidNoticeName__c = obj.bidNm;
                                leadObj.BidNoticeStatus__c = obj.etnBidSttNm;
                                leadObj.bsnsDivNm__c = obj.bizSortNm;
                                leadObj.NaraBidYN__c = obj.g2bYn == 'Y' ? true : false;
                                leadObj.OnlineBidYN__c = obj.etnBidYn == 'Y' ? true : false;
                                leadObj.BidOpenDateTime__c = obj.bidOpenDt <> null
                                    ? Datetime.valueOf((obj.bidOpenDt).substringBefore(' ') + ' ' + obj.bidOpenHh + ':00')
                                    : null;
                                leadObj.BidOpenPlace__c = obj.bidOpenPlc;
                                leadObj.rgstDt__c = obj.ancmDt <> null ? Datetime.valueOf((obj.ancmDt).substringBefore(' ') + ' ' + obj.ancmHh + ':00') : null;
                                leadObj.ContractSignMethod__c = obj.cntrctFormNm + ', ' + obj.limitConditionNm;
                                leadObj.Databasedate__c = obj.dmRegDt <> null ? Date.valueOf(obj.dmRegDt) : null;
                                leadObj.Keyword__c = keyword.Keyword__c;
                                leadObj.RecordTypeId = recordIdEx;
                                insertLeadList.add(leadObj);
                                break;
                            }
                        }
                    }
                }
                //catch end
            }
            upsert insertLeadList BidNoticeNumber__c;
        }else {
          failPageList.add(String.valueOf((Integer.valueOf(scope[0])+1)));
        }
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 실패한 건에 대한 재호출
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
      System.debug('batch finish start ====================');
      if (failPageList.size() > 0) {
        IF_SFDC_DATA_REQ_EAT_BID_INFO_ba ba = new IF_SFDC_DATA_REQ_EAT_BID_INFO_ba(keywordList, 'eaTBidList', failPageList);
        Database.executeBatch(ba, 1);
      }
    }
}