/************************************************************************************
 * File Name   		: Negotiation.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.08.19
 * Tester	  		: Negotiation_tr_test.cls
 * Description 		: Negotiation Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.02      Minje.Kim       Create
*************************************************************************************/
trigger Negotiation on Negotiation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Negotiation_tr().run();
}