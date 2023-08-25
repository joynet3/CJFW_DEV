/************************************************************************************
 * File Name   : DN_AddrSearch_wb_test.cls
 * Author      : Soyoung.Jung 
 * Date        : 2020.02.25
 * Target      : DN_AddrSearch_wb.cls
 * Description : DN_AddrSearch_wb.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2020.02.25      Soyoung.Jung    Create
*************************************************************************************/

@isTest
private class DN_AddrSearch_wb_test {

    static testMethod void doTest() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(), true);
        
        Test.stopTest();
    }

    static testMethod DN_AddrSearch_wb.Input getInputParameter() {
        DN_AddrSearch_wb.Input objInput = new DN_AddrSearch_wb.Input();
        
        objInput.confmKey       = 'TESTJUSOGOKR';
        objInput.keyword        = '강남대로12길';
        objInput.resultType     = 'json';
        objInput.currentPage    = 1;
        objInput.countPerPage   = 10;

        return objInput;
    } 

    // Http response
    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        response.setStatusCode(statusCode);
        response.setBody('{"results":{"common":{"errorMessage":"정상","countPerPage":"10","totalCount":"5","errorCode":"0","currentPage":"1"}'
                         + ',"juso":[{"detBdNmList":"","engAddr":"6, Gangnam-daero 12-gil, Seocho-gu, Seoul","rn":"강남대로12길","emdNm":"양재동"'
                         + ',"zipNo":"06779","roadAddrPart2":" (양재동)","emdNo":"01","sggNm":"서초구","jibunAddr":"서울특별시 서초구 양재동 326-1"'
                         + ',"siNm":"서울특별시","roadAddrPart1":"서울특별시 서초구 강남대로12길 6","bdNm":"","admCd":"1165010200","udrtYn":"0"'
                         + ',"lnbrMnnm":"326","roadAddr":"서울특별시 서초구 강남대로12길 6 (양재동)","lnbrSlno":"1","buldMnnm":"6","bdKdcd":"0"'
                         + ',"liNm":"","rnMgtSn":"116504163008","mtYn":"0","bdMgtSn":"1165010200103260001002677","buldSlno":"0"}]}}');

        return response;
    }
    
    // StatusCode 200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = newResponse(200);

            return response;
        }
    }

    // do execute
    private static Boolean testServiceExecute() {
        DN_AddrSearch_wb.Input objInput = getInputParameter();

        // 서비스 실행
        DN_AddrSearch_wb.Output objOutput = DN_AddrSearch_wb.getInstance().execute(objInput);         

        if(objOutput == null) return false;
        else return true;        
    }

}