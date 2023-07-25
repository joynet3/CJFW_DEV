/************************************************************************************
 * File Name   		    : CK_InAndOutMgmtController_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.06.20
 * Target	  		    : CK_InAndOutMgmtController.cls
 * Description 		    : CK_InAndOutMgmtController Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.06.20      Minje.kim       Create
 *************************************************************************************/


@IsTest
public with sharing class CK_InAndOutMgmtController_test {
    @IsTest
    public static void dotest() {
        Test.startTest();

        // 입고 데이터
        List<Order_H__c> listOrder_H = new List<Order_H__c>();
        Order_H__c objOrder_H = TestObjectCreator.getobjOrder_H('2000000154');
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

        
        // 출고 데이터
        List<Release_H__c> listRelease_H = new List<Release_H__c>();
        Release_H__c objRelease_H = TestObjectCreator.getObjRelease_H('2000000154');
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


        Map<String, Object> mapSearchParams = new Map<String, Object>();

        mapSearchParams.put('screenStatus', 'Import');
        CK_InAndOutMgmtController.doGetData(mapSearchParams);
        mapSearchParams.put('screenStatus', 'Export');
        CK_InAndOutMgmtController.doGetData(mapSearchParams);
        CK_InAndOutMgmtController.doConfirmData('Import');
        CK_InAndOutMgmtController.doConfirmData('Export');
        CK_InAndOutMgmtController.doSaveData(listOrder_H,listOrder_D);
        
        Test.stopTest();
    }
}