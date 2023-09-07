/**
 * @Class : IFN_EIF1001_FS001_MD001_test.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.08.30
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.30 | sancho         | 최초작성
 * */
@isTest
public with sharing class IFN_EIF1001_FS001_MD001_test {
    @TestSetup
    static void makeData(){
        
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        IFMaster__c objIFMaster = new IFMaster__c();

        objIFMaster.Name                = 'IFN_EIF1001_FS001_MD001';
        objIFMaster.Type__c             = 'Outbound';
        objIFMaster.WebserviceType__c   = 'REST';
        objIFMaster.Method__c           = 'GET';
        objIFMaster.ContentType__c      = 'application/json';
        objIFMaster.Endpoint__c         = 'https://openapi.foodsafetykorea.go.kr/api';
        
        listIFMaster.add(objIFMaster);

        insert listIFMaster;
    }

    @isTest
    static void test_IFN_EIF1001_FS001_MD001_ba() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('',500));

        IFN_EIF1001_FS001_MD001 b = new IFN_EIF1001_FS001_MD001();
        Database.executeBatch(b);
        
        Test.stopTest();
    }

    @isTest
    static void test_IFN_EIF1001_FS001_MD001_sc() {
        Test.startTest();

        IFN_EIF1001_FS001_MD001.RESULT result = new IFN_EIF1001_FS001_MD001.RESULT();
        result.CODE = 'INFO-000';
        result.MSG = '정상처리되었습니다.';

        List<IFN_EIF1001_FS001_MD001.row> rowlst = new List<IFN_EIF1001_FS001_MD001.row>();
        IFN_EIF1001_FS001_MD001.row row = new IFN_EIF1001_FS001_MD001.row();
        
        row.PRDLST_REPORT_NO ='1';
        row.PRMS_DT	= '1';
        row.LAST_UPDT_DTM = '1';
        row.LCNS_NO = '1';
        row.PRDLST_NM = '1';
        row.QLITY_MNTNC_TMLMT_DAYCNT = '1';
        row.BSSH_NM = '1';
        row.PRDLST_DCNM = '1';
        row.CHILD_CRTFC_YN = '1';
        row.INDUTY_CD_NM = '1';
        row.USAGE = '1';
        row.POG_DAYCNT = '1';
        row.HIENG_LNTRT_DVS_NM = '1';
        row.PRODUCTION = '1';
        row.PRPOS = '1';
        rowlst.add(row);

        IFN_EIF1001_FS001_MD001.I1250 I1250 = new IFN_EIF1001_FS001_MD001.I1250();
        I1250.Result = result;
        I1250.row = rowlst;
        I1250.total_count = '10';

        IFN_EIF1001_FS001_MD001.Output Output = new IFN_EIF1001_FS001_MD001.Output();
        Output.i1250 = I1250;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JSON.serialize(Output),200));

        SchedulableContext sc = null;
        IFN_EIF1001_FS001_MD001_sc scd = new IFN_EIF1001_FS001_MD001_sc();
        scd.execute(sc);

        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
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