/************************************************************************************
 * File Name   		: Contact.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.09.05
 * Tester	  		: Contact_tr_test.cls
 * Description 		: Contact Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.09.05      Minje.Kim       Create
*************************************************************************************/
trigger Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Contact_tr().run();
}