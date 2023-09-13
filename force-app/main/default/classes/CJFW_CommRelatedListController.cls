/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 09-13-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_CommRelatedListController {
    @AuraEnabled
    public static Map<String, Object> getRelatedParentInfo(String recordId){
        Map<String, Object> result = new Map<String, Object>();

        // Object 정보
        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        String objectLabel = Schema.getGlobalDescribe().get(objectApiName).getDescribe().getLabel();

        String fieldString = getFieldListString(objectApiName);

        String query =  ' SELECT ' + fieldString +
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

    @AuraEnabled
    public static Map<String, Object> getRecords(String recordId, String targetObjectApiName, String sqlCondition, Integer recordLimit, String sortBy, String sortDirection){
        System.debug('recordId' + recordId);
        System.debug('recordLimit' + recordLimit);
        Map<String, Object> resultMap =new Map<String, Object>();

        String fieldString = getFieldListString(targetObjectApiName);

        List<SObject> dataList = System.Database.query(
            ' SELECT ' + fieldString +
            ' FROM ' + targetObjectApiName +
            ' WHERE ' + sqlCondition +
            ' ORDER BY ' + sortBy + ' ' + sortDirection +
            ' NULLS LAST ' +
            ' LIMIT ' + recordLimit
            + ' OFFSET 0'
        );
        
        AggregateResult total =System.Database.query(
            ' SELECT COUNT(Id) total' +
            ' FROM ' + targetObjectApiName +
            ' WHERE ' + sqlCondition
        );
        resultMap.put('total', total.get('total'));
        resultMap.put('data', dataList);
            
        return resultMap;
    }

    public static String getFieldListString(String ObjectApiName){
        List<Schema.SObjectField> fieldList = COMM_Util.getFieldList(objectApiName);
        List<String> fieldNameList = new List<String>();
        
        for (Schema.SObjectField field : fieldList) {
            fieldNameList.add(field.getDescribe().getName());
        }
        
        String commaSeparatedString = String.join(fieldNameList, ',');
        return commaSeparatedString;
    }

}