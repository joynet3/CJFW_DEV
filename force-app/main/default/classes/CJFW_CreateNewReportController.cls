/**
 * @description       : Oppty 품의서 작성화면 관련 Controller ( LWC(cjfwCreateNewReport) 연결 )
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-12-2023
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

    /* 
     * 품의이력 저장 
     */
    @AuraEnabled
    public static String saveDecision(Map<String,Object> saveData){
        
        System.debug(' 넘어온 데이터  '+ saveData) ;
        
        try {
            DecisionProcess__c decPro = new DecisionProcess__c();

            decPro.Name = (String)saveData.get('Name');
            decPro.Opportunity__c = (String)saveData.get('Opportunity__c');     // 기회ID
            decPro.ReportSignature__c = (String)saveData.get('ReportSignature__c');     //품의서명
            decPro.Summary__c = (String)saveData.get('Summary__c');     //Summary__c
            decPro.ClientCompanyName__c = (String)saveData.get('ClientCompanyName__c');     //거래처명
            decPro.RepresentativeName__c = (String)saveData.get('RepresentativeName__c');   //대표자명
            decPro.BusinessPath__c = (String)saveData.get('BusinessPath__c');   //경로
            decPro.OurSales__c = String.isNotBlank((String)saveData.get('OurSales__c')) ? Decimal.valueOf((String)saveData.get('OurSales__c')) : 0.0; // 당사규모
            decPro.SalesMonthly__c = String.isNotBlank((String)saveData.get('SalesMonthly__c')) ? Decimal.valueOf((String)saveData.get('SalesMonthly__c')) : 0.0; // 전체외형
            decPro.InitialDate__c = String.isNotBlank((String)saveData.get('InitialDate__c')) ? Date.valueOf((String)saveData.get('InitialDate__c')) : null;
            decPro.Address__c = (String)saveData.get('Address__c');     //주소
            decPro.RepresentativePhone__c = (String)saveData.get('RepresentativePhone__c'); //연락처
            decPro.PV_EXISTSUP__c = (String)saveData.get('PV_EXISTSUP__c');  // 기존납품처
            decPro.ExceptionPrice__c = String.isNotBlank((String)saveData.get('ExceptionPrice__c')) ? Decimal.valueOf((String)saveData.get('ExceptionPrice__c')) : 0.0; //단가/예외가 -> currency
            decPro.Center__c = (String)saveData.get('Center__c'); //센터
            decPro.ContractStartDate__c = String.isNotBlank((String)saveData.get('ContractStartDate__c')) ? Date.valueOf((String)saveData.get('ContractStartDate__c')) : null;  //계약 시작기간
            decPro.ContractEndDate__c = String.isNotBlank((String)saveData.get('ContractEndDate__c')) ? Date.valueOf((String)saveData.get('ContractEndDate__c')) : null;    //계약 종료기간
            decPro.ContractType__c = (String)saveData.get('ContractType__c');  //계약서 종류
            decPro.OtherSupportDetail__c = (String)saveData.get('OtherSupportDetail__c');  //기타 지원세부 내역
            decPro.ImprovementPlanDetails__c = (String)saveData.get('ImprovementPlanDetails__c');  //개선 방안 내역
            decPro.OpptyDescription__c = (String)saveData.get('OpptyDescription__c');  //특이사항
            decPro.AttachedDocument__c = (String)saveData.get('AttachedDocument__c');  // 첨부서류
            decPro.DocStatus__c = '임시저장'; 
            
            insert decPro;
            return 'Success'; 

        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
            return 'Error: ' + e.getMessage(); // 에러 메시지 반환
        }
    }
}