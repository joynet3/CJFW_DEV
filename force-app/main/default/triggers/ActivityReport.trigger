/************************************************************************************
 * File Name   		: ActivityReport.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.11.01
 * Tester	  		: ActivityReport_tr_test.cls
 * Description 		: ActivityReport Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.11.01      Minje.Kim       Create
*************************************************************************************/
trigger ActivityReport on ActivityReport__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ActivityReport_tr().run();
}