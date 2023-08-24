/*
* ==================================================================================
*   File Name   : CalcNoPriceFuelActivity_ba.cls
*   Author      : Minje.kim
*   Date        : 2023.01.15
*   Tester      : CalcNoPriceFuelActivity_ba_test.cls
*   Description : 단가 미등록 주유비 재계산 배치
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2023.01.15    Minje.kim       Create
* ==================================================================================
*/
public without sharing class CalcNoPriceFuelActivity_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    Map<String, Integer> mapData = new Map<String, Integer>();     
    Map<String, String> mapOilType = new Map<String, String>();        

    public CalcNoPriceFuelActivity_ba() {
        
    }

    /***********************************************************************************************************
    *  Bacth   : Start
    *  내용    : 주유비 단가 I/F 수신 후 단가가 계산되지 않은 주유비 재계산 대상 선정
    ************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('CalcNoPriceFuelActivity_ba Start !!');
        mapOilType = CommonUtil.getMapPickListLabel('User', 'oil_type_cd__c');

        Date dateToday = Date.today();
        
        // 1. 주유비 단가 I/F 수신
        IFUtil ifutilWrapper = new IFUtil('IF_SFDC_EACCT_INQ_OIL_AMOUNT');
        Map<String, String> mapRequestBody = new Map<String, String>();
        mapRequestBody.put('system_type_cd','LIF1007');
        mapRequestBody.put('opcode','EC001');
        mapRequestBody.put('COM_CD','FW00');
        // mapRequestBody.put('BASE_MON', '202301');
        mapRequestBody.put('BASE_MON', String.valueof(dateToday.year()) + String.valueof(dateToday.month()).leftPad(2, '0'));
        mapRequestBody.put('OIL_TYPE_CD', 'A');

        String strJsonRequestBody = JSON.serialize(mapRequestBody);
        HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

        Map<String, String> mapOilTypeToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'oil_type_cd__c');

        system.debug( 'check Input ::: ' + strJsonRequestBody );
        system.debug( 'response.getStatusCode() ::: ' + response.getStatusCode() );
        system.debug( 'check Output ::: ' + response.getBody() );

        // I/F 연결성공
        if ( response.getStatusCode() == 200  ){
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
            // [재무시스템] 주유비 단가가 없거나 다른 에러가 발생
            if ( resultMap.get('ERR_CD') == 'E') {
                system.debug( '[I/F Error] ::: 재무시스템['+resultMap.get('ERR_CD')+'] '+resultMap.get('ERR_MSG_CTT'));
                return Database.getQueryLocator('SELECT Id FROM EVENT LIMIT 0');
            }
            // [중계서버] 에러가 발생
            else if ( resultMap.get('ERR_CD') == '9999') {
                system.debug( '[I/F Error] ::: 중계서버['+resultMap.get('ERR_CD')+'] '+resultMap.get('ERR_MSG_CTT'));
                return Database.getQueryLocator('SELECT Id FROM EVENT LIMIT 0');
            }
            // 정상 인입
            else {
                system.debug( 'check resultMap ::: ' + resultMap.get('ERR_CD'));
                system.debug( 'check resultMap ::: ' + resultMap.get('ERR_MSG_CTT'));
                system.debug( 'check resultMap ::: ' + resultMap.get('DS_MASTER'));
                List<Object> listData = (List<Object>)((Map<String, Object>) resultMap.get('DS_MASTER')).get('data');
               
                for ( Object objData : listData){
                    Map<String, Object> mapObjData = (Map<String, Object>) objData; 
                    system.debug( 'mapObjData ::: ' + mapObjData);
                    String OIL_TYPE_CD = String.valueOf(mapObjData.get('OIL_TYPE_CD'));
                    Integer DPRC_UNITP = Integer.valueOf(String.valueOf(mapObjData.get('OIL_UNITP')));

                    mapData.put(OIL_TYPE_CD, DPRC_UNITP);
                }
                system.debug( 'mapData ::: ' + mapData);
            }
        }
        // IF 연결실패
        else {
            system.debug( '[I/F Error] ::: [' + response.getStatusCode() + '] 서버접속 실패');
            return Database.getQueryLocator('SELECT Id FROM EVENT LIMIT 0');
        }

        // 2. 단가가 계산되지 않은 주유비 대상 선정
        String strQuery = '';
        strQuery += '   SELECT  Id, Distancekm__c, oil_type_cd__c, oil_type_nm__c';
        strQuery += '   FROM    Event';        
        strQuery += '   WHERE   (Distancekm__c != null AND Distancekm__c != 0)';
        strQuery += '   AND     (VehicleRefuelingCosts__c = null OR VehicleRefuelingCosts__c = 0)';

        return Database.getQueryLocator(strQuery);
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 주유비 재계산 대상으로 유류유형에 맞게 단가 계산
    ************************************************************************************************************/
    public void execute(Database.BatchableContext BC, List<Event> listEvent) {
        List<Event> listUpdateTarget = new List<Event>();
        for (Event objEvent : listEvent){
            if ( mapData.get(objEvent.oil_type_cd__c) != null){
                // 주유비 계산 (0의자리 반올림 처리)
                Decimal Cost = objEvent.Distancekm__c * mapData.get(objEvent.oil_type_cd__c);
                Cost = Cost.round(System.RoundingMode.HALF_UP);
                objEvent.VehicleRefuelingCosts__c = Cost;

                // 명목단가, 실질단가 계산
                Decimal ActualOilUnitPrice = Cost / objEvent.Distancekm__c ; 
                objEvent.ActualOilUnitPrice__c = ActualOilUnitPrice.setScale(2, System.RoundingMode.HALF_UP);
                objEvent.NominalOilUnitPrice__c = mapData.get(objEvent.oil_type_cd__c);

                // isSystem (유효성 체크 Pass 여부)
                objEvent.isSystem__c = true;
                listUpdateTarget.add(objEvent);
            }
        }
        if( !listUpdateTarget.isEmpty() )
            update listUpdateTarget;
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 내용 없음
    ************************************************************************************************************/
    public void finish(Database.BatchableContext BC) {
        System.debug('CalcNoPriceFuelActivity_ba finish !!');
    }
}