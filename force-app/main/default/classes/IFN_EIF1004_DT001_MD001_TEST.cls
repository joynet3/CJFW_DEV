@isTest
public class IFN_EIF1004_DT001_MD001_TEST {

    @TestSetup
    static void makeData(){
        
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        IFMaster__c objIFMaster = new IFMaster__c();
        objIFMaster.Name                = 'IFN_EIF1004_DT001_MD001';
        objIFMaster.Type__c             = 'Outbound';
        objIFMaster.WebserviceType__c   = 'REST';
        objIFMaster.Method__c           = 'GET';
        objIFMaster.ContentType__c      = 'application/json';
        objIFMaster.Endpoint__c         = 'https://dotop.kr/Service/API/';
        listIFMaster.add(objIFMaster);
		
        insert listIFMaster;

    }
    
    @isTest
    static void test_IFN_EIF1004_DT001_MD001() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        //학교급식 지역별 학교정보
        IFN_EIF1004_DT001_MD001.Output              outputObj   = new IFN_EIF1004_DT001_MD001.Output();
        IFN_EIF1004_DT001_MD001                     iftest      = new IFN_EIF1004_DT001_MD001();
        IFN_EIF1004_DT001_MD001.MD001RequstWrapper  reqmap      = new IFN_EIF1004_DT001_MD001.MD001RequstWrapper();
        reqmap.serviceKey   = '944FB5A82EAE4149B3F8AAE5C48E7752';
        reqmap.serviceDiv   = 'A01';
        reqmap.Address1     = '서울';
        outputObj = iftest.callout(reqmap);
        
        System.debug('outputObj:' + outputObj);

        Test.stopTest();
    }

    @isTest
    static void test_IFN_EIF1004_DT001_MD001_2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        //죈장, public inner class test 만족을 위해 여기서 한번씩 터치 한다.
        IFN_EIF1004_DT001_MD001.Output  Output      = new IFN_EIF1004_DT001_MD001.Output();
        List<IFN_EIF1004_DT001_MD001.meta>    Lmeta = new List<IFN_EIF1004_DT001_MD001.meta>();
        List<IFN_EIF1004_DT001_MD001.item>    Litem = new List<IFN_EIF1004_DT001_MD001.item>();

        IFN_EIF1004_DT001_MD001.meta    meta        = new IFN_EIF1004_DT001_MD001.meta();
        IFN_EIF1004_DT001_MD001.item    item        = new IFN_EIF1004_DT001_MD001.item();

        meta.result_code = '1';
        meta.err_message = '1';
        meta.err_stack = '1';
        meta.total_count = '1';
        Lmeta.add(meta);

        item.NeisCodeStd = '1';
        item.SchoolTitle = '1';
        item.Tel = '1';
        item.Fax = '1';
        item.CountRoom = '1';
        item.CountTeacher = '1';
        item.CountStudent = '1';
        item.Address1 = '1';
        item.Address2 = '1';
        Litem.add(item);
        
        Output.meta = Lmeta;
        Output.item = Litem;
    

        Test.stopTest();
    }

    @isTest
    static void test_IFN_EIF1004_DT001_MD001_Fail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        //학교급식 지역별 학교정보
        IFN_EIF1004_DT001_MD001                     iftest      = new IFN_EIF1004_DT001_MD001();
        iftest.callout(null);
        
        Test.stopTest();
    }


    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //request 
            //https://dotop.kr/Service/API/?serviceKey=944FB5A82EAE4149B3F8AAE5C48E7752&serviceDiv=A01&Address1=서울

            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":[{"result_code":"0","err_message":"","err_stack":"","total_count":"156"}],"item":[{"NeisCodeStd":"7530077","SchoolTitle":"불곡고등학교","Tel":"0317102815","Fax":"0317123726","CountRoom":40,"CountTeacher":99,"CountStudent":1214,"Address1":"경기","Address2":"성남시"},{"NeisCodeStd":"7531114","SchoolTitle":"분당경영고등학교","Tel":"03180231401","Fax":"03180231407","CountRoom":37,"CountTeacher":93,"CountStudent":1014,"Address1":"경기","Address2":"성남시"},{"NeisCodeStd":"7530136","SchoolTitle":"한솔고등학교","Tel":"0317144381","Fax":"0317144384","CountRoom":38,"CountTeacher":89,"CountStudent":1132,"Address1":"경기","Address2":"성남시"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}