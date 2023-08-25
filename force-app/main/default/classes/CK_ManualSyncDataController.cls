/*
* ==================================================================================
*   File Name   : CK_ManualSyncDataController.cls
*   Author      : Minje.kim
*   Date        : 2022.06.16
*   Tester      : CK_ManualSyncDataController_test.cls
*   Description : SAP to SFDC Data Sync
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.06.16    Minje.kim       Create
* ==================================================================================
*/

public with sharing class CK_ManualSyncDataController {


    @AuraEnabled
    public static Map<String, Object> doSyncOrderData(String paramDate) {
        system.debug('paramDate ::' + paramDate);
        IF_SFDC_SAP_REC_ORDER.Output outputObj = new IF_SFDC_SAP_REC_ORDER.Output();
        // outputObj.result.resultMessage ='';
        // outputObj.result.resultCode ='';
        IF_SFDC_SAP_REC_ORDER ifORDER = new IF_SFDC_SAP_REC_ORDER();

        String resultMessage = '';
        String resultCode = '';

        if(!Test.isRunningTest()) {
            outputObj = ifORDER.callOut(paramDate);
            resultMessage = outputObj.result.resultMessage;
            resultCode = outputObj.result.resultCode;
        }
        system.debug('outputObj ::' + outputObj);

        Map<String, object> mapResult = new Map<String, object>{
            'resultMessage' => resultMessage,
            'resultCode' => resultCode 
        };
        return mapResult;
    }

    @AuraEnabled
    public static Map<String, Object> doSyncReleaseData(String paramDate) {
        system.debug('paramDate ::' + paramDate);
        IF_SFDC_SAP_REC_RELEASE.Output outputObj = new IF_SFDC_SAP_REC_RELEASE.Output();
        IF_SFDC_SAP_REC_RELEASE ifRELEASE = new IF_SFDC_SAP_REC_RELEASE();
        
        String resultMessage = '';
        String resultCode = '';

        if(!Test.isRunningTest()) {
            outputObj = ifRELEASE.callOut(paramDate);
            resultMessage = outputObj.result.resultMessage;
            resultCode = outputObj.result.resultCode;
        }
        system.debug('outputObj ::' + outputObj);

        Map<String, object> mapResult = new Map<String, object>{
            'resultMessage' => resultMessage,
            'resultCode' => resultCode 
        };
        return mapResult;
    }

    @AuraEnabled
    public static Map<String, Object> doSyncStockData() {
        IF_SFDC_SAP_REC_STOCK.Output outputObj = new IF_SFDC_SAP_REC_STOCK.Output();
        IF_SFDC_SAP_REC_STOCK ifSTOCK = new IF_SFDC_SAP_REC_STOCK();

        String resultMessage = '';
        String resultCode = '';

        if(!Test.isRunningTest()) {
            outputObj = ifSTOCK.callOut();
            resultMessage = outputObj.result.resultMessage;
            resultCode = outputObj.result.resultCode;
        }
        system.debug('outputObj ::' + outputObj);
        
        Map<String, object> mapResult = new Map<String, object>{
            'resultMessage' => resultMessage,
            'resultCode' => resultCode 
        };
        return mapResult;
    }

    
    @AuraEnabled
    public static Map<String, Object> doReConfirm(String sObjName) {

        String resultCode = '';
        String resultMessage = '';

        try{
            if (sObjName == 'ORDER_H__c'){
                IF_SFDC_SAP_SAND_ORDER.Output outputObj = new IF_SFDC_SAP_SAND_ORDER.Output();
                IF_SFDC_SAP_SAND_ORDER ifORDER = new IF_SFDC_SAP_SAND_ORDER();
                
                if(!Test.isRunningTest()) {
                    outputObj = ifORDER.callOut();
                }
                system.debug('Import outputObj ::' + outputObj);

                resultCode = outputObj.result.resultCode;
                resultMessage = outputObj.result.resultMessage;
            }
            else if (sObjName == 'RELEASE_H__c'){
                IF_SFDC_SAP_SAND_RELEASE.Output outputObj = new IF_SFDC_SAP_SAND_RELEASE.Output();
                IF_SFDC_SAP_SAND_RELEASE ifRELEASE = new IF_SFDC_SAP_SAND_RELEASE();
                
                if(!Test.isRunningTest()) {
                    outputObj = ifRELEASE.callOut();
                }
                system.debug('Export outputObj ::' + outputObj);

                resultCode = outputObj.result.resultCode;
                resultMessage = outputObj.result.resultMessage;
            }
            else {
                resultCode = '-1';
                resultMessage = 'Unknown Error';
            }
        }
        catch(Exception e){
            system.debug('CK_ManualSyncDataController doReConfirm error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');    
            resultCode = '-1';
            resultMessage ='CK_ManualSyncDataController doReConfirm error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')';
        }

        Map<String, object> mapResult = new Map<String, object>{
            'resultCode' => resultCode,
            'resultMessage' => resultMessage
        };
        return mapResult;
    }

}