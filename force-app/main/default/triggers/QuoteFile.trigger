/************************************************************************************
 * File Name   		: QuoteFile.trigger
 * Author	  		: Minje.Kim
 * Date				: 2022.09.05
 * Tester	  		: QuoteFile_tr_test.cls
 * Description 		: QuoteFile Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.09.05      Minje.Kim       Create
*************************************************************************************/
trigger QuoteFile on QuoteFile__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new QuoteFile_tr().run();
}