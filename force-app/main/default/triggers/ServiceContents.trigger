/************************************************************************************
 * File Name   		: ServiceContents.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.10.12 
 * Tester	  		: ServiceContents_tr_test.cls
 * Description 		: ServiceContents Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.10.12      Minje.Kim       Create
*************************************************************************************/
trigger ServiceContents on ServiceContents__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ServiceContents_tr().run();
}