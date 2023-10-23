/**
 * @Class : IF_SFDC_KIND_REQ_test.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.10.19
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.19 | sancho         | 최초작성
 * */
@isTest
public with sharing class IF_SFDC_KIND_REQ_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_KIND_REQ_BASE_INFO', 'IF_SFDC_KIND_REQ_SCHOOL_MEAL'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'GET';
            objIFMaster.ContentType__c = 'application/json';
            if(str.equals('IF_SFDC_KIND_REQ_BASE_INFO')){
                objIFMaster.Endpoint__c = 'https://e-childschoolinfo.moe.go.kr/api/notice/basicInfo2.do';
            }else{
                objIFMaster.Endpoint__c = 'https://e-childschoolinfo.moe.go.kr/api/notice/schoolMeal.do';
            }
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;
    }

    @isTest
    static void testIF_SFDC_CRCT_REQ_CENTER_INFO_sc() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        IF_SFDC_KIND_REQ_BASE_INFO a = new IF_SFDC_KIND_REQ_BASE_INFO(false,null);
        Database.executeBatch(a,1);

        IF_SFDC_KIND_REQ_SCHOOL_MEAL b = new IF_SFDC_KIND_REQ_SCHOOL_MEAL(false,null);
        Database.executeBatch(b,1);

        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('<response><item><sidoname>서울특별시</sidoname><sigunname>강서구</sigunname><stcode>11500000038</stcode><crname>화동교회방과후어린이집</crname><crtypename>법인·단체등</crtypename><crstatusname>정상</crstatusname><zipcode>07783</zipcode><craddr>서울특별시 강서구 곰달래로 200 (화곡동)</craddr><crtelno>070-7169-9910</crtelno><crfaxno>02-2608-3274</crfaxno><crhome/><nrtrroomcnt>5</nrtrroomcnt><nrtrroomsize>300</nrtrroomsize><plgrdco>1</plgrdco><cctvinstlcnt>12</cctvinstlcnt><chcrtescnt>7</chcrtescnt><crcapat>60</crcapat><crchcnt>48</crchcnt><la>37.53148578</la><lo>126.8553736</lo><crcargbname>미운영</crcargbname><crcnfmdt>2006-04-10</crcnfmdt><crpausebegindt/><crpauseenddt/><crabldt/><datastdrdt>2022-10-05</datastdrdt><crspec>방과후 전담</crspec><CLASS_CNT_00>0</CLASS_CNT_00><CLASS_CNT_01>0</CLASS_CNT_01><CLASS_CNT_02>0</CLASS_CNT_02><CLASS_CNT_03>0</CLASS_CNT_03><CLASS_CNT_04>0</CLASS_CNT_04><CLASS_CNT_05>0</CLASS_CNT_05><CLASS_CNT_M2>0</CLASS_CNT_M2><CLASS_CNT_M5>0</CLASS_CNT_M5><CLASS_CNT_SP>0</CLASS_CNT_SP><CLASS_CNT_TOT>0</CLASS_CNT_TOT><CHILD_CNT_00>0</CHILD_CNT_00><CHILD_CNT_01>0</CHILD_CNT_01><CHILD_CNT_02>0</CHILD_CNT_02><CHILD_CNT_03>0</CHILD_CNT_03><CHILD_CNT_04>0</CHILD_CNT_04><CHILD_CNT_05>0</CHILD_CNT_05><CHILD_CNT_M2>0</CHILD_CNT_M2><CHILD_CNT_M5>0</CHILD_CNT_M5><CHILD_CNT_SP>0</CHILD_CNT_SP><CHILD_CNT_TOT>0</CHILD_CNT_TOT><EM_CNT_0Y>0</EM_CNT_0Y><EM_CNT_1Y>0</EM_CNT_1Y><EM_CNT_2Y>0</EM_CNT_2Y><EM_CNT_4Y>0</EM_CNT_4Y><EM_CNT_6Y>100</EM_CNT_6Y><EM_CNT_A1>1</EM_CNT_A1><EM_CNT_A2>4</EM_CNT_A2><EM_CNT_A3>0</EM_CNT_A3><EM_CNT_A4>0</EM_CNT_A4><EM_CNT_A5>0</EM_CNT_A5><EM_CNT_A6>0</EM_CNT_A6><EM_CNT_A10>0</EM_CNT_A10><EM_CNT_A7>0</EM_CNT_A7><EM_CNT_A8>0</EM_CNT_A8><EM_CNT_TOT>7</EM_CNT_TOT><CRREPNAME/></item><item><sidoname>서울특별시</sidoname><sigunname>강서구</sigunname><stcode>11500005526</stcode><crname>화동교회방과후어린이집</crname><crtypename>법인·단체등</crtypename><crstatusname>정상</crstatusname><zipcode>07783</zipcode><craddr>서울특별시 강서구 곰달래로 200 (화곡동)</craddr><crtelno>070-7169-9910</crtelno><crfaxno>02-2608-3274</crfaxno><crhome/><nrtrroomcnt>5</nrtrroomcnt><nrtrroomsize>300</nrtrroomsize><plgrdco>1</plgrdco><cctvinstlcnt>12</cctvinstlcnt><chcrtescnt>7</chcrtescnt><crcapat>60</crcapat><crchcnt>48</crchcnt><la>37.53148578</la><lo>126.8553736</lo><crcargbname>미운영</crcargbname><crcnfmdt>2006-04-10</crcnfmdt><crpausebegindt/><crpauseenddt/><crabldt/><datastdrdt>2022-10-05</datastdrdt><crspec>방과후 전담</crspec><CLASS_CNT_00>0</CLASS_CNT_00><CLASS_CNT_01>0</CLASS_CNT_01><CLASS_CNT_02>0</CLASS_CNT_02><CLASS_CNT_03>0</CLASS_CNT_03><CLASS_CNT_04>0</CLASS_CNT_04><CLASS_CNT_05>0</CLASS_CNT_05><CLASS_CNT_M2>0</CLASS_CNT_M2><CLASS_CNT_M5>0</CLASS_CNT_M5><CLASS_CNT_SP>0</CLASS_CNT_SP><CLASS_CNT_TOT>0</CLASS_CNT_TOT><CHILD_CNT_00>0</CHILD_CNT_00><CHILD_CNT_01>0</CHILD_CNT_01><CHILD_CNT_02>0</CHILD_CNT_02><CHILD_CNT_03>0</CHILD_CNT_03><CHILD_CNT_04>0</CHILD_CNT_04><CHILD_CNT_05>0</CHILD_CNT_05><CHILD_CNT_M2>0</CHILD_CNT_M2><CHILD_CNT_M5>0</CHILD_CNT_M5><CHILD_CNT_SP>0</CHILD_CNT_SP><CHILD_CNT_TOT>0</CHILD_CNT_TOT><EM_CNT_0Y>0</EM_CNT_0Y><EM_CNT_1Y>0</EM_CNT_1Y><EM_CNT_2Y>0</EM_CNT_2Y><EM_CNT_4Y>0</EM_CNT_4Y><EM_CNT_6Y>100</EM_CNT_6Y><EM_CNT_A1>1</EM_CNT_A1><EM_CNT_A2>4</EM_CNT_A2><EM_CNT_A3>0</EM_CNT_A3><EM_CNT_A4>0</EM_CNT_A4><EM_CNT_A5>0</EM_CNT_A5><EM_CNT_A6>0</EM_CNT_A6><EM_CNT_A10>0</EM_CNT_A10><EM_CNT_A7>0</EM_CNT_A7><EM_CNT_A8>0</EM_CNT_A8><EM_CNT_TOT>7</EM_CNT_TOT><CRREPNAME/></item></response>');
            res.setBody('{"status":"SUCCESS","kinderInfo":['
                        + '{"key":"1","kindercode":"0c4bc461-9f36-4d28-94e3-3dfb9c6cd4e3","officeedu":"서울특별시교육청","subofficeedu":"북부교육지원청","kindername":"서울상계초등학교병설유치원","establish":"공립(병설)","edate":"20170301","odate":"20170302","addr":"서울특별시 노원구 상계로9길 39","telno":"02-933-6888","hpaddr":"https://sanggye.sen.es.kr","opertime":"07시00분~19시30분","clcnt3":null,"clcnt4":"1","clcnt5":"1","mixclcnt":"0","shclcnt":null,"ppcnt3":null,"ppcnt4":"4","ppcnt5":"8","mixppcnt":"0","shppcnt":null,"rppnname":"양인화","ldgrname":"양인화","pbnttmng":"20231"}'
                        //+ ',{"key":"1","kindercode":"0c4bc461-9f36-4d28-94e3-3dfb9c6cd4e3","officeedu":"서울특별시교육청","subofficeedu":"북부교육지원청","kindername":"서울상계초등학교병설유치원","establish":"공립(병설)","mlsr_oprn_way_tp_cd":"직영(학교급식)","cons_ents_nm":null,"al_kpcnt":null,"mlsr_kpcnt":"12","ntrt_tchr_agmt_yn":"Y","snge_agmt_ntrt_thcnt":"0","cprt_agmt_ntrt_thcnt":"1","ckcnt":"0","cmcnt":"0","mas_mspl_dclr_yn":"NA","pbnttmng":"20231","page":null}'
                        + ']}'
                        );

            res.setStatusCode(200);
            return res;
        }
    }
}