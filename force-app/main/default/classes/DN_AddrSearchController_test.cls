/************************************************************************************
 * File Name   : DN_AddrSearchController_test.cls
 * Author      : Soyoung.Jung 
 * Date        : 2020.02.25
 * Target      : DN_AddrSearchController.cls
 * Description : DN_AddrSearchController.cls Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2020.02.25      Soyoung.Jung    Create
*************************************************************************************/

@isTest
private class DN_AddrSearchController_test {

    static testMethod void doTest() {
        // 사업장
        Account objProject = TestObjectCreator.getObjAccount();
        objProject.Name = '테스트사업장';        
        insert objProject;

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        DN_AddrSearchController.doSearchAddress('강남대로12길', 1, 10);

        DN_AddrSearchController.getInitData(objProject.Id, 'Account', 'PostalCode__c', 'Address__c', 'AddressDetails__c');
        DN_AddrSearchController.doSave(
                objProject.Id,
                '06779',
                '서울특별시 서초구 강남대로12길 6 (양재동)',
                'test',
                'Account',
                'PostalCode__c',
                'Address__c',
                'AddressDetails__c',
                'test'
        );

        Test.stopTest();
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

}