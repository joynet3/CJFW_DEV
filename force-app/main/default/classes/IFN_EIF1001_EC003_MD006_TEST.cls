/**
 * @Class : IFN_EIF1001_EC003_MD006_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.09.07
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.07 | 조일근  | 최초작성
 * */
@isTest
public class IFN_EIF1001_EC003_MD006_TEST {

    @TestSetup
    static void makeData(){
        IFN_TestDataFactory.createIfPrograms();

    }

    @isTest
    static void test01() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> resMap = new Map<String, Object>();
        Map<String, Object> resDataMap = new Map<String, Object>();
        resDataMap.put('code','C100');
        resMap.put('results',resDataMap);

        String strBody = JSON.serialize(resMap);
        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_EIF1001_EC003_MD006.doPost();
        
        Test.stopTest();
    }


 

}