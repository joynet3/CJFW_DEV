/************************************************************************************
 * File Name   		: Quote.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.09.05
 * Tester	  		: Quote_tr_test.cls
 * Description 		: Quote Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.09.05      Minje.Kim       Create
*************************************************************************************/
trigger Quote on Quote (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Quote_tr().run();
}