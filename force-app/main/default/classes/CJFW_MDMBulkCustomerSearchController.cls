/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 10-27-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkCustomerSearchController {
    
    @AuraEnabled(cacheable=true)
    public static DataWrapper getCustomerInfo(String searchWord, String recordId, Integer pageNumber, Integer pageSize) {

        system.debug('### CJFW_MDMBulkAccountSearchController ###');
        system.debug('>>> getAccountInfo()');
        system.debug('>>> searchWord ' + searchWord);
        system.debug('>>> recordId ' + recordId);

        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();
        
        try {

            List<MDMRegRequestCustomer__c> searchResult = new List<MDMRegRequestCustomer__c>(); // 분할해서 담은
            List<MDMRegRequestCustomer__c> listSearchResult = new List<MDMRegRequestCustomer__c>(); // 모두 담은

            String strQuery = 'SELECT Id, PV_NAME1__c, PV_CUSTTYPE__c, PV_PERNR__c FROM MDMRegRequestCustomer__c ';
            strQuery += ' WHERE   	MDMRegRequestBulkCustomer__c = \'' + recordId + '\'';
            if(searchWord <> null) {
                strQuery += ' AND     (PV_NAME1__c LIKE \'%' + searchWord + '%\')';
            }

            System.debug('============> strQuery : ' + strQuery);
            
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
        public List<MDMRegRequestCustomer__c> searchResult {get;set;}

        @AuraEnabled
        public List<MDMRegRequestCustomer__c> listSearchResult {get;set;}

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