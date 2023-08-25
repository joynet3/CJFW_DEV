/**
 * Created by kw on 2023-02-02.
 */

@IsTest
private class ApprovalLineAutoUpdate_ba_test {
    @TestSetup
    static void ApprovalLineAutoUpdate_ba_testSetUp() {
        try{
            Set<String> setIFId = new Set<String>{'IF_SFDC_IFRESH_INFO_APPROVAL'};

            List<IFMaster__c> listIF = new List<IFMaster__c>();

            for(String str : setIFId) {
                IFMaster__c obj = new IFMaster__c();
                obj.Name = str;
                obj.ContentType__c = 'application/json';
                obj.Endpoint__c = 'https://test.salesforce.com';
                obj.Method__c = 'POST';
                obj.Type__c = 'Inbound';
                obj.WebserviceType__c = 'REST';

                listIF.add(obj);
            }

            insert listIF;

            IF_RELAY_INFO__c objRelayInfo = new IF_RELAY_INFO__c();
            objRelayInfo.Interface_id__c = 'test';
            objRelayInfo.Interface_auth_key__c = 'test';

            insert objRelayInfo;

            Account objAccount = TestObjectCreator.objHealthAccount;
            insert objAccount;

            PricebookEntry objPriceBookEntry = TestObjectCreator.objPricebookEntry;
            insert objPriceBookEntry;

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = Date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'NaraMarket';
            objOpportunity.BidQualifyRegistCloseDateTime__c = Date.valueOf('2022-01-01');
            insert objOpportunity;

            DecisionProcess__c objDecisionProcess = new DecisionProcess__c();
            objDecisionProcess.Name = '제안 품의';
            objDecisionProcess.DocStatus__c = '임시저장';
            objDecisionProcess.DocId__c = '046B9F0DC91A';
            objDecisionProcess.totalLineCount__c = 2;
            objDecisionProcess.approvedCount__c = 1;
            objDecisionProcess.approvedUserName__c = '김성진님';
            objDecisionProcess.approvedUserType__c = '기안자';
            objDecisionProcess.approvedUserCode__c = '1000000245';
            objDecisionProcess.approvedDate__c = '"2023-01-20 16:01:54';
            insert objDecisionProcess;
    
        } catch (Exception e) {
            System.debug('ApprovalLineAutoUpdate_ba_test line : ' + e.getLineNumber());
            System.debug('ApprovalLineAutoUpdate_ba_test message : ' + e.getMessage());
            System.debug('ApprovalLineAutoUpdate_ba_test cause : ' + e.getCause());
        }
    }
    
    @IsTest
    static void ApprovalLineAutoUpdate_ba_test() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        ApprovalLineAutoUpdate_ba ba = new ApprovalLineAutoUpdate_ba();
        Database.executeBatch(ba);
        Test.stopTest();
    }

    // err_cd":"성공"
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = newResponse(200);
            return response;
        }
    }

    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"err_cd":"성공","err_msg_ctt":"","doc_state":"임시저장","url":"http://epqa2.ifresh.co.kr/Approval/Document/DocFrame?DocFolderType=TEMP\\u0026DocID=046B9F0DC91A","approval_line":[{"no":"1","approval_type":"기안자","status":"임시저장","user_id":"1000000245","user_name":"김성진님","approval_date":"2023-01-20 16:01:54"}]}');
        return response;
    }
}