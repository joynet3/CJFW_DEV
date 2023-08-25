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
        IFN_Scheduler_TEST.createIfPrograms(); 
    }


    public static void createIfPrograms() {
        List<IF_Program__c> ifPorgObj = new List<IF_Program__c>();
        ifPorgObj.add(new IF_Program__c(Name='IF_ERP_GradeInformationSearchQueueable', EndPoint__c = 'https://test.test'));
        ifPorgObj.add(new IF_Program__c(Name='Dummy', EndPoint__c = ''));

        INSERT ifPorgObj;

    } //end of createIfProgramObj()

    @isTest
    static void testOne()
    {
        Test.startTest();
        
        IFN_Scheduler sch = new IFN_Scheduler('IF_ERP_GradeInformationSearchQueueable','200');
        system.schedule('test1', '0 0 0 * * ?', sch);
        IFN_Scheduler sch2 = new IFN_Scheduler('IF_ERP_GradeInformationSearchBatch','200');
        system.schedule('test2', '0 0 0 * * ?', sch2);
        
        Test.stopTest();
    }
}