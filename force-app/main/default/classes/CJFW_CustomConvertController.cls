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
    public static Map<String,Object> convert(Map<String, Map<String,Object>> convertInfo, String recordId, String sessionId){
        Map<String,Object> resultMap = new  Map<String,Object>();
        
        resultMap.put('sessionId', sessionId);

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
            
            //1. convert Account
            Account acc = new Account();
            Map<String,Object> accountConvertInfo = (Map<String,Object>)convertInfo.get('Account');
            Id accRecordTypeId    = [SELECT Id, Name, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Account' AND DeveloperName = 'ProspectiveCustomer'].Id;

            if((Boolean)accountConvertInfo.get('convert')){
                
                for (String key : accountMappingField.keySet()) {
                    String value = accountMappingField.get(key);
                    acc.put(value, convertObj.get(key));
                }
                
                if((Boolean)accountConvertInfo.get('create')){
                    Map<Object,Object> accfield = (Map<Object,Object>)accountConvertInfo.get('fields');
                    acc.put('Name', accfield.get('Name'));
                } else if(!(Boolean)accountConvertInfo.get('create')){
                    acc.put('Id',accountConvertInfo.get('convertedId'));
                }
                
                acc.put('RecordTypeId', accRecordTypeId);
                upsert acc;
                updateConvertObj.put('ConvertedAccount__c', acc.Id);
            }
            
            //2. convert Contact
            Contact con = new Contact();
            Map<String,Object> contactConvertInfo = (Map<String,Object>)convertInfo.get('Contact');
            if((Boolean)contactConvertInfo.get('convert')){
                for (String key : contactMappingField.keySet()) {
                    String value = contactMappingField.get(key);
                    con.put(value, convertObj.get(key));
                }
                
                if((Boolean)contactConvertInfo.get('create')){
                    Map<Object,Object> contfield = (Map<Object,Object>)contactConvertInfo.get('fields');
                    con.put('Salutation', contfield.get('Salutation'));
                    con.put('LastName', contfield.get('LastName'));
                    con.put('FirstName', contfield.get('FirstName'));
                    con.put('AccountId', acc.Id);
                } else if(!(Boolean)contactConvertInfo.get('create')){
                    con.put('Id',contactConvertInfo.get('convertedId'));
                }
                upsert con;
                updateConvertObj.put('ConvertedContact__c', con.Id);
            }
            
            //3. convert Oppty
            Opportunity opp = new Opportunity();
            Map<String,Object> opptyConvertInfo = (Map<String,Object>)convertInfo.get('Opportunity');
            Id opptyRecordTypeId    = [SELECT Id, Name, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Opportunity' AND DeveloperName = 'General'].Id;

            if((Boolean)opptyConvertInfo.get('convert')){
                for (String key : opportunityMappingField.keySet()) {
                    String value = opportunityMappingField.get(key);
                    opp.put(value, convertObj.get(key));
                }
                opp.put('StageName','Needs Analysis');
                opp.put('CloseDate',Date.today().addDays(30));//TODO
                
                if((Boolean)opptyConvertInfo.get('create')){
                    Map<Object,Object> oppfield = (Map<Object,Object>)opptyConvertInfo.get('fields');
                    opp.put('Name', oppfield.get('Name'));
                    opp.put('AccountId', acc.Id);
                } else if(!(Boolean)opptyConvertInfo.get('create')){
                    String convertedId = (String)opptyConvertInfo.get('convertedId');
                    updateConvertObj.put('Id',convertedId);
                }

                opp.put('RecordTypeId', opptyRecordTypeId);
                upsert opp;
                updateConvertObj.put('ConvertedOpportunity__c', opp.Id);
            }
            
            //if (condition) {
     		//   throw new Exception('예외 발생');
    		//}

            updateConvertObj.put('IsConverted__c',true);
            //4. update updateConvertObj;
            String jsonStr = JSON.serialize(updateConvertObj);
			resultMap.put('jsonStr', jsonStr);
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