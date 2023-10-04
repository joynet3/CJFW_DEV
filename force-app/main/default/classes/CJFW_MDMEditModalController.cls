/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 09-25-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   09-22-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMEditModalController {
     /**
     * @description : 화면에서 Param으로 보내준 AccountId로 customer 필드를 조회하여, 리턴
     *                customer 타입에 따라 화면을 분기 처리해 주기 위함.
     *
     * @return      `String`
     */
    @AuraEnabled
    public static DataWrapper getCustomerTypeInfo(Id recordId) {
        DataWrapper objWrapper = new DataWrapper();
        system.debug(' ###CJFW_MDMEditModalController > getCustomerTypeInfo()');
        // ObjectType 
        
        system.debug(' >>> recordId' + recordId);

        String strObjectType = String.valueOf(recordId.getSobjectType());
        String customerType = '';
        
        system.debug(' >>> strObjectType ' + strObjectType);        
        
        // [2. MDMRegRequestCustomer__c에서 수정 시] 
        if(strObjectType == 'MDMRegRequestCustomer__c'){
            objWrapper.strObjectType = 'MDMRegRequestCustomer';
            system.debug(' ====================================> MDMRegRequestCustomer 에서 Edit 중');
            List<MDMRegRequestCustomer__c> mdmRegRequestCustomer = [SELECT Id, PV_CUSTTYPE__c 
                                                                    FROM MDMRegRequestCustomer__c 
                                                                    WHERE Id =:recordId
                                                                    Limit 1];
            if(!mdmRegRequestCustomer.isEmpty()){
                objWrapper.customerType = mdmRegRequestCustomer[0]?.PV_CUSTTYPE__c;
                system.debug(' ====================================> mdmRegRequestCustomer[0]?.PV_CUSTTYPE__c ' + mdmRegRequestCustomer[0]?.PV_CUSTTYPE__c);
            }
        // [3. Account Detail에서 수정 시]
        }else{
            objWrapper.strObjectType = 'Account';
            system.debug(' ====================================> Account 에서 Edit 중');
            List<Account> accountList = [SELECT Id, customerType__c
                                        FROM Account
                                        WHERE Id =: recordId
                                        LIMIT 1];

            List<Contact> listContact = [
                SELECT Id, AccountId  FROM Contact WHERE AccountId =:recordId
            ];

            if(listContact <> null && listContact.size() > 0) {
                objWrapper.isContact = true;
            }
            
            if(!accountList.isEmpty()) {
                objWrapper.customerType = accountList[0]?.customerType__c;
                system.debug(' ====================================> accountList[0]?.customerType__c ' + accountList[0]?.customerType__c);
            }
        }
        return objWrapper;
    }

    /**
    * @description 로딩시 뿌려줘야할 데이터 Wrapper
    */
    public class DataWrapper {
        /** @description 반환성공을 알려주는 Status*/
        @AuraEnabled public String strStatus {get;set;}
        /** @description 에러메세지*/
        @AuraEnabled public String strMessage {get;set;}
        /** @description 레코드아이디를 통해 알아낸 고객유형*/
        @AuraEnabled public String customerType {get;set;}
        /** @description Object Name*/
        @AuraEnabled public String strObjectType {get;set;}
         /** @description Object Name*/
         @AuraEnabled public Boolean isContact {get;set;}

        public DataWrapper() {}
    }
}