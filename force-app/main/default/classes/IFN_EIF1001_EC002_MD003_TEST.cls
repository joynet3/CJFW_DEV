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
            Endpoint__c = 'TEST'
        );

        insert ifMaster;
    }

    @isTest
    static void IFN_EIF1001_EC002_MD003_TEST(){
        Test.startTest();
        
        IFN_EIF1001_EC002_MD003 upload = new IFN_EIF1001_EC002_MD003();
        ContentVersion cv = new ContentVersion(
            Description  = 'test description',
            PathOnClient ='dummy_image.jpg',
            Title = 'dummy image file'+DateTime.now(),
            versiondata=Blob.valueOf('test file body')
        );
        
        insert cv;
        ContentDocument contDoc = [Select Id From ContentDocument Limit 1];
        // Callout Interface
        upload.contDocId = contDoc.Id;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        IFN_CalloutResult calloutResult = upload.callout();
        
        String resultCode = calloutResult.result;
        
        if(resultCode.equals('S')) {
            IFN_EIF1001_EC002_MD003.EC002SuccessData response = (IFN_EIF1001_EC002_MD003.EC002SuccessData)calloutResult.response;
            // 이미지 업로드 성공
            System.debug('image_key : ' + response.image_key + ', name : ' + response.name + ', request_date : ' + response.request_date);
        } else {
            // 이미지 업로드 실패
            if(resultCode.equals('F')){
                IFN_EIF1001_EC002_MD003.EC002ErrorData response = (IFN_EIF1001_EC002_MD003.EC002ErrorData)calloutResult.response;
                System.debug('errcode : ' + response.errcode + ', errmsg : ' + response.errmsg);
            } else {
                // 콜 아웃 에러
                System.debug('CallOut Error :::::: ' + calloutResult.message);
            }
        }
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "data": { "image_key":"20200721141516123_mms_jpg_app1_135790", "request_date":"20200721", "name":"test.jpg" } }');
            res.setStatusCode(200);
            return res;
        }
    }
}