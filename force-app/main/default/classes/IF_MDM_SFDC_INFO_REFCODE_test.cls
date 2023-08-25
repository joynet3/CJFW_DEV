/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class IF_MDM_SFDC_INFO_REFCODE_test {
    
    @testSetup
	static void setData() {
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_MDM_SFDC_INFO_REFCODE'};

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
        IF_MDM_SFDC_INFO_REFCODE b = new IF_MDM_SFDC_INFO_REFCODE();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String strBody = '{"transaction_id":"CR004_20221214133848040","is_last":"true","data":[{"INSTANCEID":"IT000000010020464569","GROUPID":"CUSTTYPE","CODE":"C01","NAME_KO":"본점","NAME_EN":"본점","NAME_ZH":"본점","NAME_VI":"본점","ATTR1":"","ATTR2":"","ATTR3":"","ACTIVE":"Y"}],"total_page":"1","page_no":"1"}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IF_MDM_SFDC_INFO_REFCODE.doPost();        

        Test.stopTest();
    }
}