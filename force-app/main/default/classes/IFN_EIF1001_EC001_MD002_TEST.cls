/**
 * @Class : IFN_EIF1001_EC001_MD002_TEST.cls
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
public class IFN_EIF1001_EC001_MD002_TEST {

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
        List<Object> ListMap = new List<Object>();
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('msg_key','1');
        dataMap.put('code','1');
        dataMap.put('desc','1');
        dataMap.put('dest','1');
        dataMap.put('done_date','1');

        ListMap.add(dataMap);
        resMap.put('results',ListMap);

        String strBody = JSON.serialize(resMap);
        req.requestBody = Blob.valueOf(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IFN_EIF1001_EC001_MD002.doPost();
        
        Test.stopTest();
    }



    @isTest
    static void test02() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestBody = null;
        RestContext.request = req;
        RestContext.response = res;
        IFN_EIF1001_EC001_MD002.doPost();
        
        Test.stopTest();
    }

 

}