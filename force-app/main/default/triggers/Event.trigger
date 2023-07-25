/************************************************************************************
 * File Name   		: Event.trigger
 * Author	  		  : Minje.Kim
 * Date				    : 2022.10.25
 * Tester	  		  : Event_tr_test.cls
 * Description 		: Event Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.10.25      Minje.Kim       Create
*************************************************************************************/
trigger Event on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Event_tr().run();
}