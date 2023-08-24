@isTest 
public  class IFN_LIF1002_SE001_Callout_TEST {

    @TestSetup
    static void setup(){
        IFMaster__c ifmst = new IFMaster__c();
        ifmst.Name = 'IFN_LIF1002_SE001_MD001';
        ifmst.InterfaceId__c = 'IFN_LIF1002_SE001_MD001';
        ifmst.Endpoint__c = 'test';
        ifmst.Method__c = 'POST';
        ifmst.ContentType__c = 'application/json';
        ifmst.ifKeyId__c = 'test';
        ifmst.Header__c = '';
        ifmst.Param1__c = 'test';
        ifmst.Param2__c = 'test';
        ifmst.Param3__c = 'test';
        ifmst.Param4__c = 'test';    
        insert ifmst;
    }

    @isTest
    static void testOne()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock()); 
        IFN_LIF1002_SE001_Callout.SE001RequstWrapper params = new IFN_LIF1002_SE001_Callout.SE001RequstWrapper();
        String interfaceId = 'IFN_LIF1002_SE001_MD001';
        IFN_LIF1002_SE001_Callout callout = new IFN_LIF1002_SE001_Callout(interfaceId,'Realtime');
        params.searchSp = '02';
        params.keywd = '우유';
        params.offset = '1';
        params.limitCnt = '10';
        callout.getResponse(interfaceId, params);

        Test.stopTest();
    }

    // Mock3 : ERR_CD":"9999"
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);
            return response;
        }
    }

    private static HttpResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{"total": 649,' +
                    '"search": [' +
                    '{"upd_dt": "2021-11-18T01:58:12.000Z",' +
                    '"sale_unit_cd": "EA",' +
                    '"co_id": "FW00",  ' +
                    '"migr_orinat_cd_nm": "한국",' +
                    '"gd_cls_id3": "600401",' +
                    '"migr_orinat_cd": "KR",' +
                    '"gd_cls_id2": "6004",' +
                    '"gd_cls_id4": "60040101",' +
                    '"gd_cls_nm3": "유제품류",' +
                    '"gd_cls_nm2": "음료류",' +
                    '"gd_cls_id1": "60",' +
                    '"gd_cls_nm4": "우유",' +
                    '"gd_cls_nm1": "매점상품",' +
                    '"taxt_cl_cd": "0",' +
                    '"gd_cls_id": "60040101",' +
                    '"gd_no": "800865",' +
                    '"brd_nm": null,' +
                    '"id": "FW00-800865",' +
                    '"gd_bd": "서울우유 흰우유(200g/EA)",' +
                    '"gd_bd_kw": "서울우유 흰우유(200g/EA)",' +
                    '"taxt_cl_cd_nm": "면세" }' +
                    ']}');
        return response;
    }

}