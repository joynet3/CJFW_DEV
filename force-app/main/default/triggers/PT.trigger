/************************************************************************************
 * File Name   		: PT.trigger
 * Author	  		  : Minje.Kim
 * Date				    : 2023.01.09 
 * Tester	  		  : PT_tr_test.cls
 * Description 		: PT Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/
trigger PT on PT__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new PT_tr().run();
}