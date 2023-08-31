@isTest
public  class IFN_TestDataFactory_TEST {
    @isTest
    static void test01() {
        Test.startTest();

        IFN_TestDataFactory.createIfPrograms();
        
        Test.stopTest();
    }
}