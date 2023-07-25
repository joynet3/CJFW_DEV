/*
* ==================================================================================
*   File Name   : AccountOwnerUpdateController.cls
*   Author      : Minje.Kim
*   Date        : 2023.01.09
*   Tester      : AccountOwnerUpdateController_test.cls
*   Description : AccountOwnerUpdateController Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.12.28    kw            Create
*   1.1     2023.04.12    sy.lee        update
* ==================================================================================
*/

public without sharing class AccountOwnerUpdateController {
    /**
     * SMA 고객관리 담당자 일괄변경 Init
     *      
     * @return DataWrapper 
     *          - strStatus : 상태값
     *          - strMessage : 메시지
     *          - reportURL : 전체 리스트 보고서 URL
     *          - listLocationStateProvince : 지역(시/도)(LocationStateProvince__c) Picklist value list
     *          - listLocationState : 지역(LocationState__c) Picklist value list
     *          - mapLocation : 지역 종속성 Map
     * 
    **/
    @AuraEnabled
    public static DataWrapper doInit() {
        String strStatus = 'SUCCESS';
        String strMessage = '';
        DataWrapper objWrapper = new DataWrapper();

        try{
            objWrapper.listLocationStateProvince = CommonUtil.getPickListValues('Account', 'LocationStateProvince__c', false);
            objWrapper.listLocationState = CommonUtil.getPickListValues('Account', 'LocationState__c', false);
            objWrapper.listSmaCustMngGrdCd = CommonUtil.getPickListValues('Account', 'sma_cust_mng_grd_cd__c', false);
            objWrapper.mapLocation = CommonUtil.getDependentPicklistValues(Account.LocationState__c);
            objWrapper.mapLocation.put('none',objWrapper.listLocationState);

            AccountOwnerReportURL__c objReportURL = new AccountOwnerReportURL__c();
            String strReportURL = '';
            objReportURL = AccountOwnerReportURL__c.getValues(UserInfo.getUserId());

            if ( objReportURL == null){
                objReportURL = AccountOwnerReportURL__c.getValues(UserInfo.getProfileId());
            } else {
                strReportURL = objReportURL.ReportURL__c;
            }

            if ( objReportURL == null){
                objReportURL = AccountOwnerReportURL__c.getOrgDefaults();
            } else {
                strReportURL = objReportURL.ReportURL__c;
            }

            if ( objReportURL.Id == null){
                objReportURL = null;
            } else {
                strReportURL = objReportURL.ReportURL__c;
            }
            objWrapper.reportURL = strReportURL;

        }catch (Exception e){
            strStatus = 'ERROR';
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                strMessage = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': []');
            }else{
                strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            }
        }
        System.debug( objWrapper.reportURL);
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;
        return objWrapper;
    }

    /**
     * SMA 고객정보 조회
     *      
     * @params mapParam : selectedLocationStateProvince 지역(시/도), selectedLocationState 지역(시/군/구), selectedUserId User Id
     * @return DataWrapper
     *          - strStatus : 상태값
     *          - strMessage : 메시지
     *          - listSearchWrapper : 조회결과 
    **/
    @AuraEnabled
    public static DataWrapper getDataTable(Map<String, String> mapParam) {
        String strStatus = 'SUCCESS';
        String strMessage = '';
        Boolean isLocationStateProvince = false;
        DataWrapper objWrapper = new DataWrapper();
        List<SearchWrapper> listSearchWrapper = new List<SearchWrapper>();
        Id recordIdSchool = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SchoolDepartment').getRecordTypeId();

        try {
            if (mapParam != null) {
                String strQuery =   '   SELECT     Id, Name, OwnerId, Owner.Name, Owner.EmployeeNumber, sma_cust_mng_grd_cd__c, toLabel(jrsdt_cido_eduofic_cd__c), toLabel(jrsdt_gugun_eduofic_cd__c), Phone';
                strQuery +=         '   FROM       Account';
                strQuery +=         '   WHERE       RecordTypeId = :recordIdSchool';
                if (mapParam.get('selectedLocationStateProvince') != null && mapParam.get('selectedLocationStateProvince') != 'none') {
                    strQuery +=     '   AND      LocationStateProvince__c = \''+mapParam.get('selectedLocationStateProvince')+'\'';
                    isLocationStateProvince = true;
                }
                if (mapParam.get('selectedLocationState') != null && mapParam.get('selectedLocationState') != 'none') {
                    strQuery +=     '   AND     LocationState__c = \''+mapParam.get('selectedLocationState')+'\'';
                }
                if (mapParam.get('selectedUserId') != null && mapParam.get('selectedUserId') != '') {
                    strQuery +=     '   AND     OwnerId = \''+mapParam.get('selectedUserId')+'\'';
                }
                strQuery +=         '   ORDER BY       Name';
            for(Account objAccount : Database.query(strQuery)) {
                if (objAccount.jrsdt_cido_eduofic_cd__c == '세종') {
                    objAccount.jrsdt_cido_eduofic_cd__c = null;
                }
                SearchWrapper objSearch = new SearchWrapper(objAccount);
                listSearchWrapper.add(objSearch);
            }

            }else {
                strStatus = 'ERROR';
                strMessage = '지역 설정 ERROR';
            }
        }catch (Exception e) {
            strStatus = 'ERROR';
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                strMessage = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': []');
            }else{
                strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            }
        }

        objWrapper.listSearchWrapper = listSearchWrapper;
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        System.debug( 'objWrapper :: '  +  objWrapper);

        return objWrapper;
    }

    /**
     * 사용자 정보 조회
     * 
     * @return DataWrapper
     *          - strStatus : 상태값
     *          - strMessage : 메시지
     *          - listSearchWrapper : 조회결과
    **/
    @AuraEnabled
    public static DataWrapper getUserDataTable() {
        String strStatus = 'SUCCESS';
        String strMessage = '';
        DataWrapper objWrapper = new DataWrapper();
        List<SearchWrapper> listSearchWrapper = new List<SearchWrapper>();

        try {
            //Param조건 추가
            String strQuery =   '   SELECT      id, Name, EmployeeNumber, toLabel(Team__c),toLabel(CJTitle__c), Phone, Email';
            strQuery +=         '   FROM        User';
            strQuery +=         '   WHERE       IsActive = TRUE';
            strQuery +=         '   AND         SU__c = \'4709\'';

            for(User objUser : Database.query(strQuery)) {
                SearchWrapper objSearch = new SearchWrapper(objUser);
                listSearchWrapper.add(objSearch);
            }

        }catch (Exception e){
            strStatus = 'ERROR';
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                strMessage = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': []');
            }else{
                strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            }
        }
        objWrapper.listSearchWrapper = listSearchWrapper;
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        System.debug( 'objWrapper :: '  +  objWrapper);

        return objWrapper;
    }

    /**
     * SMA 고객 담당자 변경
     *      
     * @params strOwnerId : 변경할 User Id
     * @params strListTarget : 변경할 SMA 고객리스트
     * @return DataWrapper
     *          - strStatus : 상태값
     *          - strMessage : 메시지
    **/
    @AuraEnabled
    public static DataWrapper doChangeOwner(String strOwnerId, String strListTarget) {

        System.debug('strOwnerId :: ' + strOwnerId);
        System.debug('strListTarget :: ' + strListTarget);

        String strStatus = 'SUCCESS';
        String strMessage = '';
        DataWrapper objWrapper = new DataWrapper();

        if (strOwnerId == null || strListTarget == null || strOwnerId == '' || strListTarget == '') {
            objWrapper.strStatus = 'ERROR';
            objWrapper.strMessage = '변경될 ';
            return objWrapper;
        }


        try {
            List<SearchWrapper> listTarget = (List<SearchWrapper>)JSON.deserialize(strListTarget, List<SearchWrapper>.class);
            List<Account> listUpdate = new List<Account>();

            for(SearchWrapper obj : listTarget) {
                Account objTarget = new Account();

                objTarget.Id = obj.id;
                objTarget.OwnerId = strOwnerId;
                listUpdate.add(objTarget);
            }

            if(listUpdate <> null && listUpdate.size() > 0) {
                update listUpdate;
            }

        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            /*
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                strMessage = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': []');
            }else{
                strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            }
            */
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    /**
     * SMA 고객 관리 등급 코드 변경
     *      
     * @params strSmaCustMngGrdCd : 변경할 SMA 고객 관리 등급 코드
     * @params strListTarget : 변경할 SMA 고객리스트
     * @return DataWrapper
     *          - strStatus : 상태값
     *          - strMessage : 메시지
    **/
    @AuraEnabled
    public static DataWrapper doChangeSmaCustMngGrdCd(String strSmaCustMngGrdCd, String strListTarget) {

        System.debug('strSmaCustMngGrdCd :: ' + strSmaCustMngGrdCd);
        System.debug('strListTarget :: ' + strListTarget);

        String strStatus = 'SUCCESS';
        String strMessage = '';
        DataWrapper objWrapper = new DataWrapper();

        if (strSmaCustMngGrdCd == null || strListTarget == null || strSmaCustMngGrdCd == 'none' || strSmaCustMngGrdCd == '' || strListTarget == '') {
            objWrapper.strStatus = 'ERROR';
            objWrapper.strMessage = '변경될 대상이 없습니다';
            return objWrapper;
        }


        try {
            List<SearchWrapper> listTarget = (List<SearchWrapper>)JSON.deserialize(strListTarget, List<SearchWrapper>.class);
            List<Account> listUpdate = new List<Account>();

            for(SearchWrapper obj : listTarget) {
                Account objTarget = new Account();

                objTarget.Id = obj.id;
                objTarget.sma_cust_mng_grd_cd__c = strSmaCustMngGrdCd;
                listUpdate.add(objTarget);
            }

            if(listUpdate <> null && listUpdate.size() > 0) {
                update listUpdate;
            }

        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            /*
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                strMessage = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': []');
            }else{
                strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            }
            */
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
        public String reportUrl {get;set;}
        @AuraEnabled
        public List<Map<String, String>> listLocationStateProvince {get;set;}
        @AuraEnabled
        public List<Map<String, String>> listLocationState {get;set;}
        @AuraEnabled
        public List<Map<String, String>> listSmaCustMngGrdCd {get;set;}
        @AuraEnabled
        public Map<String,List<Map<String, String>>> mapLocation {get;set;}
        @AuraEnabled
        public List<SearchWrapper> listSearchWrapper {get;set;}
    }

    public class SearchWrapper {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String ownerId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String ownerName {get;set;}
        @AuraEnabled
        public String ownerEmployeeNumber {get;set;}
        @AuraEnabled
        public String smaCustMngGrdCd {get;set;}
        @AuraEnabled
        public String educationOffice {get;set;}
        @AuraEnabled
        public String phone {get;set;}
        @AuraEnabled
        public String recordLink {get;set;}
        @AuraEnabled
        public String viewDetail {get;set;}
        @AuraEnabled
        public String userName {get;set;}
        @AuraEnabled
        public String employeeNumber {get;set;}
        @AuraEnabled
        public String team {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String email {get;set;}

        public SearchWrapper() {
        }

        public SearchWrapper(Account objAccount) {
            this.id = objAccount.Id;
            this.ownerId = objAccount.OwnerId;
            this.name = objAccount.Name;
            this.ownerName = objAccount.Owner.Name;
            this.ownerEmployeeNumber = objAccount.Owner.EmployeeNumber;
            this.smaCustMngGrdCd = objAccount.sma_cust_mng_grd_cd__c;
            this.educationOffice = '';
            this.educationOffice = objAccount.jrsdt_cido_eduofic_cd__c != null ? objAccount.jrsdt_cido_eduofic_cd__c + ' ' : '';
            this.educationOffice += objAccount.jrsdt_gugun_eduofic_cd__c != null ? objAccount.jrsdt_gugun_eduofic_cd__c : '';
            this.phone = objAccount.Phone;
            this.recordLink = '/'+String.valueOf(objAccount.Id);
            this.viewDetail = '상세보기';
        }
        public SearchWrapper(User objUser) {
            this.id = objUser.Id;
            this.userName = objUser.Name;
            this.employeeNumber = objUser.EmployeeNumber;
            this.team = objUser.Team__c;
            this.title = objUser.CJTitle__c;
            this.phone = objUser.Phone;
            this.email = objUser.Email;
            this.recordLink = '/'+String.valueOf(objUser.Id);
            this.viewDetail = '상세보기';
        }
    }
}