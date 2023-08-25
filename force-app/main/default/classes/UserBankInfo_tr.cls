/************************************************************************************
 * File Name   		: UserBankInfo_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.10
 * Tester	  		: UserBankInfo_tr_test.cls
 * Description 		: UserBankInfo_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.10      Minje.Kim       Create
*************************************************************************************/

public without sharing class UserBankInfo_tr extends TriggerHandler {
    public UserBankInfo_tr() {
        listNew = (List<UserBankInfo__c>) trigger.new;
        mapOld = (Map<Id, UserBankInfo__c>) trigger.oldMap;
        listOld = (List<UserBankInfo__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<UserBankInfo__c> listNew { get; set; }
    private List<UserBankInfo__c> listOld { get; set; }
    private Map<Id, UserBankInfo__c> mapOld { get; set; }

    public override void beforeInsert() {
        doInactiveOtherBank();
    }

    public override void beforeupdate() {
        doInactiveOtherBank();
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert, Before Update
    *  내용    : 레코드 생성, 변경시 주유비정산계좌여부(IsOilExpenseAccount__c) 값이 true로 변경될 경우 다른 레코드들의 IsOilExpenseAccount__c 값 false 변경
    ************************************************************************************************************/
    private void doInactiveOtherBank() {
        set<Id> setTargetUserId = new set<Id>();
        for(UserBankInfo__c objUserBankInfo : listNew) {
            if ( listOld == null){
                if ( objUserBankInfo.IsOilExpenseAccount__c ){
                    setTargetUserId.add(objUserBankInfo.User__c);
                }
            }
            else {
                if ( objUserBankInfo.IsOilExpenseAccount__c && !mapOld.get(objUserBankInfo.Id).IsOilExpenseAccount__c ){
                    setTargetUserId.add(objUserBankInfo.User__c);
                }
            }
        }
        System.debug(' setTargetUserId AA::: ' + setTargetUserId);

        if (!setTargetUserId.isEmpty()){
            System.debug(' setTargetUserId BB ::: ' + setTargetUserId);
            List<UserBankInfo__c> listUserBankInfo = [
                SELECT Id, IsOilExpenseAccount__c
                FROM   UserBankInfo__c
                WHERE  User__c IN     : setTargetUserId
                AND    IsOilExpenseAccount__c = true
            ];

            System.debug(' listUserBankInfo CC ::: ' + listUserBankInfo);
            if ( !listUserBankInfo.isEmpty() ){
                for ( UserBankInfo__c objInfo : listUserBankInfo){
                    objInfo.IsOilExpenseAccount__c = false;
                }
                update listUserBankInfo;
                System.debug(' listUserBankInfo2 DD ::: ' + listUserBankInfo);
            }
        }
    }
}