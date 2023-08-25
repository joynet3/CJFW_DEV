/************************************************************************************
 * File Name   		: PreSales.trigger
 * Author	  		  : Minje.Kim
 * Date				    : 2023.01.09 
 * Tester	  		  : PreSales_tr_test.cls
 * Description 		: PreSales Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/
trigger PreSales on PreSales__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new PreSales_tr().run();
}