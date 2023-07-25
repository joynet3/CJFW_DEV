/************************************************************************************
 * File Name   		: FieldBriefing.trigger
 * Author	  		  : Minje.Kim
 * Date				    : 2023.01.09 
 * Tester	  		  : FieldBriefing_tr_test.cls
 * Description 		: FieldBriefing Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/
trigger FieldBriefing on FieldBriefing__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new FieldBriefing_tr().run();
}