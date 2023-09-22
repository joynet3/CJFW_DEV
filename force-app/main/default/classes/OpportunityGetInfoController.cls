/**
 * @description       : Opportunity 관련 데이터를 가져오는 controller 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 09-21-2023
 * @last modified by  : jieun.lee3@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   09-05-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
public with sharing class OpportunityGetInfoController {

    /**
     cjfwOpportunityContractCompare cmp에서 사용 
     Opportunity clone 시 이전 데이터  가져오기 
    *@param  recordId  oppty record id 
    */
    @AuraEnabled(Cacheable=true)
    public static List <Opportunity> getOpportunity( String recordId ) {
        System.debug('recordId = ' + recordId);
        List<Opportunity> opptyList = [ SELECT Name 
                                            , CloseDate 
                                            , AccountId 
                                            , StageName  
                                            , FieldBriefing_ContractStartDate__c
                                            , FieldBriefing_ContractEndDate__c
                                            , ContractType__c
                                            , Amount__c
                                            , ContractPeriod__c
                                            , CommisionPercentage__c
                                            , OtherTermsOfTransaction__c
                                   FROM Opportunity
                                   WHERE Id =: recordId ];
        return opptyList;
    } 



    /* 
     * Oppty 복제전 기존에 복제된 Oppty가 있는지 확인
     */
    @AuraEnabled
    public static Opportunity CheckCloneOppty(String oldRecordId){
        try {
            System.debug('oldRecordId = '+ oldRecordId);
            Opportunity checkOppty = [
                SELECT CopyOppty__c
                FROM Opportunity
                WHERE Id = :oldRecordId
            ];            
            
            return checkOppty;
            
        } catch (Exception e) {
            System.debug('message =>' + e.getMessage());
            System.debug('trace =>' + e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }
    }

    /* 
     * 새 Opportunity 레코드 아이디를 기존 복제 전 Oppty 레코드 필드(CopyOppty__c)에 업데이트하기
     */
    @AuraEnabled
    public static void updateOpptyField(String oldRecordId, String newRecordId){
        try {
            System.debug('oldRecordId = '+ oldRecordId + ' & newRecordId = ' + newRecordId);
            Opportunity updateOppty = new Opportunity(Id = oldRecordId, CopyOppty__c = newRecordId);
            
            update updateOppty;

        } catch (Exception e) {
            System.debug('message =>' + e.getMessage());
            System.debug('trace =>' + e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * 품의 생성시 Opportunity 진행 상태 값 확인
    */
    @AuraEnabled
    public static List<Opportunity> getStage(String recordId) {
        try {
            return[
                SELECT Id, StageName
                FROM Opportunity
                WHERE Id =:recordId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }


}