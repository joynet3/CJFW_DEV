/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 09-12-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_CommRelatedListController {
    @AuraEnabled
    public static Map<String, Object> getRelatedParentInfo(String recordId){
        Map<String, Object> result = new Map<String, Object>();

        // Object 정보
        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        String objectLabel = Schema.getGlobalDescribe().get(objectApiName).getDescribe().getLabel();
        
        List<Schema.SObjectField> fieldList = COMM_Util.getFieldList(objectApiName);
        List<String> fieldNameList = new List<String>();
        
        for (Schema.SObjectField field : fieldList) {
            fieldNameList.add(field.getDescribe().getName());
        }
        
        String commaSeparatedString = String.join(fieldNameList, ',');

        String query =  ' SELECT ' + commaSeparatedString +
                        ' FROM ' + objectApiName +
                        ' WHERE Id = :recordId' +
                        ' LIMIT 1';
        sObject parentRecord = System.Database.query(query);
        
        // result.put('query', query);
        result.put('parentRecord', parentRecord);
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