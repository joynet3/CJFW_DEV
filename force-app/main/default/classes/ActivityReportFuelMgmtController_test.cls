/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class ActivityReportFuelMgmtController_test {
    @testSetup
	static void setData() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = '123456';
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4700';
        objUser.Team__c = '325';
        objUser.oil_type_cd__c = '5';
        update objUser;
        
        Account objExAccount = TestObjectCreator.objExAccount;
        insert objExAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objExAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;

        Set<String> setIFId = new Set<String>{'IF_SFDC_EACCT_INQ_OIL_AMOUNT'};
        List<IFMaster__c> listIF = new List<IFMaster__c>();
        for(String str : setIFId) {
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

        ActivityReport__c objAR = new ActivityReport__c();
        objAR.Description__c = 'test';
        objAR.ApprovalStatus__c = 'Approved';
        objAR.EventStartDate__c = Date.today();
        objAR.OilTotalAmount__c = 0;
        objAR.OilTotalDistance__c = 0;
        objAR.User__c = UserInfo.getUserId();
        objAR.isSendECCAT__c = false;
        insert objAR;

        Event objEvent = new Event();
        objEvent.ActivityDate = Date.today();
        objEvent.Subject = 'Test';
        objEvent.Opportunity__c = objOpportunity.Id;
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now().addHours(1);
        objEvent.ActivityReport__c = objAR.Id;
        objEvent.WorkType__c = '외근';
        insert objEvent;
	}

    @isTest 
    static void itShouldMock1() {
        ActivityReport__c objAR = [SELECT Id FROM ActivityReport__c LIMIT 1];
        Event objEvent = [SELECT Id FROM Event LIMIT 1];
        Opportunity obOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        ActivityReportFuelMgmtController.getInitData(objAR.Id);

        List<Event> listEvent = new List<Event>();
        listEvent.add(objEvent);

        ActivityReportFuelMgmtController.doSave(objAR.Id, 'Test', listEvent, 0);

        objAR.OilTotalAmount__c = 1000;
        objAR.OilTotalDistance__c = 0;
        update objAR;

        ActivityReportFuelMgmtController.doSave(objAR.Id, 'Test', listEvent, 0);
        ActivityReportFuelMgmtController.doSave(objAR.Id, 'Final', listEvent, 0);
        ActivityReportFuelMgmtController.getPrefix();

        Test.stopTest();
    }

    @isTest
    static void itShouldMock2() {
        ActivityReport__c objAR = [SELECT Id FROM ActivityReport__c LIMIT 1];
        Event objEvent = [SELECT Id FROM Event LIMIT 1];
        Opportunity obOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock2());
        ActivityReportFuelMgmtController.getInitData(objAR.Id);

        List<Event> listEvent = new List<Event>();
        listEvent.add(objEvent);

        ActivityReportFuelMgmtController.doSave(objAR.Id, 'Test', listEvent, 0);

        objAR.OilTotalAmount__c = 1000;
        objAR.OilTotalDistance__c = 0;
        update objAR;

        ActivityReportFuelMgmtController.doSave(objAR.Id, 'Test', listEvent, 0);
        ActivityReportFuelMgmtController.doSave(objAR.Id, 'Final', listEvent, 0);
        ActivityReportFuelMgmtController.getPrefix();

        Test.stopTest();
    }

    @isTest
    static void itShouldMock3() {
        ActivityReport__c objAR = [SELECT Id FROM ActivityReport__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock3());
        ActivityReportFuelMgmtController.getInitData(objAR.Id);
        Test.stopTest();
    }

    @isTest
    static void itShouldMock3_1() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.oil_type_cd__c = '1';
        update objUser;
        
        ActivityReport__c objAR = [SELECT Id FROM ActivityReport__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock3());
        ActivityReportFuelMgmtController.getInitData(objAR.Id);
        Test.stopTest();
    }

    @isTest
    static void itShouldMock3_2() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.oil_type_cd__c = '2';
        update objUser;

        ActivityReport__c objAR = [SELECT Id FROM ActivityReport__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock3());
        ActivityReportFuelMgmtController.getInitData(objAR.Id);
        Test.stopTest();
    }

    @isTest
    static void itShouldMock3_3() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.oil_type_cd__c = '3';
        update objUser;

        ActivityReport__c objAR = [SELECT Id FROM ActivityReport__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock3());
        ActivityReportFuelMgmtController.getInitData(objAR.Id);
        Test.stopTest();
    }

    @isTest
    static void itShouldMock3_4() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.oil_type_cd__c = '4';
        update objUser;

        ActivityReport__c objAR = [SELECT Id FROM ActivityReport__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock3());
        ActivityReportFuelMgmtController.getInitData(objAR.Id);
        Test.stopTest();
    }

    @isTest
    static void itShouldMock4() {
        ActivityReport__c objAR = [SELECT Id FROM ActivityReport__c LIMIT 1];
        Event objEvent = [SELECT Id FROM Event LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock4());

        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.oil_type_cd__c = '1';
        update objUser;
        ActivityReportFuelMgmtController.getInitData(objAR.Id);

        objUser.oil_type_cd__c = '2';
        update objUser;
        ActivityReportFuelMgmtController.getInitData(objAR.Id);

        objUser.oil_type_cd__c = '3';
        update objUser;
        ActivityReportFuelMgmtController.getInitData(objAR.Id);

        objUser.oil_type_cd__c = '4';
        update objUser;
        ActivityReportFuelMgmtController.getInitData(objAR.Id);

        Test.stopTest();
    }


    // Mock1 : SUCCESS
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);

            return response;
        }
    }

    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{"ERR_CD":"S","ERR_MSG_CTT":"","DS_MASTER":{"data":[{"OIL_UNITP":274,"BASE_MON":"202211","COM_CD":"FW00","OIL_TYPE_CD":"1","DPRC_UNITP":101}],"SVC_ERR_MSG_TEXT":"","ErrorCode":0}}');

        return response;
    }

    // Mock2 : ERR_CD":"E"
    private class HttpCalloutSuccessMock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse2(200);

            return response;
        }
    }

    private static HTTPResponse newResponse2(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{"ERR_CD":"E","ERR_MSG_CTT":"검색된 결과가 없습니다."}');

        return response;
    }

    // Mock3 : ERR_CD":"9999"
    private class HttpCalloutSuccessMock3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse3(200);
            return response;
        }
    }

    private static HttpResponse newResponse3(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{"ERR_CD":"9999","ERR_MSG_CTT":"검색된 결과가 없습니다."}');
        return response;
    }

    // Mock4 : 503 ERROR
    private class HttpCalloutSuccessMock4 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse4(503);

            return response;
        }
    }

    private static HTTPResponse newResponse4(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('<html>\n' +
                '<head><title>503 Service Temporarily Unavailable</title></head>\n' +
                '<body>\n' +
                '<center><h1>503 Service Temporarily Unavailable</h1></center>\n' +
                '</body>\n' +
                '</html>');
        return response;
    }
}