@isTest 
private class IFN_CommonLog_TEST {
    @TestSetup
    static void setup(){
        IFN_TestDataFactory.createIfPrograms();
    }


    @isTest
    static void testOne()
    {
        Test.startTest();

        IFN_CommonLog.LogWrap log = new IFN_CommonLog.LogWrap('IFN_LIF1002_OD003_MD004' , 'Real');
        log.ErrorText.add('Read Timeout');
        IFN_CommonLog commlog = new IFN_CommonLog();
        commlog.insertLog(log);
        Test.stopTest();
    }

    @isTest
    static void testTwo()
    {
        Test.startTest();
        IFN_CommonLog.LogWrap log = new IFN_CommonLog.LogWrap('IFN_LIF1002_OD003_MD004' , 'Batch');
        log.ErrorText.add('Read Timeout');
        IFN_CommonLog commlog = new IFN_CommonLog();
        commlog.insertLog(new List<IFN_CommonLog.LogWrap>{log});
        Test.stopTest();
    }
}