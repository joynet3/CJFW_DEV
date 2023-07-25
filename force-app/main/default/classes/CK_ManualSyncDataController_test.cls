/************************************************************************************
 * File Name   		    : CK_ManualSyncDataController_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.06.20
 * Target	  		    : CK_ManualSyncDataController.cls
 * Description 		    : CK_ManualSyncDataController Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.06.20      Minje.kim       Create
 *************************************************************************************/


@IsTest
public with sharing class CK_ManualSyncDataController_test {
    @IsTest
    public static void dotest() {
        Test.startTest();

        CK_ManualSyncDataController.doSyncOrderData('20220101');
        CK_ManualSyncDataController.doSyncReleaseData('20220101');
        CK_ManualSyncDataController.doSyncStockData();
        CK_ManualSyncDataController.doReConfirm('ORDER_H__c');
        CK_ManualSyncDataController.doReConfirm('RELEASE_H__c');
        CK_ManualSyncDataController.doReConfirm('');
        
        Test.stopTest();
    }
}