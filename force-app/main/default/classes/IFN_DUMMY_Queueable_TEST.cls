/**
 * @Class : IFN_DUMMY_Queueable_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.09.05
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.05 | 조일근  | 최초작성
 * */
@isTest
public with sharing class IFN_DUMMY_Queueable_TEST {
    @TestSetup
    static void setup()
    {
        IFN_TestDataFactory.createIfPrograms();
    }

    @isTest
    static void testOne()
    {
        IFN_DUMMY_Queueable qu = new IFN_DUMMY_Queueable();

        System.enqueueJob(qu);

    }
}