/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
@isTest
public class NaraTenderBtnController_test {

    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_DATA_REQ_NARA_TENDER_INFO', 'IF_SFDC_DATA_REQ_NARA_TENDER_INFO2','IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL','IF_SFDC_DATA_REQ_NARA_TENDER_RERT','IF_SFDC_DATA_REQ_NARA_TENDER_RERT2','IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE','IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE2'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'GET';
            objIFMaster.ContentType__c = 'application/json';
            objIFMaster.Endpoint__c = 'test';
            
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;
    }

    @IsTest
    static void testNaraTenderBtnController() {
        Test.startTest();
        Lead leadobj = new Lead();
        leadobj.LastName = 'test';
        leadobj.Company = 'test';
        leadobj.g2bPblancNo__c = '2022HTF089932425-01';
        leadobj.BidNoticeNumber__c = '2938120938-01';
        leadobj.bidNtceOrd__c = '01';
        insert leadobj;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        NaraTenderBtnController.doSearch('2022HTO223430987', '1', 'getBidPblancListInfoThng');
        NaraTenderBtnController.doSave(leadobj, '1','getBidPblancListInfoThng');
        Test.stopTest();
    }

    @IsTest
    static void testNaraTenderBtnController2() {
        Test.startTest();
        Lead leadobj = new Lead();
        leadobj.LastName = 'test';
        leadobj.Company = 'test';
        leadobj.g2bPblancNo__c = '2022HTF089932425-01';
        leadobj.BidNoticeNumber__c = '2938120938-01';
        leadobj.bidNtceOrd__c = '01';
        insert leadobj;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        NaraTenderBtnController.doSearch('2022HTO223430987', '2', 'getBidPblancListInfoThng');
        NaraTenderBtnController.doSave(leadobj, '2','getBidPblancListInfoThng');
        Test.stopTest();
    }

    @IsTest
    static void testNaraTenderBtnController3() {
        Test.startTest();
        Lead leadobj = new Lead();
        leadobj.LastName = 'test';
        leadobj.Company = 'test';
        leadobj.g2bPblancNo__c = '2022HTF089932425-01';
        leadobj.BidNoticeNumber__c = '2938120938-01';
        leadobj.bidNtceOrd__c = '01';
        insert leadobj;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        NaraTenderBtnController.doSearch('2022HTO223430987', '2', 'getPrvtBidPblancListInfoThng');
        NaraTenderBtnController.doSave(leadobj, '2','getPrvtBidPblancListInfoThng');
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"response":{"header":{"resultCode":"00","resultMsg":"정상"},"body":{"items":[{"bidNtceNo":"20220906405","bidNtceOrd":"00","reNtceYn":"N","rgstTyNm":"조달청 또는 나라장터 자체 공고건","ntceKindNm":"일반","intrbidYn":"N","bidNtceDt":"2022-09-07 15:30:23","refNo":"소사노 제2022-01호","bidNtceNm":"2022년 부천시소사노인복지관 경로식당 식자재 납품업체 입찰","ntceInsttCd":"Z023408","ntceInsttNm":"부천시소사노인복지관","dminsttCd":"Z023408","dminsttNm":"부천시소사노인복지관","bidMethdNm":"직찰/우편/상시","cntrctCnclsMthdNm":"제한(총액)협상에의한계약","ntceInsttOfclNm":"김은혜","ntceInsttOfclTelNo":"032-347-9534","ntceInsttOfclEmailAdrs":"sosasenior@hanmail.net","exctvNm":"김은혜","bidQlfctRgstDt":"","cmmnSpldmdAgrmntRcptdocMethd":"공고서참조","cmmnSpldmdAgrmntClseDt":"","cmmnSpldmdCorpRgnLmtYn":"N","bidBeginDt":"","bidClseDt":"","opengDt":"2022-10-06 19:00:00","ntceSpecDocUrl1":"https://www.g2b.go.kr:8081/ep/co/fileDownload.do?fileTask=NOTIFY&fileSeq=20220906405::00::1::1","ntceSpecDocUrl2":"https://www.g2b.go.kr:8081/ep/co/fileDownload.do?fileTask=NOTIFY&fileSeq=20220906405::00::2::2","ntceSpecDocUrl3":"https://www.g2b.go.kr:8081/ep/co/fileDownload.do?fileTask=NOTIFY&fileSeq=20220906405::00::2::3","ntceSpecDocUrl4":"","ntceSpecDocUrl5":"","ntceSpecDocUrl6":"","ntceSpecDocUrl7":"","ntceSpecDocUrl8":"","ntceSpecDocUrl9":"","ntceSpecDocUrl10":"","ntceSpecFileNm1":"20220906405-00_1662532094014_[공고문] 2022년도 부천시소사노인복지관 경로식당 식자재 납품업체 입찰 공고.hwp","ntceSpecFileNm2":"20220906405-00_1662532094014_별첨1_단가견적리스트(2022).xlsx","ntceSpecFileNm3":"20220906405-00_1662532094034_붙임서류.zip","ntceSpecFileNm4":"","ntceSpecFileNm5":"","ntceSpecFileNm6":"","ntceSpecFileNm7":"","ntceSpecFileNm8":"","ntceSpecFileNm9":"","ntceSpecFileNm10":"","rbidPermsnYn":"N","prdctClsfcLmtYn":"N","mnfctYn":"","prearngPrceDcsnMthdNm":"비예가","totPrdprcNum":"","drwtPrdprcNum":"","asignBdgtAmt":"250000000","presmptPrce":"227272727","opengPlce":"국가종합전자조달시스템(나라장터)","bidNtceDtlUrl":"https://www.g2b.go.kr:8081/ep/invitation/publish/bidInfoDtl.do?bidno=20220906405&bidseq=00&releaseYn=Y&taskClCd=1","bidNtceUrl":"","bidPrtcptFeePaymntYn":"","bidPrtcptFee":"","bidGrntymnyPaymntYn":"","crdtrNm":"부천시소사노인복지관장","dtilPrdctClsfcNo":"5022110101","dtilPrdctClsfcNoNm":"곡류","prdctSpecNm":"곡류","prdctQty":"1","prdctUnit":"kg","prdctUprc":"","dlvrTmlmtDt":"2022-11-01 00:00:00","dlvrDaynum":"","dlvryCndtnNm":"기타사항참조","purchsObjPrdctList":"[1^5022110101^곡류]","untyNtceNo":"","cmmnSpldmdMethdCd":"4","cmmnSpldmdMethdNm":"공동수급불허","stdNtceDocUrl":"","brffcBidprcPermsnYn":"N","dsgntCmptYn":"N","rsrvtnPrceReMkngMthdNm":"","arsltApplDocRcptMthdNm":"없음","arsltApplDocRcptDt":"","orderPlanUntyNo":"1-3-2022-Z023408-000001","sucsfbidLwltRate":"","rgstDt":"2022-09-07 15:30:23","bfSpecRgstNo":"1186862","infoBizYn":"","sucsfbidMthdCd":"13","sucsfbidMthdNm":"협상에 의한 낙찰자 결정","chgDt":"","linkInsttNm":"","dminsttOfclEmailAdrs":"","indstrytyLmtYn":"","d2bMngDcmtgOprtnDt":"","d2bMngDcmtgOprtnPlce":"","d2bMngRgnLmtYn":"","d2bMngPblctPlceNm":"","d2bMngCntrctKindNm":"","d2bMngCntrybndDedtBgnDate":"","d2bMngCntrybndDedtEndDate":"","d2bMngRsrvtnPrceBssOpenYn":"","d2bMngRrsrvtnPrceBssAplYn":"","d2bMngBssamt":"","d2bMngRgstEvalExmpYn":"","d2bMngCompCorpRsrchObjYn":"","d2bMngOrgnlbdgtDedtBgnDate":"","d2bMngOrgnlbdgtDedtEndDate":"","d2bMngAssmntUplmtRt":"","d2bMngAssmntLwstlmtRt":"","d2bMngStdIndstryClsfcCdList":"","d2bMngPrdctnAbltySbmsnClseDt":"","d2bMngProgrsSttusNm":"","d2bMngExetTyNm":"","d2bMngExetTyCd":"","d2bMngPrdlstCd":"","d2bMngItemNo":"","d2bMngNgttnStleNm":"","d2bMngNgttnPlanDate":"","d2bMngDmndYear":"","d2bMngDcsnNo":"","chgNtceRsn":"","rbidOpengDt":"","VAT":"22727273","indutyVAT":""}],"numOfRows":200,"pageNo":1,"totalCount":1}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}