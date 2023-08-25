/************************************************************************************
 * File Name   		: Lead.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.08.19
 * Tester	  		: Lead_tr_test.cls
 * Description 		: Lead Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.08.19      Minje.Kim       Create
*************************************************************************************/
trigger Lead on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Lead_tr().run();
}