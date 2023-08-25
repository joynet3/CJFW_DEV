/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class User_tr extends TriggerHandler {
    public User_tr() {
        listNew = (List<User>) trigger.new;
        mapOld = (Map<Id, User>) trigger.oldMap;
        listOld = (List<User>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<User> listNew { get; set; }
    private List<User> listOld { get; set; }
    private Map<Id, User> mapOld { get; set; }

    public override void beforeInsert() {
        doSetRoleName();
    }

    public override void beforeUpdate() {
        doSetRoleName();
    }

    public override void afterUpdate() {
    }

    /***********************************************************************************************************
    *  Trigger  : Before Insert, Before Update
    *  내용     : 레코드 생성, 변경시 UserRole 자동세팅
    ************************************************************************************************************/
    private void doSetRoleName() {
        Map<String, String> mapHeadOfficeNm = CommonUtil.getMapPickListValuetoLabel('User', 'HeadOffice__c');
        Map<String, String> mapSUNm = CommonUtil.getMapPickListValuetoLabel('User', 'SU__c');
        Map<String, String> mapTeamNm = CommonUtil.getMapPickListValuetoLabel('User', 'Team__c');

        List<User> listTarget = new List<User>();

        for(User obj : listNew) {
            if(obj.HeadOffice__c <> null && mapHeadOfficeNm <> null && mapHeadOfficeNm.get(obj.HeadOffice__c) <> null) {
                obj.HeadOfficeLabel__c = mapHeadOfficeNm.get(obj.HeadOffice__c);
            }else {
                obj.HeadOfficeLabel__c = null;
            }

            if(obj.SU__c <> null && mapSUNm <> null && mapSUNm.get(obj.SU__c) <> null) {
                obj.SULabel__c = mapSUNm.get(obj.SU__c);
            }else {
                obj.SULabel__c = null;
            }

            if(obj.Team__c <> null && mapTeamNm <> null && mapTeamNm.get(obj.Team__c) <> null) {
                obj.TeamLabel__c = mapTeamNm.get(obj.Team__c);
            }else {
                obj.TeamLabel__c = null;
            }
        }
    }
}