/************************************************************************************
 * File Name   		: FoodPrice.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.10.12 
 * Tester	  		: FoodPrice_tr_test.cls
 * Description 		: FoodPrice Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.10.12      Minje.Kim       Create
*************************************************************************************/
trigger FoodPrice on FoodPrice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new FoodPrice_tr().run();
}