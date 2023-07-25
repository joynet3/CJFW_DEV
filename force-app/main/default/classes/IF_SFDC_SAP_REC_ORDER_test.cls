/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
@isTest
public class IF_SFDC_SAP_REC_ORDER_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_SAP_REC_ORDER'};

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
        
        List<Order_H__c> listOrder_H = new List<Order_H__c>();
        Order_H__c objOrder_H = TestObjectCreator.getobjOrder_H('2165209086');
        listOrder_H.add(objOrder_H);

        insert listOrder_H;
        system.debug('listOrder_H :: ' + listOrder_H);

        List<Order_D__c> listOrder_D = new List<Order_D__c>();
        Order_D__c objOrder_D_1 = TestObjectCreator.getobjOrder_D('백설 밀가루(강력_1등 20Kg/EA)', '100070', '10', objOrder_H);
        Order_D__c objOrder_D_2 = TestObjectCreator.getobjOrder_D('오뚜기 쇠고기라면(덕용 120g/EA)', '103565', '20', objOrder_H);
        Order_D__c objOrder_D_3 = TestObjectCreator.getobjOrder_D('서울우유 우유(카톤_200ml 200g/EA)', '105336', '30', objOrder_H);
        Order_D__c objOrder_D_4 = TestObjectCreator.getobjOrder_D('백설 롱슈가(5g*1000입 일회용 5', '106208', '40', objOrder_H);
        Order_D__c objOrder_D_5 = TestObjectCreator.getobjOrder_D('연세우유 참맛두유(200ml 200g/EA)', '118700', '50', objOrder_H);
        listOrder_D.add(objOrder_D_1);
        listOrder_D.add(objOrder_D_2);
        listOrder_D.add(objOrder_D_3);
        listOrder_D.add(objOrder_D_4);
        listOrder_D.add(objOrder_D_5);

        system.debug('listOrder_D :: ' + listOrder_D);
        insert listOrder_D;
    }
    @isTest
    static void testIF_SFDC_SAP_REC_ORDER(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SapCkProcedureMock());
        IF_SFDC_SAP_REC_ORDER d = new IF_SFDC_SAP_REC_ORDER();
        d.callOut('20220620');
        
        Test.stopTest();
    }
}