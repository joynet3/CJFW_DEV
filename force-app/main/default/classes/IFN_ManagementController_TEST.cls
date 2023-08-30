@isTest 
private class IFN_ManagementController_TEST {
    
    @TestSetup
    static void setup(){
        IFN_TestDataFactory.createIfPrograms();



    }

    @isTest
    static void testOne()
    {
        Test.startTest();

        IFN_ManagementController.getData();

        IFN_ManagementController.IFMgmt param = new IFN_ManagementController.IFMgmt();
        param.interfaceId  = 'IFN_LIF1002_SE001_MD001';
        param.targetSystem = 'LIF1002';
        param.params = '{}';
        param.batchClass = '';
        param.batchOrqueueable = '';

        IFN_ManagementController.getResponse(param);


        IFN_ManagementController.BatchData c1 = new IFN_ManagementController.BatchData();
        IFN_ManagementController.BatchItem c2 = new IFN_ManagementController.BatchItem();
        IFN_ManagementController.Example   c3 = new IFN_ManagementController.Example();
        IFN_ManagementController.InterfaceData c4 = new IFN_ManagementController.InterfaceData();
        IFN_ManagementController.Data c5 = new IFN_ManagementController.Data();
        

        Test.stopTest();
    }

    @isTest
    static void testTwo()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ThisHttpCalloutMock()); 
        IFN_ManagementController.doExecuteAnonymous('String t;');
        IFN_ManagementController.getUserSessionId();
        Test.stopTest();
    }

    public class ThisHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{}');
            response.setStatusCode(200);
            return response; 
        }
    }
}