/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 08-31-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-30-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMManagementSearchController {
    @AuraEnabled(cacheable=true)
    public static DataWrapper getMDMReferenceCodeInfo(String searchWord , String strGroupId){

        system.debug('###CJFW_MDMManagementSearchController###');
        system.debug('>>> getMDMReferenceCodeInfo()');
        system.debug('>>> searchWord ' + searchWord);
        system.debug('>>> groupId ' + strGroupId);
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
            Integer listSearchResultSize = listSearchResult.size();
            
            /*
            objWrapper.listSelectBrand = CommonUtil.getPickListValues('Account', 'ExceptBrand__c', true);
            objWrapper.listSelectCompany = CommonUtil.getPickListValues('Account', 'Company__c', true);
            objWrapper.listSelectPlatform = CommonUtil.getPickListValues('Product2', 'Platform__c', true);
            */

            objWrapper.listSearchResult = listSearchResult;
            objWrapper.totalCnt = listSearchResultSize;
            
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
        public Integer totalCnt {get;set;}

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


}