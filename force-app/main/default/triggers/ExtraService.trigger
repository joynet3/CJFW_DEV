/************************************************************************************
 * File Name   		: ExtraService.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.10.12 
 * Tester	  		: ExtraService_tr_test.cls
 * Description 		: ExtraService Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.10.12      Minje.Kim       Create
*************************************************************************************/
trigger ExtraService on ExtraService__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ExtraService_tr().run();
}