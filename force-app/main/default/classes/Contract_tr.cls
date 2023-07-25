/************************************************************************************
 * File Name   		: Contract_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.10.12
 * Tester	  		: Contract_tr_test.cls
 * Description 		: Contract_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.10.12      Minje.Kim       Create
*************************************************************************************/

public with sharing class Contract_tr extends TriggerHandler {
    public Contract_tr() {
        listNew = (List<Contract>) trigger.new;
        mapOld = (Map<Id, Contract>) trigger.oldMap;
        listOld = (List<Contract>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<Contract> listNew { get; set; }
    private List<Contract> listOld { get; set; }
    private Map<Id, Contract> mapOld { get; set; }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('Contract', 'ContractTracking', listNew, mapOld);
    }
}