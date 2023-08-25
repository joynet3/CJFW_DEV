/************************************************************************************
 * File Name   		: Competitor.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.06
 * Tester	  		: Competitor_tr_test.cls
 * Description 		: Competitor Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/
trigger Competitor on Competitor__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Competitor_tr().run();
}