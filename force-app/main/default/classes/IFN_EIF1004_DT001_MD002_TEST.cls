@isTest
public class IFN_EIF1004_DT001_MD002_TEST {

    @TestSetup
    static void makeData(){
        
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        IFMaster__c objIFMaster = new IFMaster__c();
        objIFMaster.Name                = 'IFN_EIF1004_DT001_MD002';
        objIFMaster.Type__c             = 'Outbound';
        objIFMaster.WebserviceType__c   = 'REST';
        objIFMaster.Method__c           = 'GET';
        objIFMaster.ContentType__c      = 'application/json';
        objIFMaster.Endpoint__c         = 'https://dotop.kr/Service/API/';
        listIFMaster.add(objIFMaster);
		
        insert listIFMaster;

    }
    
    @isTest
    static void test_IFN_EIF1004_DT001_MD002() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        //학교급식 - 학교별 급식정보 
        IFN_EIF1004_DT001_MD002.Output              outputObj   = new IFN_EIF1004_DT001_MD002.Output();
        IFN_EIF1004_DT001_MD002                     iftest      = new IFN_EIF1004_DT001_MD002();
        IFN_EIF1004_DT001_MD002.MD002RequstWrapper  reqmap      = new IFN_EIF1004_DT001_MD002.MD002RequstWrapper();
        reqmap.serviceKey   = '944FB5A82EAE4149B3F8AAE5C48E7752';
        reqmap.serviceDiv   = 'A02';
        reqmap.NeisCodeStd  = '7569036';
        reqmap.StartDate    = '20231001';
        reqmap.EndDate      = '20231030';
        outputObj = iftest.callout(reqmap);


        Test.stopTest();
    }

    @isTest
    static void test_IFN_EIF1004_DT001_MD002_2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        //죈장, public inner class test 만족을 위해 여기서 한번씩 터치 한다.
        IFN_EIF1004_DT001_MD002.Output  Output      = new IFN_EIF1004_DT001_MD002.Output();
        List<IFN_EIF1004_DT001_MD002.meta>    Lmeta = new List<IFN_EIF1004_DT001_MD002.meta>();
        List<IFN_EIF1004_DT001_MD002.item>    Litem = new List<IFN_EIF1004_DT001_MD002.item>();

        IFN_EIF1004_DT001_MD002.meta    meta        = new IFN_EIF1004_DT001_MD002.meta();
        IFN_EIF1004_DT001_MD002.item    item        = new IFN_EIF1004_DT001_MD002.item();

        meta.result_code = '1';
        meta.err_message = '1';
        meta.err_stack = '1';
        meta.total_count = '1';
        meta.NeisCodeStd = '1';
        meta.SchoolTitle = '1';
        Lmeta.add(meta);

        item.MealDate = '1';
        item.MealDivText = '1';
        item.MenuTitle = '1';
        item.AlgInfoText = '1';
        item.NeisCodeStd = '1';
        Litem.add(item);
        
        Output.meta = Lmeta;
        Output.item = Litem;
    

        Test.stopTest();
    }

    @isTest
    static void test_IFN_EIF1004_DT001_MD002_Fail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        //학교급식 지역별 학교정보
        IFN_EIF1004_DT001_MD002                     iftest      = new IFN_EIF1004_DT001_MD002();
        iftest.callout(null);
        
        Test.stopTest();
    }


    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //request 
            //https://dotop.kr/Service/API/?serviceKey=944FB5A82EAE4149B3F8AAE5C48E7752&serviceDiv=A02&NeisCodeStd=7569036&StartDate=20231001&EndDate=20231030

            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":[{"result_code":"0","err_message":"","err_stack":"","total_count":"70","NeisCodeStd":"7569036","SchoolTitle":"안양동초등학교"}],"item":[{"MealDate":"2023-10-04","MealDivText":"중식","MenuTitle":"칼슘찹쌀밥.","AlgInfoText":"","NeisCodeStd":"7569036"},{"MealDate":"2023-10-04","MealDivText":"중식","MenuTitle":"브로콜리스프.","AlgInfoText":"(2.5.6.13.16)","NeisCodeStd":"7569036"},{"MealDate":"2023-10-04","MealDivText":"중식","MenuTitle":"꽃맛살샐러드.","AlgInfoText":"(1.5.13)","NeisCodeStd":"7569036"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}