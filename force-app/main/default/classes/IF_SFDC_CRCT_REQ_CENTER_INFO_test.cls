/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 01-10-2023
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
@isTest
public class IF_SFDC_CRCT_REQ_CENTER_INFO_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_CRCT_REQ_CENTER_INFO'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'GET';
            objIFMaster.ContentType__c = 'application/xml';
            objIFMaster.Endpoint__c = 'http://api.childcare.go.kr/mediate/rest/cpmsapi030/cpmsapi030/request';
            
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;

        // SidoCode_Set__mdt mdt = new SidoCode_Set__mdt();
        // mdt.DeveloperName = 'a11500';
        // mdt.MasterLabel = '서울특별시 강서구';
        // mdt.Label = '서울특별시 강서구';
        // mdt.QualifiedApiName = 'a11500';
        // mdt.City__c = '서울특별시';
        // mdt.isActive__c = true;
        // mdt.SidoCode__c = '11500';
        // mdt.SiGunGuName__c = '강서구';

        // insert mdt;

    }

    // @isTest
    // static void testIF_SFDC_CRCT_REQ_CENTER_INFO_ba() {
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    //     IF_SFDC_CRCT_REQ_CENTER_INFO_ba b = new IF_SFDC_CRCT_REQ_CENTER_INFO_ba(false,null);
    //     Database.executeBatch(b);
    //     Test.stopTest();
    // }

    @isTest
    static void testIF_SFDC_CRCT_REQ_CENTER_INFO_sc() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IF_SFDC_CRCT_REQ_CENTER_INFO_sc scd = new IF_SFDC_CRCT_REQ_CENTER_INFO_sc();
        scd.execute(null);

        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            /*
            System.assertEquals('http://api.childcare.go.kr/mediate/rest/cpmsapi030/cpmsapi030/request?key=110b97ddc07c433a8af0f727b0e0b1f8&arcode=11500&stcode=', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            */
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<response><item><sidoname>서울특별시</sidoname><sigunname>강서구</sigunname><stcode>11500000038</stcode><crname>화동교회방과후어린이집</crname><crtypename>법인·단체등</crtypename><crstatusname>정상</crstatusname><zipcode>07783</zipcode><craddr>서울특별시 강서구 곰달래로 200 (화곡동)</craddr><crtelno>070-7169-9910</crtelno><crfaxno>02-2608-3274</crfaxno><crhome/><nrtrroomcnt>5</nrtrroomcnt><nrtrroomsize>300</nrtrroomsize><plgrdco>1</plgrdco><cctvinstlcnt>12</cctvinstlcnt><chcrtescnt>7</chcrtescnt><crcapat>60</crcapat><crchcnt>48</crchcnt><la>37.53148578</la><lo>126.8553736</lo><crcargbname>미운영</crcargbname><crcnfmdt>2006-04-10</crcnfmdt><crpausebegindt/><crpauseenddt/><crabldt/><datastdrdt>2022-10-05</datastdrdt><crspec>방과후 전담</crspec><CLASS_CNT_00>0</CLASS_CNT_00><CLASS_CNT_01>0</CLASS_CNT_01><CLASS_CNT_02>0</CLASS_CNT_02><CLASS_CNT_03>0</CLASS_CNT_03><CLASS_CNT_04>0</CLASS_CNT_04><CLASS_CNT_05>0</CLASS_CNT_05><CLASS_CNT_M2>0</CLASS_CNT_M2><CLASS_CNT_M5>0</CLASS_CNT_M5><CLASS_CNT_SP>0</CLASS_CNT_SP><CLASS_CNT_TOT>0</CLASS_CNT_TOT><CHILD_CNT_00>0</CHILD_CNT_00><CHILD_CNT_01>0</CHILD_CNT_01><CHILD_CNT_02>0</CHILD_CNT_02><CHILD_CNT_03>0</CHILD_CNT_03><CHILD_CNT_04>0</CHILD_CNT_04><CHILD_CNT_05>0</CHILD_CNT_05><CHILD_CNT_M2>0</CHILD_CNT_M2><CHILD_CNT_M5>0</CHILD_CNT_M5><CHILD_CNT_SP>0</CHILD_CNT_SP><CHILD_CNT_TOT>0</CHILD_CNT_TOT><EM_CNT_0Y>0</EM_CNT_0Y><EM_CNT_1Y>0</EM_CNT_1Y><EM_CNT_2Y>0</EM_CNT_2Y><EM_CNT_4Y>0</EM_CNT_4Y><EM_CNT_6Y>100</EM_CNT_6Y><EM_CNT_A1>1</EM_CNT_A1><EM_CNT_A2>4</EM_CNT_A2><EM_CNT_A3>0</EM_CNT_A3><EM_CNT_A4>0</EM_CNT_A4><EM_CNT_A5>0</EM_CNT_A5><EM_CNT_A6>0</EM_CNT_A6><EM_CNT_A10>0</EM_CNT_A10><EM_CNT_A7>0</EM_CNT_A7><EM_CNT_A8>0</EM_CNT_A8><EM_CNT_TOT>7</EM_CNT_TOT><CRREPNAME/></item><item><sidoname>서울특별시</sidoname><sigunname>강서구</sigunname><stcode>11500005526</stcode><crname>화동교회방과후어린이집</crname><crtypename>법인·단체등</crtypename><crstatusname>정상</crstatusname><zipcode>07783</zipcode><craddr>서울특별시 강서구 곰달래로 200 (화곡동)</craddr><crtelno>070-7169-9910</crtelno><crfaxno>02-2608-3274</crfaxno><crhome/><nrtrroomcnt>5</nrtrroomcnt><nrtrroomsize>300</nrtrroomsize><plgrdco>1</plgrdco><cctvinstlcnt>12</cctvinstlcnt><chcrtescnt>7</chcrtescnt><crcapat>60</crcapat><crchcnt>48</crchcnt><la>37.53148578</la><lo>126.8553736</lo><crcargbname>미운영</crcargbname><crcnfmdt>2006-04-10</crcnfmdt><crpausebegindt/><crpauseenddt/><crabldt/><datastdrdt>2022-10-05</datastdrdt><crspec>방과후 전담</crspec><CLASS_CNT_00>0</CLASS_CNT_00><CLASS_CNT_01>0</CLASS_CNT_01><CLASS_CNT_02>0</CLASS_CNT_02><CLASS_CNT_03>0</CLASS_CNT_03><CLASS_CNT_04>0</CLASS_CNT_04><CLASS_CNT_05>0</CLASS_CNT_05><CLASS_CNT_M2>0</CLASS_CNT_M2><CLASS_CNT_M5>0</CLASS_CNT_M5><CLASS_CNT_SP>0</CLASS_CNT_SP><CLASS_CNT_TOT>0</CLASS_CNT_TOT><CHILD_CNT_00>0</CHILD_CNT_00><CHILD_CNT_01>0</CHILD_CNT_01><CHILD_CNT_02>0</CHILD_CNT_02><CHILD_CNT_03>0</CHILD_CNT_03><CHILD_CNT_04>0</CHILD_CNT_04><CHILD_CNT_05>0</CHILD_CNT_05><CHILD_CNT_M2>0</CHILD_CNT_M2><CHILD_CNT_M5>0</CHILD_CNT_M5><CHILD_CNT_SP>0</CHILD_CNT_SP><CHILD_CNT_TOT>0</CHILD_CNT_TOT><EM_CNT_0Y>0</EM_CNT_0Y><EM_CNT_1Y>0</EM_CNT_1Y><EM_CNT_2Y>0</EM_CNT_2Y><EM_CNT_4Y>0</EM_CNT_4Y><EM_CNT_6Y>100</EM_CNT_6Y><EM_CNT_A1>1</EM_CNT_A1><EM_CNT_A2>4</EM_CNT_A2><EM_CNT_A3>0</EM_CNT_A3><EM_CNT_A4>0</EM_CNT_A4><EM_CNT_A5>0</EM_CNT_A5><EM_CNT_A6>0</EM_CNT_A6><EM_CNT_A10>0</EM_CNT_A10><EM_CNT_A7>0</EM_CNT_A7><EM_CNT_A8>0</EM_CNT_A8><EM_CNT_TOT>7</EM_CNT_TOT><CRREPNAME/></item></response>');
            res.setStatusCode(200);
            return res;
        }
    }
}