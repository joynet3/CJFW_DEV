/**
 * @Class : IFN_EIF1001_Callout_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.08.31
 * @Version : 1.0
 * @Description : 외부 시스템 인터페이스 callout
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.31 | 조일근          | 최초작성
 * */
@isTest
public class IFN_EIF1001_Callout_TEST {
    @TestSetup
    static void setup(){

        IFN_TestDataFactory.createIfPrograms();

    }

    @isTest
    static void testIFN_EIF1001_EC002_MD003Succ()
    {

        Test.startTest();

        IFN_EIF1001_EC002_MD003.EC002Response resData = new IFN_EIF1001_EC002_MD003.EC002Response();
        IFN_EIF1001_EC002_MD003.EC002SuccessData resSucc = new IFN_EIF1001_EC002_MD003.EC002SuccessData();
        resSucc.image_key = '1';
        resSucc.name = '1';
        resSucc.request_date = '2022-03-01';
        resData.data = resSucc;
        String resbody = JSON.serialize(resData);

        Test.setMock(HttpCalloutMock.class, new IF_HttpCalloutMock(resbody,200)); 
        IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout('IFN_EIF1001_EC002_MD003','Rseal');

        IFN_EIF1001_EC002_MD003.EC002RequstWrapper reqparam = new IFN_EIF1001_EC002_MD003.EC002RequstWrapper();
        reqparam.image = '123123';
        callout.getResponse('IFN_EIF1001_EC002_MD003', reqparam);
        
        Test.stopTest();
    }

    @isTest
    static void testIFN_EIF1001_EC002_MD003Err()
    {


        Test.startTest();

        IFN_EIF1001_EC002_MD003.EC002ErrorData errData = new IFN_EIF1001_EC002_MD003.EC002ErrorData();
        errData.errcode = '-1';
        errData.errmsg = 'err';
        String resbody = JSON.serialize(errData);

        Test.setMock(HttpCalloutMock.class, new IF_HttpCalloutMock(resbody,500)); 
        IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout('IFN_EIF1001_EC002_MD003','Rseal');

        IFN_EIF1001_EC002_MD003.EC002RequstWrapper reqparam = new IFN_EIF1001_EC002_MD003.EC002RequstWrapper();
        reqparam.image = '123123';
        callout.getResponse('IFN_EIF1001_EC002_MD003', reqparam);
        
        Test.stopTest();

    }



    @isTest
    static void testIFN_EIF1001_EC002_MD004Succ()
    {

        Test.startTest();

        IFN_EIF1001_EC002_MD004.EC002Response resData = new IFN_EIF1001_EC002_MD004.EC002Response();
        IFN_EIF1001_EC002_MD004.EC002SuccessData resSucc = new IFN_EIF1001_EC002_MD004.EC002SuccessData();
        resSucc.image_key = '1';
        resSucc.name = '1';
        resSucc.request_date = '2022-03-01';
        resSucc.url = '1';
        resData.data = resSucc;
        String resbody = JSON.serialize(resData);

        Test.setMock(HttpCalloutMock.class, new IF_HttpCalloutMock(resbody,200)); 
        IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout('IFN_EIF1001_EC002_MD004','Rseal');

        IFN_EIF1001_EC002_MD004.EC002RequstWrapper reqparam = new IFN_EIF1001_EC002_MD004.EC002RequstWrapper();
        reqparam.image = '123123';
        callout.getResponse('IFN_EIF1001_EC002_MD004', reqparam);
        
        Test.stopTest();
    } 


