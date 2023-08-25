/************************************************************************************
 * File Name   : TestObjectCreator.cls
 * Author      : Minje.kim
 * Date        : 2022.06.21
 * Tester      : TestObjectCreator_test.cls
 * Target      :
 * Description : 테스트 클래스에서 사용하는 테스트용 오브젝트 반환
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.06.21      Minje.kim     	Create
*************************************************************************************/

public with sharing class TestObjectCreator {
    /************************************************************************************
	*   Account : 기존고객(MDM)
	*************************************************************************************/
    public static Account objExAccount {
        get {
            if(objExAccount == null) {
                objExAccount = new Account();

                objExAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();
                objExAccount.Name = 'ExAccount';
                objExAccount.CustomerId__c = '000001';
            }
            return objExAccount;
        }
        set;
    }

    /************************************************************************************
	*   Account : 가망고객(헬씨누리)
	*************************************************************************************/
    public static Account objHealthAccount {
        get {
            if(objHealthAccount == null) {
                objHealthAccount = new Account();

                objHealthAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HealthyNuriDepartment').getRecordTypeId();
                objHealthAccount.Name = 'HealthAccount';
            }
            return objHealthAccount;
        }
        set;
    }

    /************************************************************************************
	*   Account : 가망고객(튼튼)
	*************************************************************************************/
    public static Account objSchoolAccount {
        get {
            if(objSchoolAccount == null) {
                objSchoolAccount = new Account();

                objSchoolAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SchoolDepartment').getRecordTypeId();
                objSchoolAccount.Name = 'SchoolAccount';
            }
            return objSchoolAccount;
        }
        set;
    }

    /************************************************************************************
	*   Pricebook2 : 가격표
	*************************************************************************************/
    public static Pricebook2 objPricebook {
        get {
            if(objPricebook == null) {
                objPricebook = new Pricebook2();
                objPricebook.Id = Test.getStandardPricebookId();                
            }

            return objPricebook;
        }
        set;
    }

    /************************************************************************************
	*   Product2 : 상품정보
	*************************************************************************************/
    public static Product2 objProduct {
        get {
            if(objProduct == null) {
                objProduct = new Product2();
                
                objProduct.Name = 'testProduct';
                objProduct.ProductCode = '1000_165272';
                objProduct.gd_no__c = '165272';
                objProduct.bas_unit_cd__c = 'EA';
                objProduct.lgs_ctr__c = '1000';
                objProduct.lgs_ctr_id__c = '1000';
                objProduct.fw_gd_lar_id__c = '20';
                objProduct.fw_gd_mid_id__c = '2003';                
                objProduct.fw_gd_sml_id__c = '200304';
                objProduct.fw_gdgrp_cd__c = '51';
                objProduct.lgl_nd_cmpo_bd__c = '국내산';

                objProduct.ExtId__c = '1000_165272';
            }
            return objProduct;
        }
        set;
    }

    /************************************************************************************
	*   PricebookEntry : 가격목록항목
	*************************************************************************************/
    public static PricebookEntry objPricebookEntry {
        get {
            if(objPricebookEntry == null) {
                if(objPricebook.Id == null) insert objPricebook;
                if(objProduct.Id == null) insert objProduct;

                objPricebookEntry = new PricebookEntry();

                objPricebookEntry.Pricebook2Id = objPricebook.Id;
                objPricebookEntry.Product2Id = objProduct.Id;
                objPricebookEntry.UnitPrice = 0;

                // objPricebookEntry.lgs_ctr__c = '1000';
                objPricebookEntry.EarlyApr__c = 1000;
                objPricebookEntry.EarlyAug__c = 1000;
                objPricebookEntry.EarlyDec__c = 1000;
                objPricebookEntry.EarlyFeb__c = 1000;
                objPricebookEntry.EarlyJan__c = 1000;
                objPricebookEntry.EarlyJul__c = 1000;
                objPricebookEntry.EarlyJun__c = 1000;
                objPricebookEntry.EarlyMar__c = 1000;
                objPricebookEntry.EarlyMay__c = 1000;
                objPricebookEntry.EarlyNov__c = 1000;
                objPricebookEntry.EarlyOct__c = 1000;
                objPricebookEntry.EarlySep__c = 1000;                
                objPricebookEntry.LateApr__c = 1000;
                objPricebookEntry.LateAug__c = 1000;
                objPricebookEntry.LateDec__c = 1000;
                objPricebookEntry.LateFeb__c = 1000;
                objPricebookEntry.LateJan__c = 1000;
                objPricebookEntry.LateJul__c = 1000;
                objPricebookEntry.LateJun__c = 1000;
                objPricebookEntry.LateMar__c = 1000;
                objPricebookEntry.LateMay__c = 1000;
                objPricebookEntry.LateNov__c = 1000;
                objPricebookEntry.LateOct__c = 1000;
                objPricebookEntry.LateSep__c = 1000;

                objPricebookEntry.ExtId__c = '1000_165272';
                objPricebookEntry.lgs_ctr__c = '1000';
                objPricebookEntry.IsActive = true;

            }

            return objPricebookEntry;
        }
        set;
    }

    /************************************************************************************
	*   VOC__c : VOC
	*************************************************************************************/
    public static VOC__c objVOC {
        get {
            if(objVOC == null) {
                objVOC = new VOC__c();
                objVOC.Name = 'TEST1234';
            }

            return objVOC;
        }
        set;
    }

    /************************************************************************************
	*   VOCLineItem__c : VOC항목
	*************************************************************************************/
    public static VOCLineItem__c objVOCLineItem {
        get {
            if(objVOCLineItem == null) {
                if(objVOC.Id == null) insert objVOC;

                objVOCLineItem = new VOCLineItem__c();
                objVOCLineItem.VOC__c = objVOC.Id;

            }

            return objVOCLineItem;
        }
        set;
    }

    /************************************************************************************
	*   Account
	*************************************************************************************/
	private static Account objAccount;
	public static Account getObjAccount() {
		if(objAccount == null) {
			objAccount = new Account();
			objAccount.Name = 'Test Account';
		}
		return objAccount;
	}

	/************************************************************************************
	*   주문내역
	*************************************************************************************/
	public static Order_H__c getObjOrder_H(String strName) {
        Order_H__c objOrder_H = new Order_H__c();
        //objOrder_H.Name = strName;
        objOrder_H.EBELN__c = strName;
        objOrder_H.RESWK__c = '2600';
        objOrder_H.SHIP_TYP__c = '1';
        objOrder_H.IFDATE__c = date.valueOf('2022-01-01');
		return objOrder_H;
	}
    
    // 상품명, 상품코드, 항번, 상위 오더
	public static Order_D__c getObjOrder_D(String strMAKTX, String strMATNR, String strEBELP, Order_H__c objOrder_H) {
        Order_D__c objOrder_D = new Order_D__c();
        objOrder_D.Name = strMAKTX;
        objOrder_D.MAKTX__c = strMAKTX;
        objOrder_D.MENGE__c = 100;
        objOrder_D.MEINS__c = 'EA';
        objOrder_D.LGORT__c = 'L091';
        objOrder_D.RAUBE__c = '10';
        objOrder_D.WERKS__c = '3000';
        objOrder_D.ORDERDKEY__c = objOrder_H.EBELN__c + strEBELP ;
        objOrder_D.EBELN__c = objOrder_H.EBELN__c;
        objOrder_D.EBELP__c = strEBELP;
        objOrder_D.EINDT__c = date.valueOf('2022-01-01');
        objOrder_D.Order_H__c = objOrder_H.Id;
		return objOrder_D;
	}
    
    
	/************************************************************************************
	*   출고내역
	*************************************************************************************/
	public static RELEASE_H__c getObjRelease_H(String strEBELN) {
			RELEASE_H__c objRelease_H = new RELEASE_H__c();
			// objRelease_H.Name = strName;
			objRelease_H.EBELN__c = strEBELN;
			objRelease_H.IFDATE__c = date.valueOf('2022-01-01');
		
		return objRelease_H;
	}
    
    // 상품명, 상품코드, 항번, 상위 오더
	public static RELEASE_D__c getObjRelease_D(String strMAKTX, String strMATNR, String strEBELP, RELEASE_H__c objRelease_H) {

        RELEASE_D__c objRelease_D = new RELEASE_D__c();
        objRelease_D.Name = strMAKTX;
        objRelease_D.MAKTX__c = strMAKTX;
        objRelease_D.MENGE__c = 100;
        objRelease_D.MEINS__c = 'EA';
        objRelease_D.LGORT__c = 'L091';
        objRelease_D.RAUBE__c = '10';
        objRelease_D.WERKS__c = '3000';
        objRelease_D.RELEASEDKEY__c = objRelease_H.EBELN__c + strEBELP ;
        objRelease_D.EBELN__c = objRelease_H.EBELN__c;
        objRelease_D.EBELP__c = strEBELP;
        objRelease_D.EINDT__c = date.valueOf('2022-01-01');
        objRelease_D.Release_H__c = objRelease_H.Id;

		return objRelease_D;
	}
    
    
	/************************************************************************************
	*   재고
	*************************************************************************************/

    // 상품명, 재고키
	public static STOCK__c getObjStock_D(String strMAKTX, String strSTOCKKEY) {
        STOCK__c objSTOCK = new STOCK__c();
        objSTOCK.Name = strMAKTX;
        objSTOCK.MAKTX__c = strMAKTX;
        objSTOCK.MENGE__c = 100;
        objSTOCK.MEINS__c = 'EA';
        objSTOCK.LGORT__c = 'L091';
        objSTOCK.WERKS__c = '3000';
        objSTOCK.STOCKKEY__c = strSTOCKKEY ;
		return objSTOCK;
	}

    
    // 상품명, 재고키
	public static StockChangeLog__c getObjStockChangeLog(STOCK__c objStock) {
        StockChangeLog__c objStockChangeLog = new StockChangeLog__c();
        objStockChangeLog.MAKTX__c = objStock.MAKTX__c;
        objStockChangeLog.StockQuantity__c = objStock.MENGE__c;
        objStockChangeLog.ChangeQuantity__c = objStock.MENGE__c -1;
        objStockChangeLog.Action__c = '947';
        objStockChangeLog.MEINS__c = objStock.MEINS__c;
        objStockChangeLog.LGORT__c = objStock.LGORT__c;
        objStockChangeLog.STOCKKEY__c = objStock.STOCKKEY__c ;
		return objStockChangeLog;
	}

    /************************************************************************************
    *   제안시산
    *************************************************************************************/

    public static Balance__c objSuggestBalance {
        get {
            if(objSuggestBalance == null) {
                objSuggestBalance = new Balance__c();
                objSuggestBalance.Name = 'Test Balance';
                objSuggestBalance.IRRPct__c = -360;
                objSuggestBalance.SalesRevenue__c = '912,500';
                objSuggestBalance.PurchasingCost__c = '281,546';
                objSuggestBalance.PurchasingCostPct__c = 30;
                objSuggestBalance.ManufacturingCost__c = '287,362';
                objSuggestBalance.ManufacturingCostPct__c = 31;
                objSuggestBalance.SalesProfit__c = '343,592';
                objSuggestBalance.SalesProfitPct__c = 37;
                objSuggestBalance.MgmtProfit__c = '337,992';
                objSuggestBalance.MgmtProfitPct__c = 37;
                objSuggestBalance.Classification__c = '제안시산';
            }

            return objSuggestBalance;
        }
        set;
    }

    /************************************************************************************
    *   오픈시산
    *************************************************************************************/

    public static Balance__c objOpenBalance {
        get {
            if(objOpenBalance == null) {
                objOpenBalance = new Balance__c();
                objOpenBalance.Name = 'Test Balance';
                objOpenBalance.IRRPct__c = -360;
                objOpenBalance.SalesRevenue__c = '912,500';
                objOpenBalance.PurchasingCost__c = '281,546';
                objOpenBalance.PurchasingCostPct__c = 30;
                objOpenBalance.ManufacturingCost__c = '287,362';
                objOpenBalance.ManufacturingCostPct__c = 31;
                objOpenBalance.SalesProfit__c = '343,592';
                objOpenBalance.SalesProfitPct__c = 37;
                objOpenBalance.MgmtProfit__c = '337,992';
                objOpenBalance.MgmtProfitPct__c = 37;
                objOpenBalance.Classification__c = '오픈시산';
            }

            return objOpenBalance;
        }
        set;
    }
}