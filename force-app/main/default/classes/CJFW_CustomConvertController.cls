/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-24-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class CJFW_CustomConvertController {
    @AuraEnabled
    public static Map<String,Object> convert(Map<String, Object> convertInfo, String recordId){
        Map<String,Object> resultMap = new  Map<String,Object>();
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
        try {
            String sObjectName = Id.valueOf(recordId).getSObjectType().getDescribe().getLabel();//CJFW_BiddingInfomation__c, CJFW_PublicBiddingInfomation__c
            List<Schema.SObjectField> fieldList = COMM_Util.getFieldList(sObjectName);
            List<String> fieldNameList = new List<String>();
            for (Schema.SObjectField field : fieldList) {
                fieldNameList.add(field.getDescribe().getName());
            }



            //Lead Convert Info
            Map<String, String> accountMappingField = new Map<String, String>();
            Map<String, String> contactMappingField = new Map<String, String>();
            Map<String, String> opportunityMappingField = new Map<String, String>();

            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
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
            // resultMap.put('STATUS', 'S');
        } catch (Exception e) {
            resultMap.put('STATUS', 'E');
            resultMap.put('MESSAGE', e.getMessage());
            resultMap.put('TRACE', e.getStackTraceString());
        }
        
        return resultMap;
    }
}