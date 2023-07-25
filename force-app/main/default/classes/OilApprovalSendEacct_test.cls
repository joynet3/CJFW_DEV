/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class OilApprovalSendEacct_test {
    @testSetup
	static void setData() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = '123456';
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4700';
        objUser.Team__c = '325';

        update objUser;

        Set<String> setIFId = new Set<String>{'IF_SFDC_EACCT_REG_VRC'};

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
	}

    @isTest 
    static void itShould() {
        ActivityReport__c objAR = new ActivityReport__c();

        objAR.Description__c = 'test';
        objAR.ApprovalStatus__c = 'Approved';
        objAR.EventStartDate__c = Date.today();        
        objAR.OilTotalAmount__c = 1000;
        objAR.OilTotalDistance__c = 10;
        objAR.User__c = UserInfo.getUserId();
        objAR.isSendECCAT__c = false;
        insert objAR;        

        Event objEvent = new Event();
        objEvent.ActivityDate = Date.today();
        objEvent.Subject = 'Test';
        objEvent.StartDateTime = Datetime.now();
        objEvent.EndDateTime = Datetime.now().addHours(1);
        objEvent.WorkType__c = '내근';
        objEvent.Category__c = '기타';
        objEvent.ActivityReport__c = objAR.Id;
        insert objEvent;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        Map<String, String> mapParam = new Map<String, String>();

        OilApprovalSendEacct.doInit();

        mapParam.put('selectedStatus', 'Request');
        mapParam.put('selectedYear', String.valueOf(Date.today().year()));
        mapParam.put('selectedMonth', String.valueOf(Date.today().month()));

        User objUser = [
            SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, Team__c
            FROM    User
            WHERE   Id =: UserInfo.getUserId()
        ];

        mapParam.put('selectedHeadOffice', objUser.HeadOffice__c);
        mapParam.put('selectedSU', objUser.SU__c);
        mapParam.put('selectedTeam', objUser.Team__c);
        mapParam.put('isSendECCAT', 'false');

        OilApprovalSendEacct.getDataTable(mapParam);

        List<OilApprovalSendEacct.SearchWrapper> listWrapper = new List<OilApprovalSendEacct.SearchWrapper>();
        OilApprovalSendEacct.SearchWrapper objWrapper = new OilApprovalSendEacct.SearchWrapper();

        objWrapper.Team = 'test';
        objWrapper.TeamLabel = 'test';
        objWrapper.SU = 'test';
        objWrapper.SULabel = 'test';
        objWrapper.EmployeeNumber = objUser.EmployeeNumber;
        objWrapper.Name = 'test';
        objWrapper.OilType = 'test';
        objWrapper.CostCenter = '1000';
        objWrapper.totalAmount = '1000';
        objWrapper.totalDistance = '10';
        objWrapper.totalDistanceWithKm = '10';
        objWrapper.BankCode = '003';
        objWrapper.PaymentCode = 'test';

        listWrapper.add(objWrapper);

        String strJSON = JSON.serialize(listWrapper);

        Map<String, Object> mapActivityReportId = new Map<String, Object>();

        List<String> listId = new List<String>();

        listId.add(objAR.Id);

        mapActivityReportId.put(String.valueOf(objUser.EmployeeNumber), listId);

        OilApprovalSendEacct.doSendCredit(strJSON, JSON.serialize(mapActivityReportId), String.valueOf(Date.today()));

        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);

            return response;
        }
    }

    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"ERR_CD":"S", "ERR_MSG_CTT":"SUCCESS"}');

        return response;
    }

}