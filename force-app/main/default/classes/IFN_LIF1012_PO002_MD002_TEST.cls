/**
 * @Class : IFN_LIF1012_PO002_MD002_TEST.cls
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
public with sharing class IFN_LIF1012_PO002_MD002_TEST {
    @TestSetup
    static void setup(){

        Set<String> setIFId = new Set<String>{'IFN_LIF1012_PO002_MD002', 'IFN_LIF1012_Callout'};

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
        IFN_LIF1012_PO002_MD002.PO002_MD002ResWrapper resData = new IFN_LIF1012_PO002_MD002.PO002_MD002ResWrapper();
        IFN_LIF1012_PO002_MD002.T_RETURN_ITM resItm = new IFN_LIF1012_PO002_MD002.T_RETURN_ITM();
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

        Test.setMock(HttpCalloutMock.class, new IFN_LIF1012_PO002_MD002_TESTMock(JSON.serialize(resData),200)); 
        IFN_LIF1012_PO002_MD002.PO002_MD002ReqWrapper params = new IFN_LIF1012_PO002_MD002.PO002_MD002ReqWrapper();
        IFN_LIF1012_PO002_MD002.ZMMT1380_ITM paramitm = new IFN_LIF1012_PO002_MD002.ZMMT1380_ITM();

        IFN_LIF1012_PO002_MD002 cont = new IFN_LIF1012_PO002_MD002();
        String interfaceId = 'IFN_LIF1012_PO002_MD002';

        paramitm.MATNR = '';
        paramitm.FRBNR = '';
        paramitm.CTYPE = '';
        params.ZMMT1380 = paramitm;

        IFN_LIF1012_PO002_MD002.PO002_MD002ResWrapper res = cont.callout(params);

        

        Test.stopTest();

    }

    
    // Mock3 : ERR_CD":"9999"
    public class IFN_LIF1012_PO002_MD002_TESTMock implements HttpCalloutMock {

        public String body{get;set;}
        public Integer statusCode{get;set;}

        public IFN_LIF1012_PO002_MD002_TESTMock(String body, Integer statusCode)
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