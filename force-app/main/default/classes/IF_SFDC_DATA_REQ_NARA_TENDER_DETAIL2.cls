/**
 * @description       : 공고번호 기준으로 디테일 조회하는 api
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global without sharing class IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2 {

    global IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2() {
    }
    
    public IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Output callOut(String inputStr, String sourceSiteChk, String workDivision) {

        IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Result objResult = new IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Result();
        IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Output objOutput = new IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Output();
        LogWrapper objWrapper = new LogWrapper();
        objWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String responseBody;
        String strCode = '0000';
        String strMessage = '';
        String getRquest = '';
        List<String> errList = new List<String>();

        //2023.09.11 - sancho (Lead -> CJFW_BiddingInformation__c)
        Map<String, CJFW_BiddingInformation__c> leadMap = new Map<String, CJFW_BiddingInformation__c>(); 

        try {
            IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2'];
            API_Authenticationkey__mdt authKey = [select KeyValue__c, DateRange__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '공공데이터_Key'];
            
            //2023.09.11 - sancho (Lead -> CJFW_BiddingInformation__c)
            List<CJFW_BiddingInformation__c> insertList = new List<CJFW_BiddingInformation__c>();

            if(sourceSiteChk == '1'){
                inputStr.substring(4,11);
            }
            
            getRquest += '/' + workDivision;
            getRquest += '?inqryDiv=4';
            getRquest += '&type=json';
            if(sourceSiteChk == '1'){
                getRquest += '&bidNtceNo=' + inputStr.substring(4, 11);
            }else {
                if (workDivision == 'getBidPblancListInfoFrgcpt') {
                    getRquest += '&bidNtceNo=' + EncodingUtil.urlEncode(inputStr.substringBeforeLast('-'), 'UTF-8');
                }else {
                    getRquest += '&bidNtceNo=' + inputStr.substringBeforeLast('-');
                }
            }
            getRquest += '&pageNo=1';
            getRquest += '&numOfRows=200';
            getRquest += '&ServiceKey=' + authKey.KeyValue__c;
            System.debug('======================getRquest:::' + getRquest);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ifMasterObj.Endpoint__c + getRquest);
            request.setHeader('content-type', ifMasterObj.ContentType__c);
            request.setMethod(ifMasterObj.Method__c);
            request.setTimeout(110000);
            HttpResponse res = http.send(request);
            System.debug('res.getBody(): ' + res.getBody());
            if(res.getStatusCode() == 200) {
                IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Input input = (IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Input) JSON.deserialize(res.getBody(), IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Input.Class);
                responseBody = String.valueOf(input);

                //2023.09.11 - sancho (Lead -> CJFW_BiddingInformation__c)
                Id naraRecordId = Schema.SObjectType.CJFW_BiddingInformation__c.getRecordTypeInfosByDeveloperName().get('NaraMarket').getRecordTypeId();  //NaraMarketLead -> NaraMarket  신규(Military,Local,NaraMarket)
                System.debug('==========================itmes:::'+ input.response.body.items);

                for (IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Items item : input.response.body.items) {

                    CJFW_BiddingInformation__c leadObj = new CJFW_BiddingInformation__c();

                    if (leadMap.get(item.bidNtceNo) == null || (leadMap.get(item.bidNtceNo) <> null) && Integer.valueOf(leadMap.get(item.bidNtceOrd)) < Integer.valueOf(item.bidNtceOrd)) {
                        leadObj.PIC__c                  = (item.ofclNm == null || item.ofclNm == '') ? item.ntceInsttNm : item.ofclNm;
                        leadObj.Company__c          = item.ntceInsttNm;   //2023.10.17: 원래 Lead 에서는 leadObj.ntceInsttNm__c 이렇게 별도로 있으나, 오브젝트 분리하며 company 에 합친다.
                        //leadObj.Status = 'New';               //2023.10.17 사용안함
                        leadObj.Phone__c                = item.ofclTelNo;
                        leadObj.Email__c                = item.ofclEmail;
                        //leadObj.LeadSource = 'NaraMarket';      //2023.10.17 사용안함
                        leadObj.BidNoticeStatus__c      = item.ntceDivNm;
                        if (Integer.valueOf(item.bidNtceOrd) < 10) {
                            Integer ord = Integer.valueOf(item.bidNtceOrd);
                            leadObj.BidNoticeNumber__c      = item.bidNtceNo+'-0'+ String.valueOf(ord);
                        }else {
                            leadObj.BidNoticeNumber__c      = item.bidNtceNo+'-'+item.bidNtceOrd;
                        }
                        leadObj.SubNumber__c            = item.bidNtceOrd;
                        leadObj.Name                    = item.ntceNm;          //2023.10.17 왜 이걸쓰지...?
                        leadObj.BidMethod__c            = item.bidMethdNm;
                        leadObj.ContractSignMethod__c   = item.cntrctMthdNm;
                        leadObj.SubNumber__c            = item.bidNtceOrd;
                        leadObj.IsReBid__c              = (item.rbidDivNm == 'Y') ? true : false;
                        leadObj.BidBeginDateTime__c     = (item.bidBeginDt == null || item.bidBeginDt == '') ? null : Datetime.valueOf(item.bidBeginDt);
                        leadObj.BidOpenDateTime__c      = (item.opengDt == null || item.opengDt == '') ? null : Datetime.valueOf(item.opengDt);
                        leadObj.BidCloseDateTime__c     = (item.bidClseDt == null || item.bidClseDt == '') ? null : Datetime.valueOf(item.bidClseDt);
                        leadObj.BidOpenPlace__c         = item.opengPlce;
                        // if (item.bidWgrnteeRcptClseDt <> null && item.bidWgrnteeRcptClseDt <> '') {
                        //     if (item.bidWgrnteeRcptClseDt.length() == 16) {
                        //         leadObj.BidQualifyRegistCloseDateTime__c = Datetime.valueOf(item.bidWgrnteeRcptClseDt + ':00');
                        //     }else {
                        //         leadObj.BidQualifyRegistCloseDateTime__c = Datetime.valueOf(item.bidWgrnteeRcptClseDt);
                        //     }
                        // }else {
                        //     leadObj.BidQualifyRegistCloseDateTime__c = null;
                        // }
                        leadObj.AssignBudgetAmountCurrency__c   =  (item.asignBdgtAmt == null || item.asignBdgtAmt == '') ? null : Decimal.valueOf(item.asignBdgtAmt);
                        //leadObj.bsnsDivNm__c = item.bidNtceClsfc;
                        leadObj.rgstDt__c               = item.rgstDt;      //= item.rgstDt <> null ? Date.valueOf(item.rgstDt) : null;
                        // leadobj.ntceSpecDocUrl1__c = item.ntceSpecDocUrl1;
                        // leadobj.ntceSpecDocUrl2__c = item.ntceSpecDocUrl2;
                        // leadobj.ntceSpecDocUrl3__c = item.ntceSpecDocUrl3;
                        // leadobj.ntceSpecDocUrl4__c = item.ntceSpecDocUrl4;
                        // leadobj.ntceSpecDocUrl5__c = item.ntceSpecDocUrl5;
                        // leadobj.ntceSpecDocUrl6__c = item.ntceSpecDocUrl6;
                        // leadobj.ntceSpecDocUrl7__c = item.ntceSpecDocUrl7;
                        // leadobj.ntceSpecDocUrl8__c = item.ntceSpecDocUrl8;
                        // leadobj.ntceSpecDocUrl9__c = item.ntceSpecDocUrl9;
                        // leadobj.ntceSpecDocUrl10__c = item.ntceSpecDocUrl10;
                        if (workDivision == 'getPrvtBidPblancListInfoServcPPSSrch') {
                            leadObj.bsnsDivNm__c = '민간용역';
                        }else if (workDivision == 'getPrvtBidPblancListInfoThngPPSSrch') {
                            leadObj.bsnsDivNm__c = '민간물품';
                        }else if (workDivision == 'getPrvtBidPblancListInfoEtcPPSSrch') {
                            leadObj.bsnsDivNm__c = '민간기타';
                        }
                        leadObj.RecordtypeId = naraRecordId;
                        leadMap.put(item.bidNtceNo, leadObj);
                    }
                    
                }
            System.debug('String.valueOf(leadMap): ' + String.valueOf(leadMap));
            }else {
                strCode = '0001';
                strStatus = 'ERROR';
                strMessage = 'HTTP Status code :' + res.getStatusCode();
            }
        } catch(Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
        }
        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        objResult.resultLead = leadMap <> null && leadMap.size() > 0 ? leadMap.values() : null;
        objOutput.result = objResult;

        objWrapper.status = strStatus;
        objWrapper.resultCode = strCode;
        objWrapper.resultMessage = strMessage;
        objWrapper.responseTime = Datetime.now();
        objWrapper.requestBody = getRquest;
        objWrapper.responseBody = responseBody;
        System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);

        IFUtil objIF = new IFUtil('IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2');
        objIf.setLog(objWrapper);
        
        return objOutput;
    }
}