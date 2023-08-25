/************************************************************************************
 * File Name   		: CJOilPrice.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.06
 * Tester	  		: CJOilPrice_tr_test.cls
 * Description 		: CJOilPrice Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/
trigger CJOilPrice on CJOilPrice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CJOilPrice_tr().run();
}