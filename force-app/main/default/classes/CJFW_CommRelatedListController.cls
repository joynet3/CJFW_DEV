/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 09-11-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_CommRelatedListController {
    @AuraEnabled
    public static Map<String, Object> getRelatedParentInfo(String recordId){
        Map<String, Object> result = new Map<String, Object>();

        // Object 정보
        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        String objectLabel = Schema.getGlobalDescribe().get(objectApiName).getDescribe().getLabel();
        String query =  ' SELECT ' + String.join(COMM_Util.getFieldList(objectApiName), ', ') +
                        ' FROM ' + objectApiName +
                        ' WHERE Id = :recordId' +
                        ' LIMIT 1';
        
        result.put('query', query);
        
        try {
            sObject parentRecord = System.Database.query(
                ' SELECT ' + String.join(COMM_Util.getFieldList(objectApiName), ', ') +
                ' FROM ' + objectApiName +
                ' WHERE Id = :recordId' +
                ' LIMIT 1'
            );
            result.put('parentRecord', parentRecord);
        }
        catch (Exception e) {
            
        }
        
        result.put('parentObjectLabel', objectLabel);        
        result.put('parentObjectApiName', objectApiName);

        return result;
    }

    @AuraEnabled
    public static Map<String, Object> hasObejctAccess(String ObjectApiName){
        Map<String, Object> result = new Map<String, Object>();
        
        Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(ObjectApiName).getDescribe();

        System.debug('isCreateable' + describe.isCreateable());
        System.debug('isAccessible' + describe.isAccessible());
        System.debug('isUpdateable' + describe.isUpdateable());
        System.debug('isDeletable' + describe.isDeletable());

        result.put('isCreateable', describe.isCreateable());
        result.put('isAccessible', describe.isAccessible());
        result.put('isUpdateable', describe.isUpdateable());
        result.put('isDeletable', describe.isDeletable());

        return result;
    }
}