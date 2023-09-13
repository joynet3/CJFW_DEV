public with sharing class CJFW_MDMEditModalController {
     /**
     * @description : 화면에서 Param으로 보내준 AccountId로 customer 필드를 조회하여, 리턴
     *                customer 타입에 따라 화면을 분기 처리해 주기 위함.
     *
     * @return      `String`
     */
    @AuraEnabled
    public static String getCustomerTypeInfo(String accId) {
        system.debug('>>>getCustomerTypeInfo');
        String customerType = '';

        // 화면에 AccountId로 조회하여, 해당 조회문은 단건으로 밖에 나오지않음
        List<Account> accountList = [SELECT Id, customerType__c
                                    FROM Account
                                    WHERE Id =: accId
                                    LIMIT 1];
        if(!accountList.isEmpty())
        {
            customerType = accountList[0]?.customerType__c;
        }
        return customerType;
    }
}