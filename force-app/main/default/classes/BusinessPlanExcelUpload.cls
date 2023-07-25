/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-09-2023
 * @last modified by  : admin
**/
public without sharing class BusinessPlanExcelUpload {
    /**
     * 경영계획 엑셀업로드 Init
     *      
     * @return Map<String, object>
     *          - objUser : 사용자정보
     *          - listSelectHeadOffice : SU Picklist value 정보
     *          - mapSelectSU : 본부 SU 종속성 정보
     *          - mapSelectTeam : SU 팀 종속성 정보
    **/
    @AuraEnabled
    public static Map<String, object>  doInit() {

        User objUser = [
            SELECT  Id, Name, EmployeeNumber, HeadOffice__c, SU__c, Team__c
            FROM    User
            WHERE   Id =: UserInfo.getUserId()
        ];

        // objWrapper.listSelectStatus = CommonUtil.getPickListValues('ActivityReport__c', 'ApprovalStatus__c', false);
        // objWrapper.listSelectHeadOffice = CommonUtil.getPickListValues('User', 'HeadOffice__c', false);
        // objWrapper.mapSelectSU = CommonUtil.getDependentPicklistValues(User.SU__c); 
        // objWrapper.mapSelectTeam = CommonUtil.getDependentPicklistValues(User.Team__c); 

        Map<String, object> mapResult = new Map<String, object>{
            'objUser' => objUser,
            'listSelectHeadOffice' => CommonUtil.getPickListValues('User', 'HeadOffice__c', false),
            'mapSelectSU' => CommonUtil.getDependentPicklistValues(User.SU__c),
            'mapSelectTeam' => CommonUtil.getDependentPicklistValues(User.Team__c)            
        };
        return mapResult;
    }

    /**
     * 경영계획 엑셀파일 Validation
     *
     * @param recordId : Record Id
     * @param strItemDetail : 엑셀데이터
     * @param fileName : 
     * @param fileContents : 
     * @return DataWrapper
     *          - strStatus : 상태
     *          - strMessage : 메시지
     *          - listErrorWrapper : 오류리스트
     *          - listSuccessWrapper : 성공리스트
     *          - totalSize : 전체건수
     *          - successSize : 성공건수
     *          - errorSize : 오류건수
     *
    **/
    @AuraEnabled
    public static DataWrapper doCheckFile(String recordId, String strItemDetail, String fileName, String fileContents) {
        DataWrapper objDataWrapper = new DataWrapper();

        List<FileWrapper> listSuccessWrapper = new List<FileWrapper>();
        List<FileWrapper> listErrorWrapper = new List<FileWrapper>();

        Integer totalSize = 0;
        Integer successSize = 0;
        Integer errorSize = 0;

        try {

            System.debug('================> strItemDetail : '+strItemDetail);

            List<BusinessPlan__c> listItem = (List<BusinessPlan__c>) JSON.deserialize(strItemDetail, List<BusinessPlan__c>.class);

            totalSize = listItem.size();

            Set<String> setEmployeeNumber = new Set<String>();

            for(BusinessPlan__c obj : listItem) {
                if(obj.EmployeeNumber__c <> null) {
                    setEmployeeNumber.add(obj.EmployeeNumber__c);
                }
            }

            Map<String, User> mapUser = new Map<String, User>();

            for(User objUser : [
                SELECT  Id, Name, EmployeeNumber
                FROM    User
                WHERE   EmployeeNumber In:setEmployeeNumber
            ]) {
                mapUser.put(objUser.EmployeeNumber, objUser);
            }

            Integer intSEQ = 1;

            for(BusinessPlan__c objItem : listItem) {
                String strStatus = 'SUCCESS';
                String strMessage;

                FileWrapper objFileWrapper = new FileWrapper();

                System.debug('=========> objItem.EmployeeNumber__c : '+objItem.EmployeeNumber__c);

                objFileWrapper.intSEQ = ++intSEQ;

                if(objItem.EmployeeNumber__c <> null) {
                    objFileWrapper.inputEmployeeNumber = objItem.EmployeeNumber__c;

                    if(mapUser == null || (mapUser <> null && mapUser.get(objItem.EmployeeNumber__c) == null)) {
                        strStatus = 'ERROR';
                        strMessage = '잘못된 사원번호입니다.';
                        errorSize++;
                    }else {
                        successSize++;

                        System.debug('================> objItem : '+JSON.serialize(objItem));
                        objFileWrapper.objItem = objItem;
                    }
                }else {
                    strStatus = 'ERROR';
                    strMessage = '사원번호가 존재하지 않습니다.';
                    errorSize++;
                }

                objFileWrapper.strStatus = strStatus;
                objFileWrapper.strMessage = strMessage;

                System.debug('=============> objFileWrapper.strStatus : '+objFileWrapper.strStatus);
                System.debug('=============> objFileWrapper.strMessage : '+objFileWrapper.strMessage);

                if(objFileWrapper.strStatus == 'SUCCESS') {
                    listSuccessWrapper.add(objFileWrapper);                    
                }else {
                    listErrorWrapper.add(objFileWrapper);                    
                }
            }
        }catch(Exception e) {
            System.debug('======================> Error Line'+e.getLineNumber());
            System.debug('======================> Error Message'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        System.debug('=============> listSuccessWrapper : '+listSuccessWrapper);
        System.debug('=============> listErrorWrapper : '+listErrorWrapper);

        objDataWrapper.listErrorWrapper = listErrorWrapper;
        objDataWrapper.listSuccessWrapper = listSuccessWrapper;
        objDataWrapper.totalSize = totalSize;
        objDataWrapper.successSize = successSize;
        objDataWrapper.errorSize = errorSize;

        return objDataWrapper;
    }

    /**
     * 경영계획 엑셀업로드 Init
     *
     * @param recordId : Record Id
     * @param strAddItem : 엑셀데이터
     * @param mapCount : 
     * @return
     *
    **/
    @AuraEnabled
    public static void doAddItem(String recordId, String strAddItem, Map<String, Integer> mapCount) {
        try {

            List<FileWrapper> listItem = (List<FileWrapper>) JSON.deserialize(strAddItem, List<FileWrapper>.class);

            List<BusinessPlan__c> listAddItem = new List<BusinessPlan__c>();

            for(FileWrapper obj : listItem) {
                BusinessPlan__c objTarget = obj.objItem;

                objTarget.Year__c = objTarget.Year__c.setScale(0);                
                objTarget.ExtId__c = objTarget.EmployeeNumber__c+'_'+objTarget.Year__c+'_'+objTarget.Month__c;

                if(objTarget.Type__c == '신규') {
                    objTarget.Type__c = 'New';
                }else if(objTarget.Type__c == '기존') {
                    objTarget.Type__c = 'EXT';
                }else {
                    objTarget.Type__c = 'New';
                }
                listAddItem.add(objTarget);
            }

            if(listAddItem <> null && listAddItem.size() > 0) {
                upsert listAddItem ExtId__c;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 경영계획 엑셀업로드 샘플 다운로드
     *
     * @param selectedHeadOffice : SU정보
     * @param selectedSU : 사업부정보
     * @return List<DownloadWrapper> : 경영계획 Row 정보
     *
    **/
    @AuraEnabled
    public static List<DownloadWrapper> doGetExportTarget(String selectedHeadOffice, String selectedSU ) {
        try {

            
            Map<String, String> mapHeadOfficeToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'HeadOffice__c');
            Map<String, String> mapSUToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'SU__c');
            Map<String, String> mapTeamToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'Team__c');

            String strQuery = '';
            strQuery += '    SELECT  Id, Name, EmployeeNumber, HeadOffice__c, SU__c, Team__c';
            strQuery += '    FROM    User';
            strQuery += '    WHERE   isActive = true ';
            if(selectedHeadOffice <> null && selectedHeadOffice <> 'none') {
                strQuery += '    AND     HeadOffice__c = \''+selectedHeadOffice+'\'';
            }

            if(selectedSU <> null && selectedSU <> 'none') {
                strQuery += '    AND     SU__c = \''+ selectedSU+'\'';
            }
            strQuery += '    ORDER BY   HeadOffice__c, SU__c, Team__c, EmployeeNumber ';

            System.debug('strQuery :: ' + strQuery);
            System.debug('selectedSU :: ' + selectedSU);

            List<DownloadWrapper> listDownloadWrapper = new List<DownloadWrapper>();

            Set<String> setMonth = new Set<String>{'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'};

            for(User objUser : Database.query(strQuery)) {
                for ( String strMonth : setMonth){
                    DownloadWrapper objDownload = new DownloadWrapper();
                    objDownload.HeadOfficeName = mapHeadOfficeToLabel.get(objUser.HeadOffice__c);
                    objDownload.HeadOfficeCode = objUser.HeadOffice__c;
                    objDownload.SUName = mapSUToLabel.get(objUser.SU__c);
                    objDownload.SUCode = objUser.SU__c;
                    objDownload.TeamName = mapTeamToLabel.get(objUser.Team__c);
                    objDownload.TeamCode = objUser.Team__c;
                    objDownload.UserNumber = objUser.EmployeeNumber;
                    objDownload.UserName = objUser.Name;
                    objDownload.Year = String.valueOf(Date.today().year());
                    objDownload.Month = strMonth;
                    objDownload.Dummy1 = '신규';
                    objDownload.Dummy2 = '';
                    objDownload.Dummy3 = '';
                    objDownload.Dummy4 = '';
                    objDownload.Dummy5 = '';
                    objDownload.Dummy6 = '';
                    listDownloadWrapper.add(objDownload);
                }
            }
            return listDownloadWrapper;

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DataWrapper {
        @AuraEnabled
        public Integer totalSize;
        @AuraEnabled
        public Integer successSize;
        @AuraEnabled
        public Integer errorSize;        
        @AuraEnabled
        public List<FileWrapper> listSuccessWrapper;
        @AuraEnabled
        public List<FileWrapper> listErrorWrapper;
    }

    public class FileWrapper {
        @AuraEnabled
        public Integer intSEQ;
        @AuraEnabled
        public String strStatus;
        @AuraEnabled
        public String strMessage;
        @AuraEnabled
        public String inputEmployeeNumber;
        @AuraEnabled
        public BusinessPlan__c objItem;
    }

    public class DownloadWrapper {
        @AuraEnabled
        public String HeadOfficeName;
        @AuraEnabled
        public String HeadOfficeCode;
        @AuraEnabled
        public String SUName;
        @AuraEnabled
        public String SUCode;
        @AuraEnabled
        public String TeamName;
        @AuraEnabled
        public String TeamCode;
        @AuraEnabled
        public String UserNumber;
        @AuraEnabled
        public String UserName;
        @AuraEnabled
        public String Year;
        @AuraEnabled
        public String Month;
        @AuraEnabled
        public String Dummy1;
        @AuraEnabled
        public String Dummy2;
        @AuraEnabled
        public String Dummy3;
        @AuraEnabled
        public String Dummy4;
        @AuraEnabled
        public String Dummy5;
        @AuraEnabled
        public String Dummy6;
    }
}