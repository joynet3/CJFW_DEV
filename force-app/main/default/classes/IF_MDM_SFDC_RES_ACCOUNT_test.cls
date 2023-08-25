/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class IF_MDM_SFDC_RES_ACCOUNT_test {
    
    @testSetup
	static void setData() {
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_MDM_SFDC_RES_ACCOUNT'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Inbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'POST';
            objIFMaster.ContentType__c = 'application/json';
            objIFMaster.Endpoint__c = '';
            
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;
	}

    @isTest 
    static void itShoud() {
        Test.startTest();

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        MDMRegRequestCustomer__c objCustomer = new MDMRegRequestCustomer__c();
        objCustomer.Account__c = objAccount.Id;
        insert objCustomer;


        IF_MDM_SFDC_RES_ACCOUNT b = new IF_MDM_SFDC_RES_ACCOUNT();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String strBody = '{"transaction_id":"CR004_20230126141214727","is_last":"true","data":[{"INSTANCEID":"PI00699177","PV_CRMNO":"'+objAccount.Id+'","WF_STATUS":"PROC","WF_ACTOR":[{"EMPLOYEE_NUM":"WDE1093203","NAME":"안제헌님"}],"WF_NEXTACTOR":[{"EMPLOYEE_NUM":"","NAME":"기준정보관리자"}],"WF_DATE":"2023-01-26 14:12:11","WF_DESCRIPTION":"승인합니다."}],"total_page":"1","page_no":"1"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IF_MDM_SFDC_RES_ACCOUNT.doPost();        

        Test.stopTest();
    }
}