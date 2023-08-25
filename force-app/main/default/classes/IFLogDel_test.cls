/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class IFLogDel_test {
    @testSetup
	static void setData() {
        Set<String> setIFId = new Set<String>{'IF_HOME_TEST', 'IF_NAVER_TEST'};

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

        IFLog__c objLog = new IFLog__c();
        objLog.IFMaster__c = listIF[0].Id;
        objLog.Status__c = 'SUCCESS';

        insert objLog;
	}
    @isTest 
    static void itShould() {
        IFLogDel_ba ba = new IFLogDel_ba(1);
        Database.executeBatch(ba);
    }

    @isTest 
    static void itShould2() {
        IFLogDel_sc scd = new IFLogDel_sc();
        SchedulableContext sc = null;
        scd.execute(sc);
    }
}