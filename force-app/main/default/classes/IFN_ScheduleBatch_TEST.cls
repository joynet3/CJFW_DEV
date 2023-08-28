@isTest
public class IFN_ScheduleBatch_TEST 
{
    @TestSetup
    static void setup()
    {
        IFN_TestDataFactory.createIfPrograms();
    }

    @isTest 
    static void successTest() 
    {
        Test.startTest();

        Database.executeBatch(new IFN_ScheduleBatch(), 200);

        Test.stopTest();
    }


}