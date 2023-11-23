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
public with sharing class IFN_EIF1006_PD003_MD001_TEST {
    @TestSetup
    static void setup(){

        Set<String> setIFId = new Set<String>{'IFN_EIF1006_PD003_MD001', 'IFN_EIF1006_Callout'};

        List<IFMaster__c> listIF = new List<IFMaster__c>();

        for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'GET';
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;

    }

    @isTest
    static void testone()
    {

        Test.startTest();

        IFN_EIF1006_PD003_MD001.PD003_MD001ResWrapper PD003_MD001ResWrapper = new IFN_EIF1006_PD003_MD001.PD003_MD001ResWrapper();
        IFN_EIF1006_PD003_MD001.itmList itmList = new IFN_EIF1006_PD003_MD001.itmList();
        List<IFN_EIF1006_PD003_MD001.itmList> itmListlst = new List<IFN_EIF1006_PD003_MD001.itmList>();
        IFN_EIF1006_PD003_MD001.itmData itmData = new IFN_EIF1006_PD003_MD001.itmData();
        IFN_EIF1006_PD003_MD001.bodyitm bodyitm = new IFN_EIF1006_PD003_MD001.bodyitm();
        IFN_EIF1006_PD003_MD001.headeritm headeritm = new IFN_EIF1006_PD003_MD001.headeritm();
        IFN_EIF1006_PD003_MD001.PD003_MD001response PD003_MD001response = new IFN_EIF1006_PD003_MD001.PD003_MD001response();
        itmList.dateKind = '1';
        itmList.dateName = '1';
        itmList.isHoliday = '1';
        itmList.locdate= '1';
        itmList.seq= '1';
        itmListlst.add(itmList);
        itmData.item = itmListlst;
        bodyitm.items = itmData;
        bodyitm.numOfRows = '10';
        bodyitm.pageNo = '1';
        bodyitm.totalCount = '3';
        headeritm.resultCode = '00';
        headeritm.resultMsg = 'NORMAL SERVICE.';
        PD003_MD001response.body = bodyitm;
        PD003_MD001response.header = headeritm;
        PD003_MD001ResWrapper.response = PD003_MD001response;



        Test.setMock(HttpCalloutMock.class, new IFN_EIF1006_PD003_MD001_TESTMock(JSON.serialize(PD003_MD001ResWrapper),200)); 
        IFN_EIF1006_PD003_MD001.PD003_MD001RequstWrapper params = new IFN_EIF1006_PD003_MD001.PD003_MD001RequstWrapper();
        IFN_EIF1006_PD003_MD001 cont = new IFN_EIF1006_PD003_MD001();
        /*
        searchSp
        getAnniversaryInfo // 기념일
        getRestDeInfo // 공휴일 
        getHoliDeInfo // 국경일
        */
        params.searchSp = 'getRestDeInfo';
        params.solYear = '2023';
        params.solMonth = '10';

        IFN_EIF1006_PD003_MD001.PD003_MD001ResWrapper res1 = cont.callout(params);

        system.debug(JSon.serialize(res1));

        Test.stopTest();

    }



    @isTest
    static void test02()
    {

        Test.startTest();





        Test.setMock(HttpCalloutMock.class, new IFN_EIF1006_PD003_MD001_TESTMock('',400)); 
        IFN_EIF1006_PD003_MD001.PD003_MD001RequstWrapper params = new IFN_EIF1006_PD003_MD001.PD003_MD001RequstWrapper();
        // IFN_EIF1006_PD003_MD001 cont = new IFN_EIF1006_PD003_MD001();
        // String interfaceId = 'IFN_EIF1006_PD003_MD001';
        // params.searchSp = '02';
        // params.keywd = '우유';
        // params.page = '1';
        // params.pageSize = '10';
        // params.order = 'gd_no';
        // params.order_mt = 'asc';
        // params.keywd_sp = '';
        // IFN_EIF1006_PD003_MD001.SE001_01ResultWrapper res = cont.callout( params);

        

        Test.stopTest();

    }

    
    // Mock3 : ERR_CD":"9999"
    public class IFN_EIF1006_PD003_MD001_TESTMock implements HttpCalloutMock {

        public String body{get;set;}
        public Integer statusCode{get;set;}

        public IFN_EIF1006_PD003_MD001_TESTMock(String body, Integer statusCode)
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