/************************************************************************************
 * File Name   		    : UserBankInfo_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.02.10
 * Target	  		    : UserBankInfo_tr.cls
 * Description 		    : UserBankInfo_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.10      Minje.kim       Create
 *************************************************************************************/

@IsTest
public with sharing class UserBankInfo_tr_test {
    @isTest 
    static void itShould() {

        Test.startTest();
        UserBankInfo__c objUserBankInfo = new UserBankInfo__c();
        objUserBankInfo.Name = '씨앗은행';
        objUserBankInfo.User__c = UserInfo.getUserId();
        objUserBankInfo.PV_ZTERM_B1__c = 'K400';
        objUserBankInfo.PV_BANKL__c = '004';
        objUserBankInfo.PV_KOINH__c = '테스트';
        objUserBankInfo.PV_BKONT__c = 'HD';
        objUserBankInfo.PV_BVTYP__c = '1001';
        objUserBankInfo.PV_ACUSE__c = true;
        objUserBankInfo.Seq__c = 1;
        objUserBankInfo.IsOilExpenseAccount__c = false;
        insert objUserBankInfo;
        
        UserBankInfo__c objUserBankInfo2 = new UserBankInfo__c();
        objUserBankInfo2.Name = '풀잎은행';
        objUserBankInfo2.User__c = UserInfo.getUserId();
        objUserBankInfo2.PV_ZTERM_B1__c = 'K400';
        objUserBankInfo2.PV_BANKL__c = '004';
        objUserBankInfo2.PV_KOINH__c = '테스트';
        objUserBankInfo2.PV_BKONT__c = 'HD';
        objUserBankInfo2.PV_BVTYP__c = '1001';
        objUserBankInfo2.PV_ACUSE__c = true;
        objUserBankInfo2.Seq__c = 2;
        objUserBankInfo2.IsOilExpenseAccount__c = true;
        insert objUserBankInfo2;

        String strUserBankInfoId = objUserBankInfo.Id;
        objUserBankInfo = new UserBankInfo__c();
        objUserBankInfo.Id = strUserBankInfoId;
        objUserBankInfo.IsOilExpenseAccount__c = true;
        update objUserBankInfo;
        Test.stopTest();
    }
}