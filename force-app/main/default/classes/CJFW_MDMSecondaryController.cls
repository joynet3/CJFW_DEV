/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 09-14-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
public with sharing class CJFW_MDMSecondaryController {

    @AuraEnabled
    public static List<Account> getHKUNNR(String selectedId) {
        List<Account> accList = [SELECT Id, ParentId
                                FROM Account
                                WHERE Id =: selectedId
                                LIMIT 1];
        return accList;
    }

    @AuraEnabled
    public static void saveBank(List<AccountBankInfo__c> banks){
        
        try {

            List<AccountBankInfo__c> objList = new List<AccountBankInfo__c>();
            // String result = null;

            for(AccountBankInfo__c bank : banks) {
                AccountBankInfo__c obj = new AccountBankInfo__c();
                // obj.Account__c = '';                            // 고객
                obj.Name = bank.Name;                           // 은행명
                obj.PV_BANKL__c = bank.PV_BANKL__c;             // 은행 Key
                obj.PV_BANKN__c = bank.PV_BANKN__c;             // 가상 계좌 번호
                obj.PV_KOINH__c = bank.PV_KOINH__c;             // 예금주
                obj.PV_BKONT__c = bank.PV_BKONT__c;             // 은행 관리 Key
                obj.PV_BVTYP__c = bank.PV_BVTYP__c;             // 은행 유형
                obj.PV_BKREF__c = bank.PV_BKREF__c;             // 참조 명세
                obj.PV_ACTCLOSEYN__c = bank.PV_ACTCLOSEYN__c;   // 계좌 해지 여부
                obj.PV_ACTCLOSED__c = bank.PV_ACTCLOSED__c;     // 계좌 해지 일자

                System.debug('## new AccountBankInfo__c => ' + obj);
                objList.add(obj);
            }
            
            if(objList.size() > 0) {
                insert objList;
            }

            // return 'S';
            
        } catch (Exception e) {

            System.debug('message =>' + e.getMessage());
            System.debug('trace =>' + e.getStackTraceString());
            
            throw new AuraHandledException(e.getMessage());
            
        }

    }

}