/************************************************************************************
 * File Name   		: SampleFood.trigger
 * Author	  		  : Minje.Kim
 * Date				    : 2023.01.09 
 * Tester	  		  : SampleFood_tr_test.cls
 * Description 		: SampleFood Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/
trigger SampleFood on SampleFood__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new SampleFood_tr().run();
}