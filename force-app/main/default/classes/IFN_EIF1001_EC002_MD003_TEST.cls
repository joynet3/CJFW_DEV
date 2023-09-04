@isTest
public with sharing class IFN_EIF1001_EC002_MD003_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_EIF1001_EC002_MD003',
            Type__c = 'Outbound',
            WebserviceType__c = 'REST',
            Method__c = 'POST',
            ContentType__c = 'application/json',
            Endpoint__c = 'http://localhost:8060/gwms/crm/rest/EIF1001/EC002/MD003'
        );

        insert ifMaster;

        ContentVersion cv = new ContentVersion(
            Description  = 'test description',
            PathOnClient ='test_file.txt',
            Title = 'test file '+DateTime.now(),
            versiondata=Blob.valueOf('test file body')
        );
        
        insert cv;
    }

    @isTest
    static void IFN_EIF1001_EC002_MD003_TEST(){
        Test.startTest();
        
        IFN_EIF1001_EC002_MD003 upload = new IFN_EIF1001_EC002_MD003();
        // Callout Interface
        upload.versionId = '';
        IFN_CalloutResult calloutResult = upload.callout();
        
        String resultCode = calloutResult.result;
        Map<String, String> response = (Map<String, String>)calloutResult.response;
        
        if(resultCode.equals('S')) {
            // 이미지 업로드 성공
            for(String key : response.keySet()){
                System.debug(key + ':::::::' + response.get(key));
            }
        } else {
            // 이미지 업로드 실패
            if(resultCode.equals('F')){
                for(String key : response.keySet()){
                    System.debug(key + ':::::::' + response.get(key));
                }    
            } else {
                // 콜 아웃 에러
                System.debug('CallOut Error :::::: ' + calloutResult.message);
            }
        }
        Test.stopTest();
    }
}