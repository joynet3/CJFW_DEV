/*
* ==================================================================================
*   File Name   : OilApporvalRequest.cls
*   Author      : Minje.Kim
*   Date        : 2022.11.06
*   Tester      : OilApporvalRequest_Test.cls
*   Description : 주유비 정산 승인 관리 Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.06    Minje.Kim    Create
* ==================================================================================
*/
public with sharing class OilApporvalRequest {
    
    /**
     * 주유비 정산 승인 탭 Init (검색 조건 셋팅)
     * 
     * @params 없음
     * @return DataWrapper 
     *         - objUser : 유저 정보
     *         - listSelectStatus : 제출 상태
     *         - listSelectHeadOffice : 사업부 리스트
     *         - mapSelectSU : SU 리스트
     *         - mapSelectTeam : 팀 리스트
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
                SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, Team__c, CJTitle__c
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
            ];
            objWrapper.objUser = objUser;

            objWrapper.listSelectStatus = CommonUtil.getPickListValues('ActivityReport__c', 'ApprovalStatus__c', false);
            objWrapper.listSelectHeadOffice = CommonUtil.getPickListValues('User', 'HeadOffice__c', false);
            objWrapper.mapSelectSU = CommonUtil.getDependentPicklistValues(User.SU__c); 
            objWrapper.mapSelectTeam = CommonUtil.getDependentPicklistValues(User.Team__c); 

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
     * 주유비 정산 승인 탭 데이터 조회
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
    public static DataWrapper getDataTable(Map<String, String> mapParam) {
        String strStatus = 'SUCCESS';
        String strMessage = ''; 
        String userType = String.valueOf(mapParam.get('userType'));

        Integer targetYear = Integer.valueOf(mapParam.get('selectedYear'));
        Integer targetMonth = Integer.valueOf(mapParam.get('selectedMonth'));

        Integer targetDaysInMonth = date.daysInMonth(targetYear, targetMonth);
        
        String targetDateStart = String.valueOf(Date.newInstance(targetYear, targetMonth, 1));
        String targetDateEnd = String.valueOf(Date.newInstance(targetYear, targetMonth, targetDaysInMonth));

        String strSearchMA = '';
        if ( mapParam.get('strSearchMA') != null){
            strSearchMA = mapParam.get('strSearchMA');
        }
        
       
        DataWrapper objWrapper = new DataWrapper();

        List<SearchWrapper> listSearchWrapper = new List<SearchWrapper>();

        try {
            String strQuery = 'SELECT Id, OwnerId,';

            strQuery += '    User__r.Name, User__r.EmployeeNumber, User__r.HeadOffice__c, User__r.SU__c, User__r.Team__c, User__r.CJTitle__c,';
            strQuery += '    EventStartDate__c, OilTotalAmount__c, OilTotalDistance__c,';
            strQuery += '    ApprovalStatus__c, IsSendECCAT__c,';            
            strQuery += '    toLabel(User__r.HeadOffice__c) HeadOfficeName,';
            strQuery += '    toLabel(User__r.SU__c) SUName,';
            strQuery += '    toLabel(User__r.Team__c) TeamName,';
            strQuery += '    toLabel(ApprovalStatus__c) ApprovalStatusName';

            strQuery += '    FROM    ActivityReport__c';
            
            strQuery += '    WHERE   ApprovalStatus__c = \''+mapParam.get('selectedStatus')+'\'';
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

            if(mapParam.get('selectedTeam') <> null && mapParam.get('selectedTeam') <> 'none') {
                // 유통리테일 381, 385 통합관리
                if ( mapParam.get('selectedTeam') == '381' || mapParam.get('selectedTeam') == '385'){
                    strQuery += '    AND     User__r.Team__c IN (\'381\',\'385\') ';
                } else {
                    strQuery += '    AND     User__r.Team__c = \''+mapParam.get('selectedTeam')+'\'';
                }
            }

            if (userType == 'TM'){
                strQuery += '    AND     User__r.CJTitle__c = \'MA\'';
            }
            else if(userType == 'BM'){
                strQuery += '    AND     User__r.CJTitle__c = \'TM\'';
            }

            if ( strSearchMA != ''){
                strQuery += '    AND     (User__r.Name like \'%' + strSearchMA + '%\'  OR  User__r.EmployeeNumber like \'%' + strSearchMA + '%\')';
            }

            System.debug('strQuery :: ' + strQuery);
            System.debug('selectedSU :: ' + String.valueOf(mapParam.get('selectedSU')));
            System.debug('targetDateStart :: ' + targetDateStart);
            System.debug('targetDateEnd :: ' + targetDateEnd);

            Set<String> setUserId = new Set<String>();

            for(ActivityReport__c objAR : Database.query(strQuery)) {
                SearchWrapper objSearch = new SearchWrapper(objAR);
                listSearchWrapper.add(objSearch);
            }
        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.listSearchWrapper = listSearchWrapper;
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        System.debug( 'objWrapper :: '  +  objWrapper); 
        
        return objWrapper;
    }

    
    /**
     * 주유비 정산 승인 탭 데이터 저장 (승인, 반려)
     * 
     * @params String strListTarget : 체크된 활동보고 데이터 리스트
     * @params String ApprovalStatus : 저장 유형 (승인, 반려)
     * @return DataWrapper 
     *         - 저장 성공/실패 여부 (strStatus) 
     *         - 저장 실패시 에러메세지 (strMessage)
     *
    **/
    @AuraEnabled
    public static DataWrapper doSave(String strListTarget, String ApprovalStatus) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {
            List<SearchWrapper> listTarget = (List<SearchWrapper>)JSON.deserialize(strListTarget, List<SearchWrapper>.class);
            List<ActivityReport__c> listUpdate = new List<ActivityReport__c>();

            for(SearchWrapper obj : listTarget) {
                ActivityReport__c objTarget = new ActivityReport__c();

                objTarget.Id = obj.objActivityReport.Id;                
                objTarget.ApprovalStatus__c = ApprovalStatus;

                listUpdate.add(objTarget);
            }

            if(listUpdate <> null && listUpdate.size() > 0) {
                update listUpdate;
            }

        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
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
        public User objUser {get;set;}
        @AuraEnabled
        public String strHeadOffice {get;set;}
        @AuraEnabled
        public String strSU {get;set;}
        @AuraEnabled
        public String strTeam {get;set;}
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
        @AuraEnabled
        public Map<String, List<Map<String, String>>> mapSelectTeam {get;set;}

    }

    public class SearchWrapper{
        @AuraEnabled
        public String recordLink {get;set;}
        @AuraEnabled
        public String viewDetail {get;set;}
        @AuraEnabled
        public String strStatus {get;set;}
        @AuraEnabled
        public String eventDate {get;set;}
        @AuraEnabled
        public String strHeadOffice {get;set;}
        @AuraEnabled
        public String strSU {get;set;}
        @AuraEnabled
        public String strTeam {get;set;}
        @AuraEnabled
        public String strUserInfo {get;set;}
        @AuraEnabled
        public String totalAmount {get;set;}
        @AuraEnabled
        public String totalDistance {get;set;}

        @AuraEnabled
        public ActivityReport__c objActivityReport {get;set;}

        public SearchWrapper() {
        }

        public SearchWrapper(ActivityReport__c objActivityReport) {

            this.objActivityReport = objActivityReport;

            // 2022-11-06 toLabel 필드때문에 Update가 안되어 Id, ApprovalStatus__c 만 세팅
            ActivityReport__c objNewAR = new ActivityReport__c();
            objNewAR.Id = objActivityReport.Id;
            objNewAR.ApprovalStatus__c = objActivityReport.ApprovalStatus__c;
            this.objActivityReport = objNewAR;

            this.strStatus = String.valueOf(objActivityReport.get('ApprovalStatusName'));
            this.eventDate = String.valueOf(objActivityReport.EventStartDate__c);

            if(objActivityReport.User__r <> null) {
                User objTargetUser = (User)objActivityReport.User__r;

                if(objTargetUser.get('HeadOfficeName') <> null) {
                    this.strHeadOffice = String.valueOf(objTargetUser.get('HeadOfficeName'));
                }
    
                if(objTargetUser.get('SUName') <> null) {
                    this.strSU = String.valueOf(objTargetUser.get('SUName'));
                }
    
                if(objTargetUser.get('TeamName') <> null) {
                    this.strTeam = String.valueOf(objTargetUser.get('TeamName'));
                }
            }

            String strUserName = objActivityReport.User__r.Name;
            String strUserEmployeeNumber = objActivityReport.User__r.EmployeeNumber;
            

            if(strUserEmployeeNumber <> null && strUserEmployeeNumber.length() > 0) {
                this.strUserInfo = strUserName+'('+strUserEmployeeNumber+')';
            }else {
                this.strUserInfo = strUserName;
            }

            this.totalAmount = String.valueOf(objActivityReport.OilTotalAmount__c);
            this.recordLink = '/'+String.valueOf(objActivityReport.Id);
            this.viewDetail = '상세보기';
            this.totalDistance = String.valueOf(objActivityReport.OilTotalDistance__c);
        }
    }
}