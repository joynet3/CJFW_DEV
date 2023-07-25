/*
* ==================================================================================
*   File Name   : LineItemExcelPasteController_test.cls
*   Author      : Minje.Kim
*   Date        : 2022.11.19
*   Target      : LineItemExcelPasteController.cls
*   Description : LineItemExcelPasteController
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.19    Minje.Kim    Create
* ==================================================================================
*/
@isTest
private class LineItemExcelPasteController_test {
    @isTest 
    static void itShould() {


        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        PricebookEntry objPriceBookEntry = TestObjectCreator.objPricebookEntry;
        insert objPriceBookEntry;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.Pricebook2Id = objPriceBookEntry.Pricebook2Id;
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;

        Quote objQuote = new Quote();
        objQuote.OpportunityId = objOpportunity.Id;
        objQuote.Pricebook2Id = objPriceBookEntry.Pricebook2Id;
        objQuote.Name = '견적서';
        insert objQuote;

        Test.startTest();
        LineItemExcelPasteController.doInit('Quote');

        List<String> listTargetEntryCode = new List<String>();
        List<Map<String,Object>> listValidTargetData  = new List<Map<String,Object>>();
        Map<String,Object> objValidTargetData = new Map<String,Object>();

        // 정상
        objValidTargetData.put('fm_ProductCode__c','165272');
        objValidTargetData.put('Month__c','1월 상순');
        objValidTargetData.put('LogisticsCenter__c','1000');
        objValidTargetData.put('UnitPrice','2500');
        listValidTargetData.add(objValidTargetData);
        LineItemExcelPasteController.doCheckValid(objPriceBookEntry.Pricebook2Id, objQuote.Id, 'Quote',listValidTargetData, listTargetEntryCode);

        objValidTargetData = new Map<String,Object>();
        objValidTargetData.put('fm_ProductCode__c','165272');
        objValidTargetData.put('Month__c','1월 상순');
        objValidTargetData.put('LogisticsCenter__c','1000');
        objValidTargetData.put('ProfitMargin__c','10');
        listValidTargetData.add(objValidTargetData);
        LineItemExcelPasteController.doCheckValid(objPriceBookEntry.Pricebook2Id, objQuote.Id, 'Quote',listValidTargetData, listTargetEntryCode);

        listTargetEntryCode.add('165272');
        objValidTargetData = new Map<String,Object>();
        objValidTargetData.put('fm_ProductCode__c','165272');
        objValidTargetData.put('Month__c','1월 상순');
        objValidTargetData.put('LogisticsCenter__c','1000');
        objValidTargetData.put('ProfitMargin__c','10');
        listValidTargetData.add(objValidTargetData);
        LineItemExcelPasteController.doCheckValid(objPriceBookEntry.Pricebook2Id, objQuote.Id, 'Quote',listValidTargetData, listTargetEntryCode);


        // 코드길이
        objValidTargetData = new Map<String,Object>();
        objValidTargetData.put('fm_ProductCode__c','1652723');
        objValidTargetData.put('Month__c','EarlyJan');
        objValidTargetData.put('LogisticsCenter__c','1000');
        objValidTargetData.put('UnitPrice','2500');
        listValidTargetData.add(objValidTargetData);

        // 중복입력
        objValidTargetData = new Map<String,Object>();
        objValidTargetData.put('fm_ProductCode__c','165272');
        objValidTargetData.put('Month__c','EarlyTest');
        objValidTargetData.put('LogisticsCenter__c','1000');
        objValidTargetData.put('UnitPrice','2500');
        listValidTargetData.add(objValidTargetData);

        // 센터코드
        objValidTargetData = new Map<String,Object>();
        objValidTargetData.put('fm_ProductCode__c','165273');
        objValidTargetData.put('Month__c','EarlyJan');
        objValidTargetData.put('LogisticsCenter__c','Test');
        objValidTargetData.put('UnitPrice','2500');
        listValidTargetData.add(objValidTargetData);
        
        // 금액
        objValidTargetData = new Map<String,Object>();
        objValidTargetData.put('fm_ProductCode__c','165274');
        objValidTargetData.put('Month__c','EarlyJan');
        objValidTargetData.put('LogisticsCenter__c','1000');
        objValidTargetData.put('UnitPrice','Test');
        listValidTargetData.add(objValidTargetData);

        // 월
        objValidTargetData = new Map<String,Object>();
        objValidTargetData.put('fm_ProductCode__c','165275');
        objValidTargetData.put('Month__c','EarlyTest');
        objValidTargetData.put('LogisticsCenter__c','1000');
        objValidTargetData.put('UnitPrice','2500');
        listValidTargetData.add(objValidTargetData);


        LineItemExcelPasteController.doCheckValid(objPriceBookEntry.Pricebook2Id, objQuote.Id, 'Quote',listValidTargetData, listTargetEntryCode);

        Test.stopTest();
    }
}