/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class EDMSFileListView {
    /**
     * EDMS File List Init
     * 
     * @param recordId record Id     
     * @return DataWrapper
     *          - strStatus : 상태
     *          - strMessage : 메시지
     *          - listSearchWrapper : 조회결과
     *
    **/
    @AuraEnabled
    public static DataWrapper getDataTable(String recordId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';
        DataWrapper objWrapper = new DataWrapper();
        List<SearchWrapper> listSearchWrapper = new List<SearchWrapper>();
        try {
            if (recordId != null) {
                String strQuery =   '   SELECT      Id, Name, DownloadURL__c, toLabel(Status__c), tolabel(Type__c), LastModifiedBy.Name, FORMAT(LastModifiedDate)';
                strQuery +=         '   FROM        EDMSFile__c';
                strQuery +=         '   WHERE       TargetId__c =: recordId';
                strQuery +=         '   ORDER BY    LastModifiedDate desc';

                System.debug('strQuery : ' + strQuery);
                for(EDMSFile__c objEDMSFile : Database.query(strQuery)) {
                    SearchWrapper objSearch = new SearchWrapper(objEDMSFile);
                    listSearchWrapper.add(objSearch);
                }
            }else {
                strStatus = 'ERROR';
                strMessage = 'RecordId ERROR';
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
    public class DataWrapper {
        @AuraEnabled
        public String strStatus {get;set;}
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public List<SearchWrapper> listSearchWrapper {get;set;}
    }

    public class SearchWrapper {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String LastModifiedUser { get; set; }
        @AuraEnabled
        public Datetime LastModifiedDate { get; set; }
        @AuraEnabled
        public String donwload { get; set; }
        @AuraEnabled
        public String downloadURL { get; set; }

        public SearchWrapper() {
        }

        public SearchWrapper(EDMSFile__c objEDMSFile) {
            this.id = objEDMSFile.Id;
            this.name = objEDMSFile.Name;
            this.status = objEDMSFile.Status__c;
            this.type = objEDMSFile.Type__c;
            this.LastModifiedUser = objEDMSFile.LastModifiedBy.Name;
            this.LastModifiedDate = objEDMSFile.LastModifiedDate;
            this.downloadURL = objEDMSFile.DownloadURL__c;
            this.donwload = '다운로드';
        }
    }
}