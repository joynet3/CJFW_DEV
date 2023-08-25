/**
 * @description       : 리드 입찰공고 가져오기
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class NaraTenderBtnController {
    /**
     * 입찰공고번호 조회
     * 
     * @param inputStr 입찰공고번호
     * @param sourceSiteChk 1(나라장터), 2(국방부전자조달시스템)
     * @param workDivision getBidPblancListInfoThng(물품), getBidPblancListInfoServc(용역), getBidPblancListInfoFrgcpt(외자), getBidPblancListInfoEtc(기타)
     *                     getPrvtBidPblancListInfoThng(민간물품), getPrvtBidPblancListInfoServc(민간용역), getPrvtBidPblancListInfoEtc(민간기타)
     * @return Map<String, Object>
     *
    **/
    @AuraEnabled
    public static Map<String, Object> doSearch(String inputStr, String sourceSiteChk, String workDivision) {
        system.debug('inputStr ::' + inputStr);
        System.debug('sourceSiteChk :: ' + sourceSiteChk);
        System.debug('workDivision :: ' + workDivision);

        IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Output outputObj = new IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL.Output();
        IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL ifDetail = new IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL();
        IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2 ifDetail2 = new IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2();

        String resultMessage = '';
        String resultCode = '';
        Lead resultLead = new Lead();

        if(!Test.isRunningTest()) {
            if (workDivision == 'getPrvtBidPblancListInfoThng' || workDivision == 'getPrvtBidPblancListInfoServc' || workDivision == 'getPrvtBidPblancListInfoEtc') {
                outputObj = ifDetail2.callOut(inputStr, sourceSiteChk, workDivision);
            }else {
                outputObj = ifDetail.callOut(inputStr, sourceSiteChk, workDivision);
            }
            resultMessage = outputObj.result.resultMessage;
            resultCode = outputObj.result.resultCode;
            resultLead = outputObj.result.resultLead;
            System.debug('resultMessage: ' + resultMessage);
        }
        system.debug('outputObj ::' + outputObj);

        Map<String, object> mapResult = new Map<String, object>{
            'resultMessage' => resultMessage,
            'resultCode' => resultCode,
            'resultLead' => resultLead
        };
        return mapResult;
    }

    /**
     * 입찰공고(Lead) 저장
     * 
     * @param insertLead Lead Object 정보
     * @param sourceSiteChk 1(나라장터), 2(국방부전자조달시스템)
     * @param workDivision getBidPblancListInfoThng(물품), getBidPblancListInfoServc(용역), getBidPblancListInfoFrgcpt(외자), getBidPblancListInfoEtc(기타)
     *                     getPrvtBidPblancListInfoThng(민간물품), getPrvtBidPblancListInfoServc(민간용역), getPrvtBidPblancListInfoEtc(민간기타)
     * @return Map<String, Object>
     *
    **/
    @AuraEnabled
    public static Map<String, Object> doSave(Lead insertLead, String sourceSiteChk, String workDivision) {
        String resultCode = '0000';
        String resultMessage = '';
        AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        // dmlOpts.EmailHeader.TriggerUserEmail = true;

        insertLead.setOptions(dmlOpts);

        try {
            Set<Id> joinLeadSet = new Set<Id>();
            if (sourceSiteChk == '1') {
                upsert insertLead g2bPblancNo__c;
                joinLeadSet.add(insertLead.Id);
                // IF_SFDC_DATA_REQ_NARA_TENDER_RERT_ba b = new IF_SFDC_DATA_REQ_NARA_TENDER_RERT_ba(joinLeadSet, 1);
                IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba b2 = new IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba(joinLeadSet, 1);
                // Database.executeBatch(b, 1);
                Database.executeBatch(b2, 1);
            }else {
                upsert insertLead BidNoticeNumber__c;
                joinLeadSet.add(insertLead.Id);
                
                if (workDivision == 'getPrvtBidPblancListInfoThng' || workDivision == 'getPrvtBidPblancListInfoServc' || workDivision == 'getPrvtBidPblancListInfoEtc') {
                    IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba b = new IF_SFDC_DATA_REQ_NARA_TENDER_RERT2_ba(joinLeadSet, 1);
                    IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE2_ba b2 = new IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE2_ba(joinLeadSet, 1);
                    Database.executeBatch(b, 1);
                    Database.executeBatch(b2, 1);
                }else {
                    // IF_SFDC_DATA_REQ_NARA_TENDER_RERT_ba b = new IF_SFDC_DATA_REQ_NARA_TENDER_RERT_ba(joinLeadSet, 1);
                    IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba b2 = new IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE_ba(joinLeadSet, 1);
                    // Database.executeBatch(b, 1);
                    Database.executeBatch(b2, 1);
                }
            }
        } catch(Exception e) {
            resultCode = '-1';
            resultMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(resultMessage);
        }

        Map<String, object> mapResult = new Map<String, object>{
            'resultMessage' => resultMessage,
            'resultCode' => resultCode,
            'resultId' => insertLead.Id
        };

        return mapResult;
    }
}