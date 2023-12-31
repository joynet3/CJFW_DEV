/**
 * Created by 천유정 on 2023-01-30.
 */

@IsTest
private class DecisionProcessNewController_test {
    @TestSetup
    static void DecisionProcessNewController_testSetUp() {

        Set<String> setIFId = new Set<String>{'IF_SFDC_IFRESH_REG_APPROVAL'};

        List<IFMaster__c> listIF = new List<IFMaster__c>();

        for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'POST';
            obj.Type__c = 'Outbound';
            obj.WebServiceType__c = 'REST';

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
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.StageName = 'Proposal';
        objOpportunity.BidNoticeSource__c = 'NotNull';
        objOpportunity.LeadSource = 'NaraMarket';
        objOpportunity.BidQualifyRegistCloseDateTime__c = date.valueOf('2022-01-01');
        insert objOpportunity;
    }

    @IsTest
    static void DecisionProcessNewController_test() {
        test.startTest();

        try {
            Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
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
            objDecisionProcess.Type__c = 'CRM004';
            objDecisionProcess.Opportunity__c = objOpportunity.Id;

            PageReference pageRef = Page.ESM_RiskCheck;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', objOpportunity.Id);

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

            DecisionProcessNewController.getInitData();
            DecisionProcessNewController.doCheckOpenApproval(objOpportunity.Id, objDecisionProcess.Type__c);
            DecisionProcessNewController.doSave(objOpportunity.Id, objDecisionProcess);
        } catch (Exception e) {
            system.debug('DecisionProcessNewController_test  error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
        test.stopTest();
    }

    @IsTest
    static void DecisionProcessNewController_test2() {
        test.startTest();

        try {
            Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

            DecisionProcess__c objDecisionProcess = new DecisionProcess__c();
            objDecisionProcess.Name = '오픈 품의';
            objDecisionProcess.DocStatus__c = '임시저장';
            objDecisionProcess.DocId__c = '046B9F0DC91A';
            objDecisionProcess.totalLineCount__c = 2;
            objDecisionProcess.approvedCount__c = 1;
            objDecisionProcess.approvedUserName__c = '김성진님';
            objDecisionProcess.approvedUserType__c = '기안자';
            objDecisionProcess.approvedUserCode__c = '1000000245';
            objDecisionProcess.approvedDate__c = '"2023-01-20 16:01:54';
            objDecisionProcess.Type__c = 'CRM005';
            objDecisionProcess.Opportunity__c = objOpportunity.Id;

            PageReference pageRef = Page.ESM_SealUse;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', objOpportunity.Id);

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock2());

            DecisionProcessNewController.getInitData();
            DecisionProcessNewController.doCheckOpenApproval(objOpportunity.Id, objDecisionProcess.Type__c);
            DecisionProcessNewController.doSave(objOpportunity.Id, objDecisionProcess);

        } catch (Exception e) {
            system.debug('DecisionProcessNewController_test  error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
        test.stopTest();
    }

    @IsTest
    static void DecisionProcessNewController_test3() {
        test.startTest();

        try {
            Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

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
            objDecisionProcess.Type__c = 'CRM005';
            objDecisionProcess.Opportunity__c = objOpportunity.Id;

            PageReference pageRef = Page.ESM_OpenApproval;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', objOpportunity.Id);

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

            DecisionProcessNewController.getInitData();
            DecisionProcessNewController.doCheckOpenApproval(objOpportunity.Id, objDecisionProcess.Type__c);
            DecisionProcessNewController.doSave(objOpportunity.Id, objDecisionProcess);

        } catch (Exception e) {
            system.debug('DecisionProcessNewController_test  error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
        test.stopTest(); 
    }

    // err_cd":"성공"
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = newResponse(200);

            return response;
        }
    }

    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"err_cd":"성공","err_msg_ctt":"","doc_id":"046848E632CA","doc_num":"","url":"http://epqa2.ifresh.co.kr/Approval/Document/DocFrame?DocFolderType=TEMP\\u0026DocID=046848E632CA"}');
        return response; 
    }

    // err_cd":"실패"
    private class HttpCalloutSuccessMock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse2(200);

            return response;
        }
    }

    private static HTTPResponse newResponse2(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"err_cd":"실패","err_msg_ctt":"Object reference not set to an instance of an object.","doc_id":null,"doc_num":null,"url":null}');
        return response;
    }

}