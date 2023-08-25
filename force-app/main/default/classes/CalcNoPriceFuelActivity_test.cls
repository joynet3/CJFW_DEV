/**
 * Created by kw on 2023-02-02.
 */

@IsTest
private class CalcNoPriceFuelActivity_test {
    @TestSetup
    static void CalcNoPriceFuelActivity_testSetUp() {
        try{
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

            User objUser = new User();
            objUser.Id = UserInfo.getUserId();
            objUser.EmployeeNumber = 'test1234';
            objUser.oil_type_cd__c = '1';
            update objUser;

            Event objEvent = new Event();
            objEvent.Distancekm__c = 5.29;
            objEvent.VehicleRefuelingCosts__c = 0;
            objEvent.DurationInMinutes = 1;
            objEvent.WorkType__c = '외근';
            objEvent.oil_type_cd__c = '1';
            objEvent.ActivityDateTime = Datetime.now();
            insert objEvent;
            system.debug('objEvent :: ' + objEvent);

        } catch (Exception e) {
            System.debug('CalcNoPriceFuelActivity_test line : ' + e.getLineNumber());
            System.debug('CalcNoPriceFuelActivity_test message : ' + e.getMessage());
            System.debug('CalcNoPriceFuelActivity_test cause : ' + e.getCause());
        }
    }

    @IsTest
    static void CalcNoPriceFuelActivity_test() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        CalcNoPriceFuelActivity_sc sc = new CalcNoPriceFuelActivity_sc();
        System.schedule('CalcNoPriceFuelActivity_sc','0 0 2 1/1 * ? *', sc);

        Test.stopTest();
    }

    // SUCCESS
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);

            return response;
        }
    }

    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{"ERR_CD":"S","ERR_MSG_CTT":"","DS_MASTER":{"data":[{"OIL_UNITP":262,"BASE_MON":"202301","COM_CD":"FW00","OIL_TYPE_CD":"1","DPRC_UNITP":101}],"SVC_ERR_MSG_TEXT":"","ErrorCode":0}}');
        return response;
    }
}