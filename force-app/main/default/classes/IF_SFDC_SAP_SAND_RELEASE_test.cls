/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
@isTest
public class IF_SFDC_SAP_SAND_RELEASE_test {
    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SFDC_SAP_SAND_RELEASE'};

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
        
        List<Release_H__c> listRelease_H = new List<Release_H__c>();
        Release_H__c objRelease_H = TestObjectCreator.getObjRelease_H('2000000154');
        objRelease_H.CHECK__c= 'Y';
        objRelease_H.CONFIRM__c= 'N';
        listRelease_H.add(objRelease_H);

        insert listRelease_H;
        system.debug('listRelease_H :: ' + listRelease_H);

        List<Release_D__c> listRelease_D = new List<Release_D__c>();
        Release_D__c objRelease_D_1 = TestObjectCreator.getObjRelease_D('백설 밀가루(강력_1등 20Kg/EA)', '100070', '10', objRelease_H);
        Release_D__c objRelease_D_2 = TestObjectCreator.getObjRelease_D('오뚜기 쇠고기라면(덕용 120g/EA)', '103565', '20', objRelease_H);
        Release_D__c objRelease_D_3 = TestObjectCreator.getObjRelease_D('서울우유 우유(카톤_200ml 200g/EA)', '105336', '30', objRelease_H);
        Release_D__c objRelease_D_4 = TestObjectCreator.getObjRelease_D('백설 롱슈가(5g*1000입 일회용 5', '106208', '40', objRelease_H);
        Release_D__c objRelease_D_5 = TestObjectCreator.getObjRelease_D('연세우유 참맛두유(200ml 200g/EA)', '118700', '50', objRelease_H);
        listRelease_D.add(objRelease_D_1);
        listRelease_D.add(objRelease_D_2);
        listRelease_D.add(objRelease_D_3);
        listRelease_D.add(objRelease_D_4);
        listRelease_D.add(objRelease_D_5);

        system.debug('listRelease_D :: ' + listRelease_D);
        insert listRelease_D;
    }
    @isTest
    static void testIF_SFDC_SAP_SAND_RELEASE() {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SapCkProcedureMock_release());
        IF_SFDC_SAP_SAND_RELEASE d = new IF_SFDC_SAP_SAND_RELEASE();
        d.callOut();
        Test.stopTest();
    }
}