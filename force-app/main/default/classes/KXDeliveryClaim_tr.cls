/************************************************************************************
 * File Name   		: KXDeliveryClaim_tr.cls
 * Author	  		: Jeongin.Jo
 * Date				: 2023.07.18
 * Tester	  		: KXDeliveryClaim_tr_test.cls
 * Description 		: KXDeliveryClaim_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.07.18      Jeongin.Jo       Create
*************************************************************************************/
public without sharing class KXDeliveryClaim_tr extends TriggerHandler {
    public KXDeliveryClaim_tr() {
        //listNew = (List<KXDeliveryClaim__c>) trigger.new;
        //mapOld = (Map<Id, KXDeliveryClaim__c>) trigger.oldMap;
        //listOld = (List<KXDeliveryClaim__c>) trigger.old;
        String testStr = '';
    }

    /*** TriggerHandler ***/
    /*private List<KXDeliveryClaim__c> listNew { get; set; }
    private List<KXDeliveryClaim__c> listOld { get; set; }
    private Map<Id, KXDeliveryClaim__c> mapOld { get; set; }

    public override void beforeInsert() {
        doSetName();
    }*/

    /***********************************************************************************************************
    *  Trigger : Before Insert
    *  내용    : 레코드 생성시 Name 자동세팅
    ************************************************************************************************************/
    /*private void doSetName() {
        List<String> listClaimType = new List<String>();
        List<String> listOrderDate = new List<String>();
        List<String> listAccountCode = new List<String>();
        List<String> listAccountName = new List<String>();

        for(KXDeliveryClaim__c objKXDC : listNew) {
            listAccountName.add(objKXDC.Account__c);
        }
     
        Map<Id, Account> mapDeliveryAccount = new Map<Id, Account>([
            SELECT Id, Name
            FROM Account
            WHERE Id IN :listAccountName
        ]);

        for(KXDeliveryClaim__c objKXDC : listNew) {
            objKXDC.Name = '['+objKXDC.ClaimType__c+'] ['+mapDeliveryAccount.get(objKXDC.Account__c).Name+' | '+objKXDC.fm_AccountCode__c+'] '+objKXDC.Name;
        }
    }*/
}