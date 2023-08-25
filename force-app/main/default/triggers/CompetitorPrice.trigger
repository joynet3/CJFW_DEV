/************************************************************************************
 * File Name   		: CompetitorPrice.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.06
 * Tester	  		: CompetitorPrice_tr_test.cls
 * Description 		: CompetitorPrice Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/
trigger CompetitorPrice on CompetitorPrice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CompetitorPrice_tr().run();
}