/*
* ==================================================================================
*   File Name   : OilApporvalRequest.cls
*   Author      : Minje.Kim
*   Date        : 2022.11.06
*   Tester      : OilApporvalRequest_Test.cls
*   Description : 주유비 전표처리 관리 Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.06    Minje.Kim    Create
* ==================================================================================
*/
public with sharing class OilApprovalSendEacct {
    
    /**
     * 주유비 정산 전표처리 탭 Init (데이터 조회를 위한 정보 셋팅)
     * 
     * @params 없음
     * @return DataWrapper 
     *         - objUser : 유저 정보
     *         - listSelectStatus : 제출상태 리스트
     *         - listSelectHeadOffice : 사업부 리스트
     *         - mapSelectSU : SU 리스트
     *         - listYear : 년도 리스트
     *         - listMonth : 월 리스트
     *         - targetYear : 초기 년도 설정값
     *         - targetMonth : 초기 월 설정값
     *
    **/
    @AuraEnabled
    public static DataWrapper doInit() {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {

            User objUser = [
                SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, Team__c
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
            ];
            objWrapper.objUser = objUser;

            objWrapper.listSelectStatus = CommonUtil.getPickListValues('ActivityReport__c', 'ApprovalStatus__c', false);
            objWrapper.listSelectHeadOffice = CommonUtil.getPickListValues('User', 'HeadOffice__c', false);
            objWrapper.mapSelectSU = CommonUtil.getDependentPicklistValues(User.SU__c); 

            // Dafault 선택 년도 및 월 계산
            Date targetDate = Date.today();  
           
            String targetYear = String.valueOf(targetDate.year());
            String targetMonth = String.valueOf(targetDate.month());

            // Dafault 선택 년도 및 선택목록에 표시될 년도 셋팅
            List<Map<String,String>> listYear = new List<Map<String,String>>();
            Integer seqYear = Date.today().year() - 4;
            System.debug( 'targetYear :: ' + targetYear);
            System.debug( 'seqYear :: ' + seqYear);
            while ( seqYear <=  Date.today().year()) {
                listYear.add(new Map<String, String>{
                    'label' => String.valueOf(seqYear) + '년',
                    'value' => String.valueOf(seqYear),
                    'selected' => targetDate.year() == seqYear ? 'true' : 'false'
                });
                seqYear++;
            }
            objWrapper.listYear = listYear;
            objWrapper.targetYear = String.valueOf(targetDate.year());

            // Dafault 선택 월 및 선택목록에 표시될 월 셋팅
            List<Map<String,String>> listMonth = new List<Map<String,String>>();
            Integer seqMonth = 1; 
            while ( seqMonth < 13 ) {
                listMonth.add(new Map<String, String>{
                    'label' => String.valueOf(seqMonth) + '월',
                    'value' => String.valueOf(seqMonth),
                    'selected' => targetDate.month() == seqMonth ? 'true' : 'false'
                });
                seqMonth++;
            }
            objWrapper.listMonth = listMonth;
            objWrapper.targetMonth = String.valueOf(targetDate.month()).leftPad(2,'0') ;
            

        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    /**
     * 주유비 정산 전표처리 탭 데이터 조회
     * 
     * @params Map<String, String> mapParam
     *         - userType : 유저 정보
     *         - selectedYear : 선택된 년도 정보
     *         - selectedMonth : 선택된 월 정보
     *         - selectedStatus : 선택된 제출상태 코드
     *         - selectedHeadOffice : 선택된 사업부 코드
     *         - selectedSU : 선택된 SU 코드
     * @return DataWrapper objWrapper
     *         - mapActivityReportId : 사원번호 별 활동보고 데이터 셋
     *         - listSearchWrapper : 조회된 활동보고 데이터 리스트
     *         - strStatus : 조회 성공/실패 여부
     *         - strMessage : 조회 실패시 에러메세지
     *
    **/
    @AuraEnabled
    public static DataWrapper getDataTable(Map<String, String> mapParam) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();
        List<SearchWrapper> listSearchWrapper = new List<SearchWrapper>();
        Map<String, Set<String>> mapActivityReportId = new Map<String, Set<String>>();

        Map<String, String> mapSUToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'SU__c');
        Map<String, String> mapTeamToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'Team__c');
        String userType = String.valueOf(mapParam.get('userType'));
        
        // Date Calc
        Integer targetYear = Integer.valueOf(mapParam.get('selectedYear'));
        Integer targetMonth = Integer.valueOf(mapParam.get('selectedMonth'));
        Integer targetDaysInMonth = date.daysInMonth(targetYear, targetMonth);
        String targetDateStart = String.valueOf(Date.newInstance(targetYear, targetMonth, 1));
        String targetDateEnd = String.valueOf(Date.newInstance(targetYear, targetMonth, targetDaysInMonth));

        try {
            
            System.debug('selectedHeadOffice :: ' + String.valueOf(mapParam.get('selectedHeadOffice')));
            System.debug('selectedSU :: ' + String.valueOf(mapParam.get('selectedSU')));

            String strQuery = '';
            strQuery += '    SELECT Id, User__r.EmployeeNumber, OwnerId  ';
            strQuery += '    FROM    ActivityReport__c   ';
            strQuery += '    WHERE   ApprovalStatus__c = \'Approved\'';
            strQuery += '    AND     EventStartDate__c >= '+ targetDateStart;
            strQuery += '    AND     EventStartDate__c <= '+ targetDateEnd;

            if(mapParam.get('selectedHeadOffice') <> null && mapParam.get('selectedHeadOffice') <> 'none') {
                strQuery += '    AND     User__r.HeadOffice__c = \''+mapParam.get('selectedHeadOffice')+'\'';
            }

            if(mapParam.get('selectedSU') <> null && mapParam.get('selectedSU') <> 'none') {
                strQuery += '    AND     User__r.SU__c = \''+mapParam.get('selectedSU')+'\'';
            }

            System.debug('strQuery :: ' + strQuery);

            List<ActivityReport__c> listActivityReport = Database.query(strQuery);

            for ( ActivityReport__c objActivityReport: listActivityReport ){
                Set<String> strIds = new Set<String>();
                if( mapActivityReportId.get(objActivityReport.User__r.EmployeeNumber) != null ){
                    strIds = mapActivityReportId.get(objActivityReport.User__r.EmployeeNumber);
                }
                strIds.add(objActivityReport.Id);
                mapActivityReportId.put(objActivityReport.User__r.EmployeeNumber,strIds);
            }
            objWrapper.mapActivityReportId = mapActivityReportId;
            
            strQuery = '';
            strQuery += '    SELECT  User__c, SUM(OilTotalAmount__c) totalAmount, SUM(OilTotalDistance__c) totalDistance  ';
            strQuery += '    FROM    ActivityReport__c   ';
            strQuery += '    WHERE   ApprovalStatus__c = \'Approved\'';
            strQuery += '    AND     EventStartDate__c >= '+ targetDateStart;
            strQuery += '    AND     EventStartDate__c <= '+ targetDateEnd;
            strQuery += '    AND     OilTotalDistance__c != 0';
            strQuery += '    AND     OilTotalDistance__c != null';

            if(mapParam.get('selectedHeadOffice') <> null && mapParam.get('selectedHeadOffice') <> 'none') {
                strQuery += '    AND     User__r.HeadOffice__c = \''+mapParam.get('selectedHeadOffice')+'\'';
            }

            if(mapParam.get('selectedSU') <> null && mapParam.get('selectedSU') <> 'none') {
                strQuery += '    AND     User__r.SU__c = \''+mapParam.get('selectedSU')+'\'';
            }
            strQuery += '    GROUP BY User__c';
            System.debug('strQuery :: ' + strQuery);

            List<AggregateResult> listAggregateResult = Database.query(strQuery);

            System.debug(' listAggregateResult :: ' + listAggregateResult);

            Set<String> setUserId = new Set<String>();
            for ( AggregateResult objAggregateResult: listAggregateResult ){
                setUserId.add(String.valueOf(objAggregateResult.get('User__c')));
            }
            
            Map<Id, User> mapUser = new Map<Id, User>([
                    SELECT Id, Name, EmployeeNumber, CostCenter__c, HeadOffice__c, SU__c, Team__c, toLabel(oil_type_cd__c) 
                    FROM User
                    WHERE Id IN :setUserId
            ]);
            System.debug(' mapUser :: ' + mapUser);

            List<UserBankInfo__c> listUserBankInfo = new List<UserBankInfo__c>([
                    SELECT User__c, PV_BVTYP__c, PV_ZTERM_B1__c
                    FROM UserBankInfo__c
                    WHERE User__c IN :setUserId
                    AND IsOilExpenseAccount__c = true
            ]);
            System.debug(' listUserBankInfo :: ' + listUserBankInfo);

            Map<Id, UserBankInfo__c> mapUserBankInfo = new Map<Id, UserBankInfo__c>();
            for (UserBankInfo__c objUserBankInfo : listUserBankInfo ){
                mapUserBankInfo.put(objUserBankInfo.User__c,objUserBankInfo);
            }

            for ( AggregateResult objAggregateResult: listAggregateResult ){
                SearchWrapper objSearchWrapper = new SearchWrapper();
                User objUser = mapUser.get(String.valueOf(objAggregateResult.get('User__c')));
                UserBankInfo__c objUserBankInfo = mapUserBankInfo.get(objUser.Id) != null ? mapUserBankInfo.get(objUser.Id) : null;
                objSearchWrapper.Name = objUser.Name;
                objSearchWrapper.EmployeeNumber = objUser.EmployeeNumber;
                objSearchWrapper.Team = objUser.Team__c;
                objSearchWrapper.TeamLabel = mapTeamToLabel.get(objUser.Team__c);
                objSearchWrapper.SU = objUser.SU__c;
                objSearchWrapper.SULabel = mapSUToLabel.get(objUser.SU__c); 
                objSearchWrapper.OilType = objUser.oil_type_cd__c;
                objSearchWrapper.CostCenter = objUser.CostCenter__c;
                objSearchWrapper.totalAmount = (objAggregateResult.get('totalAmount') != null ? String.valueOf(Integer.valueOf((decimal) objAggregateResult.get('totalAmount'))) : '0');
                objSearchWrapper.totalDistance = String.valueOf(objAggregateResult.get('totalDistance'));
                objSearchWrapper.totalDistanceWithKm = (objSearchWrapper.totalDistance != null ? objSearchWrapper.totalDistance : '0')  + 'Km';
                objSearchWrapper.BankCode = objUserBankInfo != null ? objUserBankInfo.PV_BVTYP__c : '';
                objSearchWrapper.PaymentCode = objUserBankInfo != null ? objUserBankInfo.PV_ZTERM_B1__c : '';
                listSearchWrapper.add(objSearchWrapper);
            }

        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.listSearchWrapper = listSearchWrapper;
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;
        system.debug('objWrapper :: ' +objWrapper );
        return objWrapper;
    }

    
    /**
     * 주유비 정산 전표처리 탭 상세정보 조회
     * 
     * @params Map<String, String> mapParam
     *         - userType : 유저 정보
     *         - selectedYear : 선택된 년도 정보
     *         - selectedMonth : 선택된 월 정보
     *         - strSearchMA : MA명 검색창에 입력된 단어
     *         - selectedStatus : 선택된 제출상태 코드
     *         - selectedHeadOffice : 선택된 사업부 코드
     *         - selectedSU : 선택된 SU 코드
     *         - selectedTeam : 선택된 팀 코드
     * @return DataWrapper objWrapper
     *         - listSearchWrapper : 조회된 활동보고 데이터 리스트
     *         - strStatus : 조회 성공/실패 여부
     *         - strMessage : 조회 실패시 에러메세지
     *
    **/
    @AuraEnabled
    public static OilApporvalRequest.DataWrapper doViewDetail(Map<String, String> mapParam) {
        return OilApporvalRequest.getDataTable(mapParam);
    }

    /**
     * 주유비 정산 전표처리 탭 상세정보 조회
     * 
     * @params String strListTarget : 전표처리할 활동보고 데이터 리스트
     * @params String strMapActivityReportId : 사원번호 별 활동보고 데이터 셋
     * @params String strSendDate : 전표처리 지급기준일
     * @return DataWrapper objWrapper
     *         - DocUrl : 재무시스템 전표처리 문서번호
     *         - strStatus : 조회 성공/실패 여부
     *         - strMessage : 조회 실패시 에러메세지
     *
    **/
    @AuraEnabled
    public static DataWrapper doSendCredit(String strListTarget, String strMapActivityReportId, String strSendDate) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        Date sendDate = Date.valueOf(strSendDate);
        strSendDate = String.valueof(sendDate.year()) + String.valueOf(sendDate.month()).leftPad(2, '0') + String.valueOf(sendDate.day()).leftPad(2, '0');  
        
        Date dateToday = Date.today();
        String today = String.valueof(dateToday.year()) + String.valueOf(dateToday.month()).leftPad(2, '0') + String.valueOf(dateToday.day()).leftPad(2, '0'); 
        
        User objUser = [
            SELECT  Id, Name, EmployeeNumber, HeadOffice__c, SU__c, Team__c
            FROM    User
            WHERE   Id =: UserInfo.getUserId()
        ];

        DataWrapper objWrapper = new DataWrapper();
        try {
            List<SearchWrapper> listTarget = (List<SearchWrapper>)JSON.deserialize(strListTarget, List<SearchWrapper>.class);
            Map<String,Object> mapActivityReportId = (Map<String,Object>)JSON.deserializeUntyped(strMapActivityReportId);
            Input objInput = new input();
            InputSub objInputSub = new InputSub();
            List<Map<String,String>> listInputThird = new List<Map<String,String>>();

            Integer totalAmount = 0;

            // 파라미터 설정 (등록자 정보)
            objInput.system_type_cd = 'LIF1007';
            objInput.opcode = 'EC002';
            objInput.COM_CD = 'FW00';
            objInput.EVID_TYPE_CD_H = 'ZZZ';
            objInput.SLIP_TYPE_CD = 'DA';
            objInput.RMK = sendDate.addMonths(-1).year() + '.' + String.valueOf(sendDate.addMonths(-1).month()).leftPad(2, '0') + ' 영업교통비';
            objInput.EVID_DT = today;
            objInput.RGSPE_EMP_NO = String.valueOf(objUser.EmployeeNumber);

            // 파라미터 설정 (전표처리 데이터 정보)
            for(SearchWrapper objTarget : listTarget) {
                Map<String,String> objInputThird = new Map<String,String>();
                objInputThird.put('__rowStatus','I');
                objInputThird.put('state','created');
                objInputThird.put('REQ_EMP_NO', objTarget.EmployeeNumber);
                objInputThird.put('REQ_CST_CNTR_CD',objTarget.CostCenter);
                objInputThird.put('SLIP_CURR_AMT', String.Valueof(objTarget.totalAmount));

                if (objTarget.PaymentCode == '' || objTarget.PaymentCode == null){
                    objInputThird.put('PAY_COND_CD', 'K400');
                }
                else {
                    objInputThird.put('PAY_COND_CD', objTarget.PaymentCode);
                }

                objInputThird.put('PAY_BASE_DT', strSendDate.left(4)+strSendDate.mid(4,2)+strSendDate.right(2));
                objInputThird.put('PAY_BANK_TYPE_CD', objTarget.BankCode);
                
                System.debug( ' objInputThird :: ' + objInputThird);
                totalAmount = totalAmount + Integer.valueOf(String.valueOf(objTarget.totalAmount));
                listInputThird.add(objInputThird);
            }

            System.debug( ' listInputThird :: ' + listInputThird );
            objInputSub.data = listInputThird;
            objInput.ds_master = objInputSub;

            System.debug( ' objInput :: ' + objInput);

            // I/F 실행
            IFUtil ifutilWrapper = new IFUtil('IF_SFDC_EACCT_REG_VRC');
            String strJsonRequestBody = JSON.serialize(objInput);
            HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

            Output objOutput = new Output();

            system.debug( 'response.getStatusCode() ::: ' + response.getStatusCode() );
            system.debug( 'check Input ::: ' + strJsonRequestBody );
            system.debug( 'check Output ::: ' + response.getBody() );
            
            // I/F 성공 시 
            if(response.getStatusCode() == 200){   
                objOutput = (Output)JSON.deserialize(response.getBody(), Output.class);
                // 반환 시 에러코드 발생한 경우 에러메세지 
                if( objOutput.ERR_CD == 'E'){
                    system.debug( '전표처리 오류 :: [' + objOutput.ERR_MSG_CTT + ']');
                    strStatus = 'ERROR';
                    strMessage = '[I/F Error] ' + objOutput.ERR_MSG_CTT;
                }
                // 반환 시 정상적인 경우 해당 품의이력에 전표처리 결과 저장
                else {
                    DecisionProcess__c objDecisionProcess = new DecisionProcess__c() ;
                    // 전송 이력 조회 용 SFDC 정보 
                    objDecisionProcess.Name = objInput.RMK;
                    objDecisionProcess.DocStatus__c = '임시저장';
                    objDecisionProcess.year__c = String.valueOf(sendDate.addMonths(-1).year());
                    objDecisionProcess.Month__c = String.valueOf(sendDate.addMonths(-1).month());
                    objDecisionProcess.RegUserName__c = objUser.Name;
                    objDecisionProcess.RegUserNumber__c = objUser.EmployeeNumber;
                    objDecisionProcess.RegUserHeadOfficeCode__c = objUser.HeadOffice__c;
                    objDecisionProcess.RegUserSUCode__c = objUser.SU__c;
                    objDecisionProcess.RegUserTeamCode__c = objUser.Team__c;
                    objDecisionProcess.totalHeadcount__c = listInputThird.size();
                    objDecisionProcess.totalAmount__c = totalAmount;
                    // 재무시스템 수신 정보
                    objDecisionProcess.DocURL__c = objOutput.APPV_URL;
                    objDecisionProcess.APPV_NO__c = objOutput.APPV_NO;
                    objWrapper.DocUrl = objOutput.APPV_URL;
                    system.debug( 'objDecisionProcess :: ' +objDecisionProcess);
                    insert objDecisionProcess;
                }
            // I/F 실패 시 에러메세지
            } else {
                system.debug( '재무시스템 접근 오류 :: Code [' + response.getStatusCode() + ']');
                strStatus = 'ERROR';
                strMessage = '[I/F Error] ('+ response.getStatusCode()+ ')] 주유비 전표처리에 실패했습니다.';
            }
        // 기타 실패 시 에러메세지
        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            system.debug('ActivityFuelMgmtController doGetData error : '+ e.getMessage() + ' Line : '+e.getLineNumber());
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    public class DataWrapper {
        @AuraEnabled
        public String strStatus {get;set;}
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public List<SearchWrapper> listSearchWrapper {get;set;}
        @AuraEnabled
        public Map<String,Set<String>> mapActivityReportId {get;set;}
        @AuraEnabled
        public User objUser {get;set;}
        @AuraEnabled
        public String strHeadOffice {get;set;}
        @AuraEnabled
        public String strSU {get;set;}
        @AuraEnabled
        public String strTeam {get;set;}
        @AuraEnabled
        public String DocUrl {get;set;}
        @AuraEnabled
        public String targetYear {get;set;}
        @AuraEnabled
        public String targetMonth {get;set;}
        @AuraEnabled
        public List<Map<String,String>> listYear {get;set;}
        @AuraEnabled
        public List<Map<String,String>> listMonth {get;set;}
        @AuraEnabled
        public List<Map<String, String>> listSelectStatus {get;set;}
        @AuraEnabled
        public List<Map<String, String>> listSelectHeadOffice {get;set;}
        @AuraEnabled
        public Map<String, List<Map<String, String>>> mapSelectSU {get;set;}        

    }

    public class Wrapper {
        @AuraEnabled
        public String Team {get;set;}
        @AuraEnabled
        public String TeamLabel {get;set;}
        @AuraEnabled
        public String SU {get;set;}
        @AuraEnabled
        public String SULabel {get;set;}
        @AuraEnabled
        public String EmployeeNumber {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String OilType {get;set;}
        @AuraEnabled
        public String CostCenter {get;set;}
        @AuraEnabled
        public String totalAmount {get;set;}
        @AuraEnabled
        public String totalDistance {get;set;}
        @AuraEnabled
        public String totalDistanceWithKm {get;set;}
        @AuraEnabled
        public String BankCode {get;set;}
        @AuraEnabled
        public String PaymentCode {get;set;}
    }

    public class SearchWrapper {
        @AuraEnabled
        public String Team {get;set;}
        @AuraEnabled
        public String TeamLabel {get;set;}
        @AuraEnabled
        public String SU {get;set;}
        @AuraEnabled
        public String SULabel {get;set;}
        @AuraEnabled
        public String EmployeeNumber {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String OilType {get;set;}
        @AuraEnabled
        public String CostCenter {get;set;}
        @AuraEnabled
        public String totalAmount {get;set;}
        @AuraEnabled
        public String totalDistance {get;set;}
        @AuraEnabled
        public String totalDistanceWithKm {get;set;}
        @AuraEnabled
        public String BankCode {get;set;}
        @AuraEnabled
        public String PaymentCode {get;set;}
    }

    public class Input{
        public String system_type_cd; // 시스템 구분코드 LIF1007
        public String opcode; // 업무코드 EC002
        public String COM_CD; // 회사코드 FW00
        public String EVID_TYPE_CD_H; // 증빙유형코드 ZZZ 
        public String SLIP_TYPE_CD; // 전표유형코드 DA
        public String RMK; // 비고  (YY.MM 영업교통비)
        public String EVID_DT; // 증빙일자 현재일자 (YYYYMMDD) 
        public String RGSPE_EMP_NO; // 등록자 사원번호
        public InputSub ds_master; 
    }

    public class InputSub{
        public List<Map<String,String>> data; 
    }

    public class Output {
        public String ERR_CD;
        public String ERR_MSG_CTT;
        public String APPV_URL;
        public String APPV_NO;
    }

}