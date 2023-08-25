/************************************************************************************
 * File Name   		: Contract.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.10.12 
 * Tester	  		: Contract_tr_test.cls
 * Description 		: Contract Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.10.12      Minje.Kim       Create
*************************************************************************************/
trigger Contract on Contract (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Contract_tr().run();
}