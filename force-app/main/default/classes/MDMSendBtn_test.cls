/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class MDMSendBtn_test {
    @testSetup
	static void setData() {

        Set<String> setIFId = new Set<String>{'IF_SFDC_MDM_REG_ACCOUNT'};

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
	}
    @isTest 
    static void itShould() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());        

        MDMRegRequestCustomer__c objCustomer = new MDMRegRequestCustomer__c();
        insert objCustomer;

        MDMRegRequestContact__c objContact = new MDMRegRequestContact__c();
        //objContact.Name = 'test';
        objContact.MDMRegRequestCustomer__c = objCustomer.Id;
        insert objContact;

        MDMSendBtn.doInit(objCustomer.Id);
        MDMSendBtn.doSendMDM(objCustomer.Id);        

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
        response.setStatusCode(statusCode);
        response.setBody('{"err_cd":"S","err_msg_ctt":"","WF_INSTANCEID":"PI00699177","PV_CRMNO":"0019D00000SVZ6BQAX","WF_STATUS":"PROC","WF_ACTOR":[{"EMPLOYEE_NUM":"258221","NAME":"권오성님"}],"WF_NEXTACTOR":[{"EMPLOYEE_NUM":"252014","NAME":"김민규님"}],"WF_DATE":"2023-01-26 14:05:40","WF_DESCRIPTION":""}');

        return response;
    }
}