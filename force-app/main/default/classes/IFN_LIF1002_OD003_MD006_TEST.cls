@isTest
public class IFN_LIF1002_OD003_MD006_TEST {

    @TestSetup
    static void makeData(){
        IFN_TestDataFactory.createIfPrograms();


    }

    @isTest
    static void test01() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{'
                        +' "cttId":"a0W9D000005hSZWUA2",'
                        +' "mdmCd":"70003",'
                        +' "accNm":"12",'
                        +' "mngNm":"12312",'
                        +' "accCall":"123",'
                        +' "svcTgtNm":"교직원",'
                        +' "svcTgtCd":"교직원",'
                        +' "reqMemCnt":"12",'
                        +' "avgAge":"1",'
                        +' "addr":"주소",'
                        +' "dscrt":"설명"'
                        +' }';

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD003_MD006.doPost();
        
        Test.stopTest();
    }

    @isTest
    static void test02() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{'
                        +' "cttId":"",'
                        +' "mdmCd":"",'
                        +' "accNm":"",'
                        +' "mngNm":"12312",'
                        +' "accCall":"123",'
                        +' "svcTgtNm":"교직원",'
                        +' "svcTgtCd":"교직원",'
                        +' "reqMemCnt":"12",'
                        +' "avgAge":"1",'
                        +' "addr":"주소",'
                        +' "dscrt":"설명"'
                        +' }';

        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_LIF1002_OD003_MD006.doPost();
        
        Test.stopTest();
    }
}