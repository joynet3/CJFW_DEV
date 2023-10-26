/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
@isTest
public with sharing class CJFW_QuoteFileCreateNewController_Test {
    @isTest
    static void setData() {
        // Test data setup
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

        CJFW_QuoteLineItem__c testItem = new CJFW_QuoteLineItem__c();
        testItem.QuoteId__c = quote.Id;
        testItem.ProductName__c = 'testItem';
        testItem.QuantityUnitOfMeasure__c = 'EA';
        testItem.ProfitMargin__c = 19;
        testItem.CountryOfOriginName__c = '국산';
        testItem.UnitPriceWithVAT__c = 2;
        testItem.VAT__c = 2;
        testItem.BasePurchasePrice__c = 8000;
        testItem.UnitPrice__c = 10;
        testItem.LogisticsCenter__c = '2600';
        testItem.Month__c = 'EarlyNov';
        testItem.ProductCode__c = '139722';
        testItem.StorageConditionName__c = '상온보관';
        testItem.SortOrder__c = 1;
        insert testItem;

        QuoteFile__c testFile = new QuoteFile__c(
            Quote__c = quote.Id,
            FileVersion__c = 0
        );

        // Actual test
        Test.startTest();

        CJFW_QuoteFileCreateNewController testTmp = new CJFW_QuoteFileCreateNewController();
        
        Id recordId = quote.Id;
        String saveType = 'PDF';
        String listSelectedSave = 'ProductCode__c,ProductName__c,BasePurchasePrice__c,UnitPriceWithVAT__c,QuantityUnitOfMeasure__c,CountryOfOriginName__c,StorageConditionName__c';
        Quote objQuote = quote;
        User objOwner = testUser;
        List<CJFW_QuoteLineItem__c> lineItem = [SELECT   Id, QuoteId__c, ProductName__c
                                                    FROM     CJFW_QuoteLineItem__c
                                                    WHERE    QuoteId__c = :recordId
                                                    ORDER BY SortOrder__c ASC
                                                    LIMIT    10000
                                                    ];
        
        PageReference pdf = new pagereference('/apex/CJFW_QuotePDFCreateNew');
        pdf.getParameters().put('Id', recordId ); 
        pdf.getParameters().put('listSelectedField', listSelectedSave );
        Test.setCurrentPage(pdf);
        
        System.assertEquals(recordId, testTmp.recordId, 'testTmp.recordId 확인');
        System.assertEquals(objQuote.Id, testTmp.objQuote.Id, 'testTmp.objQuote 확인');
        System.assertEquals(objOwner.Id, testTmp.objOwner.Id, 'testTmp.objOwner 확인');
        System.assertEquals(lineItem.size(), testTmp.listQuoteLineItem.size(), 'testTmp.listQuoteLineItem 확인');
        System.debug('testTmp.mapField = '+testTmp.mapField);
        System.debug('testTmp.listSelectedField = '+testTmp.listSelectedField);
        System.debug('testTmp.ExcelColummLength = '+testTmp.ExcelColummLength);

        CJFW_QuoteFileCreateNewController.getInitData();

        CJFW_QuoteFileCreateNewController.doCreateFile(recordId, saveType, listSelectedSave);
        
        saveType = 'Excel';
        CJFW_QuoteFileCreateNewController.doCreateFile(recordId, saveType, listSelectedSave);

        Test.stopTest();

        // Asserts
    }
}