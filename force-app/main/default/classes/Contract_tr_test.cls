/************************************************************************************
 * File Name   		    : Contract_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2022.11.21
 * Target	  		    : Contract_tr.cls
 * Description 		    : Contract_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class Contract_tr_test {
    @isTest 
    static void itShould() {

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;

        Test.startTest();
        
        Contract objContract = new Contract();
        objContract.AccountId = objAccount.Id;
        objContract.Name = '계약서';
        objContract.Status = 'Draft';
        insert objContract;

        String strContractId = objContract.Id;
        objContract = new Contract();
        objContract.Id = strContractId;
        objContract.Name = '계약서 Edit';
        update objContract;

        Test.stopTest();
    }
}