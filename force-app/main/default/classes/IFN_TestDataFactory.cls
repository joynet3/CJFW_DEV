public class IFN_TestDataFactory {
    
    
    public static void createIfPrograms()
    {
        
        StaticResource resource = [SELECT Id, Name, Body FROM StaticResource WHERE Name = 'IFMaster_JSON'];
        List<IFMaster__c> newList = (List<IFMaster__c>) JSON.deserialize(resource.Body.toString(), List<IFMaster__c>.class);
        Insert newList;

        IFMaster__c ifmst = new IFMaster__c(Name='Dummy',
            InterfaceId__c = 'Dummy',
            Endpoint__c = '',
            Method__c = 'POST',
            ContentType__c = 'application/json',
            ifKeyId__c = 'test'
        );
        insert ifmst;


        IF_RELAY_INFO__c objRelayInfo = new IF_RELAY_INFO__c();
        objRelayInfo.Interface_id__c = 'test';
        objRelayInfo.Interface_auth_key__c = 'test';
        insert objRelayInfo;
                
    }
}