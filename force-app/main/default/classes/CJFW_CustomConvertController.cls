/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-31-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_CustomConvertController {

    // @AuraEnabled(cacheable=true)
    // public static String getSessionId() {
    //     return UserInfo.getSessionId();
    // }

    public static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        //service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.SessionHeader.sessionId = getSessionForLightning.getSession();
        return service;
    }
    
    // public static Map<String,Object> createObj(String objectName, Map<String,String> mappingField, List<String> fieldNameList, Map<String, Object> convertObj){
        
    //     Map<String,Object> objMap = new Map<String,Object>();
    
    //     List<String> cvtFields = new List<String>();
    //     for (String input : mappingField.keySet()) {//opportunityMappingField
    //         if(fieldNameList.contains(input)){
    //             String output = mappingField.get(input);//opptyField
    //             cvtFields.add(input);//lead
    //         }
    //     }
        
    //     SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    //     Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
    //     System.debug('fieldMap : '+fieldMap);
        
    //     Integer cnt = cvtFields.size();
    //     for(Integer i = 0; i < cnt; i++){
    //         Schema.SObjectField field = fieldMap.get(cvtFields[i]);
    //         Schema.DescribeFieldResult fld = field.getDescribe();
    //         String fieldType = fld.getType().name();
            
    //         if( fieldType == 'INTEGER' || fieldType == 'CURRENCY' || fieldType == 'DOUBLE' 
    //             || fieldType == 'DATE' || fieldType == 'DATETIME' || fieldType == 'BOOLEAN'){
    //         }
    //     }

    //     return objMap;
    // }
    
    @AuraEnabled
    public static Object getConvertObj(String recordId){
        //Fields
        String sObjectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        List<Schema.SObjectField> fieldList = COMM_Util.getFieldList(sObjectName);
        List<String> fieldNameList = new List<String>();
        for (Schema.SObjectField field : fieldList) {
            fieldNameList.add(field.getDescribe().getName());
        }
        String allFieldString = String.join(fieldNameList, ',');

        String query = ' SELECT '
                    // +     ' Id '
                    +      allFieldString
                    +       ', ConvertedAccount__r.Name'
                    +       ', ConvertedContact__r.Name'
                    +       ', ConvertedOpportunity__r.Name'
                    +  ' FROM ' + sObjectName
                    +  ' WHERE Id =:recordId ';
        List<sObject> convertObjList = Database.query(query);
        sObject obj = convertObjList[0];

        return obj;
    }

    @AuraEnabled
    public static Map<String,Object> convert(Map<String, Map<String,Object>> convertInfo, String recordId, String convertedOwnerId){
        Map<String,Object> resultMap = new  Map<String,Object>();
        
        // resultMap.put('sessionId', sessionId);

        //Lead Convert Info
        Map<String, String> accountMappingField = new Map<String, String>();//Lead->Account
        Map<String, String> contactMappingField = new Map<String, String>();
        Map<String, String> opportunityMappingField = new Map<String, String>();

        MetadataService.MetadataPort service = createService();
        
        List<MetadataService.LeadConvertSettings> leadConvertSettings = (List<MetadataService.LeadConvertSettings>) service.readMetadata('LeadConvertSettings', new List<String>{'LeadConvertSettings'}).getRecords();
        
        for (MetadataService.LeadConvertSettings leadConvertSetting : leadConvertSettings) {
            for (MetadataService.ObjectMapping objectMapping : leadConvertSetting.objectMapping) {
                System.debug(objectMapping.inputObject + ' -> ' + objectMapping.outputObject);
                MetadataService.ObjectMapping mappingObject = objectMapping;
                for (MetadataService.ObjectMappingField fieldMapping : objectMapping.mappingFields) {
                    // System.debug('\t' + fieldMapping.inputField + ' -> ' + fieldMapping.outputField);
                    if(mappingObject.outputObject == 'Account'){
                        accountMappingField.put(fieldMapping.inputField, fieldMapping.outputField);//LeadFeild -> AccountFeild
                    } else if (mappingObject.outputObject == 'Contact'){
                        contactMappingField.put(fieldMapping.inputField, fieldMapping.outputField);
                    } else if (mappingObject.outputObject == 'Opportunity'){
                        opportunityMappingField.put(fieldMapping.inputField, fieldMapping.outputField);
                    }
                }
            }
        }
        
        resultMap.put('convertInfo', convertInfo);
        /*
            convertInfo = {
                'Account' : {
                    'convert' : true
                    'create' : true, 
                    'fields' : {
                        'Name' : ''
                    },
                    'convertedId' : '',
                },
            }
        */
        Savepoint sp = Database.setSavepoint();
        try {
            //Fields
            String sObjectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();//CJFW_BiddingInformation__c, CJFW_PublicBiddingInformation__c
            List<Schema.SObjectField> fieldList = COMM_Util.getFieldList(sObjectName);
            List<String> fieldNameList = new List<String>();
            for (Schema.SObjectField field : fieldList) {
                fieldNameList.add(field.getDescribe().getName());
            }
            String allFieldString = String.join(fieldNameList, ',');

            String query = ' SELECT '
                        // +     ' Id '
                        +      allFieldString
                        +       ', ConvertedAccount__r.Name'
                        +       ', ConvertedContact__r.Name'
                        +       ', ConvertedOpportunity__r.Name'
                        +  ' FROM ' + sObjectName
                        +  ' WHERE Id =:recordId ';
            // System.debug('query :: ' + query);
            List<sObject> convertObjList = Database.query(query);
            //Map<String, Object> convertObj = (Map<String, Object>)convertObjList[0];
            sObject obj = convertObjList[0];
    
            Map<String, Object> convertObj = new Map<String, Object>();
            for (String fieldName : allFieldString.split(',')) {
                fieldName = fieldName.trim();
                convertObj.put(fieldName, obj.get(fieldName));
            }

            /*
                # Convert
				1. Account 
				2. Contact : AccountId 생성시만 동일
				3. Opportunity : AccountId 무조건 동일 -> 동일하지 않을 경우 throw
                4. upadte converted field
			*/

            //update convertInfo 
            Map<String, Object> updateConvertObj = new Map<String, Object>();
            updateConvertObj.put('Id', convertObj.get('Id'));
            
            //1. Account Convert
            Account acc = new Account();
            Map<String,Object> accountConvertInfo = (Map<String,Object>)convertInfo.get('Account');
            Id accRecordTypeId    = [SELECT Id, Name, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Account' AND DeveloperName = 'ProspectiveCustomer'].Id;

            if((Boolean)accountConvertInfo.get('convert')){
                
                for (String key : accountMappingField.keySet()) {
                    if(fieldNameList.contains(key)){
                        String value = accountMappingField.get(key);
                        acc.put(value, convertObj.get(key));
                    }
                }
                
                if((Boolean)accountConvertInfo.get('create')){
                    Map<Object,Object> accfield = (Map<Object,Object>)accountConvertInfo.get('fields');
                    acc.put('Name', accfield.get('Name'));
                } else if(!(Boolean)accountConvertInfo.get('create')){
                    List<Object> li = (List<Object>)accountConvertInfo.get('convertedId');
                    acc.put('Id',(String)li[0]);
                }
                
                acc.put('RecordTypeId', accRecordTypeId);
                acc.put('OwnerId', convertedOwnerId);
                upsert acc;
                updateConvertObj.put('Account__c', acc.Id);
                updateConvertObj.put('ConvertedAccount__c', acc.Id);
            }
            
            //2. Contact Convert
            Contact con = new Contact();
            Map<String,Object> contactConvertInfo = (Map<String,Object>)convertInfo.get('Contact');
            if((Boolean)contactConvertInfo.get('convert')){
                for (String key : contactMappingField.keySet()) {
                    if(fieldNameList.contains(key)){
                        String value = contactMappingField.get(key);
                        con.put(value, convertObj.get(key));
                    }
                }
                
                if((Boolean)contactConvertInfo.get('create')){
                    Map<Object,Object> contfield = (Map<Object,Object>)contactConvertInfo.get('fields');
                    con.put('Salutation', contfield.get('Salutation'));
                    con.put('LastName', contfield.get('LastName'));
                    con.put('FirstName', contfield.get('FirstName'));
                    con.put('AccountId', acc.Id);
                } else if(!(Boolean)contactConvertInfo.get('create')){
                    List<Object> li = (List<Object>)contactConvertInfo.get('convertedId');
                    con.put('Id',(String)li[0]);
                }

                con.put('OwnerId', convertedOwnerId);
                upsert con;
                updateConvertObj.put('ConvertedContact__c', con.Id);
            }
            
            //3. Oppty Convert
            Opportunity opp = new Opportunity();
            Map<String,Object> opptyConvertInfo = (Map<String,Object>)convertInfo.get('Opportunity');
            Id opptyRecordTypeId    = [SELECT Id, Name, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Opportunity' AND DeveloperName = 'General'].Id;

            if((Boolean)opptyConvertInfo.get('convert')){
                for (String key : opportunityMappingField.keySet()) {
                    if(fieldNameList.contains(key)){
                        String fieldName = opportunityMappingField.get(key);
                        Object value = convertObj.get(key);
                        try {
                            opp.put(fieldName, value);
                        }
                        catch (Exception e) {
                            resultMap.put('OPPTY FIELD TYPE DIFFERENT :', fieldName+'-->'+value);
                        }
                    }
                }

                opp.put('StageName','Needs Analysis');
                opp.put('CloseDate',Date.today().addDays(30));//TODO
                
                if((Boolean)opptyConvertInfo.get('create')){
                    Map<Object,Object> oppfield = (Map<Object,Object>)opptyConvertInfo.get('fields');
                    opp.put('Name', oppfield.get('Name'));
                    opp.put('AccountId', acc.Id);
                } else if(!(Boolean)opptyConvertInfo.get('create')){
                    List<Object> li = (List<Object>)opptyConvertInfo.get('convertedId');
                    opp.put('Id',(String)li[0]);
                }

                opp.put('RecordTypeId', opptyRecordTypeId);
                opp.put('OwnerId', convertedOwnerId);
                upsert opp;
                updateConvertObj.put('ConvertedOpportunity__c', opp.Id);
            }
            
            //if (condition) {
     		//   throw new Exception('예외 발생');
    		//}
            
            //4. UPDATE updateConvertObj;
            updateConvertObj.put('IsConverted__c',true);
            String jsonStr = JSON.serialize(updateConvertObj);
			// resultMap.put('jsonStr', jsonStr);
            // SObject customObject = (SObject)JSON.deserialize(jsonStr, Sobject.class);
            // update customObject;
            if(sObjectName == 'CJFW_BiddingInformation__c') {
                CJFW_BiddingInformation__c bi = (CJFW_BiddingInformation__c)JSON.deserialize(jsonStr, CJFW_BiddingInformation__c.class);
                update bi;
            }
            if(sObjectName == 'CJFW_PublicBiddingInformation__c'){
                CJFW_PublicBiddingInformation__c pi = (CJFW_PublicBiddingInformation__c)JSON.deserialize(jsonStr, CJFW_PublicBiddingInformation__c.class);
                update pi;
            }
            
            resultMap.put('STATUS', 'S');

            convertObjList = Database.query(query);
			resultMap.put('updateConvertObj', convertObjList[0]);
            
            Database.rollback(sp);            
            // resultMap.put('STATUS', 'S');
        } catch (Exception e) {
            Database.rollback(sp);
            resultMap.put('STATUS', 'E');
            resultMap.put('MESSAGE', e.getMessage());
            resultMap.put('TRACE', e.getStackTraceString());
        }
        
        return resultMap;
    }
}