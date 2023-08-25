/************************************************************************************
 * File Name   		: ITServiceRequest.trigger
 * Author	  		: Minje.Kim
 * Date				: 2023.02.06
 * Tester	  		: ITServiceRequest_tr_test.cls
 * Description 		: ITServiceRequest Trigger Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.02.06      Minje.Kim       Create
*************************************************************************************/
trigger ITServiceRequest on ITServiceRequest__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ITServiceRequest_tr().run();
}