/************************************************************************************
 * File Name   		: DN_FieldTracking.class
 * Author	  		: mj.kim
 * Date				: 2022-08-19
 * Tester	  		: DN_FieldTracking_test.cls
 * Description 		: DN_FieldTracking
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022-08-19      mj.kim          Create
*************************************************************************************/
public without sharing class DN_FieldTracking {    
    /**
     * Field 변경이력 저장용도
     * 
     * @param strObjectAPI : Object Api Name
     * @param strFieldSetAPI : FieldSet Api Name
     * @param listNew : listNew(Trigger)
     * @param mapOld : mapOld(Trigger)
     * @return 
     *         
    **/
    public static void doFieldTrackingInsert(String strObjectAPI, String strFieldSetAPI, List<SObject> listNew, Map<Id, SObject> mapOld) {
        List<Map<String, Object>> listFieldMap = CommonUtil.getFieldSet(strObjectAPI, strFieldSetAPI);

        System.debug('==============> listFieldMap : '+listFieldMap);

        SObject tempOld;
        List<FieldTracking__c> listFieldTracking = new List<FieldTracking__c>();
        FieldTracking__c tempFieldTracking;
        String apiName;
        String dataType;

        List<String> listLookupId = new List<String>();
        Map<String, Set<String>> mapLookupList = new Map<String, Set<String>>();
        Map<String, String> mapNameFromId = new Map<String, String>();


        // LookUp getNameFromId 
        for(SObject obj : listNew) {
            tempOld = mapOld.get(obj.Id);
            for(Map<String, Object> objMap : listFieldMap) {
                apiName = (String)objMap.get('apiName');
                dataType = (String)objMap.get('type');
                if(obj.get(apiName) != tempOld.get(apiName)){
                    if(dataType == 'REFERENCE') { 
                        listLookupId.add((String)tempOld.get(apiName));
                        listLookupId.add((String)obj.get(apiName));
                    }
                }
            }
        }

        if ( !listLookupId.isEmpty()){
            for ( String idLookup : listLookupId){
                if(idLookup <> null && idLookup.length() > 0) {
                    String prefix = idLookup.substring(0,3);
                    Set<String> setTemp = new Set<String>();

                    if ( mapLookupList.get(prefix) != null ) 
                        setTemp = mapLookupList.get(prefix);

                    setTemp.add(idLookup);
                    mapLookupList.put(prefix, setTemp);
                }
            }
            
            if ( !mapLookupList.isEmpty()){
                for ( String strPrefix : mapLookupList.keySet()){
                    String sObjName = CommonUtil.findObjectNameFromRecordIdPrefix(strPrefix);
                    Set<String> listTargetId = mapLookupList.get(strPrefix);

                    String query = '';
                    query += 'SELECT    Id, Name ';
                    query += '  FROM    ' + sObjName  ;
                    query += ' WHERE    Id IN: listTargetId ' ;
                    system.debug('query :::' + query);
                    List<SObject> listTemp = Database.query(query);

                    for( SObject objTemp : listTemp ){
                        mapNameFromId.put(objTemp.Id, (String) objTemp.get('Name'));
                    }
                }
            }
        }

        

        for(SObject obj : listNew) {
            tempOld = mapOld.get(obj.Id);
            for(Map<String, Object> objMap : listFieldMap) {
                if(obj.get((String)objMap.get('apiName')) != tempOld.get((String)objMap.get('apiName'))){
                    apiName = (String)objMap.get('apiName');
                    dataType = (String)objMap.get('type');

                    tempFieldTracking = new FieldTracking__c();
                    //tempFieldTracking.Name = (String)obj.Id;
                    tempFieldTracking.API__c = apiName;
                    tempFieldTracking.Label__c = (String)objMap.get('label');

                    String strLookupFieldName = '';
                    if(strObjectAPI.indexOf('__c') < 0) 
                        strLookupFieldName = strObjectAPI + '__c';
                    else
                        strLookupFieldName = strObjectAPI;

                    tempFieldTracking.put(strLookupFieldName, obj.Id);

                    system.debug('dataType :: ' + dataType);
                    if(dataType == 'BOOLEAN') {
                        tempFieldTracking.OriginalValue__c = String.valueOf((Boolean)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = String.valueOf((Boolean)obj.get(apiName));
                    }
                    else if(dataType == 'DATE') {
                        tempFieldTracking.OriginalValue__c = String.valueOf((Date)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = String.valueOf((Date)obj.get(apiName));
                    }
                    else if(dataType == 'DATETIME') {
                        tempFieldTracking.OriginalValue__c = String.valueOf((Datetime)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = String.valueOf((Datetime)obj.get(apiName));
                    }
                    else if(dataType == 'NUMBER') {
                        tempFieldTracking.OriginalValue__c = String.valueOf((Decimal)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = String.valueOf((Decimal)obj.get(apiName));
                    }
                    else if(dataType == 'CURRENCY') {
                        Decimal oldValue = (Decimal)tempOld.get(apiName);
                        Decimal newValue = (Decimal)obj.get(apiName);

                        tempFieldTracking.OriginalValue__c = oldValue != null ? String.valueOf(oldValue.format()) : null;
                        tempFieldTracking.NewValue__c =  newValue != null ? String.valueOf(newValue.format()) : null;
                    }
                    else if(dataType == 'DECIMAL') {
                        tempFieldTracking.OriginalValue__c = String.valueOf((Decimal)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = String.valueOf((Decimal)obj.get(apiName));
                    }
                    else if(dataType == 'DOUBLE') { 
                        tempFieldTracking.OriginalValue__c = String.valueOf((Decimal)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = String.valueOf((Decimal)obj.get(apiName));
                    }
                    else if(dataType == 'INTEGER') { 
                        tempFieldTracking.OriginalValue__c = String.valueOf((Decimal)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = String.valueOf((Decimal)obj.get(apiName));
                    }
                    else if(dataType == 'PERCENT') { 
                        tempFieldTracking.OriginalValue__c = String.valueOf((Decimal)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = String.valueOf((Decimal)obj.get(apiName));
                    }                    
                    else if(dataType == 'PICKLIST') {
                        String strBeforeValue = (String)tempOld.get(apiName);                        
                        String strNewValue = (String)obj.get(apiName);

                        String strBeforeLabel = '';
                        String strNewLabel = '';

                        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(strObjectAPI);
                        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
                        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(apiName).getDescribe();
                        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                        for (Schema.PicklistEntry pickListVal : ple) {

                            if(pickListVal.getValue() == strBeforeValue) {
                                strBeforeLabel = pickListVal.getLabel();
                            }

                            if(pickListVal.getValue() == strNewValue) {
                                strNewValue = pickListVal.getLabel();
                            }
                        }

                        tempFieldTracking.OriginalValue__c = strBeforeLabel;
                        tempFieldTracking.NewValue__c = strNewValue;
                    }
                    else if(dataType == 'REFERENCE') { 
                        tempFieldTracking.OriginalValue__c = mapNameFromId.get((String)tempOld.get(apiName));
                        tempFieldTracking.NewValue__c = mapNameFromId.get((String)obj.get(apiName));
                    }      
                    else {
                        tempFieldTracking.OriginalValue__c = (String)tempOld.get(apiName);
                        tempFieldTracking.NewValue__c = (String)obj.get(apiName);
                    }

                    tempFieldTracking.User__c = UserInfo.getUserId();
                    tempFieldTracking.ChangeDT__c = DateTime.now();
                    listFieldTracking.add(tempFieldTracking);
                }
            }
        }
        if(!listFieldTracking.isEmpty()) insert listFieldTracking;
    }

    /**
     * Field 변경이력 조회
     * 
     * @param strRecordId : Record Id     
     * @return List<FieldTracking__c> : 조회결과
     *         
    **/

    @AuraEnabled
    public static List<FieldTracking__c> getData(String strRecordId){
        List<FieldTracking__c> listFieldTracking = new List<FieldTracking__c>();
        listFieldTracking = [
                SELECT  Id, Name, Label__c, OriginalValue__c, NewValue__c, User__c, fm_User__c, ChangeDT__c
                FROM    FieldTracking__c
                WHERE   Name =:strRecordId
                ORDER BY ChangeDT__c DESC
        ];
        return listFieldTracking;
    }



}