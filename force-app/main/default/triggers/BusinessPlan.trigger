/************************************************************************************
 * File Name   		: BusinessPlan.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.06
 * Tester	  		: BusinessPlan_tr_test.cls
 * Description 		: BusinessPlan Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/
trigger BusinessPlan on BusinessPlan__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new BusinessPlan_tr().run();
}