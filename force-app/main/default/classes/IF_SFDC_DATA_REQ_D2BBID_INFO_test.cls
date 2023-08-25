/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 01-12-2023
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
@isTest
public class IF_SFDC_DATA_REQ_D2BBID_INFO_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_DATA_REQ_D2BBID_INFO', 'IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'GET';
            objIFMaster.ContentType__c = 'application/xml';
            objIFMaster.Endpoint__c = 'http://openapi.d2b.go.kr/openapi/service/BidPblancInfoService';
            
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;
    }
    // @isTest
    // static void testIF_SFDC_DATA_REQ_D2BBID_INFO_qu() {
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    //     System.Queueable job = new IF_SFDC_DATA_REQ_D2BBID_INFO_qu();
    //     System.enqueueJob(job);
    //     Test.stopTest();
    // }

    @isTest
    static void testIF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba() {
        Test.startTest();
        List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> inputItemsList = new List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> ();
        IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items inputItems = new IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items();
        inputItems.demandYear = '2022';
        inputItems.orntCode = 'LGD';
        inputItems.dcsNo = '51524';
        inputItems.pblancNo = 'LGD0016';
        inputItems.pblancOdr = '01';
        inputItemsList.add(inputItems);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba b = new IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba(inputItemsList);
        Database.executeBatch(b);
        Test.stopTest();
    }

    @isTest
    static void testIF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba2() {
        Lead obj = new Lead();
        obj.Company = 'test';
        obj.Status = 'New';
        obj.LastName = 'test';
        obj.BidNoticeNumber__c = '2022LGD001651524-01';
        insert obj;
        Test.startTest();
        List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> inputItemsList = new List<IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items> ();
        IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items inputItems = new IF_SFDC_DATA_REQ_D2BBID_INFO_sc.Items();
        inputItems.demandYear = '2022';
        inputItems.orntCode = 'LGD';
        inputItems.dcsNo = '51524';
        inputItems.pblancNo = 'LGD0016';
        inputItems.pblancOdr = '01';
        inputItemsList.add(inputItems);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba b = new IF_SFDC_DATA_REQ_D2BBID_INFO_DETAIL_ba(inputItemsList);
        Database.executeBatch(b);
        Test.stopTest();
    }

    @isTest
    static void testIF_SFDC_DATA_REQ_D2BBID_INFO_sc() {
        Test.startTest();
        SchedulableContext sc = null;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        IF_SFDC_DATA_REQ_D2BBID_INFO_sc scd = new IF_SFDC_DATA_REQ_D2BBID_INFO_sc();
        scd.execute(sc);
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            // System.assertEquals('http://openapi.d2b.go.kr/openapi/service/BidPblancInfoServicegetDmstcCmpetBidPblancList?opengDateBegin=20221005&bidNm=%EC%8B%9D%EC%9E%90%EC%9E%AC&numOfRows=200', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<response>'
                + '<header>'
                + '<resultCode>00</resultCode>'
                + '<resultMsg>NORMAL SERVICE.</resultMsg>'
                + '</header>'
                + '<body>'
                + '<item>'
                + '<bidMth>총액제</bidMth>'
                + '<bidNm>00부대 간부식당 민간위탁 용역</bidNm>'
                + '<bidPartcptRegistClosDt>202212051600</bidPartcptRegistClosDt>'
                + '<bidPlace>국방전자조달시스템</bidPlace>'
                + '<bidStle>전자입찰</bidStle>'
                + '<biddocPresentnClosDt>202212061600</biddocPresentnClosDt>'
                + '<bsisPrdprcApplcAt>적용</bsisPrdprcApplcAt>'
                + '<bsnsDcMeetngDt>202211281400</bsnsDcMeetngDt>'
                + '<bsnsDcMeetngPlace>육군종합행정학교</bsnsDcMeetngPlace>'
                + '<budgetAmount>1386000000</budgetAmount>'
                + '<chargerCttpc>043-740-6734</chargerCttpc>'
                + '<chargerNm>황예슬</chargerNm>'
                + '<cntrctKnd>일반확정계약</cntrctKnd>'
                + '<cntrctMth>협상에의한계약(전자)</cntrctMth>'
                + '<compnoEntrpsRsrchTrgetAt>비대상</compnoEntrpsRsrchTrgetAt>'
                + '<copertnOutsrcFlflMthd>단독</copertnOutsrcFlflMthd>'
                + '<dcsNo>51524</dcsNo>'
                + '<estmPrce>1260000000</estmPrce>'
                + '<excutTy>용역</excutTy>'
                + '<g2bPblancNo>LGD001651524</g2bPblancNo>'
                + '<g2bPblancOdr>01</g2bPblancOdr>'
                + '<ntndbtDedt>~</ntndbtDedt>'
                + '<opengDt>202212121100</opengDt>'
                + '<orgnlbudgtDedt>~</orgnlbudgtDedt>'
                + '<ornt>육군종합행정학교</ornt>'
                + '<pblancDate>20221122</pblancDate>'
                + '<pblancNo>LGD0016</pblancNo>'
                + '<pblancOdr>1</pblancOdr>'
                + '<pblancSe>긴급공고</pblancSe>'
                + '<pblictInstt>인터넷</pblictInstt>'
                + '<registJdgmnPnttm>N</registJdgmnPnttm>'
                + '<sucbidrDecsnMth>최저가격제</sucbidrDecsnMth>'
                + '</item>'
                + '</body>'
                + '</response>');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            // System.assertEquals('http://openapi.d2b.go.kr/openapi/service/BidPblancInfoServicegetDmstcCmpetBidPblancDetail?demandYear=2022&orntCode=HDF&dcsNo=39508&pblancNo=HDF0052&pblancOdr=2', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<response>'
            + '<header>'
            + '<resultCode>00</resultCode>'
            + '<resultMsg>NORMAL SERVICE.</resultMsg>'
            + '</header>'
            + '<body>'
            + '<totalCount>1</totalCount>'
            + '<pageNo>1</pageNo>'
            + '<numOfRows>200</numOfRows>'
            + '<items>'
            + '<pblancNo>LGD0016</pblancNo>'
            + '<pblancOdr>1</pblancOdr>'
            + '<demandYear>2022</demandYear>'
            + '<orntCode>LGD</orntCode>'
            + '<dcsNo>39508</dcsNo>'
            + '<item>'
            + '<demandYear>2022</demandYear>'
            + '<orntCode>LGD</orntCode>'
            + '<areaLmttList>[17] 강원도</areaLmttList>'
            + '<bidMth>총액제</bidMth>'
            + '<bidNm>’22년 병사식당(웰빙센터) 식자재 구매</bidNm>'
            + '<bidPartcptRegistClosDt>202210051000</bidPartcptRegistClosDt>'
            + '<bidPlace>국방전자조달시스템</bidPlace>'
            + '<bidStle>일반입찰</bidStle>'
            + '<biddocPresentnClosDt>202210051030</biddocPresentnClosDt>'
            + '<bsisPrdprcApplcAt>적용</bsisPrdprcApplcAt>'
            + '<budgetAmount>77916620</budgetAmount>'
            + '<chargerCttpc>033-730-4153</chargerCttpc>'
            + '<chargerNm>김하늘</chargerNm>'
            + '<cntrctKnd>일반확정계약</cntrctKnd>'
            + '<cntrctMth>제한경쟁</cntrctMth>'
            + '<compnoEntrpsRsrchTrgetAt>비대상</compnoEntrpsRsrchTrgetAt>'
            + '<copertnOutsrcFlflMthd>단독</copertnOutsrcFlflMthd>'
            + '<dcsNo>39508</dcsNo>'
            + '<estmPrce>70833290</estmPrce>'
            + '<excutTy>구매</excutTy>'
            + '<g2bPblancNo>HDF005239508</g2bPblancNo>'
            + '<g2bPblancOdr>02</g2bPblancOdr>'
            + '<ntndbtDedt>~</ntndbtDedt>'
            + '<opengDt>202210051100</opengDt>'
            + '<orgnlbudgtDedt>~</orgnlbudgtDedt>'
            + '<ornt>공군 제8전투비행단</ornt>'
            + '<pblancDate>20220929</pblancDate>'
            + '<pblancNo>HDF0052</pblancNo>'
            + '<pblancOdr>2</pblancOdr>'
            + '<pblancSe>재공고</pblancSe>'
            + '<pblictInstt>인터넷</pblictInstt>'
            + '<registJdgmnPnttm>Y</registJdgmnPnttm>'
            + '<sucbidrDecsnMth>적격심사제</sucbidrDecsnMth>'
            + '</item>'
            + '</items>'
            + '</body>'
            + '</response>');
            res.setStatusCode(200);
            return res;
        }
    }
}