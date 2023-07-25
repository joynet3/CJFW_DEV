/**
 * Created by sy.lee on 2023-06-27
 */

 @IsTest
 private class NaverCloudOcrAPI_test {
     @isTest 
     static void itShould() {   
 
         Test.startTest();      
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());    
         NaverCloudOcrAPI.analyzeImage('https://cjck--devsales.sandbox.file.force.com/sfc/dist/version/download/?oid=00D0w0000008jEC&ids=0680w0000025VoS&d=%2Fa%2F0w0000000Y3I%2FsOdOQSgCtov.K5hiREfqVPUDqOmZSGJuoAUZc24ZYdI&asPdf=false');
         
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
        String b = '{"version":"V1","requestId":"string","timestamp":1576569034247,"images":[{"uid":"9fd73a6aacad4025b3099a36ee55aacd",';
        b += '"name":"medium","inferResult":"SUCCESS","message":"SUCCESS","convertedImageInfo":{"width":2478,"height":3504},';
        b += '"fields":[{"inferText":"자동차등록증","boundingPoly":{"vertices":[{"x":1100,"y":150}]}},{"inferText":"154수8298","boundingPoly":{"vertices":[{"x":1100,"y":150}]}},';
        b += '{"inferText":"휘발유","boundingPoly":{"vertices":[{"x":1100,"y":2000}]}}],"validationResult":{"result":"NO_REQUESTED"}}]}';
        response.setBody(b);
        return response;

    }
 }