/************************************************************************************
 * File Name   		: Quote_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.09.05
 * Tester	  		: Quote_tr_test.cls
 * Description 		: Quote_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.09.05      Minje.Kim       Create
*************************************************************************************/

public without sharing class Quote_tr extends TriggerHandler {
    public Quote_tr() {
        listNew = (List<Quote>) trigger.new;
        mapOld = (Map<Id, Quote>) trigger.oldMap;
        listOld = (List<Quote>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<Quote> listNew { get; set; }
    private List<Quote> listOld { get; set; }
    private Map<Id, Quote> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('Quote', 'QuoteTracking', listNew, mapOld);
    }
}