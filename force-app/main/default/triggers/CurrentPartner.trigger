/************************************************************************************
 * File Name   		: CurrentPartner.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.06
 * Tester	  		: CurrentPartner_tr_test.cls
 * Description 		: CurrentPartner Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/
trigger CurrentPartner on CurrentPartner__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CurrentPartner_tr().run();
}