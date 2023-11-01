/************************************************************************************
 * File Name   		: CJFW_LineItemExcelPasteNewController.class
 * Author	  		: 진현욱
 * Date				: 2023-10-24
 * Tester	  		: 
 * Description 		: CJFW_LineItemExcelPasteNewController
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023-10-24      진현욱          Create
*************************************************************************************/
public without sharing class CJFW_LineItemExcelPasteNewController {

    /**
     * 초기화 (전체 업로드 선택 필드 목록 조회)
     * 
     * @param  sObjectName : 오브젝트명 (Quote - 견적서)          
     * @return Map<String, Object>
     *         - listField : 필드셋 목록
     *         - listRequiredField : 필드셋 목록 중 선택해제불가 리스트
    **/
    @AuraEnabled
    public static Map<String, Object> doInit(String sObjectName){

        // 필드 셋 조회
        String targetObjectApi = sObjectName+'LineItem';
        if(targetObjectApi.indexOf('Quote') != -1) targetObjectApi = 'CJFW_'+targetObjectApi+'__c';

        List<Map<String, Object>> listFieldMap = CommonUtil.getFieldSet(targetObjectApi, sObjectName+'LineItemExcelUpload');

        List<Map<String, String>> listField = new List<Map<String, String>>();
        List<String> listRequiredField = new List<String>();
 
        for ( Map<String, Object> objMap : listFieldMap ) {
            listField.add(new Map<String, String>{
                    'label' => String.valueOf(objMap.get('label')),
                    'value' => String.valueOf(objMap.get('apiName')),
                    'type' => String.valueOf(objMap.get('type'))
            });
            if ( objMap.get('required') == true )
                listRequiredField.add(String.valueOf(objMap.get('apiName')));
        }

        Map<String, Object> mapInitData = new Map<String, Object>{      
            'listField' => listField,   
            'listRequiredField' => listRequiredField
        };
        return mapInitData;
    }

    /**
     * 업로드된 데이터 유효성 체크 (전체 업로드)
     * 
     * @param  pricebookId : 가격 목록 Record Id      
     * @param  recordId : 상위 레코드 ID (견적서ID)          
     * @param  sObjectName : 상위 오브젝트명 (견적서)          
     * @param  listValidTargetData : 유효성 체크 대상 리스트          
     * @param  listExistProductCode : 기존 선택된 견적상품 코드 리스트       
     * @return Map<String, Object>
     *         - listResultData : 유효성 검사 성공 후 가공된 데이터 리스트
     *         - isValid : 유효성 검사 성공 여부
    **/
    @AuraEnabled
    public static Map<String, Object> doCheckValid (String pricebookId, String recordId, String sObjectName, List<Map<String, Object>> listValidTargetData, List<String> listExistProductCode){
        
        Set<String> setMonth = new Set<String>();
        Set<String> setProductCode = new Set<String>();
        Set<String> setDupInputProductCode = new Set<String>();
        Set<String> setExtId = new Set<String>();

        String targetObjectApi = sObjectName+'LineItem';
        if(targetObjectApi.indexOf('Quote') != -1) targetObjectApi = 'CJFW_'+targetObjectApi+'__c';

        // 유효성 체크를 위한 데이터 준비
        Map<String, String> mapMonthValue = CommonUtil.getMapPickListLabeltoValue(targetObjectApi, 'Month__c');
        Map<String, String> mapCenterValue = CommonUtil.getMapPickListValuetoLabel('Product2', 'lgs_ctr__c');
        Map<String, String> mapOriginValue = CommonUtil.getMapPickListValuetoLabel('Product2', 'migr_orinat_cd__c');

        for ( Map<String, Object> objData : listValidTargetData ){
            System.debug('objData ' + objData);
            if ( setProductCode.contains(String.valueOf(objData.get('ProductCode__c')))){
                setDupInputProductCode.add(String.valueOf(objData.get('ProductCode__c')));
            }
            else{
                setProductCode.add(String.valueOf(objData.get('ProductCode__c')));
            }
            setExtId.add(String.valueOf(objData.get('LogisticsCenter__c'))+'_'+String.valueOf(objData.get('ProductCode__c')));
            String strMonth = String.valueOf(objData.get('Month__c'));
            if ( mapMonthValue.get(strMonth) != null)
                setMonth.add(mapMonthValue.get(strMonth)+'__c');
        }
        System.debug('setExtId ' + setExtId);

        List<String> listMonth = new List<String>(setMonth);
        List<String> listCenter = new List<String>(mapCenterValue.keySet());
        System.debug('listCenter ' + listCenter);

        String strSetMonth = '';
        if ( !setMonth.isEmpty())
            strSetMonth = string.join(listMonth,',');

        String Query = '';
        Query += ' SELECT  Id, Name, Product2.gd_no__c, ProductCode, UnitPrice, toLabel(Product2.strg_cond_cd__c), ';
        Query += ' toLabel(Product2.migr_orinat_cd__c), Product2.fm_TaxType__c, Product2.bas_unit_cd__c, Product2.box_ctcnt_qty__c';
        Query += ' Product2.fm_LAR_CLS_NM__c, Product2.fm_LAR_CLS_ID__c,  ExtId__c, ';
        Query += ' Product2.fm_MID_CLS_NM__c, Product2.fm_MID_CLS_ID__c, ';
        Query += ' Product2.fm_SML_CLS_NM__c, Product2.fm_SML_CLS_CD__c, ';
        Query += ' Product2.fm_XSM_CLS_NM__c, Product2.fm_XSM_CLS_CD__c ';
        if(!setMonth.isEmpty())
            Query += ' ,' + strSetMonth + ', Old' + strSetMonth;
        Query += ' FROM    PriceBookEntry ';
        Query += ' WHERE   PriceBook2Id = : PricebookId';
        Query += ' AND     ExtId__c IN : setExtId';

        System.debug('strSetMonth ' + strSetMonth);
        System.debug('Query ' + Query);
        List<PriceBookEntry> listData = Database.query(Query);

        
        System.debug('listData ' + listData);
        Map<String,PriceBookEntry> mapPriceBookEntry = new Map<String,PriceBookEntry>();
        for ( PriceBookEntry objData : listData){
            mapPriceBookEntry.put(objData.ExtId__c, objData);
        }

        // 유효성 체크
        Boolean isValid = true;
        Integer orderCount = 1;
        List<Map<String, Object>> listInvalidData = new List<Map<String, Object>>();
        for ( Map<String, Object> objData : listValidTargetData ){
            Map<String, Object> objLineItem = new Map<String, Object> ();
            String strProductCode = String.valueOf(objData.get('ProductCode__c'));
            String strMonth = String.valueOf(objData.get('Month__c'));
            String strCenter = String.valueOf(objData.get('LogisticsCenter__c'));
            String strUnitPrice = String.valueOf(objData.get('UnitPrice__c'));
            String strProfitMargin = String.valueOf(objData.get('ProfitMargin__c'));
            String strExtId = String.valueOf(objData.get('LogisticsCenter__c'))+'_'+String.valueOf(objData.get('fm_ProductCode__c'));
            if ( mapCenterValue.get(strCenter) == null){
                objData.put('result','['+orderCount+'] [물류센터] 값에 오류가 있습니다.');
                listInvalidData.add(objData);
                isValid = false;
            } else if ( mapMonthValue.get(strMonth) == null){
                objData.put('result','['+orderCount+'] [월] 값에 오류가 있습니다.');
                listInvalidData.add(objData);
                isValid = false;
            } else if( strProductCode.length() != 6){
                objData.put('result','['+orderCount+'] [제품코드] 값에 오류가 있습니다.');
                listInvalidData.add(objData);
                isValid = false;
            } else if( setDupInputProductCode.contains(strProductCode)){
                objData.put('result','['+orderCount+'] 중복입력된 [제품코드] 입니다 .');
                listInvalidData.add(objData);
                isValid = false;
            } else if( listExistProductCode.contains(strProductCode)){
                objData.put('result','['+orderCount+'] 이미 추가된 [제품코드] 입니다 .');
                listInvalidData.add(objData);
                isValid = false;
            } else if ( !mapPriceBookEntry.keySet().contains(strExtId)){
                System.debug('setProductCode ' + setProductCode);                
                objData.put('result','['+orderCount+'] 해당 센터에 존재하지 않는 [제품코드] 입니다.');
                listInvalidData.add(objData);
                isValid = false;
            } else if (mapPriceBookEntry.get(strExtId).get(mapMonthValue.get(strMonth)+'__c') == null ){   
                objData.put('result','['+orderCount+'] 해당[월]에 [기준매입가]가 지정되어 있지 않습니다.');
                listInvalidData.add(objData);
                isValid = false;
            } else if (mapPriceBookEntry.get(strExtId).get(mapMonthValue.get(strMonth)+'__c') == 0 ){
                objData.put('result','['+orderCount+'] 해당[월]에 [기준매입가]가 지정되어 있지 않습니다.');
                listInvalidData.add(objData);
                isValid = false;
            } else if ( strUnitPrice != null && !strUnitPrice.isNumeric()){
                objData.put('result','['+orderCount+'] [가격] 값에 오류가 있습니다.');
                listInvalidData.add(objData);
                isValid = false;
            } else if ( strProfitMargin != null && !strProfitMargin.isNumeric()){
                objData.put('result','['+orderCount+'] [매익률] 값에 오류가 있습니다.');
                listInvalidData.add(objData);
                isValid = false;
            } 
            orderCount++;
        }

        // 유효성 체크 성공 시 견적 리스트로 들어갈 수 있게 가공
        List<Map<String, Object>> listLineItem = new List<Map<String, Object>>();
        if (isValid){
            orderCount = 1;
            Set<String> listSelectedField = listValidTargetData[0].keyset();
            Boolean isPriceExist = listSelectedField.contains('UnitPrice') ? true : false ; 
            Boolean isMarginExist = listSelectedField.contains('ProfitMargin__c') ? true : false ; 
            
            for ( Map<String, Object> objData : listValidTargetData ){
                Map<String, Object> objLineItem = new Map<String, Object> ();

                String strProductCode = String.valueOf(objData.get('ProductCode__c'));
                String strMonth = String.valueOf(objData.get('Month__c'));
                String strCenter = String.valueOf(objData.get('LogisticsCenter__c'));
                String strExtId = String.valueOf(objData.get('LogisticsCenter__c'))+'_'+String.valueOf(objData.get('fm_ProductCode__c'));
                Decimal strUnitPrice = (objData.get('UnitPrice') != null ? Decimal.valueOf(String.valueOf(objData.get('UnitPrice'))) : 10);
                Decimal strProfitMargin = (objData.get('ProfitMargin__c') != null ? Decimal.valueOf(String.valueOf(objData.get('ProfitMargin__c'))) : 0);
                Decimal strBasePurchasePrice = (Decimal) mapPriceBookEntry.get(strExtId).get(mapMonthValue.get(strMonth)+'__c');
                Decimal strOldBasePurchasePrice = (Decimal) mapPriceBookEntry.get(strExtId).get('Old'+mapMonthValue.get(strMonth)+'__c');

                String strTaxTypeName = mapPriceBookEntry.get(strExtId).Product2.fm_TaxType__c;

                Decimal strVAT = 0;
                Decimal strUnitPriceWithVAT = strUnitPrice;
                
                objLineItem.put('SortOrder__c', orderCount++);
                objLineItem.put(sObjectName+'Id', recordId);
                objLineItem.put('ProductCode__c', strProductCode);
                objLineItem.put('BasePurchasePrice__c', strBasePurchasePrice);
                objLineItem.put('OldBasePurchasePrice__c', strOldBasePurchasePrice);

                if ( strBasePurchasePrice == 1){
                    strUnitPrice = 1;
                    strProfitMargin = 100;
                    strVAT = 0;
                    strUnitPriceWithVAT = 1;
                }
                else if( isPriceExist){
                    if( strUnitPrice < 10) strUnitPrice = 10;
                    else if ( strUnitPrice > 1000000000) strUnitPrice = 1000000000;
                    strUnitPrice = strUnitPrice.setScale(-1,System.RoundingMode.UP);  
                    strProfitMargin = ((strUnitPrice - strBasePurchasePrice) / strUnitPrice  * 100).setScale(2);

                    if ( strProfitMargin > 99 ) {
                        strProfitMargin = 99;
                        strUnitPrice = strBasePurchasePrice / (1 - strProfitMargin/100);
                    }
                    strVAT = (strTaxTypeName == '과세' ? 1 : 0) * strUnitPrice * 0.1;
                    strUnitPriceWithVAT = strUnitPrice + strVAT;
                }
                else if(isMarginExist){
                    if ( strProfitMargin > 99 ) strProfitMargin = 99;
                    else if ( strProfitMargin < -100000000) strProfitMargin = -100000000;

                    strProfitMargin = strProfitMargin.setScale(2);
                    strUnitPrice = strBasePurchasePrice / (1 - strProfitMargin/100);
                    strUnitPrice = strUnitPrice.setScale(-1,System.RoundingMode.UP);

                    strProfitMargin = ((strUnitPrice - strBasePurchasePrice)/strUnitPrice * 100).setScale(2);
                    strVAT = (strTaxTypeName == '과세' ? 1 : 0) * strUnitPrice * 0.1;
                    strUnitPriceWithVAT = strUnitPrice + strVAT;
                }
                objLineItem.put('TaxTypeName__c', strTaxTypeName);
                objLineItem.put('UnitPrice__c', strUnitPrice);
                objLineItem.put('ProfitMargin__c', strProfitMargin);
                objLineItem.put('UnitPriceWithVAT__c', strUnitPriceWithVAT);
                objLineItem.put('VAT__c', strVAT);
                objLineItem.put('Quantity__c', 1);
                //objLineItem.put('PricebookEntryId', mapPriceBookEntry.get(strExtId).Id);
                objLineItem.put('ProductName__c', mapPriceBookEntry.get(strExtId).Name);
                objLineItem.put('QuantityUnitOfMeasure__c', mapPriceBookEntry.get(strExtId).Product2.bas_unit_cd__c);
                objLineItem.put('CountryOfOriginName__c', mapPriceBookEntry.get(strExtId).Product2.migr_orinat_cd__c);
                objLineItem.put('Month__c', mapMonthValue.get(strMonth));
                objLineItem.put('MonthToLabel', strMonth);
                objLineItem.put('LogisticsCenter__c', strCenter);
                objLineItem.put('StorageConditionName__c', mapPriceBookEntry.get(strExtId).Product2.strg_cond_cd__c);                
                objLineItem.put('ProductCategoryLName__c', mapPriceBookEntry.get(strExtId).Product2.fm_LAR_CLS_NM__c);
                objLineItem.put('ProductCategoryMName__c', mapPriceBookEntry.get(strExtId).Product2.fm_MID_CLS_NM__c);
                objLineItem.put('ProductCategoryCode__c', mapPriceBookEntry.get(strExtId).Product2.fm_XSM_CLS_CD__c);
                objLineItem.put('CenterToLabel', mapCenterValue.get(strCenter));
                listLineItem.add(objLineItem);
            }
        }

        Map<String, Object> mapInitData = new Map<String, Object>{      
            'listResultData' => isValid ? listLineItem : listInvalidData,   
            'isValid' => isValid
        };
        return mapInitData;
    }
    

}