/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 10-24-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMExcelChooseColumnController {

    @AuraEnabled
    public static List<OptionObj> getAttributeOptions(String property){

        List<OptionObj> attributeOptions = new List<OptionObj>();

        if(property == 'BasicProperty') {

            OptionObj obj = new OptionObj('기본정보', 'BasicAttribute');
            attributeOptions.add(obj);

        } else if(property == 'PaymentsProperty') {

            OptionObj obj2 = new OptionObj('지급정보', 'PaymentsAttribute');
            OptionObj obj3 = new OptionObj('세금정보', 'TaxAttribute');
            attributeOptions.add(obj2);
            attributeOptions.add(obj3);

        } else {

            OptionObj obj4 = new OptionObj('영업정보', 'SalesAttribute');
            OptionObj obj5 = new OptionObj('물류정보', 'DistributionAttribute');
            attributeOptions.add(obj4);
            attributeOptions.add(obj5);

        }

        System.debug(attributeOptions);

        return attributeOptions;

    }

    /* 속성부문, 속성군, 타입에 따라 field값 다르게 도출하기 */
    @AuraEnabled
    public static List<String> getDownloadField(String property, String attribute, String type, String searchWord) {

        String typeApi = null;

        switch on type {
            when '본점' {
                typeApi = 'MDMParent';
            }
            when '판매처' {
                typeApi = 'MDMChild';
            }
            when '분할관리처' {
                typeApi = 'MDMManagement';
            }
            when '배송관리처' {
                typeApi = 'MDMDelievery';
            }
            when '2차관리처' {
                typeApi = 'MDM2ndManagement';
            }
        }

        typeApi = 'MDMParent';

        String strQuery = 'SELECT MasterLabel FROM AccountApplicableField__mdt';
        strQuery += ' WHERE AccountType__r.DeveloperName = \'' + typeApi + '\'';
        if(property != null) {
            strQuery += ' AND PropertySector__r.DeveloperName = \'' + property + '\'';
        }
        if(attribute != null) {
            strQuery += ' AND AttributeGroup__r.DeveloperName = \'' + attribute + '\'';
        }
        if(searchWord != null) {
            strQuery += ' AND MasterLabel LIKE \'%' + searchWord + '%\'';
        }
        strQuery += ' ORDER BY MasterLabel';

        System.debug('query => ' + strQuery);

        List<AccountApplicableField__mdt> fieldSet = Database.query(strQuery);

        System.debug('>>> fieldSet ' + fieldSet);

        // List<AccountApplicableField__mdt> mcs = AccountApplicableField__mdt.getAll().values();
        // System.debug('>>> mcs ' + mcs);

        List<AccountApplicableField__mdt> objects = new List<AccountApplicableField__mdt>();

        List<String> records = new List<String>();

        for(AccountApplicableField__mdt record : fieldSet) {
            records.add(record.MasterLabel);
        }

        System.debug('>>> records : ' + records);
        
        return records;

    }

    public class OptionObj {

        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        
        public OptionObj(String basic, String basic2) {
            label = basic;
            value = basic2;
        }
    }

}