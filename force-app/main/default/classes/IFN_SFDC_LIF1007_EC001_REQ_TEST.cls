@IsTest
public with sharing class IFN_SFDC_LIF1007_EC001_REQ_TEST {
    @TestSetup
    static void setup(){
        IFN_SFDC_LIF1007_EC001_REQ_TEST.createIfPrograms();
    }

    public static void createIfPrograms() {
        // List<IFMaster__c> ifPorgObj = new List<IFMaster__c>();
        // ifPorgObj.add(new IFMaster__c(Name='B2BI_SSIG_EA_KPIMASTERSEARCH_01',InterfaceId__c='B2BI_SSIG_EA_KPIMASTERSEARCH_01'
        //     , EndPoint__c = 'https://test.test'));

        // INSERT ifPorgObj;

    } //end of createIfProgramObj()



    @IsTest
    static void test01() {
        Test.startTest();

        //Test.setMock(HttpCalloutMock.class, new IFN_SFDC_LIF1007_EC001_REQCalloutMock('',200));
        IFN_SFDC_LIF1007_EC001_REQ req = new IFN_SFDC_LIF1007_EC001_REQ();
        String res = req.callout();

        Test.stopTest();
    }


    // public class IFN_SFDC_LIF1007_EC001_REQCalloutMock implements HttpCalloutMock {
    //     // Implement this interface method
    //     public String body{get;set;}
    //     public Integer statusCode{get;set;}

    //     public IFN_SFDC_LIF1007_EC001_REQCalloutMock(String body, Integer statusCode)
    //     {
    //         this.body = '{"ERR_CD":"S","ERR_MSG_CTT":"","DS_MASTER":{"data":[{"OIL_UNITP":262,"BASE_MON":"202301","COM_CD":"FW00","OIL_TYPE_CD":"1","DPRC_UNITP":101}],"SVC_ERR_MSG_TEXT":"","ErrorCode":0}}';
    //         this.statusCode = statusCode;
    //     }

    //     public HTTPResponse respond(HTTPRequest request) {
    //         // Create a fake response
    //         HttpResponse response = new HttpResponse();
    //         response.setHeader('Content-Type', 'application/text');
    //         response.setBody(this.body);
    //         response.setStatusCode(this.statusCode);
    //         return response; 
    //     }
    // }

}