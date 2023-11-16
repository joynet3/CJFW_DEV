/**
 * @Class : IFN_LIF1012_Callout_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.11.08
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.08 | 조일근  | 최초작성
 * */
@isTest
public with sharing class IFN_LIF1012_Callout_TEST {
    @TestSetup
    static void setup(){

        Set<String> setIFId = new Set<String>{'IFN_LIF1012_PO001_MD001','IFN_LIF1012_PO001_MD002','IFN_LIF1012_PO001_MD003', 'IFN_LIF1012_Callout'};

        List<IFMaster__c> listIF = new List<IFMaster__c>();

        for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'POST';
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;

    }



    @isTest
    static void test01_1()
    {

        Test.startTest();
        IFN_LIF1012_PO001_MD002.PO001_MD002ResWrapper resData = new IFN_LIF1012_PO001_MD002.PO001_MD002ResWrapper();
        IFN_LIF1012_PO001_MD002.T_OUTPUT_ITM resItm = new IFN_LIF1012_PO001_MD002.T_OUTPUT_ITM();
        resItm.VKORG = '1';         // 판매 조직
        resItm.VKBUR = '1';         // 사업장 
        resItm.VKGRP = '1';         // 영업 그룹
        resItm.PERNR = '1';         // 사원 번호
        resItm.KUNNR = '1';         // 고객 번호
        resItm.STIDA = '1';         // [FI] 미결항목일자
        resItm.NAME1 = '1';         // 이름 1
        resItm.LB004 = '1';         // 20자 
        resItm.MS004 = '1';         // 20자 
        resItm.MR006 = '1';         // 20자 
        resItm.MB004 = '1';         // 20자 
        resItm.ALLOWANCE = '1';     // 20자 
        resItm.MB02 = '1';          // 20자 
        resItm.DMBTRT = '1';        // 20자 
        resItm.VTEXT = '1';         // 영업 조직내역
        resItm.BEZEI_VKBUR = '1';   // 사업장 내역
        resItm.BEZEI_VKGRP = '1';   // 영업그룹 내역
        resItm.PV_HNAME = '1';      // 사원번호 내역

        resData.T_OUTPUT = resItm;
        resData.XMSGS = 'SD';
        resData.XSTAT= 'S';

        Test.setMock(HttpCalloutMock.class, new IFN_LIF1012_Callout_TESTMock(JSON.serialize(resData),200)); 
        IFN_LIF1012_PO001_MD002.PO001_MD002ReqWrapper params = new IFN_LIF1012_PO001_MD002.PO001_MD002ReqWrapper();
        IFN_LIF1012_PO001_MD002.ITEM_ITM paramitm = new IFN_LIF1012_PO001_MD002.ITEM_ITM();

        IFN_LIF1012_PO001_MD002 cont = new IFN_LIF1012_PO001_MD002();
        String interfaceId = 'IFN_LIF1012_PO001_MD002';
        IFN_LIF1012_Callout callout = new IFN_LIF1012_Callout(interfaceId,'Realtime');        

        paramitm.VKORG = '1';   // 판매 조직
        paramitm.VKBUR = '1';   // 사업장 
        paramitm.VKGRP = '1';   // 영업 그룹
        paramitm.PERNR = '1';   // 사원 번호
        paramitm.KUNNR = '1';   // 고객 번호
        paramitm.STIDA = '1';   // [FI] 미결항목일자
        params.ITEM = paramitm;

        callout.getResponse(interfaceId, Json.serialize(params));

        

        Test.stopTest();

    }

    
    @isTest
    static void test01_2()
    {

        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new IFN_LIF1012_Callout_TESTMock('',500)); 
        IFN_LIF1012_PO001_MD002.PO001_MD002ReqWrapper params = new IFN_LIF1012_PO001_MD002.PO001_MD002ReqWrapper();
        IFN_LIF1012_PO001_MD002.ITEM_ITM paramitm = new IFN_LIF1012_PO001_MD002.ITEM_ITM();

        IFN_LIF1012_PO001_MD002 cont = new IFN_LIF1012_PO001_MD002();
        String interfaceId = 'IFN_LIF1012_PO001_MD002';
        IFN_LIF1012_Callout callout = new IFN_LIF1012_Callout(interfaceId,'Realtime');        

        paramitm.VKORG = '1';   // 판매 조직
        paramitm.VKBUR = '1';   // 사업장 
        paramitm.VKGRP = '1';   // 영업 그룹
        paramitm.PERNR = '1';   // 사원 번호
        paramitm.KUNNR = '1';   // 고객 번호
        paramitm.STIDA = '1';   // [FI] 미결항목일자
        params.ITEM = paramitm;

        callout.getResponse(interfaceId, Json.serialize(params));

        

        Test.stopTest();

    }



    @isTest
    static void test02_1()
    {

        Test.startTest();
        IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper resData = new IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper();
        IFN_LIF1012_PO001_MD003.T_RETURN_ITM resItm = new IFN_LIF1012_PO001_MD003.T_RETURN_ITM();
        resItm.KUNNR= '';
        resItm.WERKS= '';
        resItm.LGORT= '';
        resItm.MATNR= '';
        resItm.BWTAR= '';
        resItm.CHARG= '';
        resItm.FRBNR= '';
        resItm.HISTNO= '';
        resItm.EBELN= '';
        resItm.EBELP= '';
        resItm.ZREGISTERNO= '';
        resItm.ZPROFIT= '';
        resItm.ZYEARRATE= '';
        resItm.LBKUM= '';
        resItm.VERPR= '';
        resItm.BUDAT= '';
        resItm.ZBOX = '';
        resItm.ZCONT_NO = '';
        resItm.CTYPE= '';
        resItm.HSDAT= '';
        resItm.MHDRZ= '';
        resItm.ZSHELF_DAY= '';
        resItm.RAUBE= '';
        resItm.XSTAT= '';
        resItm.XMSGS= '';
        resItm.VERPR2= '';
        resItm.GUBUN= '';
        resItm.NAME1= '';
        resItm.NAME1_WERKS= '';
        resItm.LGOBE= '';
        resItm.MAKTX= '';
        resData.T_RETURN = resItm;

        Test.setMock(HttpCalloutMock.class, new IFN_LIF1012_Callout_TESTMock(JSON.serialize(resData),200)); 
        IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper params = new IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper();
        IFN_LIF1012_PO001_MD003.ZMMT1380_ITM paramitm = new IFN_LIF1012_PO001_MD003.ZMMT1380_ITM();
        String interfaceId = 'IFN_LIF1012_PO001_MD003';

        IFN_LIF1012_Callout callout = new IFN_LIF1012_Callout(interfaceId,'Realtime');


        paramitm.MATNR = '';
        paramitm.FRBNR = '';
        paramitm.CTYPE = '';
        params.ZMMT1380 = paramitm;

        callout.getResponse(interfaceId, Json.serialize(params));

        

        Test.stopTest();

    }



    @isTest
    static void test02_2()
    {

        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new IFN_LIF1012_Callout_TESTMock('',500)); 
        IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper params = new IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper();
        IFN_LIF1012_PO001_MD003.ZMMT1380_ITM paramitm = new IFN_LIF1012_PO001_MD003.ZMMT1380_ITM();
        String interfaceId = 'IFN_LIF1012_PO001_MD003';

        IFN_LIF1012_Callout callout = new IFN_LIF1012_Callout(interfaceId,'Realtime');


        paramitm.MATNR = '';
        paramitm.FRBNR = '';
        paramitm.CTYPE = '';
        params.ZMMT1380 = paramitm;

        callout.getResponse(interfaceId, Json.serialize(params));

        

        Test.stopTest();

    }


    
    @isTest
    static void test03_1()
    {

        Test.startTest();
        IFN_LIF1012_PO001_MD001.PO001_MD001ResWrapper resData = new IFN_LIF1012_PO001_MD001.PO001_MD001ResWrapper();
        IFN_LIF1012_PO001_MD001.T_OUTPUT_ITM resItm = new IFN_LIF1012_PO001_MD001.T_OUTPUT_ITM();
        resItm.KUNNR       = '1';
        resItm.KKBER       = '1';
        resItm.VKORG       = '1';
        resItm.KLIMK       = '1';
        resItm.SAUFT       = '1';
        resItm.SBGRP       = '1';
        resItm.KATR2       = '1';
        resItm.ZINCOME     = '1';
        resItm.VTEXT       = '1';
        resItm.VTEXT_KART2 = '1';
        resItm.STEXT       = '1';
        resItm.KKBTX       = '1';
        resData.T_OUTPUT = resItm;

        resData.XMSGS = '1';
        resData.XSTAT= 'S';

        Test.setMock(HttpCalloutMock.class, new IFN_LIF1012_Callout_TESTMock(JSON.serialize(resData),200)); 
        IFN_LIF1012_PO001_MD001.PO001_MD001ReqWrapper params = new IFN_LIF1012_PO001_MD001.PO001_MD001ReqWrapper();
        IFN_LIF1012_PO001_MD001.T_INPUT_ITM paramitm = new IFN_LIF1012_PO001_MD001.T_INPUT_ITM();
        String interfaceId = 'IFN_LIF1012_PO001_MD001';

        IFN_LIF1012_Callout callout = new IFN_LIF1012_Callout(interfaceId,'Realtime');

        paramitm.KUNNR = '50000';
        paramitm.KKBER = 'FW00';
        params.T_INPUT = paramitm;

        callout.getResponse(interfaceId, Json.serialize(params));

        

        Test.stopTest();

    }


    

    @isTest
    static void test03_2()
    {

        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new IFN_LIF1012_Callout_TESTMock('',500)); 
        IFN_LIF1012_PO001_MD001.PO001_MD001ReqWrapper params = new IFN_LIF1012_PO001_MD001.PO001_MD001ReqWrapper();
        IFN_LIF1012_PO001_MD001.T_INPUT_ITM paramitm = new IFN_LIF1012_PO001_MD001.T_INPUT_ITM();
        String interfaceId = 'IFN_LIF1012_PO001_MD001';

        IFN_LIF1012_Callout callout = new IFN_LIF1012_Callout(interfaceId,'Realtime');

        paramitm.KUNNR = '50000';
        paramitm.KKBER = 'FW00';
        params.T_INPUT = paramitm;

        callout.getResponse(interfaceId, Json.serialize(params));

        

        Test.stopTest();

    }







    
    // Mock3 : ERR_CD":"9999"
    public class IFN_LIF1012_Callout_TESTMock implements HttpCalloutMock {

        public String body{get;set;}
        public Integer statusCode{get;set;}

        public IFN_LIF1012_Callout_TESTMock(String body, Integer statusCode)
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