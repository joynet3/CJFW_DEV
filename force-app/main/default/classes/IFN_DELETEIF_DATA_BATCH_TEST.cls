@isTest
public class IFN_DELETEIF_DATA_BATCH_TEST {
    @TestSetup
    static void setup()
    {
       
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
    static void testOne(){
        Test.startTest();
        Database.executeBatch(new IFN_DELETEIF_DATA_BATCH('IFLog__c',''),1000);
        Test.stopTest();
    }



}