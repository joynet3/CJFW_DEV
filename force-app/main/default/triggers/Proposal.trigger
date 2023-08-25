/************************************************************************************
 * File Name   		: Proposal.trigger
 * Author	  		  : Minje.Kim
 * Date				    : 2023.01.09 
 * Tester	  		  : Proposal_tr_test.cls
 * Description 		: Proposal Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2023.01.09      Minje.Kim       Create
*************************************************************************************/
trigger Proposal on Proposal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Proposal_tr().run();
}