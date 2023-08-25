public class IFN_TestDataFactory {
    
    
    public static void createIfPrograms()
    {
        
        StaticResource resource = [SELECT Id, Name, Body FROM StaticResource WHERE Name = 'IFMaster_JSON'];
        List<IFMaster__c> newList = (List<IFMaster__c>) JSON.deserialize(resource.Body.toString(), List<IFMaster__c>.class);
        Insert newList;
    }
}