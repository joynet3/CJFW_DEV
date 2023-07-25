/**
 * Created by kw on 2023-01-29.
 */

@IsTest
private class QuoteFileContainerController_test {
    @TestSetup
    static void QuoteFileContainerController_testSetUp() {
        try{

        } catch (Exception e) {
            System.debug('QuoteFileContainerController_test line : ' + e.getLineNumber());
            System.debug('QuoteFileContainerController_test message : ' + e.getMessage());
            System.debug('QuoteFileContainerController_test cause : ' + e.getCause());
        }
    }

    @IsTest
    static void QuoteFileContainerController_test() {
        Account objAccount = TestObjectCreator.objExAccount;
        insert objAccount;
        Opportunity objOppty = new Opportunity();
        objOppty.Name = 'test Oppty';
        objOppty.AccountId = objAccount.Id;
        objOppty.StageName = 'Needs Analysis';
        objOppty.CloseDate = Date.today() + 1 ;
        insert objOppty;
        Quote objQuote = new Quote();
        objQuote.Name = 'test Quote';
        objQuote.OpportunityId = objOppty.Id;
        insert objQuote;

        List<QuoteFile__c> listQuoteFiles = new List<QuoteFile__c>();
        Test.setCurrentPage(Page.QuoteFileEmailComposerContainer);
        QuoteFile__c objQuoteFile = new QuoteFile__c();
        objQuoteFile.FileName__c = 'test';
        objQuoteFile.Quote__c = objQuote.Id;
        listQuoteFiles.add(objQuoteFile);
        insert listQuoteFiles;

        Test.startTest();
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(listQuoteFiles);
        ssc.setSelected(listQuoteFiles);
        QuoteFileContainerController qfc = new QuoteFileContainerController(ssc);
        Test.stopTest();
    }
}