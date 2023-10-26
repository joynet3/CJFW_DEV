/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
@isTest
public with sharing class CJFW_QuoteSendEmailNewController_Test {
    @IsTest
    static void setData(){

        Account testAccount = new Account(
            Name = 'testAccount',
            Phone = '010-1111-1111',
            Address__c = '서울',
            Website = 'www.naver.com'
        );
        insert testAccount;

        Contact testContact = new Contact(
            LastName = 'testContact',
            Email = 'dy9601@cj.net',
            MobilePhone = '010-2222-2222',
            AccountId = testAccount.Id
        );
        insert testContact;

        User testUser = new User(
            // Id = UserInfo.getUserId(),
            Username = 'QuoteFileCreateTest@test.com',
            LastName = 'TEST',
            Email = 'dy9601@naver.com',
            Alias = 'TEST',
            TimeZoneSidKey = 'Asia/Seoul',
            LocaleSidKey = 'ko',
            EmailEncodingKey = 'UTF-8',
            ProfileId = '00e5i0000022sAxAAI',
            LanguageLocaleKey  = 'ko',
            MobilePhone = '010-1111-1111',
            CurrencyIsoCode = 'KRW'
        );
        insert testUser;

        Quote quote = new Quote(
            Name = 'testQuote',
            OpportunityId = '0060w00000C0e8zAAB',
            EffectiveStartDate__c = date.valueOf('2023-10-30'),
            ExpirationDate = date.valueOf('2023-10-30'),
            // Discount = '0',
            // GrandTotal = '1234',
            OwnerId = testUser.Id
        );
        insert quote;
        
        Quote cloneQuote = new Quote(
            Name = 'testQuote',
            OpportunityId = '0060w00000C0e8zAAB',
            EffectiveStartDate__c = date.valueOf('2023-10-30'),
            ExpirationDate = date.valueOf('2023-10-30'),
            // Discount = '0',
            // GrandTotal = '1234',
            OwnerId = testUser.Id
        );
        insert cloneQuote;

        CJFW_QuoteLineItem__c testItem1 = new CJFW_QuoteLineItem__c();
        testItem1.QuoteId__c = quote.Id;
        testItem1.ProductName__c = 'testItem1';
        testItem1.QuantityUnitOfMeasure__c = 'EA';
        testItem1.ProfitMargin__c = 19;
        testItem1.CountryOfOriginName__c = '국산';
        testItem1.UnitPriceWithVAT__c = 2;
        testItem1.VAT__c = 2;
        testItem1.BasePurchasePrice__c = 8000;
        testItem1.UnitPrice__c = 10;
        testItem1.LogisticsCenter__c = '2600';
        testItem1.Month__c = 'EarlyNov';
        testItem1.ProductCode__c = '139722';
        testItem1.StorageConditionName__c = '상온보관';
        testItem1.SortOrder__c = 1;
        insert testItem1;
        
        CJFW_QuoteLineItem__c testItem2 = new CJFW_QuoteLineItem__c();
        testItem2.QuoteId__c = quote.Id;
        testItem2.ProductName__c = 'testItem2';
        testItem2.QuantityUnitOfMeasure__c = 'EA';
        testItem2.ProfitMargin__c = 19;
        testItem2.CountryOfOriginName__c = '국산';
        testItem2.UnitPriceWithVAT__c = 2;
        testItem2.VAT__c = 2;
        testItem2.BasePurchasePrice__c = 8000;
        testItem2.UnitPrice__c = 10;
        testItem2.LogisticsCenter__c = '2600';
        testItem2.Month__c = 'EarlyNov';
        testItem2.ProductCode__c = '139722';
        testItem2.StorageConditionName__c = '상온보관';
        testItem2.SortOrder__c = 1;
        insert testItem2;
        
        Test.startTest();
        
        CJFW_QuoteSendEmailNewController.getInitData(quote.Id);
        CJFW_QuoteSendEmailNewController.doSearchAccount('test');
        CJFW_QuoteSendEmailNewController.getInitContactList(testAccount.Id);
        CJFW_QuoteSendEmailNewController.doCreateQuote(quote, testAccount);

        List<String> listChunkQuote = new List<String>();
        listChunkQuote.add(quote.Id);

        List<CJFW_QuoteLineItem__c> listChunkLineItem = new List<CJFW_QuoteLineItem__c>();
        listChunkLineItem.add(testItem1);
        listChunkLineItem.add(testItem2);

        CJFW_QuoteSendEmailNewController.doCreateQuoteLineItem(listChunkQuote, listChunkLineItem);
        
        String sendYN = 'Y';
        String fileType = 'PDF';
        String contentHeader = 'TEST Controller';
        String contentBody = '<p>TEST Code send Email</p>';
        Object objCurrentAccount = testAccount;
        Id recordId = cloneQuote.Id;
        String listSelected = 'ProductCode__c,ProductName__c,BasePurchasePrice__c,UnitPriceWithVAT__c,QuantityUnitOfMeasure__c,CountryOfOriginName__c,StorageConditionName__c';

        CJFW_QuoteSendEmailNewController.doCreateFileAndSendEmail(sendYN, fileType, contentHeader, contentBody, objCurrentAccount, recordId, listSelected);

        Test.stopTest();
        
    }
}