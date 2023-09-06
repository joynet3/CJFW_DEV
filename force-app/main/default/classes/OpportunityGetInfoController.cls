/**
 * @description       : Opportunity 관련 데이터를 가져오는 controller 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 09-05-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
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


}