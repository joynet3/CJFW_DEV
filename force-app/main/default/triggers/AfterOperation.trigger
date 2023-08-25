/************************************************************************************
 * File Name   		: AfterOperation.trigger
 * Author	  		  : Minje.Kim
 * Date				    : 2023.01.09
 * Tester	  		  : AfterOperation_tr_test.cls
 * Description 		: AfterOperation Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/
trigger AfterOperation on AfterOperation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AfterOperation_tr().run();
}