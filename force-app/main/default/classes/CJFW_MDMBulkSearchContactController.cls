/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
**/
public with sharing class CJFW_MDMBulkSearchContactController {
    
    @AuraEnabled(cacheable=true)
    public static DataWrapper getContactInfo(List<Map<String, String>> searchKey, String recordId, Integer pageNumber, Integer pageSize, String typeValue){

        system.debug('### CJFW_MDMBulkSearchContactController ###');
        system.debug('>>> getContactInfo()');

        String strStatus = 'SUCCESS';
        String strMessage = '';

        System.debug('===============> searchKey : ' + searchKey);
        System.debug('===============> recordId : ' + recordId);
        System.debug('===============> typeValue : ' + typeValue);

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
        
        List<String> ids = new List<String>();

        if(recordId != null) {
            List<MDMRegRequestCustomer__c> customerList = [SELECT Id, PV_KUNNR__c FROM MDMRegRequestCustomer__c WHERE MDMRegRequestBulkCustomer__c = :recordId];
            
            for(MDMRegRequestCustomer__c cus : customerList) {
                //ids.add('\'' + cus.PV_KUNNR__c + '\'');
                ids.add(cus.PV_KUNNR__c);
            }
            
            System.debug('===============> customerList : ' + customerList);
            System.debug('===============> ids : ' + ids);
        }
        

        DataWrapper objWrapper = new DataWrapper();

        try {

            List<Contact> searchResult = new List<Contact>();       // 분할해서 담은
            List<Contact> listSearchResult = new List<Contact>();   // 모두 담은

            String strQuery = 'SELECT Id, AccountId, Account.CustomerId__c, Account.Name, Name, ';
            strQuery += ' PV_KNVKGB__c, toLabel(PV_KNVKGB__c) PV_KNVKGB__LABEL, ';
            strQuery += ' Phone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, Email ';
            strQuery += ' FROM Contact ';
            strQuery += ' WHERE Account.CustomerId__c != null ';
            if(recordId != null) {
                // strQuery += ' AND Account.CustomerId__c IN (' + String.join(ids, ',') + ') ';
                strQuery += ' AND Account.CustomerId__c IN :  ids ';
            }
            if(typeValue != null) {
                strQuery += ' AND Account.CustomerType__c = \'' + typeValue + '\' ';
            }
            for(Integer i = 0; i < searchKeys.size(); i++) {
                if(searchKeys[i] == 'AccountId') {
                    strQuery += ' AND ' + searchKeys[i] + ' = \'' + searchValues[i] + '\'';
                } else {
                    strQuery += ' AND ' + searchKeys[i] + ' LIKE \'%' + searchValues[i] + '%\' ';
                }
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
        public List<Contact> searchResult {get;set;}

        @AuraEnabled
        public List<Contact> listSearchResult {get;set;}

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