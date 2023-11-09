/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_CustomConvertController {

    // public static MetadataService.MetadataPort createService(){
    //     MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    //     service.SessionHeader = new MetadataService.SessionHeader_element();
    //     service.SessionHeader.sessionId = getSessionForLightning.getSession();
    //     return service;
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
        
        //Lead Convert Info
        Map<String, String> accountMappingField = new Map<String, String>();//Lead->Account
        Map<String, String> contactMappingField = new Map<String, String>();//Lead->Contact
        Map<String, String> opportunityMappingField = new Map<String, String>();//Lead->Opportunity

        List<Bid_Info_Cvt_Field__mdt> customConvertList = [SELECT Id, OutputObject__c, InputField__c, OutputField__c FROM Bid_Info_Cvt_Field__mdt];

        for (Bid_Info_Cvt_Field__mdt cvt : customConvertList) {
            if(cvt.OutputObject__c == 'Account'){
                accountMappingField.put(cvt.InputField__c, cvt.OutputField__c);//LeadFeild -> AccountFeild
            } else if (cvt.OutputObject__c == 'Contact'){
                contactMappingField.put(cvt.InputField__c, cvt.OutputField__c);
            } else if (cvt.OutputObject__c == 'Opportunity'){
                opportunityMappingField.put(cvt.InputField__c, cvt.OutputField__c);
            }
        }
        // resultMap.put('accountMappingField', accountMappingField);
        // resultMap.put('contactMappingField', contactMappingField);
        // resultMap.put('opportunityMappingField', opportunityMappingField);

        // MetadataService.MetadataPort service = createService(); //권한이 없다잖아 ㅠㅠ
        // List<MetadataService.LeadConvertSettings> leadConvertSettings = (List<MetadataService.LeadConvertSettings>) service.readMetadata('LeadConvertSettings', new List<String>{'LeadConvertSettings'}).getRecords();
        // for (MetadataService.LeadConvertSettings leadConvertSetting : leadConvertSettings) {
        //     for (MetadataService.ObjectMapping objectMapping : leadConvertSetting.objectMapping) {
        //         System.debug(objectMapping.inputObject + ' -> ' + objectMapping.outputObject);
        //         MetadataService.ObjectMapping mappingObject = objectMapping;
        //         for (MetadataService.ObjectMappingField fieldMapping : objectMapping.mappingFields) {
        //             // System.debug('\t' + fieldMapping.inputField + ' -> ' + fieldMapping.outputField);
        //             if(mappingObject.outputObject == 'Account'){
        //                 accountMappingField.put(fieldMapping.inputField, fieldMapping.outputField);//LeadFeild -> AccountFeild
        //             } else if (mappingObject.outputObject == 'Contact'){
        //                 contactMappingField.put(fieldMapping.inputField, fieldMapping.outputField);
        //             } else if (mappingObject.outputObject == 'Opportunity'){
        //                 opportunityMappingField.put(fieldMapping.inputField, fieldMapping.outputField);
        //             }
        //         }
        //     }
        // }
        
        resultMap.put('apex:convertInfo', convertInfo);
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
            // Id accRecordTypeId    = [SELECT Id, Name, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Account' AND DeveloperName = 'ProspectiveCustomer'].Id;
            Id accRecordTypeId;
            for (Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()) {
                if (rtInfo.isDefaultRecordTypeMapping()) {
                    accRecordTypeId = rtInfo.getRecordTypeId();
                }
            }

            if((Boolean)accountConvertInfo.get('convert')){
                
                for (String key : accountMappingField.keySet()) {
                    if(fieldNameList.contains(key)){
                        String fieldName = accountMappingField.get(key);
                        try {
                            acc.put(fieldName, convertObj.get(key));
                            // resultMap.put('ACCOUNT FIELD :' + key, fieldName+' / '+convertObj.get(key));
                        } catch (Exception e) {
                            resultMap.put('ACCOUNT FIELD DIFFERENT :'+key, fieldName);
                        }
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
            resultMap.put('Convert Account::', acc);

            
            //2. Contact Convert
            Contact con = new Contact();
            Map<String,Object> contactConvertInfo = (Map<String,Object>)convertInfo.get('Contact');
            if((Boolean)contactConvertInfo.get('convert')){
                for (String key : contactMappingField.keySet()) {
                    if(fieldNameList.contains(key)){
                        String fieldName = contactMappingField.get(key);
                        try {
                            con.put(fieldName, convertObj.get(key));                            
                        } catch (Exception e) {
                            resultMap.put('CONTACT FIELD DIFFERENT :'+key, fieldName);
                        }
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
            resultMap.put('Convert Contact::', con);
            
            //3. Oppty Convert
            Opportunity opp = new Opportunity();
            Map<String,Object> opptyConvertInfo = (Map<String,Object>)convertInfo.get('Opportunity');
            // Id opptyRecordTypeId    = [SELECT Id, Name, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Opportunity' AND DeveloperName = 'General'].Id;
            Id opptyRecordTypeId;
            for (Schema.RecordTypeInfo rtInfo : Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
                if (rtInfo.isDefaultRecordTypeMapping()) {
                    opptyRecordTypeId = rtInfo.getRecordTypeId();
                }
            }

            if((Boolean)opptyConvertInfo.get('convert')){
                for (String key : opportunityMappingField.keySet()) {
                    if(fieldNameList.contains(key)){
                        String fieldName = opportunityMappingField.get(key);
                        Object value = convertObj.get(key);
                        try {
                            opp.put(fieldName, value);
                        }
                        catch (Exception e) {
                            resultMap.put('OPPTY FIELD DIFFERENT :'+key, fieldName);
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
                if(sObjectName == 'CJFW_BiddingInformation__c') opp.put('BiddingInformation__c', recordId);
                upsert opp;

                if(sObjectName == 'CJFW_BiddingInformation__c') updateConvertObj.put('Opportunity__c', opp.Id);
                updateConvertObj.put('ConvertedOpportunity__c', opp.Id);
            }
            resultMap.put('Convert Opportunity::', opp);
            
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
            
            // Database.rollback(sp);//TEST    
            
        } catch (Exception e) {
            Database.rollback(sp);
            resultMap.put('STATUS', 'E');
            resultMap.put('MESSAGE', e.getMessage());
            resultMap.put('TRACE', e.getStackTraceString());
            System.debug('MESSAGE:' + e.getMessage());
            System.debug('TRACE:' + e.getStackTraceString());
        }
        
        return resultMap;
    }
}