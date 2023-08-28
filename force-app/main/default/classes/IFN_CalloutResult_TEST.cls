@isTest 
private class IFN_CalloutResult_TEST {
    
    @TestSetup
    static void setup(){
        
    }

    @isTest
    static void testOne()
    {
        Test.startTest();
        IFN_CalloutResult result = new IFN_CalloutResult();
        result.setResult('response');
        result.setResult('S', 'S', 'response');
        result.setResult('S', 'S', 'response', new IFN_CommonLog.LogWrap('SD0501' , 'Real'));
        result.setResult('S', 'S', 100, 'response', new IFN_CommonLog.LogWrap('SD0501' , 'Real'));
        Test.stopTest();
    }
}