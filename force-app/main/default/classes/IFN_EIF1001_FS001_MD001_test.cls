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
        
        IFN_EIF1001_FS001_MD001_ba b = new IFN_EIF1001_FS001_MD001_ba();
        Database.executeBatch(b);
        
        Test.stopTest();
    }

    @isTest
    static void test_IFN_EIF1001_FS001_MD001_sc() {
        Test.startTest();
        
        SchedulableContext sc = null;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IFN_EIF1001_FS001_MD001_sc scd = new IFN_EIF1001_FS001_MD001_sc();
        scd.execute(sc);

        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                      '{'
                    + '    "I1250": {'
                    + '        "total_count": "1",'
                    + '        "row": ['
                    + '            {'
                    + '                "PRDLST_REPORT_NO": "19630364001121",'
                    + '                "PRMS_DT": "19920822",'
                    + '                "LAST_UPDT_DTM": "20160706",'
                    + '                "LCNS_NO": "19630364001",'
                    + '                "PRDLST_NM": "허벌엣센스케이",'
                    + '                "QLITY_MNTNC_TMLMT_DAYCNT": "",'
                    + '                "BSSH_NM": "(주)보락",'
                    + '                "PRDLST_DCNM": "혼합제제",'
                    + '                "CHILD_CRTFC_YN": "",'
                    + '                "INDUTY_CD_NM": "식품첨가물제조업",'
                    + '                "USAGE": "착향료",'
                    + '                "POG_DAYCNT": "유통기간미등록",'
                    + '                "HIENG_LNTRT_DVS_NM": "해당없음",'
                    + '                "PRODUCTION": "아니오",'
                    + '                "PRPOS": ""'
                    + '            },'
                    + '        ],'
                    + '        "RESULT": {'
                    + '            "MSG": "정상처리되었습니다.",'
                    + '            "CODE": "INFO-000"'
                    + '        }'
                    + '    }'
                    + '}');
            res.setStatusCode(200);
            return res;
        }
    }
}