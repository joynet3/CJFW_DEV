/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class MDMReferenceCodeSearch {
    /**
     * MDM 참조코드 Init
     * 
     * @param strGroupId GroupId
     * @param inputText 검색어
     * @return DataWrapper
     *
    **/
    @AuraEnabled
	public static DataWrapper doInit(String strGroupId, String inputText) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {

            List<MDMReferenceCode__c> listSearchResult = new List<MDMReferenceCode__c>();
            listSearchResult = [
                SELECT  Id, Name, ExtId__c, INSTANCEID__c, GROUPID__c, CODE__c, NAME_KO__c, NAME_EN__c, NAME_ZH__c, NAME_VI__c, ATTR1__c, ATTR2__c, ATTR3__c, IsActive__c, ACTIVE__c, IsDefault__c
                FROM    MDMReferenceCode__c
                WHERE   IsActive__c = TRUE
                AND     GROUPID__c =:strGroupId
                ORDER   BY GROUPID__c, CODE__c ASC
            ];

            for (MDMReferenceCode__c codeRec : listSearchResult) {
                if (codeRec.CODE__c == inputText) {
                    objWrapper.code = codeRec.CODE__c;
                    objWrapper.inputId = codeRec.Id;
                    objWrapper.inputTextLabel = codeRec.Name;
                }
            }
    
            /*
            objWrapper.listSelectBrand = CommonUtil.getPickListValues('Account', 'ExceptBrand__c', true);
            objWrapper.listSelectCompany = CommonUtil.getPickListValues('Account', 'Company__c', true);
            objWrapper.listSelectPlatform = CommonUtil.getPickListValues('Product2', 'Platform__c', true);
            */

            objWrapper.listSearchResult = listSearchResult;
            
            
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    /**
     * MDM 참조코드 조회
     * 
     * @param strGroupId GroupId
     * @param searchWord 검색어
     * @return DataWrapper
     *
    **/
    @AuraEnabled
	public static DataWrapper doSearch(String strGroupId, String searchWord) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        System.debug('===============> searchWord : '+searchWord);

        DataWrapper objWrapper = new DataWrapper();

        try {
            List<MDMReferenceCode__c> listSearchResult = new List<MDMReferenceCode__c>();

            String strQuery = 'SELECT Id,';
            strQuery += '   Name, ExtId__c, INSTANCEID__c, GROUPID__c, CODE__c,';
            strQuery += '   NAME_KO__c, NAME_EN__c, NAME_ZH__c, NAME_VI__c,';
            strQuery += '   ATTR1__c, ATTR2__c, ATTR3__c, IsActive__c, ACTIVE__c, IsDefault__c';
            strQuery += '   FROM    MDMReferenceCode__c';
            strQuery += '   WHERE   GROUPID__c = \''+strGroupId+'\'';
            strQuery += '   AND     IsActive__c = TRUE';
            if(searchWord <> null) {
                strQuery += '   AND     (Name LIKE \'%'+searchWord+'%\' OR CODE__c LIKE \'%'+searchWord+'%\')';
            }
            // 2023-01-14 지역코드일 경우 5자리 코드만 조회하도록 추가 
            if(strGroupId == 'T005S') {
                strQuery += '   AND     CODE__c LIKE \'_____\'';
            }
            // 2023-02-02 영업그룹코드일 경우 유효일자 체크로직 추가
            if(strGroupId == 'SALESGROUPH') {
                String strToday = Datetime.now().format('yyyy-MM-dd');

                strQuery += '   AND     ATTR1__c <= \''+strToday+'\'';
                strQuery += '   AND     ATTR2__c >= \''+strToday+'\'';
            }

            strQuery += '   ORDER   BY GROUPID__c, CODE__c ASC';            

            System.debug('============> strQuery : '+strQuery);

            listSearchResult = Database.query(strQuery);
            /*
            objWrapper.listSelectBrand = CommonUtil.getPickListValues('Account', 'ExceptBrand__c', true);
            objWrapper.listSelectCompany = CommonUtil.getPickListValues('Account', 'Company__c', true);
            objWrapper.listSelectPlatform = CommonUtil.getPickListValues('Product2', 'Platform__c', true);
            */

            objWrapper.listSearchResult = listSearchResult;
            
            
        } catch(Exception e) {
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
        public List<MDMReferenceCode__c> listSearchResult {get;set;}

        @AuraEnabled
        public String code {get;set;}

        @AuraEnabled
        public String inputId {get;set;}

        @AuraEnabled
        public String inputTextLabel {get;set;}

        /*
        @AuraEnabled
        public List<SearchResult> listSearchResult {get;set;}
        */
	}

    public class SearchResult {
        @AuraEnabled
        public String strId {get;set;}        
        @AuraEnabled
        public String strName {get;set;}
        @AuraEnabled
        public String strGroupId {get;set;}
        @AuraEnabled
        public String strCode {get;set;}
    }

}