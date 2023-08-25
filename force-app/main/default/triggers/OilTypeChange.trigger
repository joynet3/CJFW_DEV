/************************************************************************************
 * File Name   		: OilTypeChange.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.06
 * Tester	  		: OilTypeChange_tr_test.cls
 * Description 		: OilTypeChange Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/
trigger OilTypeChange on OilTypeChange__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new OilTypeChange_tr().run();
}