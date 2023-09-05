/**
* @Class : IFN_Scheduler Test 클래스
*
* @Author : 조일근 
* @Date : 2023. 07. 18
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2023. 07. 18 | 조일근    | 최초작성
* 
* */
@isTest
public class IFN_Scheduler_TEST {

    @TestSetup
    static void setup()
    {
        IFMaster__c ifmst = new IFMaster__c(Name='IFN_ScheduleBatch',
            InterfaceId__c = 'IFN_ScheduleBatch',
            ClassName__c = 'IFN_ScheduleBatch',
            Endpoint__c = '',
            Method__c = 'POST',
            ContentType__c = 'application/json',
            ifKeyId__c = 'IFN_ScheduleBatch',
            CallORBatch__c='Batch',
            BatchClass__c='Batch'
        );
        insert ifmst;

        IFMaster__c ifmst1 = new IFMaster__c(Name='IFN_DUMMY_Queueable',
            InterfaceId__c = 'IFN_DUMMY_Queueable',
            ClassName__c = 'IFN_DUMMY_Queueable',
            Endpoint__c = '',
            Method__c = 'POST',
            ContentType__c = 'application/json',
            ifKeyId__c = 'IFN_DUMMY_Queueable',
            CallORBatch__c='Batch',
            BatchClass__c='Queueable'
        );
        insert ifmst1;

    }


    @isTest
    static void testOne()
    {
        Test.startTest();
        
        IFN_Scheduler sch = new IFN_Scheduler('IFN_ScheduleBatch','200');
        system.schedule('test1', '0 0 0 * * ?', sch);
         IFN_Scheduler sch2 = new IFN_Scheduler('IFN_DUMMY_Queueable','200');
         system.schedule('test2', '0 0 0 * * ?', sch2);
        
        Test.stopTest();
    }
}