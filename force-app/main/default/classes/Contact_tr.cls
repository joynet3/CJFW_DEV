/************************************************************************************
 * File Name   		: Contact_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.09.05
 * Tester	  		: Contact_tr_test.cls
 * Description 		: Contact_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.09.05      Minje.Kim       Create
*************************************************************************************/

public without sharing class Contact_tr extends TriggerHandler {
    public Contact_tr() {
        listNew = (List<Contact>) trigger.new;
        mapOld = (Map<Id, Contact>) trigger.oldMap;
        listOld = (List<Contact>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<Contact> listNew { get; set; }
    private List<Contact> listOld { get; set; }
    private Map<Id, Contact> mapOld { get; set; }
    private Id recordIdEx {get; set;}

    public override void beforeUpdate() {
        doUpdateCheck(); 
    }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        DN_FieldTracking.doFieldTrackingInsert('Contact', 'ContactTracking', listNew, mapOld);
    }

    /***********************************************************************************************************
    *  Trigger : Before Update
    *  내용    : MDM에 등록된 연락처 정보인 경우 변경 불가능 Validation
    ************************************************************************************************************/
    private void doUpdateCheck() {
        List<Contact> listTarget = new List<Contact>();
        
        for(Contact obj : listNew) {
            if(obj.IsAdminUpdate__c) {
                obj.IsAdminUpdate__c = false;
            }else if (obj.PV_KUNNR__c <> null)  {
                obj.addError('MDM 등록된 담당자정보는 CRM에서 수정할 수 없습니다.');
            }
        }
    }
}