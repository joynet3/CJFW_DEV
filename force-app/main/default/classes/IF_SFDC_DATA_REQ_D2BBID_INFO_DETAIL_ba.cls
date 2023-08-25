/**
 * @description       : IF_SFDC_DATA_REQ_D2BBID_INFO_ba에서 받아온 list에대한 디테일 조회
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global with sharing class IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba implements Database.batchable<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items>, Database.Stateful, Database.AllowsCallouts{
    
    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL'];
    List<NaramarketKeyword__mdt> subKeywordList = [SELECT Keyword__c, keyword_seq__c FROM NaramarketKeyword__mdt WHERE Keyword_lv__c = 2 ORDER BY keyword_seq__c ASC];
    Id recordId = Schema.SObjectType.LEAD.getRecordTypeInfosByDeveloperName().get('MilitaryLead').getRecordTypeId();
    
    AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
    Database.DMLOptions dmlOpts = new Database.DMLOptions();

    List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> inputItemsList = new List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items>();
    Set<String> bidNoticeNumSet = new Set<String>();


    global IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba(List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> inputItemsList) {
        this.inputItemsList = inputItemsList;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 국방부 전자조달 마스터 리턴
    ************************************************************************************************************/
    global Iterable<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> start(Database.BatchableContext bc) {
        return inputItemsList;
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 국방부 전자조달정보 상세조회 API 호출 및 Lead 생성 
    ************************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> scope) {

        IFUtil objIf = new IFUtil('IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL');
        LogWrapper objWrapper = new LogWrapper();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        // dmlOpts.EmailHeader.TriggerUserEmail = true;

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String result = '';
        String getParameter = '';

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();


        getParameter += 'getDmstcCmpetBidPblancDetail';
        getParameter += '?demandYear='+ scope[0].demandYear;
        getParameter += '&orntCode='+ scope[0].orntCode;
        getParameter += '&dcsNo=' + scope[0].dcsNo;
        getParameter += '&pblancNo=' + scope[0].pblancNo;
        getParameter += '&pblancOdr=' + scope[0].pblancOdr;
        System.debug(getParameter);

        try {

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
                result = strJSON;
                System.debug('==================================getBody:::' + strJSON);
                IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input input = (IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input) JSON.deserialize(strJSON, IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Input.class);
                String bidNo = '';
                Map<String,Lead> uptLeadMap = new Map<String,Lead>();
                
                if (Integer.valueOf(input.response.body.item.g2bPblancOdr) < 10) {
                    Integer ord = Integer.valueOf(input.response.body.item.g2bPblancOdr);
                    bidNo = (scope[0].demandYear+input.response.body.item.g2bPblancNo+'-0'+ String.valueOf(ord));
                }else {
                    bidNo = (scope[0].demandYear+input.response.body.item.g2bPblancNo+'-'+input.response.body.item.g2bPblancOdr);
                }
                for (Lead obj : [SELECT Id, BidNoticeNumber__c 
                                        FROM Lead 
                                        WHERE BidNoticeNumber__c =: bidNo]) {
                        uptLeadMap.put(obj.BidNoticeNumber__c, obj);
                    }
                
                if (uptLeadMap.get(bidNo) <> null) {
                    Lead uptLead = uptLeadMap.get(bidNo);
                    uptLead.LastName = input.response.body.item.chargerNm;
                    uptLead.Status = 'New';
                    uptLead.MobilePhone = input.response.body.item.chargerCttpc;
                    uptLead.Company = input.response.body.item.ornt;
                    // uptLead.BidNoticeNumber__c = input.response.body.item.pblancNo;
                    uptLead.BidNoticeStatus__c = input.response.body.item.pblancSe;
                    uptLead.BidNoticeName__c = input.response.body.item.bidNm;
                    uptLead.BidMethod__c = input.response.body.item.bidMth;
                    uptLead.ContractSignMethod__c = input.response.body.item.cntrctMth;
                    uptLead.BidStatus__c = input.response.body.item.bidStle;
                    uptLead.ContractType__c = input.response.body.item.cntrctKnd;
                    //판단요구년도 공고번호 판단번호와 나라장터기준 차수를 조합하여 외부키값인 나라장터공고번호를 생성 및 적재
                    if (Integer.valueOf(input.response.body.item.g2bPblancOdr) < 10) {
                        Integer ord = Integer.valueOf(input.response.body.item.g2bPblancOdr);
                        uptLead.BidNoticeNumber__c = scope[0].demandYear+input.response.body.item.g2bPblancNo+'-0'+ String.valueOf(ord);
                    }else {
                        uptLead.BidNoticeNumber__c = scope[0].demandYear+input.response.body.item.g2bPblancNo+'-'+input.response.body.item.g2bPblancOdr;
                    }
                    Datetime dt = Datetime.newInstance(
                        Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(0,4))
                        ,Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(3,5))
                        ,Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(4,6))
                        ,Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(5,7))
                        ,Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(6,8))
                        , 0
                        );
                    uptLead.BidQualifyRegistCloseDateTime__c = dt;
                    dt = Datetime.newInstance(
                        Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(0,4))
                        ,Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(3,5))
                        ,Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(4,6))
                        ,Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(5,7))
                        ,Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(6,8))
                        , 0
                        );
                    uptLead.BidLetterSubmitCloseDateTime__c = dt;
                    dt = Datetime.newInstance(
                        Integer.valueOf(input.response.body.item.opengDt.substring(0,4))
                        ,Integer.valueOf(input.response.body.item.opengDt.substring(3,5))
                        ,Integer.valueOf(input.response.body.item.opengDt.substring(4,6))
                        ,Integer.valueOf(input.response.body.item.opengDt.substring(5,7))
                        ,Integer.valueOf(input.response.body.item.opengDt.substring(6,8))
                        , 0
                        );
                    uptLead.BidOpenDateTime__c = dt;
                    if (input.response.body.item.pblancDate <> null && input.response.body.item.pblancDate <> '') {
                        Date d = Date.newInstance(
                            Integer.valueOf(input.response.body.item.pblancDate.substring(0,4))
                            , Integer.valueOf(input.response.body.item.pblancDate.substring(3,5))
                            , Integer.valueOf(input.response.body.item.pblancDate.substring(4,6))
                            );

                        uptLead.pblancDate__c = d;
                    }
                    uptLead.LeadSource = 'Military';
                    uptLead.BudgetAmount__c = input.response.body.item.budgetAmount <> null ? Decimal.valueOf(input.response.body.item.budgetAmount) : null;
                    uptLead.BidDeterminMethod__c = input.response.body.item.sucbidrDecsnMth;
                    uptLead.excutTy__c = input.response.body.item.excutTy;
                    uptLead.bsisPrdprcApplcAt__c = input.response.body.item.bsisPrdprcApplcAt;
                    uptLead.bsicExpt__c = scope[0].bsicExpt <> null ? Decimal.valueOf(scope[0].bsicExpt) : null;
                    uptLead.bsisPrdprcOthbcAt__c = scope[0].bsisPrdprcOthbcAt;
                    uptLead.Keyword__c = scope[0].keyword;
                    uptLead.RecordtypeId = recordId;
                    for (NaramarketKeyword__mdt keyword : subKeywordList) {
                        if (input.response.body.item.bidNm.contains(keyword.Keyword__c)) {
                            uptLead.KeywordSub__c = keyword.Keyword__c;
                            break;
                        }
                    }
                    update uptLead;
                }else {
                    Lead objLead = new Lead();
                    objLead.setOptions(dmlOpts);
                    objLead.LastName = input.response.body.item.chargerNm;
                    objLead.Status = 'New';
                    objLead.MobilePhone = input.response.body.item.chargerCttpc;
                    objLead.Company = input.response.body.item.ornt;
                    objLead.BidNoticeStatus__c = input.response.body.item.pblancSe;
                    objLead.BidNoticeName__c = input.response.body.item.bidNm;
                    objLead.BidMethod__c = input.response.body.item.bidMth;
                    objLead.ContractSignMethod__c = input.response.body.item.cntrctMth;
                    objLead.BidStatus__c = input.response.body.item.bidStle;
                    objLead.ContractType__c = input.response.body.item.cntrctKnd;
                    //판단요구년도 공고번호 판단번호와 나라장터기준 차수를 조합하여 외부키값인 나라장터공고번호를 생성 및 적재
                    if (Integer.valueOf(input.response.body.item.g2bPblancOdr) < 10) {
                        Integer ord = Integer.valueOf(input.response.body.item.g2bPblancOdr);
                        objLead.BidNoticeNumber__c = scope[0].demandYear+input.response.body.item.g2bPblancNo+'-0'+ String.valueOf(ord);
                    }else {
                        objLead.BidNoticeNumber__c = scope[0].demandYear+input.response.body.item.g2bPblancNo+'-'+input.response.body.item.g2bPblancOdr;
                    }
                    Datetime dt = Datetime.newInstance(
                        Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(0,4))
                        ,Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(3,5))
                        ,Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(4,6))
                        ,Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(5,7))
                        ,Integer.valueOf(input.response.body.item.bidPartcptRegistClosDt.substring(6,8))
                        , 0
                        );
                    objLead.BidQualifyRegistCloseDateTime__c = dt;
                    dt = Datetime.newInstance(
                        Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(0,4))
                        ,Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(3,5))
                        ,Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(4,6))
                        ,Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(5,7))
                        ,Integer.valueOf(input.response.body.item.biddocPresentnClosDt.substring(6,8))
                        , 0
                        );
                    objLead.BidLetterSubmitCloseDateTime__c = dt;
                    dt = Datetime.newInstance(
                        Integer.valueOf(input.response.body.item.opengDt.substring(0,4))
                        ,Integer.valueOf(input.response.body.item.opengDt.substring(3,5))
                        ,Integer.valueOf(input.response.body.item.opengDt.substring(4,6))
                        ,Integer.valueOf(input.response.body.item.opengDt.substring(5,7))
                        ,Integer.valueOf(input.response.body.item.opengDt.substring(6,8))
                        , 0
                        );
                    objLead.BidOpenDateTime__c = dt;
                    if (input.response.body.item.pblancDate <> null && input.response.body.item.pblancDate <> '') {
                        Date d = Date.newInstance(
                            Integer.valueOf(input.response.body.item.pblancDate.substring(0,4))
                            , Integer.valueOf(input.response.body.item.pblancDate.substring(3,5))
                            , Integer.valueOf(input.response.body.item.pblancDate.substring(4,6))
                            );
    
                        objLead.pblancDate__c = d;
                    }
                    objLead.LeadSource = 'Military';
                    objLead.BudgetAmount__c = input.response.body.item.budgetAmount <> null ? Decimal.valueOf(input.response.body.item.budgetAmount) : null;
                    objLead.BidDeterminMethod__c = input.response.body.item.sucbidrDecsnMth;
                    objLead.excutTy__c = input.response.body.item.excutTy;
                    objLead.bsisPrdprcApplcAt__c = input.response.body.item.bsisPrdprcApplcAt;
                    objLead.bsicExpt__c = scope[0].bsicExpt <> null ? Decimal.valueOf(scope[0].bsicExpt) : null;
                    objLead.bsisPrdprcOthbcAt__c = scope[0].bsisPrdprcOthbcAt;
                    objLead.Keyword__c = scope[0].keyword;
                    objLead.RecordtypeId = recordId;
                    for (NaramarketKeyword__mdt keyword : subKeywordList) {
                        if (input.response.body.item.bidNm.contains(keyword.Keyword__c)) {
                            objLead.KeywordSub__c = keyword.Keyword__c;
                            break;
                        }
                    }
                    insert objLead;
                }
                        
            }
        } catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
        }
        
        objWrapper.status = strStatus;
        objWrapper.resultCode = strCode;
        objWrapper.resultMessage = strMessage;
        objWrapper.requestBody = getParameter;
        objWrapper.responseBody = result;
        objWrapper.responseTime = Datetime.now();
        
        objIf.setLog(objWrapper);
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('=============================:::batch finish');
    }
}