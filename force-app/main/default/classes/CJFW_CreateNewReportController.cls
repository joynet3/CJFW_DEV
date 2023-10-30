/**
 * @description       : Oppty 품의서 작성화면 관련 Controller ( LWC(cjfwCreateNewReport) 연결 )
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : yeonji.lim@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   09-13-2023   yeonji.lim@dkbmc.com      Initial Version
 * 1.1   10-06-2023   eunyoung.choi@dkbmc.com   품의이력 저장 
**/
public class CJFW_CreateNewReportController {
    
    /* 
     * Oppty에 연결된 Account 데이터 가져오기 
     */
    @AuraEnabled
    public static List<Opportunity> getAccountData(String OpptyId){
        try {
            System.debug('OpptyId = ' + OpptyId);

            List<Opportunity> accountData = [
                SELECT 	Description, Account.Name, Account.RepresentativeName__c, Account.BusinessPath__c, Account.SalesMonthly__c, Account.OurSales__c, Account.Address__c, Account.PV_EXISTSUP__c
                FROM Opportunity
                WHERE Id =:OpptyId
            ];

            return accountData.size()>0 ? accountData : new List<Opportunity>();

        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }
    }

    /* 
     * User Obj에서 영업경로 가져오기 
     */
    @AuraEnabled
    public static List<User> getSulLabel(String UserId){
        try {
            System.debug('UserId = ' + UserId);

            List<User> sulLabelData = [
                select id , SULabel__c 
                from User 
                where Id =:UserId
            ];

            return sulLabelData.size()>0 ? sulLabelData : new List<User>();

        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }
    }
}