/************************************************************************************
 * File Name   		: QuoteLineItem_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.08.24
 * Tester	  		: QuoteLineItem_tr_test.cls
 * Description 		: QuoteLineItem_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.08.24      Minje.Kim       Create
*************************************************************************************/

public with sharing class QuoteLineItem_tr extends TriggerHandler {
    public QuoteLineItem_tr() {
        listNew = (List<QuoteLineItem>) trigger.new;
        mapOld = (Map<Id, QuoteLineItem>) trigger.oldMap;
        listOld = (List<QuoteLineItem>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<QuoteLineItem> listNew { get; set; }
    private List<QuoteLineItem> listOld { get; set; }
    private Map<Id, QuoteLineItem> mapOld { get; set; }
    
    public override void beforeInsert() {
        doSetOpportunityLineItemSync();
    }

    /***********************************************************************************************************
    *  Trigger  : Before Insert
    *  내용     : 레코드 생성시 Opportunity Line Item Custom Field 싱크
    ************************************************************************************************************/
    private void doSetOpportunityLineItemSync() {        
        List<QuoteLineItem> listTarget = new List<QuoteLineItem>();        
        Set<String> setOpptyLineItemId = new Set<String>();
        
        for(QuoteLineItem obj : listNew) {
            if(obj.OpportunityLineItemId <> null) {
                listTarget.add(obj);
                setOpptyLineItemId.add(obj.OpportunityLineItemId);
            }            
        }
        
        if(!setOpptyLineItemId.isEmpty()) {
            Map<Id, OpportunityLineItem> mapTargetLineItem = new Map<Id, OpportunityLineItem>();
            
            for(OpportunityLineItem objOLI : [
                SELECT	Id
                		,VAT__c
                		,UnitPriceWithVAT__c
                		,LogisticsCenter__c
                		,Month__c
                		,BasePurchasePrice__c
                		,ProfitMargin__c
                FROM	OpportunityLineItem
                WHERE 	Id In:setOpptyLineItemId
                
            ]) {
                mapTargetLineItem.put(objOLI.Id, objOLI);
            }
            
            for(QuoteLineItem obj : listTarget) {
                if(mapTargetLineItem <> null && mapTargetLineItem.get(obj.OpportunityLineItemId) <> null) {
                    OpportunityLineItem objTarget = mapTargetLineItem.get(obj.OpportunityLineItemId);
                    
                    obj.VAT__c = objTarget.VAT__c;
                    obj.UnitPriceWithVAT__c = objTarget.UnitPriceWithVAT__c;
                    obj.LogisticsCenter__c = objTarget.LogisticsCenter__c;
                    obj.Month__c = objTarget.Month__c;
                    obj.BasePurchasePrice__c = objTarget.BasePurchasePrice__c;
                    obj.ProfitMargin__c = objTarget.ProfitMargin__c;
                  
                }
            }
        }
    }
}