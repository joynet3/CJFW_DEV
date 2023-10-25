/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_CustomConvertController {

    @AuraEnabled(cacheable=true)
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
    
    @AuraEnabled
    public static Map<String,Object> convert(Map<String, Object> convertInfo, String recordId, String sessionId){
        Map<String,Object> resultMap = new  Map<String,Object>();
        
        //Lead Convert Info
        Map<String, String> accountMappingField = new Map<String, String>();
        Map<String, String> contactMappingField = new Map<String, String>();
        Map<String, String> opportunityMappingField = new Map<String, String>();
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        service.CallOptions = new MetadataService.CallOptions_element();
        service.timeout_x = 120000;
        
        List<MetadataService.LeadConvertSettings> leadConvertSettings = (List<MetadataService.LeadConvertSettings>) service.readMetadata('LeadConvertSettings', new List<String>{'LeadConvertSettings'}).getRecords();
        
        for (MetadataService.LeadConvertSettings leadConvertSetting : leadConvertSettings) {
            for (MetadataService.ObjectMapping objectMapping : leadConvertSetting.objectMapping) {
                System.debug(objectMapping.inputObject + ' -> ' + objectMapping.outputObject);
                MetadataService.ObjectMapping mappingObject = objectMapping;
                for (MetadataService.ObjectMappingField fieldMapping : objectMapping.mappingFields) {
                    // System.debug('\t' + fieldMapping.inputField + ' -> ' + fieldMapping.outputField);
                    if(mappingObject.outputObject == 'Account'){
                        accountMappingField.put(fieldMapping.inputField, fieldMapping.outputField);
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
            String sObjectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();//CJFW_BiddingInfomation__c, CJFW_PublicBiddingInfomation__c
            List<Schema.SObjectField> fieldList = COMM_Util.getFieldList(sObjectName);
            List<String> fieldNameList = new List<String>();
            for (Schema.SObjectField field : fieldList) {
                fieldNameList.add(field.getDescribe().getName());
            }
            String allFieldString = String.join(fieldNameList, ',');

            String query = ' SELECT '
                        // +     ' Id '
                        +      allFieldString
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
			*/

            //update convertInfo 
            Map<String, Object> updateConvertObj = new Map<String, Object>();
            updateConvertObj.put('Id', convertObj.get('Id'));
            
            //1. convert Account
            Map<String,Object> accountConvertInfo = (Map<String,Object>)convertInfo.get('Account');
            if((Boolean)accountConvertInfo.get('convert')){
                Account acc = new Account();
                
                for (String key : accountMappingField.keySet()) {
                    String value = accountMappingField.get(key);
                    acc.put(value, convertObj.get(key));
                }
                
                if((Boolean)accountConvertInfo.get('create')){
                    Map<String,String> accfield = (Map<String,String>)accountConvertInfo.get('fields');
                    acc.put('Name', accfield.get('Name'));
                } else if(!(Boolean)accountConvertInfo.get('create')){
                    acc.put('Id',accountConvertInfo.get('convertedId'));
                }
                
                upsert acc;
                updateConvertObj.put('ConvertedAccount__c', acc.Id);
            }
            
            //2. convert Contact
            Map<String,Object> contactConvertInfo = (Map<String,Object>)convertInfo.get('Contact');
            if((Boolean)contactConvertInfo.get('convert')){
                Contact con = new Contact();
                for (String key : contactMappingField.keySet()) {
                    String value = contactMappingField.get(key);
                    con.put(value, convertObj.get(key));
                }
                
                if((Boolean)contactConvertInfo.get('create')){
                    Map<String,String> contfield = (Map<String,String>)contactConvertInfo.get('fields');
                    con.put('Salutation', contfield.get('Salutation'));
                    con.put('LastName', contfield.get('LastName'));
                    con.put('FirstName', contfield.get('FirstName'));
                } else if(!(Boolean)contactConvertInfo.get('create')){
                    con.put('Id',contactConvertInfo.get('convertedId'));
                }
                upsert con;
                updateConvertObj.put('ConvertedContact__c', con.Id);
            }
            
            //3. convert Oppty
            Map<String,Object> opptyConvertInfo = (Map<String,Object>)convertInfo.get('Opportunity');
            if((Boolean)opptyConvertInfo.get('convert')){
                Opportunity opp = new Opportunity();
                for (String key : opportunityMappingField.keySet()) {
                    String value = opportunityMappingField.get(key);
                    opp.put(value, convertObj.get(key));
                }
                
                if((Boolean)opptyConvertInfo.get('create')){
                    Map<String,String> oppfield = (Map<String,String>)opptyConvertInfo.get('fields');
                    opp.put('Name', oppfield.get('Name'));
                } else if(!(Boolean)opptyConvertInfo.get('create')){
                    String convertedId = (String)opptyConvertInfo.get('convertedId');
                    updateConvertObj.put('Id',convertedId);
                }
                upsert opp;
                updateConvertObj.put('ConvertedContact__c', opp.Id);
            }
            
            //if (condition) {
     		//   throw new Exception('예외 발생');
    		//}

            updateConvertObj.put('IsConverted__c',true);
            //update updateConvertObj;
            // List<SAMProduct__c> ProductList = (List<SAMProduct__c>) JSON.deserialize(param, List<SAMProduct__c>.class);
            
            resultMap.put('STATUS', 'S');
			resultMap.put('updateConvertObj', updateConvertObj);
            
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