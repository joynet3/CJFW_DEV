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
                
        Test.setMock(HttpCalloutMock.class, new IFN_LIF1002_SE001_MD001_TESTMock(JSON.serialize(searchitm),200)); 
        IFN_LIF1002_SE001_MD001.SE001RequstWrapper params = new IFN_LIF1002_SE001_MD001.SE001RequstWrapper();
        IFN_LIF1002_SE001_MD001 cont = new IFN_LIF1002_SE001_MD001();
        String interfaceId = 'IFN_LIF1002_SE001_MD001';
        params.searchSp = '05';
        params.keywd = '우유';
        params.page = '1';
        params.pageSize = '3';
        IFN_LIF1002_SE001_MD001.SE001_01ResultWrapper res = cont.callout( params);

        

        Test.stopTest();

    }

    
    // Mock3 : ERR_CD":"9999"
    private class IFN_LIF1002_SE001_MD001_TESTMock implements HttpCalloutMock {

        public String body{get;set;}
        public Integer statusCode{get;set;}

        public IFN_LIF1002_SE001_MD001_TESTMock(String body, Integer statusCode)
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