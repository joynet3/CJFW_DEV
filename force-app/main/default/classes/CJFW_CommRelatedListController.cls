/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 09-14-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_CommRelatedListController {
    
    /**
    * @description Related Parent Record 의 정보 조회
    * @author yejoo.lee@dkbmc.com | 09-14-2023 
    * @param recordId 
    * @return Map<String, Object> 
    **/
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

    /**
    * @description 사용자의 오브젝트 권한 확인
    * @author yejoo.lee@dkbmc.com | 09-14-2023 
    * @param ObjectApiName 
    * @return Map<String, Object> 
    **/
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

    /**
    * @description 해당하는 오브젝트의 리스트 정보 조회
    * @author yejoo.lee@dkbmc.com | 09-14-2023 
    * @param recordId 
    * @param targetObjectApiName 
    * @param addFieldString 
    * @param sqlCondition 
    * @param recordLimit 
    * @param sortBy 
    * @param sortDirection 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> getRecords(String recordId, String targetObjectApiName, String addFieldString, String sqlCondition, Integer recordLimit, String sortBy, String sortDirection){
        System.debug('recordId' + recordId);
        System.debug('recordLimit' + recordLimit);
        Map<String, Object> resultMap =new Map<String, Object>();

        String fieldString = getFieldListString(targetObjectApiName);

        String dataQuery =  ' SELECT ' + fieldString + ', ' + addFieldString +
                            ' FROM ' + targetObjectApiName +
                            ' WHERE ' + sqlCondition;
        
                            if(sortBy != '' && sortDirection != ''){
            dataQuery    += ' ORDER BY ' + sortBy + ' ' + sortDirection +
                            ' NULLS LAST ';
        }
        
        dataQuery   += ' LIMIT ' + recordLimit
                    + ' OFFSET 0';

        List<SObject> dataList = System.Database.query(dataQuery);
        
        AggregateResult total =System.Database.query(
            ' SELECT COUNT(Id) total' +
            ' FROM ' + targetObjectApiName +
            ' WHERE ' + sqlCondition
        );
        resultMap.put('total', total.get('total'));
        resultMap.put('data', dataList);
            
        return resultMap;
    }

    /**
    * @description 필드 리스트를 스트링으로 반환
    * @author yejoo.lee@dkbmc.com | 09-14-2023 
    * @param ObjectApiName 
    * @return String 
    **/
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