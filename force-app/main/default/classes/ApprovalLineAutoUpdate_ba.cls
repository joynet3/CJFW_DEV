/*
* ==================================================================================
*   File Name   : ApprovalLineAutoUpdate_ba.cls
*   Author      : Minje.Kim
*   Date        : 2023.01.09
*   Tester      : ApprovalLineAutoUpdate_ba_test.cls
*   Description : ApprovalLineAutoUpdate_ba Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2023.01.09    Minje.Kim    Create
* ==================================================================================
*/
public without sharing class ApprovalLineAutoUpdate_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    Map<String, Integer> mapData = new Map<String, Integer>();        

    public ApprovalLineAutoUpdate_ba() {
    }

    /***********************************************************************************************************
    *  Bacth   : Start
    *  내용    : 전자결재 상태 업데이트 대상선정(완료, 회수 제외)
    ************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('ApprovalLineAutoUpdate_ba Start !!');

		string strQuery = '';
		strQuery += '  SELECT  Id, Name, DocId__c, DocURL__c, Opportunity__c , DocStatus__c, totalLineCount__c, approvedCount__c, approvedUserName__c, approvedUserType__c, approvedDate__c, approvedUserCode__c  ';
		strQuery += '  FROM    DecisionProcess__c  ';
		strQuery += '  WHERE   DocStatus__c != \'완료\'  ';
		strQuery += '  AND     DocStatus__c != \'회수(기안취소)\'  ';
    
		return Database.getQueryLocator(strQuery);
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 전자결재 상태 업데이트 진행 ( ApprovalLineUpdateController 컨트롤러의 doUpdateApproval 함수 사용)
    ************************************************************************************************************/
    public void execute(Database.BatchableContext BC, List<DecisionProcess__c> listTarget) {

        if( !listTarget.isEmpty()){
            DecisionProcess__c objDecisionProcess = listTarget[0];
            ApprovalLineUpdateController.doUpdateApproval(objDecisionProcess);
        }
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 내용 없음
    ************************************************************************************************************/
    public void finish(Database.BatchableContext BC) {
        System.debug('ApprovalLineAutoUpdate_ba finish !!');
    }
}