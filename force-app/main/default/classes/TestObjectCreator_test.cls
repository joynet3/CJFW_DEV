/************************************************************************************
 * File Name   : TestObjectCreator_test.cls
 * Author      : Yohan.Kang
 * Date        : 2019.10.24
 * Target      : TestObjectCreator.cls
 * Description : 테스트 클래스에서 사용하는 테스트용 오브젝트 반환
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2019.10.24      Yohan.Kang      Create
*************************************************************************************/

@isTest
private class TestObjectCreator_test {
        @isTest
        static void dotest() {

                // 입고
                Order_H__c objOrder_H = TestObjectCreator.getobjOrder_H('2165209086');
                insert objOrder_H;
                Order_D__c objOrder_D = TestObjectCreator.getobjOrder_D('백설 밀가루(강력_1등 20Kg/EA)', '100070', '10', objOrder_H);
                
                // 출고
                Release_H__c objRelease_H = TestObjectCreator.getObjRelease_H('2000000154');
                insert objRelease_H;
                Release_D__c objRelease_D = TestObjectCreator.getObjRelease_D('백설 밀가루(강력_1등 20Kg/EA)', '100070', '10', objRelease_H);

                // 재고
                Stock__c objStock = TestObjectCreator.getObjStock_D('test', '1000012');
                insert objStock;
                StockChangeLog__c objstcLog = TestObjectCreator.getObjStockChangeLog(objStock);
	}

        @isTest
        static void itShould() {
                System.debug(TestObjectCreator.objExAccount);
                System.debug(TestObjectCreator.objHealthAccount);
                System.debug(TestObjectCreator.objSchoolAccount);
                System.debug(TestObjectCreator.objPricebook);
                System.debug(TestObjectCreator.objProduct);
                System.debug(TestObjectCreator.objVOC);
                System.debug(TestObjectCreator.objVOCLineItem);
                System.debug(TestObjectCreator.objPricebookEntry);
                System.debug(TestObjectCreator.objOpenBalance);
                System.debug(TestObjectCreator.objSuggestBalance);
                
                
	}
}