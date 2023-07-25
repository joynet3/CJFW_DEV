/**
 * @description       : 
 * @author            : youngmin.kim@daeunextier.com
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class MDMRegRequestMain {
    /**
     * MDM 고객정보 등록 Init
     * 
     * @params recordId MDMRegRequestCustomer Id          
     * @return DataWrapper
     *
    **/
    @AuraEnabled
    public static DataWrapper doInit(Id recordId) {
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';
        String strMessage = '';

        Boolean isMDMEdit = false;
        Boolean isMDMParent = false;
        Boolean isContact = false;

        try {
            String strObjectType = String.valueOf(recordId.getSobjectType());

            System.debug('================> recordId : '+recordId);
            System.debug('================> strObjectType : '+strObjectType);

            // MDM 신규고객등록 편집버튼 클릭시
            if(strObjectType == 'MDMRegRequestCustomer__c') {
                isMDMEdit = true;
                isContact = true;
                MDMRegRequestCustomer__c objMDMRegReqCustomer = [
                    SELECT  Id, Name, RecordTypeId, RecordType.DeveloperName
                    FROM    MDMRegRequestCustomer__c
                    WHERE   Id =:recordId
                ];

                if(objMDMRegReqCustomer.RecordType.DeveloperName == 'MDMParent') {
                    isMDMParent = true;
                }
            }else {                
                Opportunity objOpportunity = [
                    SELECT Id, AccountId FROM Opportunity WHERE Id =:recordId
                ];

                List<Contact> listContact = new List<Contact>();

                listContact = [
                    SELECT Id, AccountId  FROM Contact WHERE AccountId =:objOpportunity.AccountId
                ];

                if(listContact <> null && listContact.size() > 0) {
                    isContact = true;
                }
                
                objWrapper.strAccountId = objOpportunity.AccountId;
            }
        }catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();
        }

        objWrapper.isMDMEdit = isMDMEdit;
        objWrapper.isMDMParent = isMDMParent;
        objWrapper.isContact = isContact;

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
        public Boolean isMDMEdit {get;set;}
        @AuraEnabled
        public Boolean isMDMParent {get;set;}

        @AuraEnabled
        public Boolean isContact {get;set;}
        @AuraEnabled
        public String strAccountId {get;set;}
    }

    /**
     * 워크플로우 Lv1 카테고리 리스트 조회
     *      
     * @return List<workflow__c>
     *
    **/
	@AuraEnabled
    public static List<workflow__c> getCategoryLevel1() {
        try {
            List<workflow__c> categoryLevel1 = new List<workflow__c>();
            String catLevel1 = '1';
            categoryLevel1 = [SELECT Id, Name, LargeCode__c, level__c, ProcessId__c FROM workflow__c WHERE Level__c = :catLevel1  order by name];
            return categoryLevel1;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 
    /**
     * 워크플로우 Lv2 카테고리 리스트 조회
     *      
     * @return List<workflow__c>
     *
    **/
    @AuraEnabled
    public static List<workflow__c> getCategoryLevel2(String largeCode) {
        
        system.debug(largeCode+'라지코드');
        try {
            List<workflow__c> categoryLevel2 = new List<workflow__c>();
            String catLevel2 = '2';
			categoryLevel2 = [SELECT Id, Name, MidCategory__c,level__c FROM workflow__c WHERE Level__c = :catLevel2 AND LargeCode__c = :largeCode];
            System.debug(categoryLevel2+'<<<<<<<<<<<<<<<<<');
            
            return categoryLevel2;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * 워크플로우 Lv3 카테고리 리스트 조회
     *      
     * @return List<workflow__c>
     *
    **/
    @AuraEnabled
    public static List<workflow__c> getCategoryLevel3(String midCode, List<workflow__c> largeCode) {
        try {
            List<workflow__c> categoryLevel3 = new List<workflow__c>();
            String catLevel3 = '3';
            categoryLevel3 = [SELECT Id, Name, LargeCode__c, MidCategory__c, getCategory__c,level__c 
                              FROM workflow__c WHERE Level__c = :catLevel3 AND MidCategory__c = :midCode AND 
                              LargeCode__c = :largeCode[0].Name];
			System.debug(categoryLevel3+'카테고리 3');
            return categoryLevel3;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}