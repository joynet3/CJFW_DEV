/**
 * @Class : IFN_EIF1001_EC002_MD004_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.09.07
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.07 | 조일근  | 최초작성
 * */
@isTest
public with sharing class IFN_EIF1001_EC002_MD004_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_EIF1001_EC002_MD004',
            Type__c = 'Outbound',
            WebserviceType__c = 'Callout',
            Method__c = 'POST',
            ifKeyId__c= 'IFN_EIF1001_EC002_MD004______1',
            ClassName__c =  'IFN_EIF1001_EC002_MD004',
            ContentType__c = 'application/json',
            TargetSystem__c = 'IF0001',
            Endpoint__c = 'http://localhost:8060/gwms/crm/rest/EIF1001/EC002/MD003'
        );

        insert ifMaster;

        ContentVersion cv = new ContentVersion(
            Description  = 'test description',
            PathOnClient ='test_file.jpg',
            Title = 'test file '+DateTime.now(),
            versiondata=Blob.valueOf('test file body')
        );
        
        insert cv;

    }

    @isTest
    static void test01(){
        Test.startTest();


        IFN_EIF1001_EC002_MD004.EC002SuccessData EC002SuccessData = new IFN_EIF1001_EC002_MD004.EC002SuccessData();
        EC002SuccessData.image_key = '';
        EC002SuccessData.request_date = '';
        EC002SuccessData.name = '';
        EC002SuccessData.url = '';
        IFN_EIF1001_EC002_MD004.EC002Response EC002Response = new IFN_EIF1001_EC002_MD004.EC002Response();
        EC002Response.data = EC002SuccessData;
        IFN_EIF1001_EC002_MD004.EC002ResultWrapper EC002ResultWrapper = new IFN_EIF1001_EC002_MD004.EC002ResultWrapper();
        EC002ResultWrapper.response = EC002Response;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JSON.serialize(EC002ResultWrapper),200)); 
        IFN_EIF1001_EC002_MD004 upload = new IFN_EIF1001_EC002_MD004();
        // Callout Interface
        ContentVersion cv = [select id from ContentVersion limit 1];
        upload.versionId = cv.id;
        
        IFN_CalloutResult calloutResult = upload.callout();

        
        Test.stopTest();
    }


    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method

        public String body{get;set;}
        public Integer statusCode{get;set;}

        public MockHttpResponseGenerator(String body, Integer statusCode)
        {
            this.body = body;
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/text');
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }

}