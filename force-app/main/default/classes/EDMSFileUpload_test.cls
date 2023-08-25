/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class EDMSFileUpload_test {
    @testSetup
	static void setData() {

        Set<String> setIFId = new Set<String>{'IF_SFDC_EDMS_FILE_UPLOAD','IF_SFDC_EDMS_FILE_DELETE'};

        List<IFMaster__c> listIF = new List<IFMaster__c>();

        for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'POST';
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;
	}
    @isTest 
    static void itShould() {
        Test.startTest();



        EDMSFileUpload.doInit('test1234');

        String targetId = 'TESTID';
        String strType = '1';

        MDMRegRequestCustomer__c objCustomer = new MDMRegRequestCustomer__c();
        insert objCustomer;
        

        List<EDMSFile__c> listEDMSFile = new List<EDMSFile__c>();
        EDMSFile__c objEDMSFileExcel = new EDMSFile__c();

        objEDMSFileExcel.Name = 'Test.xlsx';
        objEDMSFileExcel.TargetId__c = objCustomer.Id;
        objEDMSFileExcel.Type__c = strType;
        objEDMSFileExcel.fileExt__c = 'xlsx';

        listEDMSFile.add(objEDMSFileExcel);

        EDMSFile__c objEDMSFilePng = new EDMSFile__c();

        objEDMSFilePng.Name = 'Test.png';
        objEDMSFilePng.TargetId__c = objCustomer.Id;
        objEDMSFilePng.Type__c = strType;
        objEDMSFilePng.fileExt__c = 'png';

        listEDMSFile.add(objEDMSFilePng);

        EDMSFile__c objEDMSFileDoc = new EDMSFile__c();

        objEDMSFileDoc.Name = 'Test.doc';
        objEDMSFileDoc.TargetId__c = objCustomer.Id;
        objEDMSFileDoc.Type__c = strType;
        objEDMSFileDoc.fileExt__c = 'doc';

        listEDMSFile.add(objEDMSFileDoc);

        EDMSFile__c objEDMSFilePDF = new EDMSFile__c();

        objEDMSFilePDF.Name = 'Test.pdf';
        objEDMSFilePDF.TargetId__c= objCustomer.Id;
        objEDMSFilePDF.Type__c = strType;
        objEDMSFilePDF.fileExt__c = 'pdf';

        listEDMSFile.add(objEDMSFilePDF);

        EDMSFile__c objEDMSFileEtc = new EDMSFile__c();

        objEDMSFileEtc.Name = 'Test.etc';
        objEDMSFileEtc.TargetId__c = objCustomer.Id;
        objEDMSFileEtc.Type__c = strType;
        objEDMSFileEtc.fileExt__c = 'etc';

        listEDMSFile.add(objEDMSFileEtc);

        insert listEDMSFile;

        EDMSFileUpload.doGetEDMSList(objCustomer.Id, strType);


        ContentVersion objContentVersion = new Contentversion();
        objContentVersion.Title = 'test';
        objContentVersion.PathOnClient = 'test.txt';
        objContentVersion.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert objContentVersion;

        objContentVersion = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:objContentVersion.Id
        ];

        System.debug('============> objContentVersion.ContentDocumentId : '+objContentVersion.ContentDocumentId);

        EDMSFileUpload.doCreatedFileURL(objContentVersion.ContentDocumentId);

        Map<String, String> mapParam = new Map<String, String>();


        mapParam.put('recordId', objCustomer.Id);
        mapParam.put('documentId', objContentVersion.ContentDocumentId);
        mapParam.put('strType', '1');
        mapParam.put('downloadUrl', 'test');

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EDMSFileUpload.doSendEMDS(mapParam);


        
        // 삭제 테스트 
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock2());
        EDMSFileUpload.FileWrapper objFileWrapper = new EDMSFileUpload.FileWrapper();
        objFileWrapper.SFDCID = objEDMSFileEtc.Id;
        objFileWrapper.downloadURL = 'https://edmsqa2.ifresh.co.kr/edms/znImgsysEncrypt/getFileEnc/101/0F761604E6CD64D39AF9227B8ADCBDB70CB404503031A667535F9C0D31E9A4F1';
        EDMSFileUpload.doDeleteFile(objFileWrapper);
        delete objEDMSFileEtc;

        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);

            return response;
        }
    }

    private class HttpCalloutSuccessMock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse2(200);
            return response;
        }
    }

    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{"download_url":"https://edmsqa2.ifresh.co.kr/edms/znImgsysEncrypt/getFileEnc/101/0F761604E6CD64D39AF9227B8ADCBDB70CB404503031A667535F9C0D31E9A4F1","err_cd":"0000","err_msg_ctt":""}');
        return response;
    }

    private static HTTPResponse newResponse2(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{"err_cd":"0000","err_msg_ctt":""}');
        return response;
    }

    
}