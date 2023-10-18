/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-17-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class SurveyClone_tr extends TriggerHandler {
    public SurveyClone_tr() {
        system.debug('Suvey Trigger Handler START');
        listNew = (List<CJFW_Survey__c>) Trigger.new;
        listOld = (List<CJFW_Survey__c>) Trigger.old;
        mapNew = (Map<Id, CJFW_Survey__c>) Trigger.newMap;
        mapOld = (Map<Id, CJFW_Survey__c>) Trigger.oldMap;
    }

    /*** TriggerHandler ***/
    private List<CJFW_Survey__c> listNew { get; set; }
    private List<CJFW_Survey__c> listOld { get; set; }
    private Map<Id, CJFW_Survey__c> mapNew { get; set; }
    private Map<Id, CJFW_Survey__c> mapOld { get; set; }

    public override void beforeInsert() { 
        doInsertCustId();
    }
    public override void afterInsert() { 
        doCloneInsert();
    }
    private void doInsertCustId(){
        System.debug('doInsertCustId START ');
        for (CJFW_Survey__c newSurvey : listNew) {
            System.debug('isClone:: '+newSurvey.isClone());
            System.debug('getCloneSourceId:: '+newSurvey.getCloneSourceId());
        }
    }
     private void doCloneInsert(){
        system.debug('doCloneInsert  START');
        List<CJFW_Survey__c> newSurveys = listNew;
        Map<Id, CJFW_Survey__c> oldMap = mapOld;
        system.debug('11111 : >> '+ newSurveys);
        system.debug('oldMap : >> '+ oldMap);
        List<CJFW_SurveyQuestion__c > surveyQuestion = new List<CJFW_SurveyQuestion__c >();
        List<CJFW_SurveyOption__c > surveyOption = new List<CJFW_SurveyOption__c >();

        for (CJFW_Survey__c newSurvey : newSurveys) {
            System.debug('isClone:: '+newSurvey.isClone());
            System.debug('getCloneSourceId:: '+newSurvey.getCloneSourceId());
            try {
                CJFW_Survey__c originSurvey = mapOld.get(newSurvey.Id);
                System.debug('originSurvey >>>>>>>> '+ originSurvey);
            }
            catch (Exception ex) {
                System.debug('error:'+ ex.getMessage());
            }
            
        }
       

     }
}