    @isTest
    static void testIFN_EIF1001_EC002_MD004Err()
    {


        Test.startTest();

        IFN_EIF1001_EC002_MD004.EC002ErrorData errData = new IFN_EIF1001_EC002_MD004.EC002ErrorData();
        errData.errcode = '-1';
        errData.errmsg = 'err';
        String resbody = JSON.serialize(errData);

        Test.setMock(HttpCalloutMock.class, new IF_HttpCalloutMock(resbody,500)); 
        IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout('IFN_EIF1001_EC002_MD004','Rseal');

        IFN_EIF1001_EC002_MD004.EC002RequstWrapper reqparam = new IFN_EIF1001_EC002_MD004.EC002RequstWrapper();
        reqparam.image = '123123';
        callout.getResponse('IFN_EIF1001_EC002_MD004', reqparam);
        
        Test.stopTest();

    }    


    
    @isTest
    static void testIFN_EIF1001_EC003_MD005Succ()
    {

        Test.startTest();

        
        IFN_EIF1001_EC003_MD005.EC003ResultWrapper resSucc = new IFN_EIF1001_EC003_MD005.EC003ResultWrapper();
        List<Map<String, Object>> resultMapLst = new List<Map<String, Object>>();
        Map<String, Object> resMap = new Map<String, Object>();
        resMap.put('1','1');
        resultMapLst.add(resMap);
        resSucc.results = resultMapLst;

        
        String resbody = JSON.serialize(resSucc);

        Test.setMock(HttpCalloutMock.class, new IF_HttpCalloutMock(resbody,200)); 
        IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout('tIFN_EIF1001_EC003_MD005','Rseal');

        // req
        IFN_EIF1001_EC003_MD005.EC003RequstWrapper reqparam = new IFN_EIF1001_EC003_MD005.EC003RequstWrapper();
        List<IFN_EIF1001_EC003_MD005.EC003RequstData> reqdatalst = new List<IFN_EIF1001_EC003_MD005.EC003RequstData>();
        IFN_EIF1001_EC003_MD005.EC003RequstData reqdata = new IFN_EIF1001_EC003_MD005.EC003RequstData();
        reqdatalst.add(reqdata);
        reqparam.msg_type = '1';

        callout.getResponse('IFN_EIF1001_EC002_MD004', reqparam);
        
        Test.stopTest();
    } 


    @isTest
    static void testIFN_EIF1001_FS001_MD001Succ()
    {

        Test.startTest();

        IFN_EIF1001_FS001_MD001.Output resData = new IFN_EIF1001_FS001_MD001.Output();
        IFN_EIF1001_FS001_MD001.I1250 I1250 = new IFN_EIF1001_FS001_MD001.I1250();
        List<IFN_EIF1001_FS001_MD001.row> datarowlst = new List<IFN_EIF1001_FS001_MD001.row>();
        IFN_EIF1001_FS001_MD001.row datarow = new IFN_EIF1001_FS001_MD001.row();
        IFN_EIF1001_FS001_MD001.RESULT resultData = new  IFN_EIF1001_FS001_MD001.RESULT();
        datarowlst.add(datarow);
        I1250.row = datarowlst;
        I1250.Result = resultData;
        resData.i1250 = I1250;

        String resbody = JSON.serialize(resData);

        Test.setMock(HttpCalloutMock.class, new IF_HttpCalloutMock(resbody,200)); 
        IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout('IFN_EIF1001_FS001_MD001','Rseal');

        String reqparam = '1111';
        callout.getResponse('IFN_EIF1001_FS001_MD001', reqparam);
        
        Test.stopTest();
    }    


    @isTest
    static void testIFN_EIF1001_FS001_MD001Err()
    {


        Test.startTest();


        String resbody = '';

        Test.setMock(HttpCalloutMock.class, new IF_HttpCalloutMock(resbody,500)); 
        IFN_EIF1001_Callout callout = new IFN_EIF1001_Callout('IFN_EIF1001_FS001_MD001','Rseal');

        String reqparam = '1111';
        callout.getResponse('IFN_EIF1001_EC002_MD004', reqparam);
        
        Test.stopTest();

    }    

    
    public class IF_HttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        public String body{get;set;}
        public Integer statusCode{get;set;}

        public IF_HttpCalloutMock(String body, Integer statusCode)
        {
            this.body = body;
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(this.body);
            response.setStatusCode(this.statusCode);
            return response; 
        }
    }






}