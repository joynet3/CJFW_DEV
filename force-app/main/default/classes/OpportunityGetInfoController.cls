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
     Opportunity clone 시 필수데이터  가져오기 
    *@param  recordId  oppty record id 
    */
    @AuraEnabled(Cacheable=true)
    public static List <Opportunity> getOpportunity( String recordId ) {
        List<Opportunity> opptyList = [ SELECT Name , CloseDate , StageName 
                                   FROM Opportunity
                                   WHERE Id =: recordId ];
        return opptyList;
    } 


}