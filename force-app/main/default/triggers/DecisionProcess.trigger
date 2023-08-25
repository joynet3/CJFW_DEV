/************************************************************************************
 * File Name   		: DecisionProcess.trigger
 * Author	  	    : Minje.Kim
 * Date				: 2023.05.26 
 * Tester	  		: DecisionProcess_tr_test.cls
 * Description 		: DecisionProcess Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.05.26      Minje.Kim       Create
*************************************************************************************/
trigger DecisionProcess on DecisionProcess__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new DecisionProcess_tr().run();
}