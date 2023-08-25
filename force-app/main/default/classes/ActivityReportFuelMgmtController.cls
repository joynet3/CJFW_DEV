/*
* ==================================================================================
*   File Name   : ActivityReportFuelMgmtController.cls
*   Author      : Minje.kim
*   Date        : 2022.08.02
*   Tester      : ActivityReportFuelMgmtController_test.cls
*   Description : 활동별 주유비 관리 Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.08.02    Minje.kim       Create
*   1.1     2023.04.11    sy.lee          update
* ==================================================================================
*/

public without sharing class ActivityReportFuelMgmtController {

    public class Output {
        public String ERR_CD ;
        public String ERR_MSG_CTT;
        public OutputSub DS_MASTER;
    }

    public class OutputSub {
        public List<OutputThird> data;
        public String SVC_ERR_MSG_TEXT;
        public Integer ErrorCode;
    }
    
    public class OutputThird {
        public String COM_CD;
        public String BASE_MON;
        public String OIL_TYPE_CD;
        public Integer OIL_UNITP;
        public Integer DPRC_UNITP;
    }

    public class OilInfo {
        @AuraEnabled
        public String TypeCode {get;set;}
        @AuraEnabled
        public String TypeName {get;set;}
        @AuraEnabled
        public String Price {get;set;}
    }

    /**
     * 주유비 등록 Init(주유비정보, 주유비단가조회)
     * 
     * @param recordId 활동보고(ActivityReport__c) Record Id
     * @return Map<String, object>
     *           - strStatus : 상태
     *           - strMessage : 메시지
     *           - listData : 업무 정보
     *           - objOilInfo : 주유비 단가 정보
     *           - objActivityReport : 활동보고 정보
     *
    **/
    @AuraEnabled
    public static  Map<String, object> getInitData(Id recordId) {

        try{

            List<Event> listData = new List<Event>();
            List<Event> listData2 = new List<Event>();

            List<ActivityReport__c> listActivityReport = new List<ActivityReport__c>();
            listActivityReport = [
                SELECT   Id, OwnerId, ApprovalStatus__c, OilTotalAmount__c, OilTotalDistance__c, EventStartDate__c
                FROM     ActivityReport__c
                WHERE    Id =: recordId
                LIMIT    1
            ]; 
            if ( listActivityReport.isEmpty()) return new Map<String, object>();

            ActivityReport__c objActivityReport = listActivityReport[0];

            User objUser = [
                SELECT  Id, ProfileId, oil_type_cd__c
                FROM    User
                WHERE   Id =: objActivityReport.OwnerId
            ];

            listData = [
                SELECT   Id, Account__c, Account__r.Name, Lead__c, Lead__r.Name, Subject, What.Id, What.Name, What.Type, 
                         VehicleRefuelingCosts__c, Distancekm__c, ActivityReport__c, StartDateTime, EndDateTime, Description, 
                         Departure__c, Arrival__c, DepartureDesc__c, ArrivalDesc__c, 
                         WayPoint1__c, WayPoint2__c, WayPoint3__c, WayPoint4__c, WayPoint5__c, 
                         WayPointDesc1__c, WayPointDesc2__c, WayPointDesc3__c, WayPointDesc4__c, WayPointDesc5__c
                FROM     Event
                WHERE    What.Type != ''
                AND      ActivityReport__c =: recordId
                AND      OwnerId =: objActivityReport.OwnerId
                AND      WorkType__c = '외근'
                AND      isPassenger__c = false
                ORDER BY StartDateTime
            ];

            listData2 = [
                SELECT   Id, Account__c, Account__r.Name, Lead__c, Lead__r.Name, Subject,
                         VehicleRefuelingCosts__c, Distancekm__c, ActivityReport__c, StartDateTime, EndDateTime, Description, 
                         Departure__c, Arrival__c, DepartureDesc__c, ArrivalDesc__c, 
                         WayPoint1__c, WayPoint2__c, WayPoint3__c, WayPoint4__c, WayPoint5__c, 
                         WayPointDesc1__c, WayPointDesc2__c, WayPointDesc3__c, WayPointDesc4__c, WayPointDesc5__c
                FROM     Event
                WHERE    What.Type = ''
                AND      ActivityReport__c =: recordId
                AND      OwnerId =: objActivityReport.OwnerId
                AND      WorkType__c = '외근'
                AND      isPassenger__c = false
                ORDER BY StartDateTime
            ]; 

            if (!listData2.isEmpty())
                listData.addall(listData2);

            system.debug('listData ::::: ' + listData);

            // 주유비 단가조회
            
            String strStatus = 'SUCCESS';
            String strMessage = '';
            Output objOutput = new Output();
            OilInfo objOilInfo = new OilInfo();

            if( objUser.oil_type_cd__c == '' ||  objUser.oil_type_cd__c == null){
                strStatus = 'ERROR';
                strMessage = '[ERROR] 유류유형이 설정되어 있지 않아 주유비 작성이 불가합니다.';
            }
            else{
                IFUtil ifutilWrapper = new IFUtil('IF_SFDC_EACCT_INQ_OIL_AMOUNT');

                Map<String, String> mapRequestBody = new Map<String, String>();
                mapRequestBody.put('system_type_cd','LIF1007');
                mapRequestBody.put('opcode','EC001');
                mapRequestBody.put('COM_CD','FW00');
                mapRequestBody.put('BASE_MON', String.valueof(objActivityReport.EventStartDate__c.year()) + String.valueof(objActivityReport.EventStartDate__c.month()).leftPad(2, '0'));
                mapRequestBody.put('OIL_TYPE_CD', String.valueOf(objUser.oil_type_cd__c));

                String strJsonRequestBody = JSON.serialize(mapRequestBody);
                HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

                Map<String, String> mapOilTypeToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'oil_type_cd__c');

                system.debug( 'check Input ::: ' + strJsonRequestBody );
                system.debug( 'check Output ::: ' + response.getBody() );
                system.debug( 'check Output ::: ' + objOutput );

                if(response.getStatusCode() == 200) {
                    
                    system.debug( '중계서버 연결 성공 ::: ');
                    objOutput = (Output)JSON.deserialize(response.getBody(), Output.class);

                    if(objOutput.ERR_CD == 'E'){
                        system.debug( '값 받아오기 실패 ::: ');
                        strStatus = 'ERROR';
                        if ( objOutput.ERR_MSG_CTT == '검색된 결과가 없습니다.'){
                            strStatus = 'warning';
                            strMessage = '당월 주유비 단가가 아직 확정되지 않아 추후 확정시 자동 업데이트됩니다.';
                            objOilInfo.TypeCode = String.valueOf(objUser.oil_type_cd__c);
                            objOilInfo.TypeName = mapOilTypeToLabel.get(String.valueOf(objUser.oil_type_cd__c));
                        }
                        else {
                            strMessage = '[I/F Error] '+ objOutput.ERR_MSG_CTT + '관리자에게 문의하세요.';
                        }
                    }
                    else if(objOutput.ERR_CD == '9999'){
                        system.debug( '재무시스템 연결 실패 ::: ');
                        strStatus = 'ERROR';
                        strMessage = '[I/F Error] 재무시스템 주유비 단가 수신오류. 관리자에게 문의하세요.';
                    }
                    else {
                        objOilInfo.TypeCode = objOutput.DS_MASTER.data[0].OIL_TYPE_CD;
                        objOilInfo.TypeName = mapOilTypeToLabel.get(objOutput.DS_MASTER.data[0].OIL_TYPE_CD);
                        objOilInfo.Price = String.valueOf(objOutput.DS_MASTER.data[0].OIL_UNITP);
                    }
                } else {
                    system.debug( '중계서버 연결 실패 ::: ');
                    strStatus = 'ERROR';
                    strMessage = '[I/F Error] 재무시스템 주유비 단가 수신오류. 관리자에게 문의하세요.';
                }

                Organization objOrganization = [SELECT IsSandbox FROM Organization LIMIT 1];

                if ( objOrganization.IsSandbox){
                    // QA 서버에서는 가데이터 사용
                    String oiltype = String.valueOf(objUser.oil_type_cd__c);

                    if ( oiltype == '1'){
                        objOilInfo.TypeName = '휘발유';
                        objOilInfo.Price = '278';
                    }                        
                    else if ( oiltype == '2'){
                        objOilInfo.TypeName = '경유';
                        objOilInfo.Price = '291';
                    }                        
                    else if ( oiltype == '3'){
                        objOilInfo.TypeName = 'LPG';
                        objOilInfo.Price = '247';
                    }                        
                    else if ( oiltype == '4'){
                        objOilInfo.TypeName = '수소차';
                        objOilInfo.Price = '190';
                    }                        
                    else if ( oiltype == '5'){
                        objOilInfo.TypeName = '전기차';
                        objOilInfo.Price = '169';
                    } 
                    objOilInfo.TypeCode = oiltype;
                    
                    strStatus = 'warning';
                    strMessage = 'QA환경에서는 단가데이터가 임의로 지정됩니다.';
                }

            }
            system.debug( 'check objOilInfo ::: ' + objOilInfo );

            // 개인별 주유비 신청 가능 기간 예외처리 설정 값 조회
            FuelExceptionDateMgmt__c objFuelExceptionDateMgmtDefault = FuelExceptionDateMgmt__c.getOrgDefaults();
            if (objFuelExceptionDateMgmtDefault.Id == null) objFuelExceptionDateMgmtDefault = null;
            FuelExceptionDateMgmt__c objFuelExceptionDateMgmt_user = FuelExceptionDateMgmt__c.getValues(objUser.Id);
            FuelExceptionDateMgmt__c objFuelExceptionDateMgmt_profile = FuelExceptionDateMgmt__c.getValues(objUser.ProfileId);

            Map<String, Object> exceptionDateMap = new Map<String, Object>();
            exceptionDateMap.put('default', objFuelExceptionDateMgmtDefault);
            exceptionDateMap.put('user', objFuelExceptionDateMgmt_user);
            exceptionDateMap.put('profile', objFuelExceptionDateMgmt_profile);
            // System.debug('objFuelExceptionDateMgmtDefault: ' + objFuelExceptionDateMgmtDefault);
            // System.debug('objFuelExceptionDateMgmt_user: ' + objFuelExceptionDateMgmt_user);
            // System.debug('objFuelExceptionDateMgmt_profile: ' + objFuelExceptionDateMgmt_profile);


            // 전체 주유비 마감 기한 설정 조회
            FuelDueWeekSetup__c objFuelDueWeekOrgDefault = FuelDueWeekSetup__c.getOrgDefaults();
            if (objFuelDueWeekOrgDefault.Id == null) objFuelDueWeekOrgDefault = null;
            FuelDueWeekSetup__c objFuelDueWeekCustom_user = FuelDueWeekSetup__c.getValues(objUser.Id);
            FuelDueWeekSetup__c objFuelDueWeekCustom_profile = FuelDueWeekSetup__c.getValues(objUser.ProfileId);
        
            Map<String, Object> dueWeekMap = new Map<String, Object>();
            dueWeekMap.put('default', objFuelDueWeekOrgDefault);
            dueWeekMap.put('user', objFuelDueWeekCustom_user);
            dueWeekMap.put('profile', objFuelDueWeekCustom_profile);
            // System.debug('objFuelDueWeekOrgDefault: ' + objFuelDueWeekOrgDefault);
            // System.debug('objFuelDueWeekCustom_user: ' + objFuelDueWeekCustom_user);
            // System.debug('objFuelDueWeekCustom_profile: ' + objFuelDueWeekCustom_profile);
            
            
            // 조직별 주유비 신청 가능 기간 설정 조회
            FuelDdayMgmt__c objFuelDdayOrgDefault = FuelDdayMgmt__c.getOrgDefaults();
            if (objFuelDdayOrgDefault.Id == null) objFuelDdayOrgDefault = null;
            FuelDdayMgmt__c objFuelDdayCustom_user = FuelDdayMgmt__c.getValues(objUser.Id);
            FuelDdayMgmt__c objFuelDdayCustom_profile = FuelDdayMgmt__c.getValues(objUser.ProfileId);
        
            Map<String, Object> dDayMap = new Map<String, Object>();
            dDayMap.put('default', objFuelDdayOrgDefault);
            dDayMap.put('user', objFuelDdayCustom_user);
            dDayMap.put('profile', objFuelDdayCustom_profile);
            // System.debug('objFuelDdayOrgDefault: ' + objFuelDdayOrgDefault);
            // System.debug('objFuelDdayCustom_user: ' + objFuelDdayCustom_user);
            // System.debug('objFuelDdayCustom_profile: ' + objFuelDdayCustom_profile);

            
            Map<String, object> mapResult = new Map<String, object>{
                'dueWeekMap' => dueWeekMap,
                'dDayMap' => dDayMap,
                'exceptionDateMap' => exceptionDateMap,
                'listData' => listData,
                'objOilInfo' => objOilInfo,
                'objActivityReport' => objActivityReport,
                'strStatus' => strStatus,
                'strMessage' => strMessage
            };
            return mapResult;
        }
        catch(Exception e){
            system.debug('ActivityFuelMgmtController doGetData error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

    /**
     * 주유비정보 저장
     * 
     * @param recordId 활동보고(ActivityReport__c) Record Id
     * @param saveType 저장타입 : Temp(임시저장), Final(저장)
     * @param listData 활동보고(ActivityReport__c) Record Id
     * @param totalCost 총 금액
     * @return 
     *
    **/
    @AuraEnabled
    public static void doSave(Id recordId, String saveType, List<Event> listData, Decimal totalCost) {
        system.debug('listData ::::: ' + listData);

        try{
            database.update(listData);

            ActivityReport__c objActivityReport = [
                SELECT   Id, OilTotalAmount__c
                FROM     ActivityReport__c
                WHERE    Id =: recordId
            ]; 

            system.debug('objActivityReport ::::: ' + objActivityReport);
            system.debug('saveType ::::: ' + saveType);
            
            if ( saveType == 'Final'){
                objActivityReport.ApprovalStatus__c ='Request';
                // 2023-03-03 주유비 총금액 업데이트 추가
                objActivityReport.OilTotalAmount__c = totalCost;
            } 

            system.debug('objActivityReport ::::: ' + objActivityReport);
            update objActivityReport;

        }
        catch(Exception e){
            system.debug('ActivityFuelMgmtController doSave error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

    /**
     * URL 조회
     *      
     * @return String
     *
    **/
    @AuraEnabled
    public static String getPrefix(){
        String prefix = URL.getSalesforceBaseUrl().toExternalForm();
        // System.debug('Base URL: ' + prefix);

        return prefix;
    }

}