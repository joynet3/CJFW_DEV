/**
 * 
 * @author 진현욱
 * @since 2023-08-02
 */
@isTest
public with sharing class COMM_Util_Test {
    @TestSetup
    static void makeData(){
        
    }

    @IsTest
    static void test01() {
        
        Test.startTest();

        Blob testBlob = COMM_Util.doEncryption('test123123123', COMM_Util.Encryption.SHA_256);
        COMM_Util.EncryptionResult encryptionResult = COMM_Util.processEncryption('test123123123');
        COMM_Util.DecryptionResult decryptionResult = COMM_Util.processDecryption(encryptionResult.encrypteValue, encryptionResult.key);

        System.debug('testBlob :: '+testBlob);
        System.debug('encryptionResult :: '+encryptionResult);
        System.debug('decryptionResult :: '+decryptionResult);

        String iconName = COMM_Util.getIconName('');
        System.debug('iconName :: '+iconName);

        iconName = COMM_Util.getIconName('Account');
        System.debug('iconName :: '+iconName);

        iconName = COMM_Util.getIconName('Notification__c');
        System.debug('iconName :: '+iconName);

        COMM_Util.SchemaInfo schemaInfo = new COMM_Util.SchemaInfo();
        schemaInfo = new COMM_Util.SchemaInfo('Account');
        schemaInfo.setSchema('Notification__c');

        Schema.SObjectType                  sObjectType    = schemaInfo.getType();
        String                              sObjType       = schemaInfo.getTypeToString();
        String                              sObjectLabel   = schemaInfo.getLabel();
        Schema.DescribeSObjectResult        sObjectResult  = schemaInfo.getResult();
        Map<Id, Schema.RecordTypeInfo>      recordTypeMap1 = schemaInfo.getRecordTypeMapByIds();
        Map<String, Schema.RecordTypeInfo>  recordTypeMap2 = schemaInfo.getRecordTypeMapByDeveloperNames();
        Map<String, Schema.RecordTypeInfo>  recordTypeMap3 = schemaInfo.getRecordTypeMapByNames();

        for(Id typeId : recordTypeMap1.keySet()) {
            Schema.RecordTypeInfo           recordType1    = schemaInfo.getRecordTypeById(typeId);
            System.debug('recordType1 :: '+recordType1);
            break;
        }

        for(String typeName : recordTypeMap2.keySet()) {
            Schema.RecordTypeInfo           recordType2    = schemaInfo.getRecordTypeByDeveloperName(typeName);
            System.debug('recordType2 :: '+recordType2);
            break;
        }

        Map<String, Schema.SObjectField>    fieldMap       = schemaInfo.getFieldMap();
        Map<String, Schema.FieldSet>        fieldSetMap    = schemaInfo.getFieldSetMap();
        Schema.DescribeFieldResult          fieldResult    = schemaInfo.getFieldInfo('Name');
        List<Schema.PicklistEntry>          picklistEntry  = schemaInfo.getPicklistEntrys('CurrencyIsoCode');

        System.debug('sObjectType :: '+sObjectType);
        System.debug('sObjType :: '+sObjType);
        System.debug('sObjectLabel :: '+sObjectLabel);
        System.debug('sObjectResult :: '+sObjectResult);
        System.debug('recordTypeMap1 :: '+recordTypeMap1);
        System.debug('recordTypeMap2 :: '+recordTypeMap2);
        System.debug('recordTypeMap3 :: '+recordTypeMap3);
        System.debug('fieldMap :: '+fieldMap);
        System.debug('fieldSetMap :: '+fieldSetMap);
        System.debug('fieldResult :: '+fieldResult);
        System.debug('picklistEntry :: '+picklistEntry);

        String orgType = COMM_Util.getOrganizationType();
        System.debug('organization type: '+orgType);

        Map<String,Object> result = COMM_Util.getAllPicklistOptionType('Account');
        List<Schema.SObjectField> fieldList = COMM_Util.getFieldList('Notification__c');
        Map<String,String> resultFieldMap = COMM_Util.getFieldToLabelMap('Account');


        Test.stopTest();
        
    }
}