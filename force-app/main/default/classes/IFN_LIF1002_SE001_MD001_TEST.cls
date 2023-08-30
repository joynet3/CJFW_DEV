/**
 * @Class : IFN_LIF1002_Callout_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.08.30
 * @Version : 1.0
 * @Description : 주문 시스템 callout 테스트 클래스
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.30 | 조일근  | 최초작성
 * */
@isTest
public with sharing class IFN_LIF1002_SE001_MD001_TEST {
    @TestSetup
    static void setup(){

        IFN_TestDataFactory.createIfPrograms();

    }

    @isTest
    static void testone()
    {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock()); 
        IFN_LIF1002_SE001_MD001.SE001RequstWrapper params = new IFN_LIF1002_SE001_MD001.SE001RequstWrapper();
        IFN_LIF1002_SE001_MD001 cont = new IFN_LIF1002_SE001_MD001();
        String interfaceId = 'IFN_LIF1002_SE001_MD001';
        params.searchSp = '05';
        params.keywd = '우유';
        params.offset = '';
        params.limitCnt = '3';
        IFN_LIF1002_SE001_MD001.SE001_01ResultWrapper res = cont.callout( params);
        IFN_LIF1002_SE001_MD001.SearchLst searchitm = new IFN_LIF1002_SE001_MD001.SearchLst();
        searchitm.upd_dt = '';
        searchitm.sale_unit_cd = '';
        searchitm.co_id = '';
        searchitm.brd_nm = '';        
        searchitm.migr_orinat_cd_nm = '';
        searchitm.gd_cls_id3 = '';
        searchitm.migr_orinat_cd = '';
        searchitm.gd_cls_id2 = '';
        searchitm.gd_cls_id4 = '';
        searchitm.gd_cls_nm3 = '';
        searchitm.gd_cls_nm2 = '';
        searchitm.gd_cls_id1 = '';
        searchitm.gd_cls_nm4 = '';
        searchitm.gd_cls_nm1 = '';
        searchitm.taxt_cl_cd = '';
        searchitm.gd_cls_id = '';
        searchitm.gd_no = '';
        searchitm.id = '';
        searchitm.gd_bd = '';
        searchitm.gd_bd_kw = '';
        searchitm.taxt_cl_cd_nm = '';

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