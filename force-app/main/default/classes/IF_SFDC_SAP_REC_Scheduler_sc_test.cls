/**
 * @description       : 
 * @author            : 김민제
 * @group             : 
 * @last modified on  : 06-30-2022
 * @last modified by  : 김민제
**/
@isTest
public class IF_SFDC_SAP_REC_Scheduler_sc_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_SAP_REC_RELEASE'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'POST';
            objIFMaster.ContentType__c = 'application/xml';
            objIFMaster.Endpoint__c = 'test';
            
            listIFMaster.add(objIFMaster);
        }
        
        insert listIFMaster;
    }
    @isTest
    static void testIF_SFDC_SAP_REC_RELEASE(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SapCkProcedureMock_release());
        IF_SFDC_SAP_REC_RELEASE d = new IF_SFDC_SAP_REC_RELEASE();
        d.callOut('20220620');
        String CRON_EXP = '0 0 22 * * ?';
 		System.schedule('입고 동기화1', CRON_EXP, new IF_SFDC_SAP_REC_Scheduler_sc('입고'));
        CRON_EXP = '0 1 22 * * ?';
        System.schedule('출고 동기화2', CRON_EXP, new IF_SFDC_SAP_REC_Scheduler_sc('출고'));
        CRON_EXP = '0 00 * * * ?';
        System.schedule('재고 동기화3', CRON_EXP, new IF_SFDC_SAP_REC_Scheduler_sc('재고'));
        Test.stopTest();
    }
}