/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 12-07-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
@isTest
public class IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL','IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'GET';
            objIFMaster.ContentType__c = 'application/json';
            objIFMaster.Endpoint__c = 'http://apis.data.go.kr/1230000/BidPublicInfoService03';
            
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;
    }
    
    @isTest
    static void testIF_SFDC_DATA_REQ_NARA_TENDER_DETAIL() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL i = new IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL();
        i.callOut('2018LHG004628819-01', '1', 'getBidPblancListInfoThng');
        Test.stopTest();
    }

    @isTest
    static void testIF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL i = new IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL();
        i.callOut('20221003464-00', '2', 'getBidPblancListInfoThng');
        Test.stopTest();
    }

    @isTest
    static void testIF_SFDC_DATA_REQ_NARA_TENDER_DETAIL3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2 i2 = new IF_SFDC_DATA_REQ_NARA_TENDER_DETAIL2();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        i2.callOut('20221003464-00', '2', 'getBidPblancListInfoThng');
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
            res.setBody('{"response":{"header":{"resultCode":"00","resultMsg":"정상"},"body":{"items":[{"bidNtceNo":"LHG0046","bidNtceOrd":"01","reNtceYn":"","rgstTyNm":"연계기관 공고건","ntceKindNm":"","intrbidYn":"N","bidNtceDt":"","refNo":"","bidNtceNm":"18-29차 부대구매(의료기재) 집행","ntceInsttCd":"","ntceInsttNm":"","dminsttCd":"LHG","dminsttNm":"제1862부대","bidMethdNm":"","cntrctCnclsMthdNm":"수의계약(총액제)","ntceInsttOfclNm":"정태환","ntceInsttOfclTelNo":"033-460-6503","ntceInsttOfclEmailAdrs":"","exctvNm":"","bidQlfctRgstDt":"","cmmnSpldmdAgrmntRcptdocMethd":"공고서참조","cmmnSpldmdAgrmntClseDt":"","cmmnSpldmdCorpRgnLmtYn":"N","bidBeginDt":"","bidClseDt":"2018-08-14 10:00:00","opengDt":"2018-08-14 11:00:00","ntceSpecDocUrl1":"","ntceSpecDocUrl2":"","ntceSpecDocUrl3":"","ntceSpecDocUrl4":"","ntceSpecDocUrl5":"","ntceSpecDocUrl6":"","ntceSpecDocUrl7":"","ntceSpecDocUrl8":"","ntceSpecDocUrl9":"","ntceSpecDocUrl10":"","ntceSpecFileNm1":"","ntceSpecFileNm2":"","ntceSpecFileNm3":"","ntceSpecFileNm4":"","ntceSpecFileNm5":"","ntceSpecFileNm6":"","ntceSpecFileNm7":"","ntceSpecFileNm8":"","ntceSpecFileNm9":"","ntceSpecFileNm10":"","rbidPermsnYn":"","prdctClsfcLmtYn":"","mnfctYn":"","prearngPrceDcsnMthdNm":"","totPrdprcNum":"","drwtPrdprcNum":"","asignBdgtAmt":"2951600","presmptPrce":"","opengPlce":"국방전자조달체계","bidNtceDtlUrl":"","bidNtceUrl":"","bidPrtcptFeePaymntYn":"","bidPrtcptFee":"","bidGrntymnyPaymntYn":"","crdtrNm":"","dtilPrdctClsfcNo":"","dtilPrdctClsfcNoNm":"","prdctSpecNm":"","prdctQty":"","prdctUnit":"","prdctUprc":"","dlvrTmlmtDt":"","dlvrDaynum":"","dlvryCndtnNm":"","purchsObjPrdctList":"","untyNtceNo":"","cmmnSpldmdMethdCd":"","cmmnSpldmdMethdNm":"","stdNtceDocUrl":"","brffcBidprcPermsnYn":"","dsgntCmptYn":"N","rsrvtnPrceReMkngMthdNm":"","arsltApplDocRcptMthdNm":"","arsltApplDocRcptDt":"","orderPlanUntyNo":"","sucsfbidLwltRate":"88","rgstDt":"2018-08-14 00:30:00","bfSpecRgstNo":"","infoBizYn":"","sucsfbidMthdCd":"","sucsfbidMthdNm":"최저가격제","chgDt":"","linkInsttNm":"방위사업청","dminsttOfclEmailAdrs":"","indstrytyLmtYn":"","d2bMngDcmtgOprtnDt":"","d2bMngDcmtgOprtnPlce":"","d2bMngRgnLmtYn":"Y","d2bMngPblctPlceNm":"","d2bMngCntrctKindNm":"","d2bMngCntrybndDedtBgnDate":"","d2bMngCntrybndDedtEndDate":"","d2bMngRsrvtnPrceBssOpenYn":"","d2bMngRrsrvtnPrceBssAplYn":"Y","d2bMngBssamt":"2865630","d2bMngRgstEvalExmpYn":"","d2bMngCompCorpRsrchObjYn":"","d2bMngOrgnlbdgtDedtBgnDate":"","d2bMngOrgnlbdgtDedtEndDate":"","d2bMngAssmntUplmtRt":"3","d2bMngAssmntLwstlmtRt":"-3","d2bMngStdIndstryClsfcCdList":"","d2bMngPrdctnAbltySbmsnClseDt":"","d2bMngProgrsSttusNm":"공개협상완료","d2bMngExetTyNm":"","d2bMngExetTyCd":"","d2bMngPrdlstCd":"","d2bMngItemNo":"***","d2bMngNgttnStleNm":"전자협상","d2bMngNgttnPlanDate":"2018-08-14","d2bMngDmndYear":"2018","d2bMngDcsnNo":"28819","chgNtceRsn":"","rbidOpengDt":"","VAT":"","indutyVAT":""},{"bidNtceNo":"LHG0046","bidNtceOrd":"1","reNtceYn":"","rgstTyNm":"연계기관 공고건","ntceKindNm":"","intrbidYn":"N","bidNtceDt":"","refNo":"","bidNtceNm":"동계대비 보일러설비 및 전기설비 자재 구매","ntceInsttCd":"","ntceInsttNm":"","dminsttCd":"LHG","dminsttNm":"제1862부대","bidMethdNm":"","cntrctCnclsMthdNm":"수의계약(총액제)","ntceInsttOfclNm":"정태환","ntceInsttOfclTelNo":"033-460-6501","ntceInsttOfclEmailAdrs":"","exctvNm":"","bidQlfctRgstDt":"","cmmnSpldmdAgrmntRcptdocMethd":"공고서참조","cmmnSpldmdAgrmntClseDt":"","cmmnSpldmdCorpRgnLmtYn":"N","bidBeginDt":"","bidClseDt":"2019-11-29 10:00:00","opengDt":"2019-11-29 11:00:00","ntceSpecDocUrl1":"","ntceSpecDocUrl2":"","ntceSpecDocUrl3":"","ntceSpecDocUrl4":"","ntceSpecDocUrl5":"","ntceSpecDocUrl6":"","ntceSpecDocUrl7":"","ntceSpecDocUrl8":"","ntceSpecDocUrl9":"","ntceSpecDocUrl10":"","ntceSpecFileNm1":"","ntceSpecFileNm2":"","ntceSpecFileNm3":"","ntceSpecFileNm4":"","ntceSpecFileNm5":"","ntceSpecFileNm6":"","ntceSpecFileNm7":"","ntceSpecFileNm8":"","ntceSpecFileNm9":"","ntceSpecFileNm10":"","rbidPermsnYn":"","prdctClsfcLmtYn":"","mnfctYn":"","prearngPrceDcsnMthdNm":"","totPrdprcNum":"","drwtPrdprcNum":"","asignBdgtAmt":"36196160","presmptPrce":"","opengPlce":"국방전자조달시스템","bidNtceDtlUrl":"","bidNtceUrl":"","bidPrtcptFeePaymntYn":"","bidPrtcptFee":"","bidGrntymnyPaymntYn":"","crdtrNm":"","dtilPrdctClsfcNo":"","dtilPrdctClsfcNoNm":"","prdctSpecNm":"","prdctQty":"","prdctUnit":"","prdctUprc":"","dlvrTmlmtDt":"","dlvrDaynum":"","dlvryCndtnNm":"","purchsObjPrdctList":"","untyNtceNo":"","cmmnSpldmdMethdCd":"","cmmnSpldmdMethdNm":"","stdNtceDocUrl":"","brffcBidprcPermsnYn":"","dsgntCmptYn":"N","rsrvtnPrceReMkngMthdNm":"","arsltApplDocRcptMthdNm":"","arsltApplDocRcptDt":"","orderPlanUntyNo":"","sucsfbidLwltRate":"88","rgstDt":"2019-11-29 00:30:00","bfSpecRgstNo":"","infoBizYn":"","sucsfbidMthdCd":"","sucsfbidMthdNm":"최저가격제","chgDt":"","linkInsttNm":"방위사업청","dminsttOfclEmailAdrs":"","indstrytyLmtYn":"","d2bMngDcmtgOprtnDt":"","d2bMngDcmtgOprtnPlce":"","d2bMngRgnLmtYn":"Y","d2bMngPblctPlceNm":"","d2bMngCntrctKindNm":"","d2bMngCntrybndDedtBgnDate":"","d2bMngCntrybndDedtEndDate":"","d2bMngRsrvtnPrceBssOpenYn":"","d2bMngRrsrvtnPrceBssAplYn":"Y","d2bMngBssamt":"35486431","d2bMngRgstEvalExmpYn":"","d2bMngCompCorpRsrchObjYn":"","d2bMngOrgnlbdgtDedtBgnDate":"","d2bMngOrgnlbdgtDedtEndDate":"","d2bMngAssmntUplmtRt":"2","d2bMngAssmntLwstlmtRt":"-2","d2bMngStdIndstryClsfcCdList":"","d2bMngPrdctnAbltySbmsnClseDt":"","d2bMngProgrsSttusNm":"공개협상완료","d2bMngExetTyNm":"","d2bMngExetTyCd":"","d2bMngPrdlstCd":"","d2bMngItemNo":"***","d2bMngNgttnStleNm":"전자협상","d2bMngNgttnPlanDate":"2019-11-29","d2bMngDmndYear":"2019","d2bMngDcsnNo":"46458","chgNtceRsn":"","rbidOpengDt":"","VAT":"","indutyVAT":""},{"bidNtceNo":"LHG0046","bidNtceOrd":"1","reNtceYn":"","rgstTyNm":"연계기관 공고건","ntceKindNm":"긴급공고","intrbidYn":"N","bidNtceDt":"2022-09-07 00:00:00","refNo":"","bidNtceNm":"10월 부대조달 식자재 납품(불고기패티)","ntceInsttCd":"","ntceInsttNm":"","dminsttCd":"LHG","dminsttNm":"제1862부대","bidMethdNm":"전자입찰","cntrctCnclsMthdNm":"제한경쟁(총액제)","ntceInsttOfclNm":"김희수","ntceInsttOfclTelNo":"033-460-6505","ntceInsttOfclEmailAdrs":"","exctvNm":"","bidQlfctRgstDt":"2022-09-14 16:00:00","cmmnSpldmdAgrmntRcptdocMethd":"공고서참조","cmmnSpldmdAgrmntClseDt":"","cmmnSpldmdCorpRgnLmtYn":"N","bidBeginDt":"","bidClseDt":"2022-09-15 10:00:00","opengDt":"2022-09-15 10:30:00","ntceSpecDocUrl1":"","ntceSpecDocUrl2":"","ntceSpecDocUrl3":"","ntceSpecDocUrl4":"","ntceSpecDocUrl5":"","ntceSpecDocUrl6":"","ntceSpecDocUrl7":"","ntceSpecDocUrl8":"","ntceSpecDocUrl9":"","ntceSpecDocUrl10":"","ntceSpecFileNm1":"","ntceSpecFileNm2":"","ntceSpecFileNm3":"","ntceSpecFileNm4":"","ntceSpecFileNm5":"","ntceSpecFileNm6":"","ntceSpecFileNm7":"","ntceSpecFileNm8":"","ntceSpecFileNm9":"","ntceSpecFileNm10":"","rbidPermsnYn":"","prdctClsfcLmtYn":"","mnfctYn":"","prearngPrceDcsnMthdNm":"","totPrdprcNum":"","drwtPrdprcNum":"","asignBdgtAmt":"10740344","presmptPrce":"","opengPlce":"국방전자조달시스템","bidNtceDtlUrl":"","bidNtceUrl":"","bidPrtcptFeePaymntYn":"","bidPrtcptFee":"","bidGrntymnyPaymntYn":"","crdtrNm":"","dtilPrdctClsfcNo":"","dtilPrdctClsfcNoNm":"","prdctSpecNm":"","prdctQty":"","prdctUnit":"","prdctUprc":"","dlvrTmlmtDt":"","dlvrDaynum":"","dlvryCndtnNm":"","purchsObjPrdctList":"","untyNtceNo":"","cmmnSpldmdMethdCd":"","cmmnSpldmdMethdNm":"단독","stdNtceDocUrl":"","brffcBidprcPermsnYn":"","dsgntCmptYn":"N","rsrvtnPrceReMkngMthdNm":"","arsltApplDocRcptMthdNm":"","arsltApplDocRcptDt":"","orderPlanUntyNo":"","sucsfbidLwltRate":"","rgstDt":"2022-09-15 00:30:00","bfSpecRgstNo":"","infoBizYn":"","sucsfbidMthdCd":"","sucsfbidMthdNm":"적격심사제","chgDt":"","linkInsttNm":"방위사업청","dminsttOfclEmailAdrs":"","indstrytyLmtYn":"","d2bMngDcmtgOprtnDt":"","d2bMngDcmtgOprtnPlce":"","d2bMngRgnLmtYn":"N","d2bMngPblctPlceNm":"인터넷","d2bMngCntrctKindNm":"일반확정계약","d2bMngCntrybndDedtBgnDate":"","d2bMngCntrybndDedtEndDate":"","d2bMngRsrvtnPrceBssOpenYn":"Y","d2bMngRrsrvtnPrceBssAplYn":"Y","d2bMngBssamt":"10740344","d2bMngRgstEvalExmpYn":"Y","d2bMngCompCorpRsrchObjYn":"N","d2bMngOrgnlbdgtDedtBgnDate":"","d2bMngOrgnlbdgtDedtEndDate":"","d2bMngAssmntUplmtRt":"","d2bMngAssmntLwstlmtRt":"","d2bMngStdIndstryClsfcCdList":"","d2bMngPrdctnAbltySbmsnClseDt":"","d2bMngProgrsSttusNm":"","d2bMngExetTyNm":"제조/구매 ","d2bMngExetTyCd":"N","d2bMngPrdlstCd":"","d2bMngItemNo":"","d2bMngNgttnStleNm":"","d2bMngNgttnPlanDate":"","d2bMngDmndYear":"2022","d2bMngDcsnNo":"37288","chgNtceRsn":"","rbidOpengDt":"","VAT":"","indutyVAT":""},{"bidNtceNo":"LHG0046","bidNtceOrd":"2","reNtceYn":"","rgstTyNm":"연계기관 공고건","ntceKindNm":"재공고","intrbidYn":"N","bidNtceDt":"2022-09-15 00:00:00","refNo":"","bidNtceNm":"10월 부대조달 식자재 납품(불고기패티)","ntceInsttCd":"","ntceInsttNm":"","dminsttCd":"LHG","dminsttNm":"제1862부대","bidMethdNm":"전자입찰","cntrctCnclsMthdNm":"제한경쟁(총액제)","ntceInsttOfclNm":"김희수","ntceInsttOfclTelNo":"033-460-6505","ntceInsttOfclEmailAdrs":"","exctvNm":"","bidQlfctRgstDt":"2022-09-22 16:00:00","cmmnSpldmdAgrmntRcptdocMethd":"공고서참조","cmmnSpldmdAgrmntClseDt":"","cmmnSpldmdCorpRgnLmtYn":"N","bidBeginDt":"","bidClseDt":"2022-09-23 10:00:00","opengDt":"2022-09-23 10:30:00","ntceSpecDocUrl1":"","ntceSpecDocUrl2":"","ntceSpecDocUrl3":"","ntceSpecDocUrl4":"","ntceSpecDocUrl5":"","ntceSpecDocUrl6":"","ntceSpecDocUrl7":"","ntceSpecDocUrl8":"","ntceSpecDocUrl9":"","ntceSpecDocUrl10":"","ntceSpecFileNm1":"","ntceSpecFileNm2":"","ntceSpecFileNm3":"","ntceSpecFileNm4":"","ntceSpecFileNm5":"","ntceSpecFileNm6":"","ntceSpecFileNm7":"","ntceSpecFileNm8":"","ntceSpecFileNm9":"","ntceSpecFileNm10":"","rbidPermsnYn":"","prdctClsfcLmtYn":"","mnfctYn":"","prearngPrceDcsnMthdNm":"","totPrdprcNum":"","drwtPrdprcNum":"","asignBdgtAmt":"10740344","presmptPrce":"","opengPlce":"국방전자조달시스템","bidNtceDtlUrl":"","bidNtceUrl":"","bidPrtcptFeePaymntYn":"","bidPrtcptFee":"","bidGrntymnyPaymntYn":"","crdtrNm":"","dtilPrdctClsfcNo":"","dtilPrdctClsfcNoNm":"","prdctSpecNm":"","prdctQty":"","prdctUnit":"","prdctUprc":"","dlvrTmlmtDt":"","dlvrDaynum":"","dlvryCndtnNm":"","purchsObjPrdctList":"","untyNtceNo":"","cmmnSpldmdMethdCd":"","cmmnSpldmdMethdNm":"단독","stdNtceDocUrl":"","brffcBidprcPermsnYn":"","dsgntCmptYn":"N","rsrvtnPrceReMkngMthdNm":"","arsltApplDocRcptMthdNm":"","arsltApplDocRcptDt":"","orderPlanUntyNo":"","sucsfbidLwltRate":"","rgstDt":"2022-09-23 00:30:00","bfSpecRgstNo":"","infoBizYn":"","sucsfbidMthdCd":"","sucsfbidMthdNm":"적격심사제","chgDt":"","linkInsttNm":"방위사업청","dminsttOfclEmailAdrs":"","indstrytyLmtYn":"","d2bMngDcmtgOprtnDt":"","d2bMngDcmtgOprtnPlce":"","d2bMngRgnLmtYn":"N","d2bMngPblctPlceNm":"인터넷","d2bMngCntrctKindNm":"일반확정계약","d2bMngCntrybndDedtBgnDate":"","d2bMngCntrybndDedtEndDate":"","d2bMngRsrvtnPrceBssOpenYn":"Y","d2bMngRrsrvtnPrceBssAplYn":"Y","d2bMngBssamt":"10740344","d2bMngRgstEvalExmpYn":"Y","d2bMngCompCorpRsrchObjYn":"N","d2bMngOrgnlbdgtDedtBgnDate":"","d2bMngOrgnlbdgtDedtEndDate":"","d2bMngAssmntUplmtRt":"","d2bMngAssmntLwstlmtRt":"","d2bMngStdIndstryClsfcCdList":"","d2bMngPrdctnAbltySbmsnClseDt":"","d2bMngProgrsSttusNm":"","d2bMngExetTyNm":"제조/구매 ","d2bMngExetTyCd":"N","d2bMngPrdlstCd":"","d2bMngItemNo":"","d2bMngNgttnStleNm":"","d2bMngNgttnPlanDate":"","d2bMngDmndYear":"2022","d2bMngDcsnNo":"37288","chgNtceRsn":"","rbidOpengDt":"","VAT":"","indutyVAT":""}],"numOfRows":200,"pageNo":1,"totalCount":4}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}