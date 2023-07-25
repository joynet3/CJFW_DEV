/**
 * @description       : IF Dummy Object 레코드 삭제
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
/*

IF_DUMMY_DEL_ba b = new IF_DUMMY_DEL_ba('IF_IFRESH_SFDC_INFO_ORDER_0001__c', 'ALL');
Database.executeBatch(b, 1000);

*/

global with sharing class IF_DUMMY_DEL_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    global String strObjectType;
    global String transactionId;

    global IF_DUMMY_DEL_ba(String strObjectType, String transactionId) {
        this.strObjectType = strObjectType;
        this.transactionId = transactionId;
    }
    /***********************************************************************************************************
    *  Bacth   : Start
    *  내용    : IF Dummy Object 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id';                
        strQuery += '   FROM    '+strObjectType;
        if(transactionId != 'ALL') {
            strQuery += '   WHERE   transactionId__c = \'' + transactionId + '\'' ;
            strQuery += '   AND     IsUpdate__c = true' ;
        }

        // 2022-11-20 VOC는 Master 정보(IF_IFRESH_SFDC_VOC_INFO_MASTER__c) 생성 또는 업데이트 되지 않았을경우
        // IsNotVOC__c = false로 되어져 있는 Dummy 데이터만 삭제한다
        /*
        if(strObjectType.contains('IF_IFRESH_SFDC_VOC_INFO_DETAIL__c') || strObjectType.contains('IF_IFRESH_SFDC_VOC_INFO_COMMENT__c')) {            
            strQuery += '   AND     IsNotVOC__c = false' ;
        }
        */


        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 삭제
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        delete scope;
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 내용 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('finish batch');
    }
}