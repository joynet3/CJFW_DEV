/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 09-22-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkAccountSearchController {

    @AuraEnabled(cacheable=true)
    public static DataWrapper getAccountInfo(String searchWord, String type, Integer pageNumber, Integer pageSize) {

        system.debug('### CJFW_MDMBulkAccountSearchController ###');
        system.debug('>>> getAccountInfo()');
        system.debug('>>> searchWord ' + searchWord);
        system.debug('>>> type ' + type);

        String searchCode = null;

        if(type == '판매처') {
            searchCode = 'C02';
        } else if(type == '관리처') {
            searchCode = 'C03\', \'C04\', \'C11';
        }

        searchCode = searchCode.replace(' ', '');

        String[] codeList = searchCode.split(',');

        String strStatus = 'SUCCESS';
        String strMessage = '';

        System.debug('===============> searchWord : '+searchWord);
        System.debug('===============> searchCode : '+searchCode);

        DataWrapper objWrapper = new DataWrapper();

        
        try {

            List<Account> searchResult = new List<Account>(); // 분할해서 담은
            List<Account> listSearchResult = new List<Account>(); // 모두 담은

            String strQuery = 'SELECT Id, CustomerID__c, Name, Owner.Name';
            strQuery += '   FROM    Account';
            strQuery += '   WHERE   CustomerType__c IN ( \'' + searchCode + '\' ) AND CustomerId__c != NULL ';
            if(searchWord <> null) {
                strQuery += '   AND     (Name LIKE \'%' + searchWord + '%\' OR Owner.Name LIKE \'%' + searchWord + '%\')';
            }

            System.debug('============> strQuery : '+strQuery);
            
            listSearchResult = Database.query(strQuery);

            Integer listSearchResultSize = listSearchResult.size();

            Integer startIndex = (pageNumber - 1) * pageSize;
            Integer endIndex = Math.min(startIndex + pageSize, listSearchResultSize);

            if(endIndex > startIndex){
                for (Integer i = startIndex; i < endIndex; i++) {
                    searchResult.add(listSearchResult[i]);
                }
            }

            objWrapper.searchResult = searchResult;

            System.debug('결과 => ' + searchResult);

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
        public List<Account> searchResult {get;set;}

        @AuraEnabled
        public List<Account> listSearchResult {get;set;}

        @AuraEnabled
        public Integer totalCnt {get;set;}

        @AuraEnabled
        public String code {get;set;}

        @AuraEnabled
        public String inputId {get;set;}

        @AuraEnabled
        public String inputTextLabel {get;set;}

	}

}