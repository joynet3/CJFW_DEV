/**
 * Created by kw on 2023-01-30.
 */

@IsTest
private class OilApprovalSendHistory_test {
    @TestSetup
    static void ApprovalLineUpdateController_testSetUp() {

        Set<String> setIFId = new Set<String>{
                'IF_SFDC_IFRESH_INFO_APPROVAL'
        };

        List<IFMaster__c> listIF = new List<IFMaster__c>();

        for (String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'POST';
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;
        IF_RELAY_INFO__c objRelayInfo = new IF_RELAY_INFO__c();
        objRelayInfo.Interface_id__c = 'test';
        objRelayInfo.Interface_auth_key__c = 'test';

        insert objRelayInfo;
    }
    
    @IsTest
    static void OilApprovalSendHistory_test() {
        DecisionProcess__c objDecisionProcess = new DecisionProcess__c();
        objDecisionProcess.Name = 'test';
        objDecisionProcess.DocStatus__c = '임시저장';
        objDecisionProcess.totalLineCount__c = 1;
        objDecisionProcess.approvedCount__c = 0;
        objDecisionProcess.approvedUserName__c = UserInfo.getName();
        objDecisionProcess.approvedUserType__c = '기안자';
        objDecisionProcess.approvedDate__c = '2023-01-30 14:01:07';
        objDecisionProcess.approvedUserCode__c = '1000000245';
        objDecisionProcess.APPV_NO__c = '4561899';
        insert objDecisionProcess;

        Test.startTest();
        System.debug(OilApprovalSendHistory.doInit());
        Map<String, String> mapParam = new Map<String, String>();
        mapParam.put('selectedYear' , '');
        mapParam.put('selectedMonth', '');
        mapParam.put('selectedHeadOffice', '');
        mapParam.put('selectedSU', '');
        System.debug(OilApprovalSendHistory.doGetTargetData(mapParam));
        System.debug(OilApprovalSendHistory.doUpdateDocId(objDecisionProcess.Id));


        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.debug(OilApprovalSendHistory.doUpdateDocState(objDecisionProcess.Id));
        List<id> targetId = new List<Id>();
        targetId.add(objDecisionProcess.Id);
        System.debug(OilApprovalSendHistory.getDataTable(targetId));


        Test.stopTest();
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
        response.setBody('{"err_cd":"성공","err_msg_ctt":"","doc_state":"임시저장","url":"http://epqa2.ifresh.co.kr/Approval/Document/DocFrame?DocFolderType=TEMP\\u0026DocID=046B9F0DC91A","approval_line":[{"no":"1","approval_type":"기안자","status":"임시저장","user_id":"1000000245","user_name":"김성진님","approval_date":"2023-01-20 16:01:54"}]}');
        return response;
    }
}