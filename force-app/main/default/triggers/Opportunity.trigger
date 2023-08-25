/************************************************************************************
 * File Name   		: Opportunity.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.08.24
 * Tester	  		: Opportunity_tr_test.cls
 * Description 		: Opportunity Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.08.24      Minje.Kim       Create
*************************************************************************************/
trigger Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Opportunity_tr().run();
}