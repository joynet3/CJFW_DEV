/************************************************************************************
 * File Name   		: UserBankInfo.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.10 
 * Tester	  		: UserBankInfo_tr_test.cls
 * Description 		: UserBankInfo Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.10      Minje.Kim       Create
*************************************************************************************/
trigger UserBankInfo on UserBankInfo__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new UserBankInfo_tr().run();
}