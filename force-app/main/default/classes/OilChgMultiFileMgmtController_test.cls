/**
 * Created by sy.lee on 2023-05-31
 */

 @IsTest
 private class OilChgMultiFileMgmtController_test {
     @isTest 
     static void itShould() {   
 
         Test.startTest();      
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());    
         OilTypeChange__c oilObj = new OilTypeChange__c();
         oilObj.StartDate__c = Date.today();
         oilObj.EndDate__c = Date.today();
         oilObj.ApprovalStatus__c = '작성중';
         oilObj.oil_type_cd__c = '1';
         oilObj.CarNo__c = '154수8298';
         insert oilObj;    

         OilChgMultiFileMgmtController.doSearchAttachments(oilObj.Id, 'attachedFile1__c', 'attachedFile2__c', 'attachedFile3__c','true');         
 
         ContentVersion cv1 = new ContentVersion();
         cv1.Title = '자동차등록증_최상준';
         cv1.PathOnClient = '자동차등록증_최상준.JPG';
         cv1.VersionData = EncodingUtil.base64Decode('EPAAIAAAAIAAAAqwExAAIAAAAOAAAAswITAAMAAAAB');
         insert cv1;         
         cv1 = [
             SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id
         ];

         ContentDocumentLink cdlObj1 = new ContentDocumentLink();
         cdlObj1.ContentDocumentId = cv1.ContentDocumentId;
         cdlObj1.LinkedEntityId = oilObj.Id;
         insert cdlObj1;
         ContentVersion cv2 = new ContentVersion();
         cv2.Title = '자동차등록증_최상준';
         cv2.PathOnClient = '자동차등록증_최상준.JPG';
         cv2.VersionData = EncodingUtil.base64Decode('EPAAIAAAAIAAAAqwExAAIAAAAOAAAAswITAAMAAAAB');
         insert cv2;         
         cv2 = [
             SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id
         ];

         ContentDocumentLink cdlObj2 = new ContentDocumentLink();
         cdlObj2.ContentDocumentId = cv2.ContentDocumentId;
         cdlObj2.LinkedEntityId = oilObj.Id;
         insert cdlObj2;
         ContentVersion cv3 = new ContentVersion();
         cv3.Title = '자동차등록증_최상준';
         cv3.PathOnClient = '자동차등록증_최상준.JPG';
         cv3.VersionData = EncodingUtil.base64Decode('EPAAIAAAAIAAAAqwExAAIAAAAOAAAAswITAAMAAAAB');
         insert cv3;         
         cv3 = [
             SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv3.Id
         ];

         ContentDocumentLink cdlObj3 = new ContentDocumentLink();
         cdlObj3.ContentDocumentId = cv3.ContentDocumentId;
         cdlObj3.LinkedEntityId = oilObj.Id;

         insert cdlObj3;
         oilObj.attachedFile1__c = cv1.ContentDocumentId;
         oilObj.attachedFile2__c = cv2.ContentDocumentId;
         oilObj.attachedFile3__c = cv3.ContentDocumentId;
         update oilObj;
         OilChgMultiFileMgmtController.doSearchAttachments(oilObj.Id, 'attachedFile1__c', 'attachedFile2__c', 'attachedFile3__c','true'); 
         Map<String, Object> mapReturnValue1 = OilChgMultiFileMgmtController.doUpdateAttach(oilObj.Id, cv1.ContentDocumentId,'attachedFile1__c');
         Id contDistriId = (Id)mapReturnValue1.get('cdId');
 
         OilChgMultiFileMgmtController.doNaverOcrProcess(oilObj.Id, contDistriId);
 
         OilChgMultiFileMgmtController.doDeleteFile(oilObj.Id, cv1.ContentDocumentId, 'attachedFile1__c');
         
         Test.stopTest();
     }
     // err_cd":"성공"
     private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);
            return response;
        }
    }
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setStatus('success');
        // String a = '{"images":[{"message":"SUCCESS","convertedImageInfo":{"width":1902,"height":2751}';
        // a += ',"fields":[{"boundingPoly":{"vertices":{"x":1100,"y":150}},"inferText":"자동차등록증"}';
        // a += ',{"boundingPoly":{"vertices":{"x":1100,"y":150}},"inferText":"154수8298"}';
        // a += ',{"boundingPoly":{"vertices":{"x":1100,"y":2000}},"inferText":"휘발유"}]},{"error":null}]}';
        String b = '{"version":"V1","requestId":"string","timestamp":1576569034247,"images":[{"uid":"9fd73a6aacad4025b3099a36ee55aacd",';
        b += '"name":"medium","inferResult":"SUCCESS","message":"SUCCESS","convertedImageInfo":{"width":2478,"height":3504},';
        b += '"fields":[{"inferText":"자동차등록증","boundingPoly":{"vertices":[{"x":1100,"y":150}]}},{"inferText":"154수8298","boundingPoly":{"vertices":[{"x":1100,"y":150}]}},';
        b += '{"inferText":"휘발유","boundingPoly":{"vertices":[{"x":1100,"y":2000}]}}],"validationResult":{"result":"NO_REQUESTED"}}]}';
        response.setBody(b);
        return response;

    }
 }