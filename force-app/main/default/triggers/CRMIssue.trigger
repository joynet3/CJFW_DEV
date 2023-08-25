/************************************************************************************
 * File Name   		: CRMIssue.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.06
 * Tester	  		: CRMIssue_tr_test.cls
 * Description 		: CRMIssue Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/
trigger CRMIssue on CRM_Issue__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CRMIssue_tr().run();
}