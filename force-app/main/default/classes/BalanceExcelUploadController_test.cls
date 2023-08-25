/**
 * Created by 천유정 on 2023-01-30.
 */

@IsTest
private class BalanceExcelUploadController_test {
    @TestSetup
    static void BalanceExcelUploadController_testSetUp() {
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

    }

    @IsTest
    static void BalanceExcelUploadController_test() {
        test.startTest();

        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Balance__c objBalance = TestObjectCreator.objSuggestBalance;
        objBalance.Opportunity__c = objOpportunity.Id;
        insert objBalance;

        List<BalanceDetail__c> listBalanceDetail = new List<BalanceDetail__c>();
        BalanceDetail__c objBalanceDetail = new BalanceDetail__c();
        objBalanceDetail.Balance__c = objBalance.Id;
        listBalanceDetail.add(objBalanceDetail);

        List<BalanceDetail__c> listBalanceDetail2 = new List<BalanceDetail__c>();
        BalanceDetail__c objBalanceDetail2 = new BalanceDetail__c();
        objBalanceDetail2.Balance__c = objBalance.Id;
        listBalanceDetail2.add(objBalanceDetail2);

        BalanceExcelUploadController balClass = new BalanceExcelUploadController();
        System.debug(balClass.recordId);
        System.debug(balClass.selectedTab);
        System.debug(balClass.balanceType);

        PageReference pageRef = Page.BalanceExcelUploadView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', objOpportunity.Id);
        ApexPages.currentPage().getParameters().put('balanceType', '제안시산');
        ApexPages.currentPage().getParameters().put('viewType', 'PL');

        BalanceExcelUploadController controller = new BalanceExcelUploadController();
        System.debug(controller.objBalance);
        System.debug(controller.listBalanceDetail_SUM);
        System.debug(controller.listBalanceDetail_IRR);
        System.debug(controller.listBalanceDetail_PL);


        BalanceExcelUploadController.doGetPrefix();
        BalanceExcelUploadController.doInit(objOpportunity.Id, '제안시산');
        BalanceExcelUploadController.doInit(objOpportunity.Id, '오픈시산');

        BalanceExcelUploadController.doOpenUpload(objOpportunity.Id, '제안시산');
        BalanceExcelUploadController.doOpenUpload(objOpportunity.Id, '오픈시산');

        BalanceExcelUploadController.doSave(objOpportunity.Id, '제안시산', objBalance, listBalanceDetail, listBalanceDetail, listBalanceDetail);
        System.debug(balClass.objProposalBalance);

        Balance__c objBalance2 = TestObjectCreator.objOpenBalance;
        objBalance2.Opportunity__c = objOpportunity.Id;
        insert objBalance2;

        BalanceExcelUploadController.doSave(objOpportunity.Id, '오픈시산', objBalance2, listBalanceDetail2, listBalanceDetail2, listBalanceDetail2);
        System.debug(balClass.objOpenBalance); 

        test.stopTest();
    }

}