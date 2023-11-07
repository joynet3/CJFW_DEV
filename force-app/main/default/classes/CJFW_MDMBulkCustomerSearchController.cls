/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-02-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMBulkCustomerSearchController {
    
    @AuraEnabled(cacheable=true)
    public static DataWrapper getCustomerInfo(List<Map<String, String>> searchKey, String recordId, Integer pageNumber, Integer pageSize) {

        system.debug('### CJFW_MDMBulkAccountSearchController ###');
        system.debug('>>> getAccountInfo()');

        String strStatus = 'SUCCESS';
        String strMessage = '';

        System.debug('===============> searchKey : ' + searchKey);
        System.debug('===============> recordId : ' + recordId);

        // Key와 Value 따로 담아 주기
        List<String> searchKeys = new List<String>();
        List<String> searchValues = new List<String>();
        Map<String, String> dateValues = new Map<String, String>();

        for(Map<String, String> data : searchKey) {

            String apiType = data.get('type');
            String fieldName = data.get('fieldName');
            String datePoint = data.get('datePoint');
            String searchWord = data.get('searchKey');

            System.debug('## get param > ' + 'fieldName: ' + fieldName + ', apiType: ' + apiType + ', datePoint: ' + datePoint + ', searchWord: ' + searchWord);

            if(searchWord != null) {
                searchWord = searchWord.trim();
            }

            if(searchWord != null && searchWord.length() > 0 && fieldName != 'CreatedDate') {
                searchKeys.add(fieldName);
                searchValues.add(searchWord);
            } else if(searchWord != null && searchWord.length() > 0 && fieldName == 'CreatedDate') {
                searchWord = searchWord + 'T00:00:00.000+0000'; // UTC
                dateValues.put(datePoint, searchWord);
            }

        }

        System.debug('===============> searchKeys : ' + searchKeys);
        System.debug('===============> searchValues : ' + searchValues);
        System.debug('===============> dateValues : ' + dateValues);

        DataWrapper objWrapper = new DataWrapper();
        
        try {

            List<MDMRegRequestCustomer__c> searchResult = new List<MDMRegRequestCustomer__c>(); // 분할해서 담은
            List<MDMRegRequestCustomer__c> listSearchResult = new List<MDMRegRequestCustomer__c>(); // 모두 담은

            String strQuery = 'SELECT Id, PV_NAME1__c, PV_CUSTTYPE__c, toLabel(PV_CUSTTYPE__c) CustTypeLabel, PV_PERNR__c FROM MDMRegRequestCustomer__c ';
            strQuery += ' WHERE   	MDMRegRequestBulkCustomer__c = \'' + recordId + '\'';
            for(Integer i = 0; i < searchKeys.size(); i++) {
                if(searchKeys[i] == 'OwnerId') {
                    strQuery += ' AND ' + searchKeys[i] + ' = \'' + searchValues[i] + '\'';
                } else {
                    strQuery += ' AND ' + searchKeys[i] + ' LIKE \'%' + searchValues[i] + '%\' ';
                }
            }
            if(dateValues.size() > 0) {
                if(dateValues.get('start') != null) {
                    strQuery += ' AND CreatedDate >= ' + dateValues.get('start');
                } else if(dateValues.get('end') != null) {
                    strQuery += ' AND CreatedDate <= ' + dateValues.get('end');
                }
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