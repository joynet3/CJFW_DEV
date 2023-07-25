/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
@isTest
public class IF_SFDC_SAP_REC_STOCK_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_SAP_REC_STOCK'};

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
    static void testIF_SFDC_SAP_REC_STOCK(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SapCkProcedureMock_stock());
        IF_SFDC_SAP_REC_STOCK c = new IF_SFDC_SAP_REC_STOCK();
        c.callOut();
        Test.stopTest();
    }
}