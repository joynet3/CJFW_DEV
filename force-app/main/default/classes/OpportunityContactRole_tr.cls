/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-31-2023
 * @last modified by  : yeonji.lim@dkbmc.com
 ****************************************************************
 * Modification Log
 * Ver      Date            Author                  Modification
 * 1.0      10-31-2023      yeonji.lim@dkbmc.com    Create
**/
public with sharing class OpportunityContactRole_tr extends TriggerHandler{
    
    /*** TriggerHandler ***/
    private List<OpportunityContactRole> listOld { get; set; }
    private List<OpportunityContactRole> listNew { get; set; }
    
    public OpportunityContactRole_tr() {
        System.debug('OpportunityContactRole Trigger Handler START');
        
        listOld = (List<OpportunityContactRole>) trigger.old;
        listNew = (List<OpportunityContactRole>) trigger.new;
    }

    public override void beforeInsert() {
        updateIsPrimary();
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert
    *  내용    : 특정 영업기회에 연결된 OpportunityContactRole에 레코드가 하나도 없을 시 
                처음으로 생성되는 레코드의 필드(IsPrimary)값을 true로 수정
    ************************************************************************************************************/ 
    private void updateIsPrimary(){
        System.debug('listOld => '+ listOld);
        System.debug('listNew => '+ listNew);

    }
}