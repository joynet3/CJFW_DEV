/**
 * Created by kw on 2023-01-06.
 */

@IsTest
private class IF_SFDC_IFRESH_REG_ACCOUNT_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();
        List<String> listIF = new List<String>{'IF_SFDC_IFRESH_REG_ACCOUNT'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'GET';
            objIFMaster.ContentType__c = 'application/json';
            objIFMaster.Endpoint__c = 'test';

            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;

        Account objAcc = TestObjectCreator.objSchoolAccount;
        insert objAcc;

    }

    @IsTest
    static void IF_SFDC_IFRESH_SEND_ACCOUNT_test() {
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        List<String> listTargetAccoutId = new List<String>();
        Set<Id> setUserId = new Set<Id>();
        Map<Id, String> mapCUD = new Map<Id, String>();
        Map<Id, String> mapCUD2 = new Map<Id, String>();
        Set<String> setTargetcustId = new Set<String>();

        listTargetAccoutId.add(objAcc.Id);
        setUserId.add(UserInfo.getUserId());
        mapCUD.put(objAcc.Id,'C');
        mapCUD2.put(objAcc.Id,'U');
        setTargetcustId.add('123');

        Test.startTest();
        IF_SFDC_IFRESH_REG_ACCOUNT.doSend(listTargetAccoutId, setUserId, mapCUD, setTargetcustId);
        IF_SFDC_IFRESH_REG_ACCOUNT.doSend(listTargetAccoutId, setUserId, mapCUD2, setTargetcustId);
        IF_SFDC_IFRESH_REG_ACCOUNT.doSend(null, null, null, setTargetcustId);

        Test.stopTest();

    }
}