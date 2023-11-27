/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 11-24-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
**/
public with sharing class CJFW_MDMExcelChooseColumnController {

    @AuraEnabled
    public static List<OptionObj> getAttributeOptions(String property){
        system.debug('# getAttributeOptions() ');
        system.debug('property ' + property);

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
    public static List<AccountApplicableField__mdt> getDownloadField(String property, String attribute, String type, String searchWord) {
        system.debug('# getDownloadField() ');
        system.debug('property ' + property);
        system.debug('property ' + attribute);
        system.debug('property ' + type);
        system.debug('property ' + searchWord);

        String typeApi = null;

        if (type == '본점') {
            typeApi = 'MDMParent';
        } else if (type == '판매처') {
            typeApi = 'MDMChild';
        } else if (type == '관리처-분할') {
            typeApi = 'MDMManagement';
        } else if (type == '관리처-배송') {
            typeApi = 'MDMDelievery';
        } else if (type == '관리처-2차') {
            typeApi = 'MDM2ndManagement';
        }

        System.debug('## type => ' + type);
        System.debug('## typeApi => ' + typeApi);

        String strQuery = 'SELECT MasterLabel, FieldType__c, ApiName__c, GroupCode__c FROM AccountApplicableField__mdt';
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
        strQuery += ' AND ApiName__c != \'CreatedDate\' ';
        strQuery += ' ORDER BY MasterLabel';

        System.debug('query => ' + strQuery);

        List<AccountApplicableField__mdt> fieldSet = Database.query(strQuery);

        System.debug('>>> fieldSet ' + fieldSet);

        return fieldSet;

    }

    /* Filter 값 불러오기 */
    @AuraEnabled
    public static List<AccountApplicableField__mdt> getFilterField(String property, String attribute, String type, String searchWord) {
        system.debug('# getFilterField() ');
        system.debug('property ' + property);
        system.debug('property ' + attribute);
        system.debug('property ' + type);
        system.debug('property ' + searchWord);
        String typeApi = null;

        if (type == '본점') {
            typeApi = 'MDMParent';
        } else if (type == '판매처') {
            typeApi = 'MDMChild';
        } else if (type == '관리처-분할') {
            typeApi = 'MDMManagement';
        } else if (type == '관리처-배송') {
            typeApi = 'MDMDelievery';
        } else if (type == '관리처-2차') {
            typeApi = 'MDM2ndManagement';
        }

        System.debug('## type => ' + type);
        System.debug('## typeApi => ' + typeApi);

        String strQuery = 'SELECT MasterLabel, FieldType__c, ApiName__c, GroupCode__c FROM AccountApplicableField__mdt';
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
        strQuery += ' AND isFilter__c = true ';
        strQuery += ' ORDER BY MasterLabel';

        System.debug('query => ' + strQuery);

        List<AccountApplicableField__mdt> fieldSet = Database.query(strQuery);

        System.debug('>>> fieldSet ' + fieldSet);

        return fieldSet;

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