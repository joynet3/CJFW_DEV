/*
* ==================================================================================
*   File Name   : CK_InAndOutMgmtController.cls
*   Author      : Minje.kim
*   Date        : 2022.05.09
*   Tester      : CK_InAndOutMgmtController_test.cls
*   Description : CK 입출고 관리 Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.05.09    Minje.kim       Create
* ==================================================================================
*/

public with sharing class CK_InAndOutMgmtController {


    @AuraEnabled
    public static List<SObject> doGetData(Map<String, Object> mapParam) {

        try{
            
            Map<String, Object> mapInitData = new Map<String, Object>{            
                'SHIP_TYP__c' => getPicklistValues('ORDER_H__c', 'SHIP_TYP__c', true, false)
            };

            List<SObject> listData;

            String screenStatus = String.valueOf(mapParam.get('screenStatus')) ;
            
            String Query = '';
            // 입고
            if(screenStatus == 'Import'){
                Query += 'SELECT  Id, Name, tolabel(SHIP_TYP__c), IFDATE__c, EBELN__c, EBELN_R__c, RESWK__c, CHECK__c, CONFIRM__c, SND_YN__c, XDATS__c, XTIMS__c, ';
                Query += '(SELECT Id, Name, EBELN__c, EBELP__c, LOEKZ__c, WERKS__c, LGORT__c, MATNR__c, MAKTX__c, MENGE__c, MEINS__c, RAUBE__c, EINDT__c, RETPO__c, BUDAT__c, ORDER_H__c FROM ORDER_D__r WHERE MENGE__c > 0 ORDER BY EBELP__c)  ';
                Query += 'FROM   ORDER_H__c  ';
                Query += 'WHERE  CONFIRM__c = \'N\'  ';
                Query += ' ORDER BY  EBELN__c' ;
            }
            // 입고
            else if (screenStatus == 'Export'){
                Query += 'SELECT  Id, Name, EBELN__c, CHECK__c, CONFIRM__c, SND_YN__c, XDATS__c, XTIMS__c, ';
                Query += '(SELECT Id, Name, EBELN__c, EBELP__c, WERKS__c, LGORT__c, MATNR__c, MAKTX__c, CHARG__c, MENGE__c, MEINS__c, RAUBE__c, EINDT__c, RETPO__c FROM RELEASE_D__r WHERE MENGE__c > 0 ORDER BY EBELP__c)  ';
                Query += 'FROM   RELEASE_H__c ';
                Query += 'WHERE  CONFIRM__c = \'N\'  ';
                Query += ' ORDER BY  EBELN__c' ;
            }
            system.debug('Query ::::: ' +Query);
            listData = Database.query(Query);
            
            return listData;
        }
        catch(Exception e){
            system.debug('CK_InAndOutMgmtController doGetData error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
        
    }

    
    // @AuraEnabled
    // public static List<Object> doSaveData(Map<String, Object> mapParam) {

    @AuraEnabled
    public static void doSaveData(List<SObject> listData, List<SObject> listSubData) {
        system.debug('listData ::::: ' + listData);
        system.debug('listSubData ::::: ' + listSubData);

        try{
            database.update(listData);
            database.update(listSubData); 
        }
        catch(Exception e){
            system.debug('CK_InAndOutMgmtController doGetData error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

    
    @AuraEnabled
    public static Map<String, Object> doConfirmData(String screenStatus) {

        String resultCode = '';
        String resultMessage = '';
        try{
            if (screenStatus == 'Import'){
                IF_SFDC_SAP_SAND_ORDER.Output outputObj = new IF_SFDC_SAP_SAND_ORDER.Output();
                IF_SFDC_SAP_SAND_ORDER ifORDER = new IF_SFDC_SAP_SAND_ORDER();

                List<Order_H__C> listCheckOrder_H = [
                    SELECT IFDATE__c, EBELN__c, EBELN_R__c, RESWK__c, CHECK__c, SHIP_TYP__c, CONFIRM__c, SND_YN__c, XDATS__c, XTIMS__c
                    FROM Order_H__C
                    WHERE CHECK__c = 'Y' AND EBELN_R__c = ''
                ];

                if( listCheckOrder_H.isEmpty()){
                    resultCode = '-1';
                    resultMessage = '확정대상이 없습니다.';
                }
                else{
                    if(!Test.isRunningTest()) {
                        outputObj = ifORDER.callOut();
                    }
                    system.debug('Import outputObj ::' + outputObj);
    
                    resultCode = outputObj.result.resultCode;
                    resultMessage = outputObj.result.resultMessage;
                }
            }
            else if (screenStatus == 'Export'){
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
            system.debug('CK_InAndOutMgmtController doConfirmData error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');    
            resultCode = '-1';
            resultMessage ='CK_InAndOutMgmtController doConfirmData error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')';
        }

        Map<String, object> mapResult = new Map<String, object>{
            'resultCode' => resultCode,
            'resultMessage' => resultMessage
        };
        return mapResult;
    }

    // @InvocableMethod(label='Send STOCK to SAP')
    // public static void doSendStock(List<STOCK__c> listTarget) {


    //     String resultCode = '';
    //     String resultMessage = '';
    //     try{
    //         IF_SFDC_SAP_SAND_STOCK.Output outputObj = new IF_SFDC_SAP_SAND_STOCK.Output();
    //         IF_SFDC_SAP_SAND_STOCK ifSTOCK = new IF_SFDC_SAP_SAND_STOCK();
            
    //         outputObj = ifSTOCK.callOut(listTarget);
    //         system.debug('Stock outputObj ::' + outputObj);

    //         resultCode = outputObj.result.resultCode;
    //         resultMessage = outputObj.result.resultMessage;
    //     }
    //     catch(Exception e){
    //         resultCode = '-1';
    //         resultMessage ='CK_InAndOutMgmtController doSendStock error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')';
    //         system.debug('CODE :: ' + resultCode + ' : ' + resultMessage);    
    //     }
    // }


    @AuraEnabled
	public static List<Map<String, String>> getPicklistValues(String ObjectApi_name, String Field_name, Boolean isNone, Boolean isLabelToValue){
		List<Map<String, String>> lstPickvals = new List<Map<String, String>>();

		//String strNoneLabel = Label.Text_None;

		String strNoneLabel = 'None';

		if(isNone) {
			lstPickvals.add(new Map<String, String>{'value' => '', 'label' => '-- '+strNoneLabel+' --'});
		}

		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
		Sobject Object_name = targetType.newSObject();
		Schema.sObjectType sobject_type = Object_name.getSObjectType();
		Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
		Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
		List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();    

		for (Schema.PicklistEntry a : pick_list_values) {

			if(isLabelToValue) {
				lstPickvals.add(new Map<String, String>{'value' => a.getValue(), 'label' => a.getValue()});
			}else {
				lstPickvals.add(new Map<String, String>{'value' => a.getValue(), 'label' => a.getLabel()});
			}      
		}

		return lstPickvals;
	}
}