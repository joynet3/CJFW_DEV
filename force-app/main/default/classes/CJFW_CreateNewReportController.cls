/**
 * @description       : Oppty 품의서 작성화면 관련 Controller
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 09-13-2023
 * @last modified by  : yeonji.lim@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   09-13-2023   yeonji.lim@dkbmc.com      Initial Version
**/
public class CJFW_CreateNewReportController {
    
    /* 
     * lwc (cjfwCreateNewReport) 연결
     * Oppty에 연결된 Account 데이터 가져오기 
     */
    @AuraEnabled
    public static Opportunity getAccountData(String OpptyId){
        try {
            System.debug('OpptyId = ' + OpptyId);

            Opportunity accountData = [
                SELECT Id, Name, Account.Name, Account.RepresentativeName__c, Account.BusinessPath__c, Account.SalesMonthly__c, Account.OurSales__c, Account.Address__c, Account.PV_EXISTSUP__c
                FROM Opportunity
                WHERE Id =:OpptyId
            ];

            return accountData;

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
    public static User getSulLabel(String UserId){
        try {
            System.debug('UserId = ' + UserId);

            User sulLabelData = [
                select id , SULabel__c 
                from User 
                where Id ='0050w000004E8L1AAK'
            ];

            return sulLabelData;

        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }
    }
}