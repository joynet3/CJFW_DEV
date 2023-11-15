/**
 * @Class : IFN_LIF1012_PO001_MD003_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.08.30
 * @Version : 1.0
 * @Description : 미계약 상품 조회 I/F callout 테스트 클래스
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.08 | 조일근  | 최초작성
 * */
@isTest
public with sharing class IFN_LIF1012_PO001_MD003_TEST {
    @TestSetup
    static void setup(){

        Set<String> setIFId = new Set<String>{'IFN_LIF1012_PO001_MD003', 'IFN_LIF1012_Callout'};

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
    static void testone()
    {

        Test.startTest();
        IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper resData = new IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper();
        IFN_LIF1012_PO001_MD003.T_OUTPUT_ITM resItm = new IFN_LIF1012_PO001_MD003.T_OUTPUT_ITM();
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


        Test.setMock(HttpCalloutMock.class, new IFN_LIF1012_PO001_MD003_TESTMock(JSON.serialize(resData),200)); 
        IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper params = new IFN_LIF1012_PO001_MD003.PO001_MD003ReqWrapper();
        IFN_LIF1012_PO001_MD003.T_INPUT_ITM paramitm = new IFN_LIF1012_PO001_MD003.T_INPUT_ITM();

        IFN_LIF1012_PO001_MD003 cont = new IFN_LIF1012_PO001_MD003();
        String interfaceId = 'IFN_LIF1012_PO001_MD003';

        paramitm.KUNNR = '50000             ';
        paramitm.KKBER = 'FW00';
        params.T_INPUT = paramitm;

        IFN_LIF1012_PO001_MD003.PO001_MD003ResWrapper res = cont.callout(params);

        System.debug(JSON.serialize(res));

        Test.stopTest();

    }

    
    // Mock3 : ERR_CD":"9999"
    public class IFN_LIF1012_PO001_MD003_TESTMock implements HttpCalloutMock {

        public String body{get;set;}
        public Integer statusCode{get;set;}

        public IFN_LIF1012_PO001_MD003_TESTMock(String body, Integer statusCode)
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