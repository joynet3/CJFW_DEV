/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 02-05-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class IF_SFDC_DATA_REQ_NARA_TENDER_INFO_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();
        List<String> listIF = new List<String>{'IF_SFDC_DATA_REQ_NARA_TENDER_INFO','IF_SFDC_DATA_REQ_NARA_TENDER_INFO2', 'IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE', 'IF_SFDC_DATA_REQ_NARA_TENDER_LICENSE2','IF_SFDC_DATA_REQ_NARA_TENDER_RERT','IF_SFDC_DATA_REQ_NARA_TENDER_RERT2'};

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

    // @isTest
    // static void testIF_SFDC_DATA_REQ_NARA_TENDER_INFO_qu() {
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    //     System.Queueable job = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_qu();
    //     System.enqueueJob(job);
    //     Test.stopTest();
    // }

    @isTest
    static void testIF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SchedulableContext sc = null;
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc scd = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc();
        IF_SFDC_DATA_REQ_NARA_TENDER_FRGC_sc scd2 = new IF_SFDC_DATA_REQ_NARA_TENDER_FRGC_sc();
        IF_SFDC_DATA_REQ_NARA_TENDER_SERVC_sc scd3 = new IF_SFDC_DATA_REQ_NARA_TENDER_SERVC_sc();
        IF_SFDC_DATA_REQ_NARA_TENDER_THNG_sc scd4 = new IF_SFDC_DATA_REQ_NARA_TENDER_THNG_sc();
        scd.execute(sc);
        scd2.execute(sc);
        scd3.execute(sc);
        scd4.execute(sc);
        Test.stopTest();
    }

    @isTest
    static void testIF_SFDC_DATA_REQ_NARA_TENDER_INFO2_sc() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SchedulableContext sc = null;
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_sc scd = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_sc();
        scd.execute(sc);
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
            res.setBody('{"response":{"header":{"resultCode":"00","resultMsg":"정상"},"body":{"items":[{"bidNtceNo":"20221141337","bidNtceOrd":"00","reNtceYn":"N","rgstTyNm":"조달청 또는 나라장터 자체 공고건","ntceKindNm":"일반","intrbidYn":"N","bidNtceDt":"2022-11-28 13:04:10","refNo":"세화여자고등학교-13510","NtceNm" : "2023학년도 학교급식 중식 및 석식 일부위탁 용역 종합 노인 어린이 유치원 식당 입찰 공고","bidNtceNm":"2023학년도 학교급식 중식 및 석식 일부위탁 용역 종합 노인 어린이 유치원 식당 입찰 공고","ntceInsttCd":"7010198","ntceInsttNm":"서울특별시교육청 세화여자고등학교","dminsttCd":"7010198","dminsttNm":"서울특별시교육청 세화여자고등학교","bidMethdNm":"전자입찰","cntrctCnclsMthdNm":"제한(총액)규격가격동시","ntceInsttOfclNm":"김은진","ntceInsttOfclTelNo":"02-594-4886","ntceInsttOfclEmailAdrs":"keun222@sen.go.kr","exctvNm":"김은진","bidQlfctRgstDt":"2022-12-22 18:00","cmmnSpldmdAgrmntRcptdocMethd":"공고서참조","cmmnSpldmdAgrmntClseDt":"","cmmnSpldmdCorpRgnLmtYn":"N","bidBeginDt":"2022-11-28 14:00:00","bidClseDt":"2022-12-23 16:00:00","opengDt":"2023-01-30 15:00:00","ntceSpecDocUrl1":"https://www.g2b.go.kr:8081/ep/co/fileDownload.do?fileTask=NOTIFY&fileSeq=20221141337::00::1::4","ntceSpecDocUrl2":"https://www.g2b.go.kr:8081/ep/co/fileDownload.do?fileTask=NOTIFY&fileSeq=20221141337::00::2::2","ntceSpecDocUrl3":"https://www.g2b.go.kr:8081/ep/co/fileDownload.do?fileTask=NOTIFY&fileSeq=20221141337::00::2::3","ntceSpecDocUrl4":"","ntceSpecDocUrl5":"","ntceSpecDocUrl6":"","ntceSpecDocUrl7":"","ntceSpecDocUrl8":"","ntceSpecDocUrl9":"","ntceSpecDocUrl10":"","ntceSpecFileNm1":"20221141337-00_1669608140810_2023학년도 세화여자고등학교 학교급식 일부위탁 용역 입찰 공고.hwp","ntceSpecFileNm2":"20221141337-00_1669607097800_2023학년도 세화여자고등학교 급식 일부위탁 과업설명서.hwp","ntceSpecFileNm3":"20221141337-00_1669607097800_2023학년도 세화여자고등학교 급식 일부위탁 계약특수조건.hwp","ntceSpecFileNm4":"","ntceSpecFileNm5":"","ntceSpecFileNm6":"","ntceSpecFileNm7":"","ntceSpecFileNm8":"","ntceSpecFileNm9":"","ntceSpecFileNm10":"","rbidPermsnYn":"Y","pqApplDocRcptMthdNm":"","pqApplDocRcptDt":"","tpEvalApplMthdNm":"","tpEvalApplClseDt":"","jntcontrctDutyRgnNm1":"","jntcontrctDutyRgnNm2":"","jntcontrctDutyRgnNm3":"","rgnDutyJntcontrctRt":"","dtlsBidYn":"","bidPrtcptLmtYn":"N","prearngPrceDcsnMthdNm":"복수예가","totPrdprcNum":"15","drwtPrdprcNum":"4","asignBdgtAmt":"842401000","presmptPrce":"765819091","opengPlce":"국가종합전자조달시스템(나라장터)","dcmtgOprtnDt":"","dcmtgOprtnPlce":"","bidNtceDtlUrl":"https://www.g2b.go.kr:8081/ep/invitation/publish/bidInfoDtl.do?bidno=20221141337&bidseq=00&releaseYn=Y&taskClCd=5","bidNtceUrl":"","bidPrtcptFeePaymntYn":"","bidPrtcptFee":"","bidGrntymnyPaymntYn":"","crdtrNm":"교장","ppswGnrlSrvceYn":"N","srvceDivNm":"일반용역","prdctClsfcLmtYn":"","mnfctYn":"","purchsObjPrdctList":"","untyNtceNo":"","cmmnSpldmdMethdCd":"","cmmnSpldmdMethdNm":"공동수급불허","stdNtceDocUrl":"","brffcBidprcPermsnYn":"","dsgntCmptYn":"N","arsltCmptYn":"N","pqEvalYn":"N","tpEvalYn":"N","ntceDscrptYn":"N","rsrvtnPrceReMkngMthdNm":"재입찰시 기존 예비가격을 사용하여 예정가격이 산정됩니다.","arsltApplDocRcptMthdNm":"없음","arsltReqstdocRcptDt":"","orderPlanUntyNo":"5-1-2023-7010198-000001","sucsfbidLwltRate":"","rgstDt":"2022-11-28 13:04:10","bfSpecRgstNo":"1214452","infoBizYn":"","sucsfbidMthdCd":"21","sucsfbidMthdNm":"최저가낙찰제","chgDt":"","linkInsttNm":"","dminsttOfclEmailAdrs":"","indstrytyLmtYn":"Y","d2bMngRgnLmtYn":"","d2bMngPblctPlceNm":"","d2bMngCntrctKindNm":"","d2bMngCnstwkOutlnCntnts":"","d2bMngCnstwkPrdCntnts":"","d2bMngCntrybndDedtBgnDate":"","d2bMngCntrybndDedtEndDate":"","d2bMngCnstwkScleCntnts":"","d2bMngRsrvtnPrceBssOpenYn":"","d2bMngRsrvtnPrceBssAplYn":"","d2bMngBssamt":"","d2bMngUprcSstmTyNm":"","d2bMngRgstEvalExmpYn":"","d2bMngCompCorpRsrchObjYn":"","d2bMngOrgnlbdgtDedtBgnDate":"","d2bMngOrgnlbdgtDedtEndDate":"","d2bMngBfEvalObjYn":"","d2bMngBfEvalClseDt":"","d2bMngAssmntUplmtRt":"","d2bMngAssmntLwstlmtRt":"","d2bMngStdIndstryClsfcCdList":"","d2bMngPrdctnAbltySbmsnClseDt":"","d2bMngCnstwkLctNm":"","d2bMngProgrsSttusNm":"","d2bMngExetTyNm":"","d2bMngExetTyCd":"","d2bMngPrdlstNm":"","d2bMngPrdlstCd":"","d2bMngItemNo":"","d2bMngNgttnStleNm":"","d2bMngNgttnPlanDate":"","d2bMngDmndYear":"","d2bMngDcsnNo":"","d2bMngCnstwkNo":"","chgNtceRsn":"","rbidOpengDt":"2023-01-30 15:00:00","VAT":"76581909","indutyVAT":""}],"numOfRows":200,"pageNo":1,"totalCount":1}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}