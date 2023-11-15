@isTest
public class IFN_GET_KAKAOGEO_INFO_TEST {

    @TestSetup
    static void makeData(){
        
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        IFMaster__c objIFMaster = new IFMaster__c();
        objIFMaster.Name                = 'IFN_COMMMON_KAKAO_GEOINFO';
        objIFMaster.Type__c             = 'Outbound';
        objIFMaster.WebserviceType__c   = 'REST';
        objIFMaster.Method__c           = 'GET';
        objIFMaster.ContentType__c      = 'application/json';
        objIFMaster.Endpoint__c         = 'https://dotop.kr/Service/API/';
        listIFMaster.add(objIFMaster);
		
        insert listIFMaster;

    }
    
    @isTest
    static void test_IFN_GET_KAKAOGEO_INFO() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IFN_GET_KAKAOGEO_INFO api = new IFN_GET_KAKAOGEO_INFO();
        IFN_CalloutResult resData = api.getResponse('경기도 파주시 성재길 3');
        IFN_GET_KAKAOGEO_INFO.SearcXY ccc = (IFN_GET_KAKAOGEO_INFO.SearcXY) resData.response;
        System.debug(Json.serialize(ccc.XPoint));
        System.debug(Json.serialize(ccc.YPoint));

        
        Test.stopTest();
    }


    @isTest
    static void test_IFN_GET_KAKAOGEO_INFO_Fail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.stopTest();
    }


    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //request 
            //https://dapi.kakao.com/v2/local/search/address.json?query=강서구 화곡동

            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"documents":[{"address":{"address_name":"서울 강서구 화곡8동","b_code":"","h_code":"1150059300","main_address_no":"","mountain_yn":"N","region_1depth_name":"서울","region_2depth_name":"강서구","region_3depth_h_name":"화곡8동","region_3depth_name":"","sub_address_no":"","x":"126.848362286981","y":"37.5326259869176"},"address_name":"서울 강서구 화곡8동","address_type":"REGION","road_address":null,"x":"126.848362286981","y":"37.5326259869176"}],"meta":{"is_end":true,"pageable_count":1,"total_count":1}}');
            res.setStatusCode(200);
            return res;
        }
    }
}