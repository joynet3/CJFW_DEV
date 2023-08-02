/**
 * 공통 UTIL 클래스
 * @group Common
 * @author 진현욱
 * @since 2023-08-02
 */
public without sharing class COMM_Util {
    /**
     * 상태값 정의 enum
     */
    public enum StatusCode {
        SUCCESS, ERROR
    }

    /**
     * 암호화 타입 열거형 클래스
     */
    public enum Encryption {MD5, SHA1, SHA3_256, SHA3_384, SHA3_512, SHA_256, SHA_512}

    /**
     * 문자 암호화
     * @param text 암호화 대상 문자
     * @param type 암호화 타입
     * @return  `Blob`
     */
    public static Blob doEncryption(String text, Encryption type) {
        if(String.isBlank(text)) return null;
        if(type == null) return null;

        Blob hash = Crypto.generateDigest(type.name().replace('_', '-'), Blob.valueOf(text));
        return hash;
    }

    
    /**
     * AES128 방식 암호화
     * @param targetData 암호화할 데이터
     * @return  `EncryptionResult`
     */
    public static EncryptionResult processEncryption(string targetData){
        Blob cryptoKey = Crypto.generateAesKey(128); 
        String strkey = EncodingUtil.base64Encode(cryptoKey);
        Blob data = Blob.valueOf(targetData); 
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data ); 
        string b64Data = EncodingUtil.base64Encode(encryptedData);  

        return new EncryptionResult(strkey, b64Data);
    }
    public class EncryptionResult {
        public String key {get;set;}
        public String encrypteValue {get;set;}
        public EncryptionResult(String key, String encrypteValue) {
            this.key = key;
            this.encrypteValue = encrypteValue;
        }
    }

    /**
     * AES128 방식 복호화
     * @param encrypteValue 복호화할 데이터
     * @param key 복호화 Key
     * @return  `DecryptionResult`
     */
    public static DecryptionResult processDecryption(string encrypteValue, String key){
        DecryptionResult result = new DecryptionResult();
        Blob data = EncodingUtil.base64Decode(encrypteValue);
        Blob privateKey = EncodingUtil.base64Decode(key);

        try{ 
            Blob dataToDecrypt = Crypto.decryptWithManagedIV('AES128', privateKey, data);
            result.decryptedData = dataToDecrypt.toString();
            result.isSuccess = true;
        } catch(Exception e){
            result.errorMessage = e.getMessage();
            result.isSuccess = false;
        }

        return result;
    }
    public class DecryptionResult {
        public Boolean isSuccess {get;set;}
        public String decryptedData {get;set;}
        public String errorMessage {get;set;}
    }

    /**
     * SObject Schema 정보 정리 class
     */
    public class SchemaInfo {
        private Schema.SObjectType type;
        private Schema.DescribeSObjectResult result;

        public SchemaInfo() {}
        public SchemaInfo(String sObjectType) {
            this.setSchema(sObjectType);
        }

        public void setSchema(String sObjectType) {
            this.type = Schema.getGlobalDescribe().get(sObjectType);
            this.result = this.type.getDescribe();
        }

        public Schema.SObjectType getType() {
            return this.type;
        }

        public String getTypeToString() {
            return String.valueOf(this.type);
        }

        public String getLabel() {
            return this.result.getLabel();
        }

        public Schema.DescribeSObjectResult getResult() {
            return this.result;
        }

        public Map<Id, Schema.RecordTypeInfo> getRecordTypeMapByIds() {
            return this.result.getRecordTypeInfosById();
        }

        public Map<String, Schema.RecordTypeInfo> getRecordTypeMapByDeveloperNames() {
            return this.result.getRecordTypeInfosByDeveloperName();
        }

        public Map<String, Schema.RecordTypeInfo> getRecordTypeMapByNames() {
            return this.result.getRecordTypeInfosByName();
        }

        public Schema.RecordTypeInfo getRecordTypeByDeveloperName(String name) {
            return this.result.getRecordTypeInfosByDeveloperName().get(name);
        }

        public Schema.RecordTypeInfo getRecordTypeById(String typeId) {
            return this.result.getRecordTypeInfosById().get(typeId);
        }

        public Map<String, Schema.SObjectField> getFieldMap() {
            return this.result.fields?.getMap();
        }

        public Map<String, Schema.FieldSet> getFieldSetMap() {
            return this.result.fieldsets?.getMap();
        }

        public Schema.DescribeFieldResult getFieldInfo(String fieldName) {
            return this.getFieldMap().get(fieldName.toLowerCase())?.getDescribe();
        }

        public List<Schema.PicklistEntry> getPicklistEntrys(String picklistFieldName) {
            return this.getFieldInfo(picklistFieldName)?.getPicklistValues();
        }
    }

    /**
     * sObject Tab Icon 정보 조회 
     * 
     * @param sObjectName 조회 대상 sObject API Name
     * @return  `String`  
     */
    public static String getIconName(String sObjectName) {
        String iconInfo = 'custom:custom20';
        if(sObjectName == '') {
            iconInfo += ',' + 'Object';
            return iconInfo;
        } 
        try{
            List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
            List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
            Schema.DescribeSobjectResult descSObject = Schema.describeSObjects(new String[]{sObjectName})[0];
            String objLabel = descSObject.getLabel();

            for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
                for(Schema.DescribeTabResult tr : tsr.getTabs()) {
                    if(sObjectName == tr.getSobjectName()) {
                        if( tr.isCustom() == true ) {
                            iconDesc.addAll(tr.getIcons());
                        } else {
                            iconInfo = 'standard:' + sObjectName.toLowerCase();
                        }
                    }
                }
            }
            for (Schema.DescribeIconResult ir : iconDesc) {
                if (ir.getContentType() == 'image/svg+xml'){
                    iconInfo = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                    break;
                }
            }
                     
            
            iconInfo += ',' + objLabel;
        } catch(Exception e) {
            iconInfo = e.getMessage();
        }  
    
        return iconInfo;
    }

    /**
     * get orgarniztion type: PRODUCTION/FULL/PARTIAL
     * @return  `String`
     */
    public static String getOrganizationType() {
        String organiztionType = '';
        Boolean isSandbox;
        try{
            isSandbox = [SELECT IsSandbox FROM Organization WHERE Id = :System.UserInfo.getOrganizationId()]?.IsSandbox;
            if(isSandbox) {
                Integer storageLimit = OrgLimits.getMap().get('DataStorageMB').getLimit();
                switch on storageLimit{
                    when 200 {
                        organiztionType = 'DEVELOPER';
                    }
                    when 1024 {
                        organiztionType = 'DEVELOPER_PRO';
                    }
                    when 5120 {
                        organiztionType = 'PARTIAL';
                    }
                    when else {
                        organiztionType = 'FULL';
                    }
                }
            } else {
                organiztionType = 'PRODUCTION';
            }

        } catch(Exception e) {

        }  
    
        return organiztionType;
    }
}