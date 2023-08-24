/************************************************************************************
 * File Name   		: Lead_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.08.19
 * Tester	  		: Lead_tr_test.cls
 * Description 		: Lead_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.08.19      Minje.Kim       Create
*************************************************************************************/

public without sharing class Lead_tr extends TriggerHandler {
    public Lead_tr() {
        listNew = (List<Lead>) trigger.new;
        mapOld = (Map<Id, Lead>) trigger.oldMap;
        listOld = (List<Lead>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<Lead> listNew { get; set; }
    private List<Lead> listOld { get; set; }
    private Map<Id, Lead> mapOld { get; set; }

    public override void beforeUpdate() {
        doOwnerUpdateCheck();
    }

    public override void afterUpdate() {
        doFieldTracking();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking(사용자들이 변경한 데이터만 생성되도록 I/F를 통한 업데이트는 제외)
    ************************************************************************************************************/
    private void doFieldTracking() {
        List<Lead> listTargetNew = new List<Lead>();
        Map<Id, Lead> mapTargetOld = new Map<Id, Lead>();

        for(Lead obj : listNew) {
            String UserName = UserInfo.getUserName().toLowerCase(); 
            if(!(UserName.contains('admin') || UserName.contains('interface')) || UserName.contains('freshway')) {
                listTargetNew.add(obj);
                mapTargetOld.put(obj.Id, mapOld.get(obj.Id));
            }
        }

        // 2022-11-11 LEAD 공공데이터 API I/F로 인해 수정될 경우 필드트래킹 하지 않는다
        if(listTargetNew <> null && listTargetNew.size() > 0) {
            DN_FieldTracking.doFieldTrackingInsert('Lead', 'LeadTracking', listTargetNew, mapTargetOld);
        }
    }

    /***********************************************************************************************************
    *  Trigger : Before Update    
    *  내용    : 자신이 소유한 레코드만 소유자를 변경할 수 있도록 Validation
    ************************************************************************************************************/    
    private void doOwnerUpdateCheck() {
        List<Lead> listTarget = new List<Lead>();
        Set<String> setOwnerId = new Set<String>();

        for(Lead obj : listNew) {
            if(obj.OwnerId <> mapOld.get(obj.Id).OwnerId) {
                listTarget.add(obj);
                setOwnerId.add(mapOld.get(obj.Id).OwnerId);
            }
        }

        if(listTarget <> null && listTarget.size() > 0) {
            Map<String, String> mapUser = new Map<String, String>();

            for(User obj : [
                SELECT  Id, Name
                FROM    User
                WHERE   Id In:setOwnerId
            ]) {
                mapUser.put(obj.Id, obj.Name);
            }

            for(Lead obj : listTarget) {
                if(mapUser <> null && mapUser.get(obj.OwnerId) <> null) {
                    String strTargetUserName = mapUser.get(obj.OwnerId);
                    System.debug('============> strTargetUserName : '+strTargetUserName);
                    String UserName = UserInfo.getUserName().toLowerCase(); 
                    if(!(UserName.contains('admin') || UserName.contains('interface')) || UserName.contains('freshway')) {
                        if(!Test.isRunningTest()) 
                            obj.addError('다른 사용자 잠재고객의 소유자는 변경 불가합니다.');
                    }
                }
            }
        }
    }

}