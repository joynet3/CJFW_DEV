/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 02-04-2023
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
@isTest
public with sharing class IF_SFDC_LOCAL_DATA_INFO_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_LOCAL_DATA_INFO'};

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

    @isTest
    static void testIF_SFDC_LOCAL_DATA_INFO() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IF_SFDC_LOCAL_DATA_INFO_sc sc = new IF_SFDC_LOCAL_DATA_INFO_sc();
        IF_SFDC_LOCAL_DATA_INFO_RESTAURANT_sc sc2= new IF_SFDC_LOCAL_DATA_INFO_RESTAURANT_sc();
        IF_SFDC_LOCAL_DATA_INFO_FOOD_sc sc3= new IF_SFDC_LOCAL_DATA_INFO_FOOD_sc();
        sc3.execute(null);
        sc2.execute(null);
        sc.execute(null);

        List<String> upsertFailList = new List<String>();
        IF_SFDC_LOCAL_DATA_INFO_MEDI_ba b = new IF_SFDC_LOCAL_DATA_INFO_MEDI_ba(upsertFailList);
        Database.executeBatch(b,1);
        
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result":{"header":{"columns":[{"rowNum":"번호","opnSfTeamCode":"개방자치단체코드","mgtNo":"관리번호","opnSvcId":"개방서비스ID","updateGbn":"데이터갱신구분","updateDt":"데이터갱신일자","opnSvcNm":"개방서비스명","bplcNm":"사업장명","sitePostNo":"지번우편번호","siteWhlAddr":"지번주소","rdnPostNo":"도로명우편번호","rdnWhlAddr":"도로명주소","siteArea":"소재지면적","apvPermYmd":"인허가일자","apvCancelYmd":"인허가취소일자","dcbYmd":"폐업일자","clgStdt":"휴업시작일자","clgEnddt":"휴업종료일자","ropnYmd":"재개업일자","trdStateGbn":"영업상태코드","trdStateNm":"영업상태명","dtlStateGbn":"상세영업상태코드","dtlStateNm":"상세영업상태명","x":"좌표정보(X)","y":"좌표정보(Y)","lastModTs":"최종수정일자","uptaeNm":"업태구분명","siteTel":"전화번호","bdngOwnSeNm":"건물소유구분명","fctyOwkEpCnt":"공장사무직직원수","fctyPdtJobEpCnt":"공장생산직직원수","fctySilJobEpCnt":"공장판매직직원수","rgtMbdSno":"권리주체일련번호","wtrSplyFacilSeNm":"급수시설구분명","manEipCnt":"남성종사자수","multUsnUpsoYn":"다중이용업소여부","lvSeNm":"등급구분명","isreAm":"보증액","hoffEpCnt":"본사직원수","equSiz":"설비규격","facilTotScp":"시설총규모","wmEipCnt":"여성종사자수","trdpJubnSeNm":"영업장주변구분명","monAm":"월세액","sntUptaeNm":"위생업태명","jtUpsoMainEdf":"전통업소주된음식","jtUpsoAsgnNo":"전통업소지정번호","totEpNum":"총직원수","lindPrcbGbnNm":"축산물가공업구분명","lindJobGbnNm":"축산업무구분명","lindSeqNo":"축산일련번호","homepage":"홈페이지"}],"paging":{"pageIndex":1,"totalCount":1,"pageSize":200},"process":{"code":"00","message":"정상 처리되었습니다."}},"body":{"rows":[{"row":[{"rowNum":2,"opnSfTeamCode":4290000,"mgtNo":"4290000-120-2023-00001","opnSvcId":"07_22_12_P","updateGbn":"I","updateDt":"2023-02-04 00:41:21","opnSvcNm":"위탁급식영업","bplcNm":"본우리집밥 강원랜드그랜드호텔점","sitePostNo":"233-901","siteWhlAddr":"강원도 정선군 사북읍 사북리 424 강원랜드 ","rdnPostNo":26154,"rdnWhlAddr":"강원도 정선군 사북읍 하이원길 265, 강원랜드 3층","siteArea":1123.97,"apvPermYmd":"2023-02-02","apvCancelYmd":"2023-02-02","dcbYmd":"2023-02-02","clgStdt":"2023-02-02","clgEnddt":"2023-02-02","ropnYmd":"2023-02-02","trdStateGbn":"01","trdStateNm":"영업정상","dtlStateGbn":"01","dtlStateNm":"영업","x":"361518.513221455    ","y":"413851.267613498    ","lastModTs":"2023-02-02 16:24:02","uptaeNm":"위탁급식영업","siteTel":"0230192273","bdngOwnSeNm":"","fctyOwkEpCnt":0,"fctyPdtJobEpCnt":0,"fctySilJobEpCnt":0,"wtrSplyFacilSeNm":"","manEipCnt":0,"multUsnUpsoYn":"N","lvSeNm":"","isreAm":0,"hoffEpCnt":0,"facilTotScp":1123.97,"wmEipCnt":0,"trdpJubnSeNm":"","monAm":0,"sntUptaeNm":"위탁급식영업","jtUpsoMainEdf":"","jtUpsoAsgnNo":"","totEpNum":0,"homepage":""}]}]}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}