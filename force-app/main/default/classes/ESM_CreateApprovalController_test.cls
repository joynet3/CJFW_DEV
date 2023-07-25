/**
 * Created by kw on 2023-01-30.
 */

@IsTest
private class ESM_CreateApprovalController_test {
    @TestSetup
    static void ESM_CreateApprovalController_testSetUp() {
        try{
            Account objAccount = TestObjectCreator.objExAccount;
            insert objAccount;

            PricebookEntry objPriceBookEntry = TestObjectCreator.objPricebookEntry;
            insert objPriceBookEntry;

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.Name = '영업활동';
            objOpportunity.CloseDate = date.valueOf('2022-01-01');
            objOpportunity.StageName = 'Proposal';
            objOpportunity.BidNoticeSource__c = 'NotNull';
            objOpportunity.LeadSource = 'NaraMarket';
            objOpportunity.BidQualifyRegistCloseDateTime__c = date.valueOf('2022-01-01');
            insert objOpportunity;


            Balance__c objBalance = TestObjectCreator.objSuggestBalance;
            objBalance.Opportunity__c = objOpportunity.Id;
            objBalance.Classification__c = '오픈시산';
            insert objBalance;

            Balance__c objBalance2 = objBalance.clone();
            objBalance2.Id = null;
            objBalance2.Opportunity__c = objOpportunity.Id;
            objBalance2.Classification__c = '제안시산';
            insert objBalance2;

            
            List<BalanceDetail__c> listBalanceDetail = new List<BalanceDetail__c>();
            BalanceDetail__c objBalanceDetail = new BalanceDetail__c();
            objBalanceDetail.Balance__c = objBalance.Id;
            listBalanceDetail.add(objBalanceDetail);
            insert listBalanceDetail;

            List<BalanceDetail__c> listBalanceDetail2 = new List<BalanceDetail__c>();
            BalanceDetail__c objBalanceDetail2 = new BalanceDetail__c();
            objBalanceDetail2.Balance__c = objBalance2.Id;
            listBalanceDetail2.add(objBalanceDetail2);
            insert listBalanceDetail2;

        } catch (Exception e) {
            System.debug('ESM_CreateApprovalController_test line : ' + e.getLineNumber());
            System.debug('ESM_CreateApprovalController_test message : ' + e.getMessage());
            System.debug('ESM_CreateApprovalController_test cause : ' + e.getCause());
        }
    }
    
    @IsTest
    static void ESM_CreateApprovalController_test() {
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<Balance__c> listBalance = new List<Balance__c>([SELECT Id FROM Balance__c LIMIT 2]);
        Balance__c objBalance = listBalance[0];

        ESM_CreateApprovalController esmCAC = new ESM_CreateApprovalController();
        Test.startTest();

        PageReference pageRef = Page.ESM_OpenApproval;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',objOpportunity.Id);

        System.debug(esmCAC.recordId);
        System.debug(esmCAC.objUser);
        System.debug(esmCAC.objOpportunity);
        System.debug(esmCAC.objProposalBalance);
        System.debug(esmCAC.objOpenBalance);
        System.debug(esmCAC.listProposalBalanceDetail_SUM);
        System.debug(esmCAC.listProposalBalanceDetail_IRR);
        System.debug(esmCAC.listProposalBalanceDetail_PL);
        System.debug(esmCAC.listOpenBalanceDetail_SUM);
        System.debug(esmCAC.listOpenBalanceDetail_PL);
        System.debug(esmCAC.listOpenBalanceDetail_IRR);

        Test.stopTest();
    }

    @IsTest
    static void ESM_CreateApprovalController_test2() {
        List<Balance__c> listBalance = new List<Balance__c>([SELECT Id FROM Balance__c LIMIT 2]);
        Balance__c objBalance = listBalance[0];

        ESM_CreateApprovalController esmCAC = new ESM_CreateApprovalController();
        Test.startTest();
        Test.setCurrentPage(Page.ESM_RiskCheck);
        ApexPages.currentPage().getParameters().put('id',objBalance.Id);
        Test.stopTest();
    }
}